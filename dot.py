#!/usr/bin/python

import re

importPattern = re.compile(ur'"include\(\s*(.+)\s*\)')

infile = file(u'./dot_base.vim')
lines = infile.readlines()
infile.close()

resultLines = []

for i in range(0, len(lines)):
    mo = importPattern.match(lines[i])
    if mo:
        modfile = file(u'./' + mo.groups(0)[0])
        modlines = modfile.readlines()
        modfile.close()
        resultLines.extend(modlines)
    else:
        resultLines.append(lines[i])

outfile = file(u'./dot.vim', 'wb')
outfile.writelines(resultLines)
outfile.close()

# vim: set et ff=unix fenc= sts=4 sw=4 ts=4 : 
