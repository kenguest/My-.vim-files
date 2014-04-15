
" {{{ Settings

" Set new grep command, which ignores SVN!
" TODO: Add this to SVN
set grepprg=/usr/bin/vimgrep\ $*\ /dev/null

" Auto expand tabs to spaces, but only if env variable 'ET' isn't set to 'no'
if $ET=='no'
  setlocal noexpandtab
else
  setlocal expandtab
endif

" Auto indent after a {
setlocal autoindent
setlocal smartindent

" Linewidth to 79, because of the formatoptions this is only valid for
" comments
setlocal textwidth=79
" setlocal formatoptions=qrocb

" Do not wrap lines automatically
setlocal nowrap


" Switch syntax highlighting on, if it was not
if !exists("g:syntax_on")
    syntax
endif

" Highlight trailing whitespaces
highlight ExtraWhitespace ctermbg=red guibg=red
match ExtraWhitespace /\s\+$/
autocmd BufWinEnter * match ExtraWhitespace /\s\+$/
autocmd InsertEnter * match ExtraWhitespace /\s\+\%#\@<!$/
autocmd InsertLeave * match ExtraWhitespace /\s\+$/
autocmd BufWinLeave * call clearmatches()

" MovingThroughCamelCaseWords
nnoremap <silent><C-Left>  :<C-u>cal search('\<\<Bar>\U\@<=\u\<Bar>\u\ze\%(\U\&\>\@!\)\<Bar>\%^','bW')<CR>
nnoremap <silent><C-Right> :<C-u>cal search('\<\<Bar>\U\@<=\u\<Bar>\u\ze\%(\U\&\>\@!\)\<Bar>\%$','W')<CR>
inoremap <silent><C-Left>  <C-o>:cal search('\<\<Bar>\U\@<=\u\<Bar>\u\ze\%(\U\&\>\@!\)\<Bar>\%^','bW')<CR>
inoremap <silent><C-Right> <C-o>:cal search('\<\<Bar>\U\@<=\u\<Bar>\u\ze\%(\U\&\>\@!\)\<Bar>\%$','W')<CR> 

" }}} Settings

" {{{ Command mappings

" Map ; to add ; to the end of the line, when missing"
noremap <buffer> ; :s/\([^;]\)$/\1;/<cr>
" Map , to add , to the end of the line, when missing"
noremap <buffer> , :s/\([^,]\)$/\1,/<cr>
" }}}

" ensure syntax is set to coldfusion/cf
if has("syntax")
    set syntax=cf
endif
" turn off spell check
if has("spell")
  set nospell
endif
" fold by syntax
set foldmethod=syntax

" Map F7 to remove additional DOS line endings.
map <F7> <ESC>:%s///g<CR>

func! PreWriteTidyUp()
    " use silent! to prevent substitutions from getting into the general
    " command history
    let save_cursor = getpos('.')
    let old_query = getreg('/')
    silent! %s/\s\+$//ge
    silent! %s/\($\n\s*\)\+\%$//ge
    silent! %s/){/) {/ge
    silent! %s/( /(/ge
    silent! %s/if(/if (/ge
    silent! %s/while(/while (/ge
    call setpos('.', save_cursor)
    call setreg('/', old_query)
endfunction

function! Lint()
    ! /home/kguest/dev/Apps/CFLint-0.1.7/bin/cflint -file "%" -text
    cwindow
endfunction

if !exists("autocommands_loaded")
    let autocommands_loaded = 1
    autocmd BufWritePost *.cfm call Lint()
    autocmd BufWritePre *.cfm call PreWriteTidyUp()
endif
