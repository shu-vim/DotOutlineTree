"
"reStructuredText plugin for DOT
"===============================
"
"ThisIs:
"-------
"   A plugin for DOT.
"   With this plugin, DOT can make outline tree from reStrucredText.
"
"Usage:
"-------
"   Add a new line to the target buffer.
"       > outline: <rest>
"   or
"       > vim: set hoge : <rest>

if index(g:DOT_types, 'rest') == -1
    call add(g:DOT_types, 'rest')
endif

let s:DOT_REST_REGEXP = '\m^[-=`:.''"~^_*+#]\{2,\}$'

function! g:DOT_restInit(buffNum)
    call setbufvar(a:buffNum, 'DOT_restSectionMarks', [])
    "let b:DOT_restSectionMarks = []
endfunction

" section 1.            <- detected
" ===============       <- not detected
function! g:DOT_restDetectHeading(buffNum, targetLine, targetLineIndex, entireLines)
    let detected = 0

    if a:targetLineIndex == len(a:entireLines) - 1 | return 0 | endif

    let nextLine = s:DOT__restStripCommenterCharacters(a:buffNum, a:entireLines[a:targetLineIndex + 1])

    " ignore an over line of a TITLE
    if a:targetLineIndex + 3 < len(a:entireLines)
        let nextLine3 = s:DOT__restStripCommenterCharacters(a:buffNum, a:entireLines[a:targetLineIndex + 3])
        if nextLine[0] == nextLine3[0] | return 0 | endif
    endif

    " ignore transitions and literal blocks and empty comments
    if len(a:targetLine) == 0 | return 0 | endif

    if nextLine =~ s:DOT_REST_REGEXP && a:targetLine !~ s:DOT_REST_REGEXP
        let detected = 1

        " add if no entry
        let mark = nextLine[0]
        "echoe mark . ' ' . nextLine
        if index(getbufvar(a:buffNum, 'DOT_restSectionMarks'), mark) == -1
            call add(getbufvar(a:buffNum, 'DOT_restSectionMarks'), mark)
        endif
    endif

    return detected
endfunction


function! g:DOT_restExtractTitle(buffNum, targetLine, targetLineIndex, entireLines)
    " strip leading spaces
    return substitute(a:targetLine, '\V\^\%(\s\*\)\(\.\*\)\$', '\1', '')
endfunction


function! g:DOT_restExtractLevel(buffNum, targetLine, targetLineIndex, entireLines)
    let mark = s:DOT__restStripCommenterCharacters(a:buffNum, a:entireLines[a:targetLineIndex + 1])[0]
    "echom l:mark . (index(getbufvar(a:buffNum, 'DOT_restSectionMarks'), l:mark) + 1) . join(getbufvar(a:buffNum, 'DOT_restSectionMarks'))
    return index(getbufvar(a:buffNum, 'DOT_restSectionMarks'), mark) + 1
endfunction


function! g:DOT_restSetHeading(buffNum, title, level, lineNum)
    let mark = ':'
    if a:level <= len(getbufvar(a:buffNum, 'DOT_restSectionMarks')) | let mark = getbufvar(a:buffNum, 'DOT_restSectionMarks')[a:level - 1] | endif

    call setline(a:lineNum, [a:title, repeat(mark, 20)])
endfunction


function! g:DOT_restDecorateHeading(buffNum, title, level)
    let mark = ':'
    if a:level <= len(getbufvar(a:buffNum, 'DOT_restSectionMarks')) | let mark = getbufvar(a:buffNum, 'DOT_restSectionMarks')[a:level - 1] | endif

    return {'lines':[a:title, repeat(mark, 20), '', ''], 'cursorPos': [2, 0]}
endfunction


function! s:DOT__restStripCommenterCharacters(buffNum, line)
    let commentpattern = '\v' . substitute(escape(getbufvar(a:buffNum, '&commentstring'), '.*\()[]{}?'), '%s', '(.*)', '')
    return substitute(a:line, commentpattern, '\1', '')
    "echoe commentpattern
    "echoe line . ' => ' . nextLine
endfunction
"
" vim: set et ff=unix sts=4 sw=4 ts=4 : <rest>
