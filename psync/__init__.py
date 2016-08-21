#!/usr/bin/env python

# Copyright (c) 2016, Robert Escriva
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
#     * Redistributions of source code must retain the above copyright notice,
#       this list of conditions and the following disclaimer.
#     * Redistributions in binary form must reproduce the above copyright notice,
#       this list of conditions and the following disclaimer in the documentation
#       and/or other materials provided with the distribution.
#     * Neither the name of this project nor the names of its contributors may
#       be used to endorse or promote products derived from this software
#       without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
# ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
# (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
# LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
# ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
# Because this code links libgpod, you may have further obligations under the
# LGPL if you choose to distribute it.  That's on you to figure out.

import argparse
import fcntl
import hashlib
import json
import os
import os.path
import subprocess
import sys
import tempfile

import psync.gpod
from psync.gpod import Track

MUSIC_EXTS = ('.flac', '.mp3', '.m4a', '.aac', '.ogg')

def sha256sum(path):
    f = open(path, 'rb')
    sha256 = hashlib.sha256()
    d = f.read(65536)
    while d:
        sha256.update(d)
        d = f.read(65536)
    return sha256.hexdigest()

def metadata(path):
    raw = subprocess.check_output(('ffmpeg', '-i', path, '-nostdin',
        '-loglevel', 'error', '-y', '-f', 'ffmetadata', '/dev/stdout'),
        stderr=subprocess.STDOUT)
    raw = raw.decode('utf8')
    md = {}
    for line in raw.split('\n'):
        if '=' not in line: continue
        field, value = line.split('=', 1)
        field = field.strip().lower()
        md[field] = value
    return md

class Repository:

    def __init__(self, path, create=False):
        self.path = path
        if not os.path.exists(self.METADATA):
            if not create:
                raise RuntimeError("repository does not exist and create was not specified")
            os.makedirs(self.METADATA, 0o700)
        self.lock = open(self.LOCK, 'w')
        try:
            fcntl.flock(self.lock, fcntl.LOCK_EX|fcntl.LOCK_NB)
        except IOError as e:
            if e.errno != errno.EAGAIN:
                raise e
            raise RuntimeError("repository already in use")
        self.inodes2hashes = {}
        self.hashes2metadata = {}
        self.paths2hashes = {}
        self._load_inodes()
        self._load_hashes()
        for k, v in self.hashes2metadata.items():
            self.paths2hashes[v['path']] = k

    @property
    def METADATA(self):
        return os.path.join(self.path, '.psync')

    @property
    def LOCK(self):
        return os.path.join(self.METADATA, 'LOCK')

    @property
    def INODES2HASHES(self):
        return os.path.join(self.METADATA, 'INODES2HASHES')

    @property
    def HASHES2METADATA(self):
        return os.path.join(self.METADATA, 'HASHES2METADATA')

    def index(self, subpath='', limit=None):
        root = os.path.join(self.path, subpath)
        root_dev = os.stat(root).st_dev
        i = 0
        for root, dirs, files in os.walk(root):
            for f in files:
                path = os.path.join(root, f)
                ext = os.path.splitext(path)[1].lower()
                if ext not in MUSIC_EXTS:
                    continue
                st = os.stat(path)
                if st.st_dev != root_dev:
                    raise RuntimeError("repository cannot cross disk boundaries")
                mtime, sha = self.inodes2hashes.get(st.st_ino, (0, ''))
                if mtime >= st.st_mtime: continue
                if limit is not None and i > limit:
                    return
                i += 1
                s = sha256sum(path)
                self.inodes2hashes[st.st_ino] = (st.st_mtime, s)
                if s not in self.hashes2metadata:
                    m = metadata(path)
                    track_no = None
                    try:
                        track_no = int(m.get('track', None))
                    except:
                        pass
                    relpath = os.path.relpath(path, self.path)
                    self.hashes2metadata[s] = {'path': relpath,
                                               'artist': m.get('artist', ''),
                                               'title': m.get('title', ''),
                                               'album': m.get('album', ''),
                                               'track': track_no}
                    self.paths2hashes[relpath] = s

    def list_tracks(self, subpath=''):
        self.index(subpath=subpath)
        root = os.path.join(self.path, subpath)
        for root, dirs, files in os.walk(os.path.join(self.path, subpath)):
            for f in sorted(files):
                path = os.path.relpath(os.path.join(root, f), self.path)
                if path not in self.paths2hashes:
                    continue
                sha256 = self.paths2hashes[path]
                md = self.hashes2metadata[sha256]
                yield path, Track(artist=md['artist'],
                                  title=md['title'],
                                  album=md['album'],
                                  track=md['track'],
                                  uid=sha256[:24],
                                  ipod_id=None)

    def sync(self):
        # inodes
        out = tempfile.NamedTemporaryFile(mode='w+', dir=self.METADATA,
                prefix='psync-inodes-', delete=False)
        for k, v in sorted(self.inodes2hashes.items()):
            out.write('{0} {1} {2}\n'.format(k, v[0], v[1]))
        out.flush()
        os.rename(out.name, self.INODES2HASHES)
        # hashes
        out = tempfile.NamedTemporaryFile(mode='w+', dir=self.METADATA,
                prefix='psync-hashes-', delete=False)
        for k, v in sorted(self.hashes2metadata.items()):
            out.write('{0} {1}\n'.format(k, json.dumps(v)))
        out.flush()
        os.rename(out.name, self.HASHES2METADATA)

    def _load_inodes(self):
        if not os.path.exists(self.INODES2HASHES):
            return
        for line in open(self.INODES2HASHES):
            ino, mtime, sha = line.strip().split()
            ino = int(ino)
            mtime = float(mtime)
            self.inodes2hashes[ino] = (mtime, sha)

    def _load_hashes(self):
        if not os.path.exists(self.HASHES2METADATA):
            return
        for line in open(self.HASHES2METADATA):
            sha, md = line.strip().split(' ', 1)
            self.hashes2metadata[sha] = json.loads(md)

def find_repo_path(path):
    p = os.path.abspath(os.path.realpath(path))
    while True:
        if os.path.exists(os.path.join(p, '.psync')):
            break
        if p == '/':
            raise RuntimeError('repository not found')
        p = os.path.dirname(p)
    return p, os.path.relpath(path, p)

def main_init_music(path):
    repo = Repository(path, create=True)
    repo.sync()

def main_index_music(path):
    path, subpath = find_repo_path(path)
    repo = Repository(path)
    repo.index(subpath)
    repo.sync()

def main_copy_to_ipod(music, ipod_path):
    repo_path, repo_subpath = find_repo_path(music)
    repo = Repository(repo_path)
    ipod = psync.gpod.iTunesDB(ipod_path)
    seen = set()
    for t in ipod.list_tracks():
        seen.add(t.uid)
    for p, t in repo.list_tracks(repo_subpath):
        if t.uid in seen:
            continue
        tmpwav = tempfile.NamedTemporaryFile(dir=repo.METADATA, prefix='psync-track-', suffix='.wav')
        tmpm4a = tempfile.NamedTemporaryFile(dir=repo.METADATA, prefix='psync-track-', suffix='.m4a')
        args = ('mplayer', '-nocorrect-pts', '-benchmark', '-vo', 'null', '-vc', 'null',
                '-ao', 'pcm:waveheader:fast:file=%s' % tmpwav.name, os.path.join(repo_path, p))
        proc = subprocess.Popen(args, stdout=open('/dev/null'), stderr=open('/dev/null'))
        proc.communicate()
        if proc.returncode != 0:
            raise RuntimeError("encoding failed")
        args = ('neroAacEnc', '-q', '0.7', '-if', tmpwav.name, '-of', tmpm4a.name)
        proc = subprocess.Popen(args, stdout=open('/dev/null'), stderr=open('/dev/null'))
        proc.communicate()
        if proc.returncode != 0:
            raise RuntimeError("encoding failed")
        ipod.add_song(t, tmpm4a.name)
    ipod.sync()
    del ipod

def main_remove_from_ipod(music, ipod_path):
    repo_path, repo_subpath = find_repo_path(music)
    repo = Repository(repo_path)
    ipod = psync.gpod.iTunesDB(ipod_path)
    seen = set()
    for t in ipod.list_tracks():
        seen.add(t.uid)
    for p, t in repo.list_tracks(repo_subpath):
        if t.uid not in seen:
            continue
        ipod.remove_track(uid=t.uid)
    ipod.sync()
    del ipod

def main_remove_all_tracks(ipod_path):
    ipod = psync.gpod.iTunesDB(ipod_path)
    for t in set(ipod.list_tracks()):
        ipod.remove_track(ipod_id=t.ipod_id)
    ipod.sync()
    del ipod

def main_remove_non_psync_tracks(ipod_path):
    ipod = psync.gpod.iTunesDB(ipod_path)
    for t in set(ipod.list_tracks()):
        if t.uid is None:
            ipod.remove_track(ipod_id=t.ipod_id)
    ipod.sync()
    del ipod

###############################################################################

def main():
    parser = argparse.ArgumentParser(prog='psync')
    subparsers = parser.add_subparsers(help='actions', dest='action')
    # init-music
    p = subparsers.add_parser('init-music')
    p.add_argument('music', type=str, help='top level music directory')
    # index-music
    p = subparsers.add_parser('index-music')
    p.add_argument('music', type=str, help='music directory')
    # copy-to-ipod
    p = subparsers.add_parser('copy-to-ipod')
    p.add_argument('ipod', type=str, help='iPod mount point')
    p.add_argument('music', type=str, help='music directory')
    # remove-from-ipod
    p = subparsers.add_parser('remove-from-ipod')
    p.add_argument('ipod', type=str, help='iPod mount point')
    p.add_argument('music', type=str, help='music directory')
    args = parser.parse_args()
    if args.action == 'init-music':
        sys.exit(main_init_music(args.music))
    if args.action == 'index-music':
        sys.exit(main_index_music(args.music))
    if args.action == 'copy-to-ipod':
        sys.exit(main_copy_to_ipod(args.music, args.ipod))
    if args.action == 'remove-from-ipod':
        sys.exit(main_remove_from_ipod(args.music, args.ipod))
    parser.print_help()
    sys.exit(1)

if __name__ == '__main__':
    main()
