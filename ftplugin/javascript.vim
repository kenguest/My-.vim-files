" javascript.vim
set omnifunc=javascriptcomplete#CompleteJS

if &cp || exists("loaded_javascript")
    finish
endif
let loaded_javascript = 1

" {{{ Settings
set makeprg=jsl\ -nologo\ -nofilelisting\ -nosummary\ -nocontext\ -conf\ '/etc/jsl.conf'\ -process\ % 
set errorformat=%f(%l):\ %m
set nospell
" Auto indent after a {
set autoindent
set smartindent

" Linewidth to endless
set textwidth=0

" Do not wrap lines automatically
set nowrap
set formatoptions=qroct

" fold by syntax
let javaScript_fold=1
let javascript_enable_domhtmlcss=1 
set foldmethod=syntax
" ensure syntax is set to php
if has("syntax")
    set syntax=javascript
endif
" }}} Settings
" {{{ Command mappings
" Map ; to "add ; to the end of the line, when missing"
noremap ; :s/\([^;]\)$/\1;/<cr>
"make F10 call make for linting etc.
inoremap <silent> <F10> <C-O>:make<CR>
map <silent> <F10> :make<CR>
" }}} Command mappings
" {{{ Wrap visual selections with chars

:vnoremap ( "zdi(<C-R>z)<ESC>
:vnoremap { "zdi{<C-R>z}<ESC>
:vnoremap [ "zdi[<C-R>z]<ESC>
:vnoremap ' "zdi'<C-R>z'<ESC>
:vnoremap " "zdi"<C-R>z"<ESC>

" }}} Wrap visual selections with chars
function! Lint()
  redir => lint
  silent ! jsl -nologo -nofilelisting -nosummary -nocontext -conf /etc/jsl.conf -process %
  redir END
  tabnew
  silent put=lint
  set nomodified
endfunction
command! -nargs=0 -complete=command Lint call Lint()
inoremap <silent> <F10> <C-O>:Lint
map <silent> <F10> :Lint
