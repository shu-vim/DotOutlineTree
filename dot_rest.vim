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
    "let b:DOT_restSectionMarks = []
    call setbufvar(a:buffNum, 'DOT_restSectionMarks', [])
    call setbufvar(a:buffNum, 'DOT_restSectionStyles', []) "0:underlined, 1:also overlined
endfunction

" hogehoge              <- not detected because next line is for section 1.
" ===============       <- detected if exists
" section 1.            <- detected
" ===============       <- not detected
function! g:DOT_restDetectHeading(buffNum, targetLine, targetLineIndex, entireLines)
    let headingLineCount = 0

    if a:targetLineIndex == len(a:entireLines) - 1 
        return 0 
    endif

    let overlineIdx = -1
    let overline = ''
    let titleIdx = -1
    let title = ''
    let underlineIdx = -1
    let underline = ''

    " test if targetLine is an overline
    let overline = s:DOT__restStripCommenterCharacters(a:buffNum, a:targetLine)
    if overline =~ s:DOT_REST_REGEXP
        "echom '  overline: ' . overline
        let headingLineCount = 2

        let overlineIdx = a:targetLineIndex

        " boudary check (needs 2 more lines)
        "echom '  boundary ... tgtLineIdx: ' . a:targetLineIndex . ', entire: ' . len(a:entireLines)
        if a:targetLineIndex + 2 > len(a:entireLines) - 1 
            return 0 
        endif

        " title
        let titleIdx = a:targetLineIndex + 1
        let title = substitute(s:DOT__restStripCommenterCharacters(a:buffNum, a:entireLines[titleIdx]), '\V\^\%(\s\*\)\(\.\*\)\$', '\1', '')
        "echom '  title: "' . title . '"'
        " title check
        if title == '' || title =~ s:DOT_REST_REGEXP
            return 0
        endif

        " underline
        let underlineIdx = a:targetLineIndex + 2
        let underline = s:DOT__restStripCommenterCharacters(a:buffNum, a:entireLines[underlineIdx])
        "echom '  underline: ' . underline
        " underline check
        if underline != overline
            return 0
        endif
    else
        let headingLineCount = 1

        let overlineIdx = -1
        let overline = ''

        " boudary check (needs 1 more line)
        "echom '  boundary ... tgtLineIdx: ' . a:targetLineIndex . ', entire: ' . len(a:entireLines)
        if a:targetLineIndex + 1 > len(a:entireLines) - 1 
            return 0 
        endif

        " title
        let titleIdx = a:targetLineIndex
        let title = substitute(s:DOT__restStripCommenterCharacters(a:buffNum, a:targetLine), '\V\^\%(\s\*\)\(\.\*\)\$', '\1', '')
        "echom '  title: "' . title . '"'
        " title check
        if title == '' || title =~ s:DOT_REST_REGEXP
            return 0
        endif

        " underline
        let underlineIdx = a:targetLineIndex + 1
        let underline = s:DOT__restStripCommenterCharacters(a:buffNum, a:entireLines[underlineIdx])
        "echom '  underline: ' . underline
        " underline check
        if underline !~ s:DOT_REST_REGEXP
            return 0
        endif

        " check if the target line is just before an overline
        if a:targetLineIndex + 3 <= len(a:entireLines) - 1
            let nextSectionUnderline = s:DOT__restStripCommenterCharacters(a:buffNum, a:entireLines[a:targetLineIndex + 3])
            if nextSectionUnderline == underline
                " if this level's style is overlined and underlined, this line
                " should be skipped.
                let level = g:DOT_restExtractLevel(a:buffNum, underline, underlineIdx, a:entireLines)
                " encounterd for the first time  or  overlined and underlined style
                if level == 0 || s:DOT__restGetSectionStyle(a:buffNum, level) != 0
                    return 0
                endif
            endif
        endif
    endif

    " add if no entry
    let mark = underline[0]
    "echoe mark . ' ' . underline
    if index(getbufvar(a:buffNum, 'DOT_restSectionMarks'), mark) == -1
        call add(getbufvar(a:buffNum, 'DOT_restSectionMarks'), mark)
        " overlined?
        call add(getbufvar(a:buffNum, 'DOT_restSectionStyles'), (overlineIdx != -1) )
    endif

    return headingLineCount


    "let nextLine = s:DOT__restStripCommenterCharacters(a:buffNum, a:entireLines[a:targetLineIndex + 1])

    "" ignores an overline of the next section heading
    "if a:targetLineIndex + 3 < len(a:entireLines)
    "    let nextLine3 = s:DOT__restStripCommenterCharacters(a:buffNum, a:entireLines[a:targetLineIndex + 3])
    "    if nextLine[0] == nextLine3[0] | return 0 | endif
    "endif

    "" ignore transitions and literal blocks and empty comments
    "if len(a:targetLine) == 0 | return 0 | endif

    "if nextLine =~ s:DOT_REST_REGEXP && a:targetLine !~ s:DOT_REST_REGEXP
    "    let headingLineCount = 1

    "    " add if no entry
    "    let mark = nextLine[0]
    "    "echoe mark . ' ' . nextLine
    "    if index(getbufvar(a:buffNum, 'DOT_restSectionMarks'), mark) == -1
    "        call add(getbufvar(a:buffNum, 'DOT_restSectionMarks'), mark)
    "        " overlined?
    "        let sectionStyle = 0
    "        if a:targetLineIndex > 0 && a:entireLines[a:targetLineIndex - 1] =~ s:DOT_REST_REGEXP
    "            let sectionStyle = 1
    "        endif
    "        call add(getbufvar(a:buffNum, 'DOT_restSectionStyles'), sectionStyle)
    "    endif
    "endif

    "return headingLineCount
endfunction


function! g:DOT_restExtractTitle(buffNum, targetLine, targetLineIndex, entireLines)
    " strip leading spaces
    let title = s:DOT__restStripCommenterCharacters(a:buffNum, a:targetLine)
    if title =~ s:DOT_REST_REGEXP
        let title = a:entireLines[a:targetLineIndex + 1]
    endif
    return substitute(title, '\V\^\%(\s\*\)\(\.\*\)\$', '\1', '')
endfunction


function! g:DOT_restExtractLevel(buffNum, targetLine, targetLineIndex, entireLines)
    let test = s:DOT__restStripCommenterCharacters(a:buffNum, a:targetLine)
    if test =~ s:DOT_REST_REGEXP
        let undeline = test
    else
        let undeline = s:DOT__restStripCommenterCharacters(a:buffNum, a:entireLines[a:targetLineIndex + 1])
    endif
    let mark = undeline[0]

    return index(getbufvar(a:buffNum, 'DOT_restSectionMarks'), mark) + 1
endfunction


function! g:DOT_restSetHeading(buffNum, title, level, lineNum)
    let mark = s:DOT__restGetSectionMark(a:buffNum, a:level)
    let style = s:DOT__restGetSectionStyle(a:buffNum, a:level)

    let lines = []

    if style == 1
        let lines = [s:DOT__repeat(mark, a:title), a:title, s:DOT__repeat(mark, a:title)]
    else
        let lines = [a:title, s:DOT__repeat(mark, a:title)]
    endif

    call setline(a:lineNum, lines)
endfunction


function! g:DOT_restDecorateHeading(buffNum, title, level)
    let mark = s:DOT__restGetSectionMark(a:buffNum, a:level)
    let style = s:DOT__restGetSectionStyle(a:buffNum, a:level)

    let lines = []
    let cursorPos = [0, 0]
    let deletedLineCount = 2

    if style == 1
        let lines = [s:DOT__repeat(mark, a:title), a:title, s:DOT__repeat(mark, a:title)]
        let cursorPos = [4, 0]
    else
        let lines = [a:title, s:DOT__repeat(mark, a:title)]
    let cursorPos = [3, 0]
    endif

    return {'marginTop': [], 'lines': lines, 'marginBottom': ['', ''], 'cursorPos': cursorPos}
endfunction


function! s:DOT__repeat(mark, s)
    if exists('*strwidth')
        return repeat(a:mark, strwidth(a:s))
    else
        return repeat(a:mark, len(a:s))
    endif
endfunction


function! s:DOT__restGetSectionMark(buffNum, level)
    let marks = getbufvar(a:buffNum, 'DOT_restSectionMarks')
    if a:level <= len(marks) 
        let mark = marks[a:level - 1] 
    else
        let mark = ':'
    endif

    return mark
endfunction


function! s:DOT__restGetSectionStyle(buffNum, level)
    let styles = getbufvar(a:buffNum, 'DOT_restSectionStyles')
    if a:level <= len(styles) 
        let style = styles[a:level - 1] 
    else
        let style = styles[len(styles) - 1] 
    endif

    return style
endfunction


function! s:DOT__restStripCommenterCharacters(buffNum, line)
    let commentpattern = '\v' . substitute(escape(getbufvar(a:buffNum, '&commentstring'), '.*\()[]{}?'), '%s', '(.*)', '')
    return substitute(a:line, commentpattern, '\1', '')
    "echoe commentpattern
    "echoe line . ' => ' . nextLine
endfunction
"
" vim: set et ff=unix sts=4 sw=4 ts=4 : <rest>
