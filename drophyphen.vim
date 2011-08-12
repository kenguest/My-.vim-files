" -*- vim -*-
" Vim global plugin for correcting typing mistakes
" Last Change: 2002 Mar 5 
" Maintainer: Ken Guest 
function! <SID>Drophyphen() range
  execute(a:firstline) . ", " . a:lastline . 's/-/_/g '
endfunction

function! <SID>Rtrim() range

  let mark = "normal " . (line(".") ) . "G" 
  execute(a:firstline) . ", " . a:lastline . 's/ *$//g '
  execute mark
endfunction

function! <SID>Ltrim() range
  execute(a:firstline) . ", " . a:lastline . 's/^ *//g '
endfunction

command! -nargs=* -range Dh <line1>, <line2> call <SID>Drophyphen(<f-args>)
command! -nargs=* -range Ltrim <line1>, <line2> call <SID>Ltrim(<f-args>)
command! -nargs=* -range Rtrim <line1>, <line2> call <SID>Rtrim(<f-args>)
