#!/usr/bin/python
'''Make emacs startup work like I think it should

If emacs is not running, start it
If it is, run emacsclient to connect to it

Jun 2011 gb
'''

import sys
import os
import os.path as osp
import socket

EMACS = '/usr/bin/emacs23'
EMACSCLIENT = '/usr/bin/emacsclient'

socket_name = '/tmp/emacs%d/server' % os.geteuid()
if osp.exists(socket_name):
    s = socket.socket(socket.AF_UNIX)
    try:
        s.connect(socket_name)
    except socket.error:
        pass
    else:
        args = sys.argv[1:]
        if not os.isatty(sys.stdin.fileno()):
            args.insert(0, '-n')
        os.execl(EMACSCLIENT, EMACSCLIENT, *args)

# we only get here is all else fails        
os.execl(EMACS, EMACS, '-f', 'server-start', *sys.argv[1:])

