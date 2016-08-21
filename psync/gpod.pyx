# Copyright (c) 2016, Robert Escriva
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
# ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
# (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES
# LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
# ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
# Because this code links libgpod, you may have further obligations under the
# LGPL if you choose to distribute it.  That's on you to figure out.

cdef extern from "stdlib.h":
    ctypedef int time_t
    cdef void* malloc(size_t size)
    cdef void free(void* ptr)

cdef extern from "string.h":
    void* memmove(void* dest, const void* src, size_t n)

cdef extern from "stdint.h":
    ctypedef signed char int8_t
    ctypedef short int int16_t
    ctypedef int int32_t
    ctypedef long int int64_t
    ctypedef unsigned char uint8_t
    ctypedef unsigned short int uint16_t
    ctypedef unsigned int uint32_t
    ctypedef unsigned long int uint64_t

cdef extern from "glib.h":
    ctypedef char gchar
    ctypedef int gint
    ctypedef gint gboolean
    ctypedef void* gpointer
    ctypedef char gint8
    ctypedef unsigned char guint8
    ctypedef short gint16
    ctypedef unsigned short guint16
    ctypedef long gint32
    ctypedef unsigned long guint32
    ctypedef long long gint64
    ctypedef unsigned long long guint64
    cdef struct _GError:
        gchar       *message
    ctypedef _GError GError
    cdef struct _GList:
        gpointer data
        _GList *next
        _GList *prev
    ctypedef _GList GList

cdef extern from "gpod/itdb.h":
    ctypedef void (* ItdbUserDataDestroyFunc) (gpointer userdata)
    ctypedef gpointer (* ItdbUserDataDuplicateFunc) (gpointer userdata)
    cdef struct _Itdb_Device:
        gchar *mountpoint
    ctypedef _Itdb_Device Itdb_Device

    cdef struct _Itdb_iTunesDB:
        GList *tracks
        GList *playlists
        gchar *filename
        Itdb_Device *device
        guint32 version
        guint64 id
        gint32 reserved_int1
        gint32 reserved_int2
        gpointer reserved1
        gpointer reserved2
        guint64 usertype
        gpointer userdata
        ItdbUserDataDuplicateFunc userdata_duplicate
        ItdbUserDataDestroyFunc userdata_destroy
    ctypedef _Itdb_iTunesDB Itdb_iTunesDB

    cdef struct _Itdb_Artwork 
    cdef struct _Itdb_Chapterdata 
    ctypedef _Itdb_Chapterdata Itdb_Chapterdata
    cdef struct _Itdb_Track_Private 
    ctypedef _Itdb_Track_Private Itdb_Track_Private
    cdef struct _Itdb_Track:
        Itdb_iTunesDB *itdb
        gchar   *title
        gchar   *ipod_path
        gchar   *album
        gchar   *artist
        gchar   *genre
        gchar   *filetype
        gchar   *comment
        gchar   *category
        gchar   *composer
        gchar   *grouping
        gchar   *description
        gchar   *podcasturl
        gchar   *podcastrss
        Itdb_Chapterdata *chapterdata
        gchar   *subtitle
        gchar   *tvshow
        gchar   *tvepisode
        gchar   *tvnetwork
        gchar   *albumartist
        gchar   *keywords
        gchar   *sort_artist
        gchar   *sort_title
        gchar   *sort_album
        gchar   *sort_albumartist
        gchar   *sort_composer
        gchar   *sort_tvshow
        guint32 id
        guint32  size
        gint32  tracklen
        gint32  cd_nr
        gint32  cds
        gint32  track_nr
        gint32  tracks
        gint32  bitrate
        guint16 samplerate
        guint16 samplerate_low
        gint32  year
        gint32  volume
        guint32 soundcheck
        time_t  time_added
        time_t  time_modified
        time_t  time_played
        guint32 bookmark_time
        guint32 rating
        guint32 playcount
        guint32 playcount2
        guint32 recent_playcount
        gboolean transferred
        gint16  BPM
        guint8  app_rating
        guint8  type1
        guint8  type2
        guint8  compilation
        guint32 starttime
        guint32 stoptime
        guint8  checked
        guint64 dbid
        guint32 drm_userid
        guint32 visible
        guint32 filetype_marker
        guint16 artwork_count
        guint32 artwork_size
        float samplerate2
        guint16 unk126
        guint32 unk132
        time_t  time_released
        guint16 unk144
        guint16 explicit_flag
        guint32 unk148
        guint32 unk152
        guint32 skipcount
        guint32 recent_skipcount
        guint32 last_skipped
        guint8 has_artwork
        guint8 skip_when_shuffling
        guint8 remember_playback_position
        guint8 flag4
        guint64 dbid2
        guint8 lyrics_flag
        guint8 movie_flag
        guint8 mark_unplayed
        guint8 unk179
        guint32 unk180
        guint32 pregap
        guint64 samplecount
        guint32 unk196
        guint32 postgap
        guint32 unk204
        guint32 mediatype
        guint32 season_nr
        guint32 episode_nr
        guint32 unk220
        guint32 unk224
        guint32 unk228, unk232, unk236, unk240, unk244
        guint32 gapless_data
        guint32 unk252
        guint16 gapless_track_flag
        guint16 gapless_album_flag
        guint16 obsolete
        _Itdb_Artwork *artwork
        guint32 mhii_link
        gint32 reserved_int1
        gint32 reserved_int2
        gint32 reserved_int3
        gint32 reserved_int4
        gint32 reserved_int5
        gint32 reserved_int6
        Itdb_Track_Private *priv
        gpointer reserved2
        gpointer reserved3
        gpointer reserved4
        gpointer reserved5
        gpointer reserved6
        guint64 usertype
        gpointer userdata
        ItdbUserDataDuplicateFunc userdata_duplicate
        ItdbUserDataDestroyFunc userdata_destroy
    ctypedef _Itdb_Track Itdb_Track

    cdef struct _Itdb_Playlist:
        Itdb_iTunesDB *itdb
        gchar *name
        guint8 type
        guint8 flag1
        guint8 flag2
        guint8 flag3
        gint  num
        GList *members
        gboolean is_spl
        time_t timestamp
        guint64 id
        guint32 sortorder
        guint32 podcastflag
        gpointer reserved100
        gpointer reserved101
        gint32 reserved_int1
        gint32 reserved_int2
        gpointer reserved1
        gpointer reserved2
        guint64 usertype
        gpointer userdata
        ItdbUserDataDuplicateFunc userdata_duplicate
        ItdbUserDataDestroyFunc userdata_destroy
    ctypedef _Itdb_Playlist Itdb_Playlist

    Itdb_iTunesDB *itdb_new()
    Itdb_iTunesDB *itdb_parse(const gchar *mp, GError **error)
    void itdb_free(Itdb_iTunesDB *itdb)
    int itdb_write(Itdb_iTunesDB *itdb, GError **error)
    const gchar *itdb_get_mountpoint(Itdb_iTunesDB *itdb)
    gchar *itdb_filename_on_ipod (Itdb_Track *track);
    gchar *itdb_get_music_dir(const gchar *mountpoint)
    void itdb_filename_fs2ipod(gchar *filename);
    gint itdb_musicdirs_number(Itdb_iTunesDB *itdb);

    Itdb_Track *itdb_track_new()
    void itdb_track_free(Itdb_Track *track)
    void itdb_track_add(Itdb_iTunesDB *itdb, Itdb_Track *track, gint32 pos)
    void itdb_track_remove(Itdb_Track *track);
    gboolean itdb_cp(const gchar *from_file, const gchar *to_file, GError **error);
    Itdb_Track *itdb_cp_finalize(Itdb_Track *track,
			         const gchar *mountpoint,
			         const gchar *dest_filename,
			         GError **error);

    void itdb_playlist_add(Itdb_iTunesDB *itdb, Itdb_Playlist *pl, gint32 pos)
    void itdb_playlist_remove(Itdb_Playlist *pl)
    gboolean itdb_playlist_is_mpl(Itdb_Playlist *pl)
    gboolean itdb_playlist_is_podcasts(Itdb_Playlist *pl)
    Itdb_Playlist *itdb_playlist_mpl(Itdb_iTunesDB *itdb)
    Itdb_Playlist *itdb_playlist_podcasts(Itdb_iTunesDB *itdb);
    Itdb_Playlist *itdb_playlist_by_name(Itdb_iTunesDB *itdb, gchar *name)

    void itdb_playlist_add_track(Itdb_Playlist *pl, Itdb_Track *track, gint32 pos)
    void itdb_playlist_remove_track(Itdb_Playlist *pl, Itdb_Track *track);

import collections
import os
import re
import subprocess
import time

import psync

cdef MEDIATYPES = ((0x00000001, "Audio"),
                   (0x00000004, "Podcast"),
                   (0x00000008, "Audiobook"))

Track = collections.namedtuple('Track', ('artist', 'title', 'album', 'track', 'uid', 'ipod_id'))

cdef gchar* malloc_utf8(str s):
    cdef bytes b = s.encode('utf8')
    cdef gchar* ptr = <char*>malloc(len(b) + 1)
    if not ptr:
        raise MemoryError()
    memmove(ptr, <char*>b, len(b))
    ptr[len(b)] = 0
    return ptr

cdef str utf8_decode(gchar* s):
    if not s: return ""
    return s.decode('utf8')

cdef track_re = re.compile(':([0-9a-zA-Z]{24}).[a-z0-9]+$')
cdef path2uid(Itdb_Track* track):
    m = track_re.search(track.ipod_path.decode('utf8'))
    if m is not None:
        m = m.group(1)
    return m

cdef ipod2track(Itdb_Track* track):
    return Track(artist=utf8_decode(track.artist),
                 title=utf8_decode(track.title),
                 album=utf8_decode(track.album),
                 track=track.track_nr,
                 uid=path2uid(track), ipod_id=track.id)

cdef Itdb_Track* track2ipod(track, mediatype):
    cdef Itdb_Track* t = itdb_track_new()
    if not track:
        raise RuntimeError("could not allocate new track")
    t.mediatype = dict([(v,k) for k,v in MEDIATYPES]).get(mediatype, 0x01)
    t.artist = malloc_utf8(track.artist)
    t.title = malloc_utf8(track.title)
    t.album = malloc_utf8(track.album)
    nr = 0
    try:
        if isinstance(track.track, int) or isinstance(track.track, long):
            nr = track.track
        else:
            nr = int(track.track, 10)
    except Exception as e:
        pass
    t.track_nr = nr
    return t

cdef playlist2dict(Itdb_Playlist* pl):
    return {'name': pl.name,
            'is_master': itdb_playlist_is_mpl(pl) != 0,
            'is_podcasts': itdb_playlist_is_podcasts(pl) != 0}

cdef class Playlist(object):
    cdef iTunesDB db

cdef class iTunesDB(object):
    cdef bytes path
    cdef Itdb_iTunesDB* db
    cdef str music_dir
    cdef int mod

    def __cinit__(self, str path):
        cdef gchar* tmp = NULL
        cdef GError* err = NULL
        self.path = path.encode('utf8')
        self.db = itdb_parse(self.path, &err)
        if not self.db:
            raise RuntimeError("could not open iTunes database")
        tmp = itdb_get_music_dir(itdb_get_mountpoint(self.db))
        self.music_dir = tmp.decode('utf8')
        self.mod = itdb_musicdirs_number(self.db) or 50
        free(tmp)

    def __dealloc__(self):
        if self.db:
            itdb_free(self.db)

    def list_tracks(self):
        cdef GList* tracks = self.db.tracks
        cdef Itdb_Track* track
        ret = []
        while tracks:
            track = <Itdb_Track*>tracks.data
            t = ipod2track(track)
            ret.append(t)
            tracks = tracks.next
        return ret

    cdef str ipod_filename(self, uid, ext):
        cdef gchar* tmp = NULL
        num = int(uid, 16) % self.mod
        return os.path.join(self.music_dir, 'F%02d' % num, uid + ext)

    cdef ffprobe(self, path, fmt):
        args = ('ffprobe', '-i', path, '-show_entries', 'format=' + fmt,
                '-v', 'quiet', '-of', 'csv=p=0')
        out = subprocess.check_output(args).strip()
        return out.strip()

    cdef samplerate(self, path):
        args = ('ffprobe', '-i', path, '-show_streams', '-v', 'quiet')
        out = subprocess.check_output(args).strip()
        out = out.decode('utf8', 'ignore')
        out = [x for x in out.split('\n') if x.startswith('sample_rate=')]
        if not out:
            return 44100
        out = out[0][len('sample_rate='):]
        return int(out)

    cdef add_track(self, track, str mediatype, str path, Itdb_Playlist* pl):
        cdef GError* err = NULL
        cdef Itdb_Track* t = NULL
        free_it = True
        try:
            t = track2ipod(track, mediatype)
            if not t:
                raise RuntimeError("could not add track to iTunes database")
            t.itdb = self.db
            t.ipod_path = NULL
            t.transferred = 0
            ts = float(self.ffprobe(path, 'duration'))
            t.filetype = malloc_utf8('MPEG audio file')
            t.tracklen = int(ts * 1000)
            t.bitrate = int(self.ffprobe(path, 'bit_rate')) / 1000
            t.samplerate = self.samplerate(path)
            t.samplerate2 = t.samplerate
            t.time_added = int(time.time())
            t.time_modified = t.time_added
            mpl = itdb_playlist_mpl(self.db)
            if not mpl:
                raise RuntimeError("could not add track to iTunes database")
            ext = os.path.splitext(path)[1].lower()
            dest = self.ipod_filename(track.uid, ext).encode('utf8')
            if not os.path.exists(os.path.dirname(dest)):
                os.makedirs(os.path.dirname(dest))
            if not itdb_cp(path.encode('utf8'), dest, &err):
                raise RuntimeError("could not add track to iTunes database: %s" % err.message)
            if not itdb_cp_finalize(t, NULL, dest, &err):
                raise RuntimeError("could not add track to iTunes database: %s" % err.message)
            itdb_track_add(self.db, t, -1)
            free_it = False
            itdb_playlist_add_track(mpl, t, -1)
            if mpl != pl and pl:
                itdb_playlist_add_track(pl, t, -1)
        finally:
            if t and free_it:
                itdb_track_free(t)

    def add_song(self, track, str path):
        return self.add_track(track, 'Audio', path, NULL)

    def add_podcast(self, track, str path):
        return self.add_track(track, 'Podcast', path, NULL)

    def remove_track(self, uid=None, ipod_id=None):
        cdef GList* tracks = self.db.tracks
        cdef Itdb_Track* track = NULL
        cdef Itdb_Track* tmp
        mpl = itdb_playlist_mpl(self.db)
        if not mpl:
            raise RuntimeError("could not remove track from iTunes database")
        while tracks:
            tmp = <Itdb_Track*>tracks.data
            if ipod_id and tmp.id == ipod_id:
                track = tmp
                break
            if uid and path2uid(tmp) == uid:
                track = tmp
                break
            tracks = tracks.next
        if not track:
            return False
        cdef GList* playlists = self.db.playlists
        cdef Itdb_Playlist* pl
        while playlists:
            pl = <Itdb_Playlist*>playlists.data
            itdb_playlist_remove_track(pl, track)
            playlists = playlists.next
        itdb_playlist_remove_track(mpl, track)
        itdb_track_remove(track)
        return True

    def list_playlists(self):
        cdef GList* playlists = self.db.playlists
        cdef Itdb_Playlist* pl
        ret = []
        while playlists:
            pl = <Itdb_Playlist*>playlists.data
            ret.append(playlist2dict(pl))
            playlists = playlists.next
        return ret

    def sync(self):
        cdef GError* err = NULL
        if itdb_write(self.db, &err) == 0:
            raise RuntimeError("could not sync iTunes database")
        itdb_free(self.db)
        self.db = itdb_parse(self.path, &err)
        if not self.db:
            raise RuntimeError("could not sync iTunes database")
