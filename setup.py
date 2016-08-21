#!/usr/bin/python

import subprocess

from setuptools import setup, find_packages, Extension

deps = ('libgpod-1.0', 'glib-2.0')
includes = subprocess.check_output(('pkg-config', '--cflags-only-I') + deps).decode('utf8')
includes = [x.strip() for x in includes.split('-I') if x.strip()]
libraries = subprocess.check_output(('pkg-config', '--libs-only-l') + deps).decode('utf8')
libraries = [x.strip() for x in libraries.split('-l') if x.strip()]

print(includes)
print(libraries)

gpod = Extension('psync.gpod',
                 sources=['psync/gpod.c'],
                 include_dirs=includes,
                 libraries=libraries
                 )

setup(name = 'psync',
      version = '0.0.1',
      description = 'A simple iPod sync tool',
      url = 'http://rescrv.net/',
      author = 'Robert Escriva',
      author_email = 'robert@rescrv.net',
      license = 'BSD',
      keywords = 'iPod',
      packages = find_packages(),
      ext_modules=[gpod],
      entry_points = {
          'console_scripts': ['psync = psync:main']
          }
      )
