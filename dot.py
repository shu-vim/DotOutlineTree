#!/usr/bin/python

import re

importPattern = re.compile(u'"include\(\s*(.+)\s*\)')

infile = file(u'./dot_base.vim', 'r')
lines = infile.readlines()
infile.close()

for i in range(0, len(lines)):
    mo = importPattern.match(lines[i])
    if mo is not None:
        modfile = file(u'./' + mo.groups(0)[0])
        modlines = modfile.readlines()
        modfile.close()
        lines[i:i + 1] = modlines

outfile = file(u'./dot.vim', 'w')
outfile.writelines(lines)
outfile.close()

# vim: set et ff=unix fenc= sts=4 sw=4 ts=4 : 
