"
"TaskPaper plugin for DOT:
"
"ThisIs:
"   A plugin for DOT.
"   With this plugin, DOT can make outline tree from TaskPaper.
"
"Usage:
"   Add a new line to the target buffer.
"       > outline: <taskpaper>
"   or
"       > vim: set hoge : <taskpaper>

if index(g:DOT_types, 'taskpaper') == -1
    call add(g:DOT_types, 'taskpaper')
endif

let s:DOT_TASKPAPER_REGEXP = '\m^\(.\+\):\s*$'

function! g:DOT_taskpaperDecorateHeading(buffNum, title, level)
    return {'lines':[a:title . ':', '', '', ''], 'cursorPos': [1, 0]}
endfunction


function! g:DOT_taskpaperInit(buffNum)
endfunction


function! g:DOT_taskpaperDetectHeading(buffNum, targetLine, targetLineIndex, entireLines)
    return (a:targetLine =~ s:DOT_TASKPAPER_REGEXP)
endfunction


function! g:DOT_taskpaperExtractTitle(buffNum, targetLine, targetLineIndex, entireLines)
    return substitute(a:targetLine, s:DOT_TASKPAPER_REGEXP, '\1', '')
endfunction


function! g:DOT_taskpaperExtractLevel(buffNum, targetLine, targetLineIndex, entireLines)
    return 1
endfunction


function! g:DOT_taskpaperSetHeading(buffNum, title, level, lineNum)
    call setline(a:lineNum, a:title . ':')
endfunction
"
" vim: set et ff=unix fenc=utf-8 sts=4 sw=4 ts=4 : <taskpaper>
