" {{{ Wrap visual selections with chars

:vnoremap ( "zdi(<C-R>z)<ESC>
:vnoremap { "zdi{<C-R>z}<ESC>
:vnoremap [ "zdi[<C-R>z]<ESC>
:vnoremap ' "zdi'<C-R>z'<ESC>
:vnoremap " "zdi"<C-R>z"<ESC>

" }}} Wrap visual selections with chars
" {{{ Dictionary completion

" The completion dictionary is provided by Rasmus:
set dictionary-=~/.vim/mysql.txt dictionary+=~/.vim/mysql.txt
" Use the dictionary completion
set complete-=k complete+=k
" }}} Dictionary completion
" turn off spell check
if has("spell")
  set nospell
endif

"
" vim:set et sts=2 sw=2:
