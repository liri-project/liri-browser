#!/usr/bin/env python3
# this is a modified version of get-libs.py which is part of checkbox.
# See http://bazaar.launchpad.net/~checkbox-dev/checkbox/trunk/view/head:/checkbox-touch/get-libs
#
# copyright 2015 by Tim Süberkrüb
# copyright 2014 canonical ltd.
# written by:
#   maciej kisielewski <maciej.kisielewski@canonical.com>
#
# checkbox is free software: you can redistribute it and/or modify
# it under the terms of the gnu general public license version 3,
# as published by the free software foundation.
#
# checkbox is distributed in the hope that it will be useful,
# but without any warranty; without even the implied warranty of
# merchantability or fitness for a particular purpose.  see the
# gnu general public license for more details.
#
# you should have received a copy of the gnu general public license
# along with checkbox.  if not, see <http://www.gnu.org/licenses/>.
"""
Download and extract .deb packages necessary to run checkbox-touch
Extraction is done to specific directories as required by click package

For typical development iteration, after hacking something in plainbox,
run ./get-libs --plainbox-only
"""

import apt
import apt_pkg
import argparse
import collections
import os
import shutil
import subprocess
import sys
import tarfile
import tempfile
import urllib.request
import zipfile

# arch_list contains list of architectures for which the packages should be
# downloaded
arch_list = ['i386', 'amd64', 'armhf']
# multiarch_list contains full architecture name as used in the directoriesroot.app.
# in contents of click package
multiarch_list = ["i386-linux-gnu", "x86_64-linux-gnu", "arm-linux-gnueabihf"]

def copy_tree(src, dest, preserve_symlinks=False):
    """
    copy files from src to dest using rsync
    """
    links_option = "-l" if preserve_symlinks else "-L"
    parent_dir = os.path.split(os.path.abspath(dest))[0]
    # adding trailing slash if it's not already there
    src = os.path.join(src, '')
    if not os.path.exists(parent_dir):
        os.makedirs(parent_dir)
    subprocess.check_call(["rsync", "-a", links_option, src, dest])


def prepare_uris():
    """
    prepare_uris function builds caches for architectures defined in arch_list
    and builds a dictionary of URLs indexed by (package_name, arch) tuple.
    It returns that dictionary.
    """

    packages = ['qml-module-qtquick-controls']

# uris will serve as a database of uris from which to download packages
    uris = dict()
    Source = collections.namedtuple('Source', ['uri', 'repositories'])
    sources = {
        'armhf': [Source('http://ports.ubuntu.com/ubuntu-ports',
                         'main restricted universe'),
                  Source('http://ppa.launchpad.net/checkbox-dev/ppa/ubuntu',
                         'main')],
        'i386': [Source('http://archive.ubuntu.com/ubuntu',
                        'main restricted universe'),
                 Source('http://ppa.launchpad.net/checkbox-dev/ppa/ubuntu',
                         'main')],
        'amd64': [Source('http://archive.ubuntu.com/ubuntu',
                         'main restricted universe'),
                  Source('http://ppa.launchpad.net/checkbox-dev/ppa/ubuntu',
                         'main')],
    }
    for arch in arch_list:
        print('Getting information about packages for {0} arch.'.format(arch))
        # prepare sources.list for apt
        with tempfile.TemporaryDirectory() as tmp:
            new_etc_apt = os.path.join(tmp, 'etc', 'apt')
            os.makedirs(new_etc_apt)
            # copy over trusted.gpg
            shutil.copyfile('/etc/apt/trusted.gpg',
                            os.path.join(new_etc_apt, 'trusted.gpg'))
            # copy over additional keyrings
            if os.path.exists('/etc/apt/trusted.gpg.d'):
                shutil.copytree('/etc/apt/trusted.gpg.d',
                                os.path.join(new_etc_apt, 'trusted.gpg.d'))
            sources_list = open(os.path.join(new_etc_apt, 'sources.list'), "w")
            for source in sources[arch]:
                sources_list.write(
                    "deb [arch={arch}] {uri} wily {repositories}\n"
                    .format(arch=arch, uri=source.uri,
                            repositories=source.repositories))
            sources_list.close()
            apt_pkg.config["Apt::Architecture"] = arch
            cache = apt.Cache(rootdir=tmp)
            cache.update()
            cache.open(None)
            for pkg in packages:
                if pkg not in cache or len(cache[pkg].versions) < 1:
                    # package not found
                    raise Exception('Package {0} not found for arch {1}'
                                    .format(pkg, arch))
                # use first uri available
                uris[pkg, arch] = cache[pkg].versions[0].uri
    # return filled dictionary
    return uris


def get_package_from_url_and_extract(url, target_dir):
    filename = os.path.join(target_dir, url.split('/')[-1])
    print('retrieving {0}'.format(url))
    urllib.request.urlretrieve(url, filename)
    subprocess.check_call(["dpkg", "-x", filename, target_dir])


def main():
    uris = prepare_uris()
    # libs_urls contains list of .deb packages that will be downloaded and
    # extracted. After extraction contents of ./usr/lib are copied to ./lib
    libs_urls = [uris['qml-module-qtquick-controls', arch] for arch in arch_list]
    for lib in libs_urls:
        with tempfile.TemporaryDirectory() as tmp:
            get_package_from_url_and_extract(lib, tmp)
            # TODO: remove unwanted files from the extracted tree (e.g. *.h)
            copy_tree(
                os.path.join(tmp, 'usr', 'lib'), 'lib',
                preserve_symlinks=1)
    # python3_libs_urls contains list of .deb packages that will be downloaded
    # and extracted. After extraction contents of
    # ./usr/lib/python3/dist-packages are copied to ./lib/py.
    python3_libs = []

    python3_libs_urls = [
        uris[lib, arch] for arch in arch_list for lib in python3_libs]
    for pylib in python3_libs_urls:
        with tempfile.TemporaryDirectory() as tmp:
            get_package_from_url_and_extract(pylib, tmp)
            copy_tree(
                os.path.join(tmp, 'usr', 'lib', 'python3',
                             'dist-packages'),
                os.path.join('lib', 'py'),
                preserve_symlinks=1)

    # Remove the python3.4 directory
    # currently it only holds a few config-directories with symlinks
    # and those are not used by anything from this location
    if os.path.exists('lib/python3.4'):
        shutil.rmtree('lib/python3.4')


if __name__ == "__main__":
    main()
