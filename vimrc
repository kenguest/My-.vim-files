"vim:set et sts=2 sw=2:
" {{{  Settings 
set nocompatible        " I want VIM not vi. B-)
let mapleader = ","

retab
" Use filetype plugins, e.g. for PHP
filetype plugin on
" wordlist contains fixes for my silly tpyos. 
source ~/.vim/wordlist.vim
" Insert mode completion options
set completeopt=menu,longest,preview
" use CTRL-F for omni completion
imap <C-F> 
" Enable per-directory .vimrc files and disable unsafe commands in them
set exrc
" force 256 colours on terminals
set t_Co=256
"
set runtimepath^=~/.vim/bundle/ctrlp.vim
"
set pastetoggle=<F2>
"
set printfont=courier:h8

" Pathogen {{{
" Read this: http://tammersaleh.com/posts/the-modern-vim-config-with-pathogen
if has("autocmd")
  call pathogen#infect()
  call pathogen#helptags()
endif
" }}}

"show possible completions
set wildmenu
" Set command-line completion mode:
"   - on first <Tab>, when more than one match, list all matches and complete
"     the longest common  string
"   - on second <Tab>, complete the next full match and show menu
":set wildmode=longest,list
set wildmode=list:longest,full
"Ignore these
set wildignore=*~,*gz,*.a,*.bmp,*.class,*.flp,*.gif,*.jpg,*.la,*.mo,*.o,*.obj
set wildignore+=*.png,*.so,*.swp,*.xpm,.svn,CVS,*.mli,*.cmi,*.cmx

" Write with sudo ":w!!"
cnoremap w!! w !sudo tee % >/dev/null

" map ,f to display all lines with keyword under cursor and ask which one to
" jump to
nmap ,f [I:let nr = input("Which one: ")<Bar>exe "normal " . nr ."[\t"<CR>
" Optimize for fast terminal connections
set ttyfast
" Allow backspace in insert mode
set backspace=indent,eol,start

set textwidth=79        " wrap at 79 characters
if v:version >= 703
  hi ColorColumn guibg=#101010
  set colorcolumn=80,120
else
  au BufWinEnter * let w:m2=matchadd('ErrorMsg', '\%>79v.\+', -1)
endif

set backup              " backups are good
set backupdir=~/.vim/backup
set directory=~/tmp/vim

set wrapmargin=1
set viminfo='20,\"50    " read/write a .viminfo file, don't store more than
                        " 50 lines of registers
set history=50          " keep 50 lines of command line history
set autoindent
set smartindent
set incsearch           " Use incremental searching
set nohlsearch          " don't highlight results of search. I think it's ugly.
set showcmd             " show the command in the status line
set showmatch           " Show matching brackets.
" Enable CTRL-A/CTRL-X to work on octal and hex numbers, as well as characters
set nrformats=octal,hex,alpha

" Jump to matching bracket for 2/10th of a second (works with showmatch)
set matchtime=2
set laststatus=2        " Always have a status line
set report=2            " If I've changed more than one...
set ruler               " show the cursor position all the time
set splitbelow          " Put new windows on bottom
set splitright          " New windows in vertical splits to go to the right.
set ttimeout notimeout timeoutlen=100
set showmode            " What mode am I in?
set encoding=utf8
set termencoding=utf-8
set shell=bash
"tabs...
set expandtab
set tabstop=4
" Use 4 spaces for (auto)indent
set shiftwidth=4
" Don't request terminal version string (for xterm)
set t_RV=
" Round indent to multiple of 'shiftwidth' for > and < commands
set shiftround
set softtabstop=4
set nojoinspaces
" Show line numbers by default
set number
""" Enable folding by fold markers
set foldmethod=marker
" Autoclose folds, when moving out of them
set foldclose=all
" Jump 5 lines when running out of the screen
"set scrolljump=5
" Indicate jump out of the screen when 3 lines before end of the screen
"set scrolloff=3
"also ignore .pyc files...
set suffixes+=.pyc,.ps
"shut up and don't flash (no noise; neither audio or visual)
set vb t_vb=
"automatically write the current file out when I move on to the next one.
set autowrite
set updatecount=50          " write a swapfile every 50 chars
set updatetime=15000        " or every 15000 milliseconds
""let me type in vowels with fadas and such.
"set digraph
" Where to find tags files for jumping to function definitions.
set tags=./tags,../tags,../../tags,../../../tags,../../../../tags,../../../../../tags
" Where to find headers
set path=.
",/usr/include,/usr/X11/include,/usr/local/include,/usr/src/linux/include/

"set cursorline
"if I have split windows vertically, I want them to be at least 80 chars wide
"and 10 chars tall when active
if v:version >= 600
  if has("windows")
    set winwidth=80
    set winheight=10
  endif
endif        

if v:version >= 703
  set relativenumber
  set undofile
  set undodir=~/.vim/undo
endif

"only use the mouse for resizing windows and so on in Normal mode,
"still want to be able to select/copy/paste text through all open xterms.
if has("mouse")
  set mouse=n
  set mousemodel=popup
endif

if has("spell")
  setlocal spell spelllang=en_gb
  set nospell
endif

if $TERM=='screen'
  exe "set title titlestring=vim:%f"
  exe "set title t_ts=\<ESC>k t_fs=\<ESC>\\"
endif


" }}}

" {{{ Macros 
"macro for uppercasing some SQL built-in functions
map s :s/select/SELECT/g<CR>:s/from/FROM/g<CR>:s/where/WHERE/g<CR>
"macro for inserting current time-stamp
map T  "='['.strftime("%c").']'<CR>p
" use Q for formatting, not ex-mode:
map Q gq
" }}}

" Helpful window navigation {{{
" moves up and down between windows and maximises the focused window.
map <C-J> <C-W>j<C-W>_
map <C-K> <C-W>k<C-W>_
" }}}

" Syntax color coding {{{
"have to toggle syntax for it to use the right colors after changing the
"background value
if has("syntax")
  "syntax off
  if v:progname =~ "vim.exe"
    set background=light
    color darkblue
    colorscheme solarized
  elseif v:progname =~ "gvim"  
    set background=dark
    color darkblue
    colorscheme solarized
  else
    set background=dark
    colorscheme solarized
  endif  
  if &diff
    syntax off
  else
    syntax on
  endif
endif
if &bg == "dark"
  highlight Comment ctermfg=darkgreen
  highlight MatchParen ctermbg=blue guibg=blue
  highlight StatusLine ctermfg=white ctermbg=blue cterm=bold
  highlight StatusLineNC ctermfg=lightgray ctermbg=black
endif
highlight Comment ctermfg=darkgreen
" }}}

" Autocommands {{{
if has("autocmd")
  if v:progname =~ "vim$"
    au BufEnter * let &titlestring = $USER . "@" . hostname() . ":$vim %-0.65F"
    if version >= 600
        au BufEnter * let &printheader = $USER . "@" . hostname() . 
                                                         \ ": %-0.65F%=Page %N"
    endif
  endif

  " Update status line on reads and writes {{{
  au BufWrite * call SetStatusLine()
  au BufRead * call SetStatusLine()
  " }}}

  au BufEnter *     set title titlelen=79
"  cron on FreeBSD doesn't like backups being made.
  au BufEnter       crontab.*     set nobackup
  au BufEnter       crontab.*     set nowritebackup
  au BufNewFile,BufRead sql*     set filetype=sql
  au BufNewFile,BufRead *.phpt    set filetype=php
  au BufNewFile,BufRead *.as      set filetype=actionscript
  au BufNewFile,BufRead *.py      set expandtab
  au BufNewFile,BufRead *.py      set comments=:# 
  au BufNewFile,BufRead *.py      source ~/.vim/python.vim
  au BufNewFile,BufRead *.mail    set syntax=mail
  au BufNewFile,BufRead *.vim     set foldmethod=marker 
  au BufNewFile,BufRead *.vim     set nospell
    " Treat .json files as .js
  au BufNewFile,BufRead *.json setfiletype json syntax=javascript
  au BufNewFile ~/.vim/skeletons/*.suffix TSkeletonSetup othertemplate.suffix
  au BufNewFile *.suffix       TSkeletonSetup template.suffix

  " Automatically chmod +x Shell and Perl scripts
  au BufWritePost   *.sh             !chmod +x %
  au BufWritePost   *.pl             !chmod +x %

  " Transparent editing of gpg encrypted files. {{{
  " By Wouter Hanegraaff <wouter@blub.net>
  augroup encrypted
  au!

  " First make sure nothing is written to ~/.viminfo while editing
  " an encrypted file.
  autocmd BufReadPre,FileReadPre      *.gpg set viminfo=
  " We don't want a swap file, as it writes unencrypted data to disk
  autocmd BufReadPre,FileReadPre      *.gpg set noswapfile
  " Switch to binary mode to read the encrypted file
  autocmd BufReadPre,FileReadPre      *.gpg set bin
  autocmd BufReadPre,FileReadPre      *.gpg let ch_save = &ch|set ch=2
  autocmd BufReadPre,FileReadPre      *.gpg let shsave=&sh
  autocmd BufReadPre,FileReadPre      *.gpg let &sh='sh'
  autocmd BufReadPre,FileReadPre      *.gpg let ch_save = &ch|set ch=2
  autocmd BufReadPost,FileReadPost    *.gpg '[,']!gpg --decrypt --default-recipient-self 2> /dev/null
  autocmd BufReadPost,FileReadPost    *.gpg let &sh=shsave

  " Switch to normal mode for editing
  autocmd BufReadPost,FileReadPost    *.gpg set nobin
  autocmd BufReadPost,FileReadPost    *.gpg let &ch = ch_save|unlet ch_save
  autocmd BufReadPost,FileReadPost    *.gpg execute ":doautocmd BufReadPost " . expand("%:r")

  " Convert all text to encrypted text before writing
  autocmd BufWritePre,FileWritePre    *.gpg set bin
  autocmd BufWritePre,FileWritePre    *.gpg let shsave=&sh
  autocmd BufWritePre,FileWritePre    *.gpg let &sh='sh'
  autocmd BufWritePre,FileWritePre    *.gpg '[,']!gpg --encrypt --default-recipient-self 2>/dev/null
  autocmd BufWritePre,FileWritePre    *.gpg let &sh=shsave

  " Undo the encryption so we are back in the normal text, directly
  " after the file has been written.
  autocmd BufWritePost,FileWritePost  *.gpg silent u
  autocmd BufWritePost,FileWritePost  *.gpg set nobin
  augroup END
  " }}}
endif
" }}}
" jump between windows without requiring ctrl-w prefix
nmap <C-J> <C-W><C-J>
nmap <C-K> <C-W><C-K>
nmap <C-H> <C-W><C-H>
nmap <C-L> <C-W><C-L>

"{{{ <home> toggles between start of line and start of text
"<home> toggles between start of line and start of text
imap <khome> <home>
nmap <khome> <home>
inoremap <silent> <home> <C-O>:call Home()<CR>
nnoremap <silent> <home> :call Home()<CR>
function Home()
    let curcol = wincol()
    normal ^
    let newcol = wincol()
    if newcol == curcol
        normal 0
    endif
endfunction
"}}}
"
"{{{<end> goes to end of screen before end of line
imap <kend> <end>
nmap <kend> <end>
inoremap <silent> <end> <C-O>:call End()<CR>
nnoremap <silent> <end> :call End()<CR>
function End()
    let curcol = wincol()
    normal g$
    let newcol = wincol()
    if newcol == curcol
        normal $
    endif
    "The following is to work around issue for insert mode only.
    "normal g$ doesn't go to pos after last char when appropriate.
    "More details and patch here:
    "http://www.pixelbeat.org/patches/vim-7.0023-eol.diff
    if virtcol(".") == virtcol("$") - 1
        normal $
    endif
endfunction

"}}}

"make F10 call make for linting etc. {{{
inoremap <silent> <F10> <C-O>:make<CR>
map <silent> <F10> :make<CR>
" }}}

"F5 toggles spell check {{{
inoremap <silent> <F5> <C-O>:call SpellToggle()<CR>
map <silent> <F5> :call SpellToggle()<CR>
function SpellToggle()
    if &spell == 1
        set nospell
    else
        set spell
    endif
endfunction
" }}}

" {{{  GenUtils
"genutils is dependant on multvals so the order they are loaded in is important
source $HOME/.vim/scripts/multvals.vim
source $HOME/.vim/scripts/genutils.vim
let tskelUserName='Ken Guest'
let tskelUserEmail='ken@linux.ie'
source $HOME/.vim/overrides.vim
" }}}

"Statusline {{{
"highlight StatusLine ctermfg=yellow ctermbg=red cterm=bold
highlight StatusLineNC ctermfg=lightgray ctermbg=blue
let g:netrw_ftp_cmd="ftp -p"

function! SetStatusLine()
  set statusline=[%n]\ %f\ %(\ \ (%M%R%H)%)\ \ \ %=\t%{ShowTab()}\ \ \ Modified:\ %{Time()}\ \ [%3l:%3L,%2c]\ %p%%\ 
endfunction

function! Time()
  return strftime("%c", getftime(bufname("%")))
endfunction

function! ShowTab()
  let TabLevel = (indent('.') / &ts )
  if TabLevel == 0
    let TabLevel='*'
  endif
  return TabLevel
endfunction
"}}}

" Respect modeline in files {{{
set modeline
set modelines=4
"}}}

" Syntastic settings {{{
let g:syntastic_php_phpcs_args='--standard=pear'
let g:rainbow_active = 1

let g:syntastic_php_checkers = ['php', 'phpcs']
set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*

let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0
" }}}

" Some PHP things {{{
" Put at the very end of your .vimrc file.
" << https://github.com/StanAngeloff/php.vim >>

function! PhpSyntaxOverride()
  hi! def link phpDocTags  phpDefine
  hi! def link phpDocParam phpType
endfunction

augroup phpSyntaxOverride
  autocmd!
  autocmd FileType php call PhpSyntaxOverride()
augroup END
let g:php_cs='pear'
let g:php_syntax_extensions_enabled = 1
let b:php_syntax_extensions_enabled = 1
" }}}

" gutentags {{{
let g:gutentags_exclude = ['*.css', '*.html', '*.js'] 
let g:gutentags_cache_dir = '~/.vim/gutentags'
" }}}:w



" Vim. Live it. {{{
noremap <up> <nop>
noremap <down> <nop>
noremap <left> <nop>
noremap <right> <nop>
inoremap <down> <nop>
inoremap <left> <nop>
inoremap <right> <nop>
inoremap <up> <nop>
" }}}
