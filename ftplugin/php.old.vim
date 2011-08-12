" .vim/ftplugin/php.vim by Tobias Schlitt <toby@php.net>.
" No copyright, feel free to use this, as you like.

" Including PDV
source ~/config/vim/php-doc.vim

" {{{ trim trailing spaces from files before writing them
autocmd BufWritePre *.php :%s/\s\+$//e
"autocmd BufWritePre *.phpt :%s/\s\+$//e
"}}}

" {{{ Settings

" Auto expand tabs to spaces
"set expandtab

" ensure syntax is set to php
if has("syntax")
    set syntax=php
endif
set keywordprg=pman
" turn off spell check
if has("spell")
  set nospell
endif
" fold by syntax
set foldmethod=syntax

" Auto indent after a {
set autoindent
set smartindent

" Linewidth to endless
set textwidth=0

" Do not wrap lines automatically
set nowrap

" Correct indentation after opening a phpdocblock and automatic * on every
" line
set formatoptions=qroct

" Use php syntax check when doing :make
set makeprg=php5\ -l\ %

" Use errorformat for parsing PHP error output
set errorformat=%m\ in\ %f\ on\ line\ %l

"Enable folding for classes and functions
let php_folding = 1
"turn off SQL syntax hightlighting inside Strings
let php_sql_query = 0
"highlight parent errors
let php_parent_error_close = 1
let php_parent_error_open = 1
"For highlighting parent error ] or ):
let php_parent_error_close = 1
"For skipping an php end tag, if there exists an open ( or [ without a closing
"one
let php_parent_error_open = 1
"For highlighting the Baselib methods
let php_baselib = 1
"Disable short tags
let php_noShortTags = 1

" }}} Settings

" {{{ Command mappings

" Map ; to run PHP parser check
" noremap ; :!php5 -l %<CR>

" Map ; to "add ; to the end of the line, when missing"
noremap ; :s/\([^;]\)$/\1;/<cr>

" DEPRECATED in favor of PDV documentation (see below!)
" Map <CTRL>-P to run actual file with PHP CLI
" noremap <C-P> :w!<CR>:!php5 %<CR>

" Map F8, not <ctrl>+p to single line mode documentation (in insert and command mode)
"inoremap <C-P> :call PhpDocSingle()<CR>i
"nnoremap <C-P> :call PhpDocSingle()<CR>
inoremap <F8> :call PhpDocSingle()<CR>i
nnoremap <F8> :call PhpDocSingle()<CR>
" Map F8, not <ctrl>+p to multi line mode documentation (in visual mode)
"vnoremap <C-P> :call PhpDocRange()<CR>
vnoremap <F8> :call PhpDocRange()<CR>

" Map <CTRL>-H to search phpm for the function name currently under the cursor (insert mode only)
inoremap <C-H> <ESC>:!phpm <C-R>=expand("<cword>")<CR><CR>

" Map F7 to remove additional DOS line endings.
map <F7> <ESC>:%s///g<CR>
" }}}

" {{{ Automatic close char mapping

" More common in PEAR coding standard
"inoremap  { {<CR>}<C-O>O
" Maybe this way in other coding standards
" inoremap  { <CR>{<CR>}<C-O>O

"inoremap [ []<LEFT>

" Standard mapping after PEAR coding standard
"inoremap ( ()<LEFT> 

" Maybe this way in other coding standards
" inoremap ( ( )<LEFT><LEFT> 

"inoremap " ""<LEFT>
"inoremap ' ''<LEFT>

" }}} Automatic close char mapping

" {{{ Wrap visual selections with chars

:vnoremap ( "zdi(<C-R>z)<ESC>
:vnoremap { "zdi{<C-R>z}<ESC>
:vnoremap [ "zdi[<C-R>z]<ESC>
:vnoremap ' "zdi'<C-R>z'<ESC>
:vnoremap " "zdi"<C-R>z"<ESC>

" }}} Wrap visual selections with chars

" {{{ Dictionary completion

" The completion dictionary is provided by Rasmus:
" http://lerdorf.com/funclist.txt
set dictionary-=~/.vim/funclist.txt dictionary+=~/.vim/funclist.txt
set dictionary-=~/.vim/xdebugfuncs.txt dictionary+=~/.vim/xdebugfuncs.txt
" Use the dictionary completion
set complete-=k complete+=k

" }}} Dictionary completion

" {{{ Autocompletion using the TAB key

" This function determines, wether we are on the start of the line text (then tab indents) or
" if we want to try autocompletion
func! InsertTabWrapper()
    let col = col('.') - 1
    if !col || getline('.')[col - 1] !~ '\k'
        return "\<tab>"
    else
        return "\<c-p>"
    endif
endfunction


autocmd BufWritePre *.php call ScrubTrailing()
func! ScrubTrailing()
    let save_cursor = getpos('.')
    %s/\s\+$//e
    call setpos('.', save_cursor)
endfunction

" Remap the tab key to select action with InsertTabWrapper
inoremap <tab> <c-r>=InsertTabWrapper()<cr>

" }}} Autocompletion using the TAB key
"
" {{{ abbreviations for common keypresses
iab g global
iab pub public
iab pcg pgc
iab ret return
iab iflist if(cond){<CR>pass;<CR>} else {<CR>pass;<CR>}
iab .? echo 
iab .r print_r
iab .d var_dump
iab iselect <select name=""><CR></select>
iab ifunction function foo(){<CR>}<CR>
iab pf public function
iab pfn public function
iab psf public static function
iab catchnone catch(Exception $e) {}
abb fh <BACKSPACE><ESC>:r ~/config/vim/phpdocheader.txt<RETURN>
"
" }}} abbreviations for common keypresses
"
" Function to locate endpoints of a PHP block {{{
function! PhpBlockSelect(mode)
	let motion = "v"
	let line = getline(".")
	let pos = col(".")-1
	let end = col("$")-1

	if a:mode == 1
		if line[pos] == '?' && pos+1 < end && line[pos+1] == '>'
			let motion .= "l"
		elseif line[pos] == '>' && pos > 1 && line[pos-1] == '?'
			" do nothing
		else
			let motion .= "/?>/e\<CR>"
		endif
		let motion .= "o"
		if end > 0
			let motion .= "l"
		endif
		let motion .= "?<\\?php\\>\<CR>"
	else
		if line[pos] == '?' && pos+1 < end && line[pos+1] == '>'
			" do nothing
		elseif line[pos] == '>' && pos > 1 && line[pos-1] == '?'
			let motion .= "h?\\S\<CR>""
		else
			let motion .= "/?>/;?\\S\<CR>"
		endif
		let motion .= "o?<\\?php\\>\<CR>4l/\\S\<CR>"
	endif

	return motion
endfunction
" }}}

" Mappings to select full/inner PHP block
nmap <silent> <expr> vaP PhpBlockSelect(1)
nmap <silent> <expr> viP PhpBlockSelect(0)
" Mappings for operator mode to work on full/inner PHP block
omap <silent> aP :silent normal vaP<CR>
omap <silent> iP :silent normal viP<CR>
" Generate @uses tag based on inheritance info
let g:pdv_cfg_Uses = 1
" vim:set et sts=2 sw=2:
