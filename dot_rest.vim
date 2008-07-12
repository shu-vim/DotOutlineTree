"
"reStructuredText plugin for DOT
"===============================
"
"Summary 
"-------
"ThisIs:
"~~~~~~~
"   A plugin for DOT.
"   With this plugin, DOT can make outline tree from reStrucredText.
"
"Usage:
"~~~~~~
"   Add a new line to the target buffer.
"       > outline: <rest>
"   or
"       > vim: set hoge : <rest>

if index(g:DOT_types, 'rest') == -1
    call add(g:DOT_types, 'rest')
endif

function! g:DOT_restInit()
    let b:DOT_restSectionMarks = []
endfunction

" section 1.            <- detected
" ===============       <- not detected
function! g:DOT_restDetectHeading(targetLine, targetLineIndex, entireLines)
    let detected = 0

    if a:targetLineIndex == len(a:entireLines) - 1 | return 0 | endif

    let nextLine = s:DOT__restStripCommenterCharacters(a:entireLines[a:targetLineIndex + 1])

    if nextLine =~ '^[-=`:.''"~^_*+#]\{2,\}$' && a:targetLine !~ '^[-=`:.''"~^_*+#]\{2,\}$'
        let detected = 1

        " add if no entry
        let mark = nextLine[0]
        "echoe mark . ' ' . nextLine
        if index(b:DOT_restSectionMarks, mark) == -1
            call add(b:DOT_restSectionMarks, mark)
        endif
    endif

    return detected
endfunction


function! g:DOT_restExtractTitle(targetLine, targetLineIndex, entireLines)
    return a:targetLine
endfunction


function! g:DOT_restExtractLevel(targetLine, targetLineIndex, entireLines)
    let mark = s:DOT__restStripCommenterCharacters(a:entireLines[a:targetLineIndex + 1])[0]
    "echom l:mark . (index(b:DOT_restSectionMarks, l:mark) + 1)
    return index(b:DOT_restSectionMarks, mark) + 1
endfunction


function! g:DOT_restSetHeading(title, level, lineNum)
    let mark = ':'
    if a:level <= len(b:DOT_restSectionMarks) | let mark = b:DOT_restSectionMarks[a:level - 1] | endif

    call setline(a:lineNum, [a:title, repeat(mark, 20)])
endfunction


function! g:DOT_restDecorateHeading(title, level)
    let mark = ':'
    if a:level <= len(b:DOT_restSectionMarks) | let mark = b:DOT_restSectionMarks[a:level - 1] | endif

    return {'lines':[a:title, repeat(mark, 20), '', ''], 'cursorPos': [2, 0]}
endfunction


function! s:DOT__restStripCommenterCharacters(line)
    let commentpattern = '\v' . substitute(escape(&commentstring, '.*\()[]{}?'), '%s', '(.*)', '')
    return substitute(a:line, commentpattern, '\1', '')
    "echoe commentpattern
    "echoe line . ' => ' . nextLine
endfunction
"
" vim: set et ff=unix fenc=utf-8 sts=4 sw=4 ts=4 : <rest>
