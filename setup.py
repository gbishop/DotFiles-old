#!/usr/bin/python
import os
import os.path as osp
import sys
import subprocess as sp

inHome = 'bashrc emacs gitconfig gitignore profile'.split()

inApps = [ 'gnome-terminal.desktop',
           'nautilus-home.desktop',
           'ubuntu-software-center.desktop',
           ]

home = os.getenv('HOME')

def newLink(s, d):
    s = osp.abspath(s)
    if not d.startswith('/'):
        d = osp.join(os.getenv('HOME'), d)
    if osp.exists(d):
        os.remove(d)
    dir = osp.dirname(d)
    if not osp.exists(dir):
        os.makedirs(dir)
    os.symlink(s, d)
    print d, '-->', s
    

for fname in inHome:
    newLink(fname, '.' + fname)

apps = osp.join('.local', 'share', 'applications')

for fname in inApps:
    d = osp.join(apps, fname)
    newLink(fname, d)

def GitIt(repo, url):
    if not osp.exists(repo):
        sp.check_call(['git', 'clone', url])
    else:
        sp.check_call(['git', 'pull', 'origin'], cwd=repo)

# Git Nautilus Icons
GitIt('GitNautilusIcons', 'git://github.com/gbishop/GitNautilusIcons.git')
s = 'GitNautilusIcons/git-icon-emblems.py'
d = osp.join(home, '.nautilus', 'python-extensions', 'git-icon-emblems.py')
newLink(s, d)

newLink('GitNautilusIcons/hicolor',
        osp.join('.icons', 'hicolor'))

# Nautilus Scripts
ns = '.gnome2/nautilus-scripts'
newLink('scripts/GitCommit', osp.join(ns, 'Git Commit'))
newLink('scripts/OpenTerminalHere', osp.join(ns, 'Open Terminal Here'))
newLink('scripts/OpenWith', osp.join(ns, 'localhost'))
newLink('scripts/OpenWith', osp.join(ns, 'local.dev'))




