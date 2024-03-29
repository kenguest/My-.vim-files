" .vim/ftplugin/php.vim by Tobias Schlitt <toby@php.net>.
" No copyright, feel free to use this, as you like.

" Including PDV
source ~/.vim/php-doc.vim

let PHP_autoformatcomment = 1

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

" Correct indentation after opening a phpdocblock and automatic * on every
" line
""setlocal formatoptions=qroct
setlocal formatoptions=croqj

" Use php syntax check when doing :make
setlocal makeprg=php\ -l\ %

" Use errorformat for parsing PHP error output
setlocal errorformat=%m\ in\ %f\ on\ line\ %l

" Switch syntax highlighting on, if it was not
if !exists("g:syntax_on")
    syntax
endif

" Use pman for manual pages
setlocal keywordprg=pman

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

" Map ; to run PHP parser check
" noremap ; :!php5 -l %<CR>

" Map ; to add ; to the end of the line, when missing"
noremap <buffer> ; :s/\([^;]\)$/\1;/<cr>
" Map , to add , to the end of the line, when missing"
noremap <buffer> , :s/\([^,]\)$/\1,/<cr>

" DEPRECATED in favor of PDV documentation (see below!)
" Map <CTRL>-P to run actual file with PHP CLI
" noremap <C-P> :w!<CR>:!php5 %<CR>

" Map <ctrl>+p to single line mode documentation (in insert and command mode)
inoremap <buffer> <C-P> :call PhpDocSingle()<CR>i
nnoremap <buffer> <C-P> :call PhpDocSingle()<CR>
" Map <ctrl>+p to multi line mode documentation (in visual mode)
vnoremap <buffer> <C-P> :call PhpDocRange()<CR>

" Map <CTRL>-H to search phpm for the function name currently under the cursor (insert mode only)
inoremap <buffer> <C-H> <ESC>:!phpm <C-R>=expand("<cword>")<CR><CR>

" Map <CTRL>-a to alignment function
vnoremap <buffer> <C-a> :call PhpAlign()<CR>

" Map <CTRL>-a to (un-)comment function
vnoremap <buffer> <C-c> :call PhpUnComment()<CR>

" }}}

" {{{ Automatic close char mapping

" More common in PEAR coding standard
" inoremap <buffer>  { {<CR>}<C-O>O
" Maybe this way in other coding standards
inoremap <buffer>  { {<CR>}<C-O>O

inoremap <buffer> [ []<LEFT>

" Standard mapping after PEAR coding standard
" inoremap <buffer> ( (  )<LEFT><LEFT>
inoremap <buffer> ( ()<LEFT>

" Maybe this way in other coding standards
" inoremap ( ( )<LEFT><LEFT>

inoremap <buffer> " ""<LEFT>
inoremap <buffer> ' ''<LEFT>

" }}} Automatic close char mapping

" {{{ Wrap visual selections with chars

:vnoremap <buffer> ( "zdi(<C-R>z)<ESC>
:vnoremap <buffer> { "zdi{<C-R>z}<ESC>
:vnoremap <buffer> [ "zdi[<C-R>z]<ESC>
:vnoremap <buffer> ' "zdi'<C-R>z'<ESC>
" Removed in favor of register addressing
" :vnoremap " "zdi"<C-R>z"<ESC>

" }}} Wrap visual selections with chars

" {{{ Dictionary completion

" The completion dictionary is provided by Rasmus:
" http://lerdorf.com/funclist.txt
setlocal dictionary-=~/.vim/funclist.txt dictionary+=~/.vim/funclist.txt
" Use the dictionary completion
setlocal complete-=k complete+=k

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

" Remap the tab key to select action with InsertTabWrapper
"inoremap <buffer> <tab> <c-r>=InsertTabWrapper()<cr>

" }}} Autocompletion using the TAB key

" {{{ Alignment

func! PhpAlign() range
    let l:paste = &g:paste
    let &g:paste = 0

    let l:line        = a:firstline
    let l:endline     = a:lastline
    let l:maxlength = 0
    while l:line <= l:endline
		" Skip comment lines
		if getline (l:line) =~ '^\s*\/\/.*$'
			let l:line = l:line + 1
			continue
		endif
		" \{-\} matches ungreed *
        let l:index = substitute (getline (l:line), '^\s*\(.\{-\}\)\s*\S\{0,1}=\S\{0,1\}\s.*$', '\1', "") 
        let l:indexlength = strlen (l:index)
        let l:maxlength = l:indexlength > l:maxlength ? l:indexlength : l:maxlength
        let l:line = l:line + 1
    endwhile
    
	let l:line = a:firstline
	let l:format = "%s%-" . l:maxlength . "s %s %s"
    
	while l:line <= l:endline
		if getline (l:line) =~ '^\s*\/\/.*$'
			let l:line = l:line + 1
			continue
		endif
        let l:linestart = substitute (getline (l:line), '^\(\s*\).*', '\1', "")
        let l:linekey   = substitute (getline (l:line), '^\s*\(.\{-\}\)\s*\(\S\{0,1}=\S\{0,1\}\)\s\(.*\)$', '\1', "")
        let l:linesep   = substitute (getline (l:line), '^\s*\(.\{-\}\)\s*\(\S\{0,1}=\S\{0,1\}\)\s\(.*\)$', '\2', "")
        let l:linevalue = substitute (getline (l:line), '^\s*\(.\{-\}\)\s*\(\S\{0,1}=\S\{0,1\}\)\s\(.*\)$', '\3', "")

        let l:newline = printf (l:format, l:linestart, l:linekey, l:linesep, l:linevalue)
        call setline (l:line, l:newline)
        let l:line = l:line + 1
    endwhile
    let &g:paste = l:paste
endfunc

" }}}   

" {{{ (Un-)comment

func! PhpUnComment() range
    let l:paste = &g:paste
    let &g:paste = 0

    let l:line        = a:firstline
    let l:endline     = a:lastline

	while l:line <= l:endline
		if getline (l:line) =~ '^\s*\/\/.*$'
			let l:newline = substitute (getline (l:line), '^\(\s*\)\/\/ \(.*\).*$', '\1\2', '')
		else
			let l:newline = substitute (getline (l:line), '^\(\s*\)\(.*\)$', '\1// \2', '')
		endif
		call setline (l:line, l:newline)
		let l:line = l:line + 1
	endwhile

    let &g:paste = l:paste
endfunc

" }}}

" ensure syntax is set to php
if has("syntax")
    set syntax=php
endif
" turn off spell check
if has("spell")
  set nospell
endif
" fold by syntax
set foldmethod=syntax

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
"Allow short tags
let php_noShortTags = 0
let php_smart_members = 1
let php_alt_properties = 1
let rewritephp=0

" Map F7 to remove additional DOS line endings.
map <F7> <ESC>:%s///g<CR>

func! PreWriteTidyUp()
    " use silent! to prevent substitutions from getting into the general
    " command history
    if g:rewritephp=='1'
        let save_cursor = getpos('.')
        let old_query = getreg('/')
        silent! %s///ge
        silent! %s/\s\+$//ge
        silent! %s/\($\n\s*\)\+\%$//ge
        silent! %s/){/) {/ge
        silent! %s/( /(/ge
        silent! %s/if(/if (/ge
        silent! %s/var_dump /var_dump/ge
        silent! %s/while(/while (/ge
        call setpos('.', save_cursor)
        call setreg('/', old_query)
    endif
endfunction

function! Phpcs()
    " phpcs
    "let php_cs='zend'
    if g:php_cs=='pear'
        ! /usr/bin/php -l "%" && /usr/bin/phpcs --standard=PSR2 "%"
        let g:phpcsed='pear'
    elseif g:php_cs=='zend'
        ! /usr/bin/php -l "%" && /usr/bin/phpcs --standard=Zend "%"
        let g:phpcsed='zend'
    elseif g:php_cs=='psr2zf1'
        ! /usr/bin/php -l "%" && /usr/bin/phpcs --standard=PSR2ZF1 "%"
        let g:phpcsed='psr2zf1'
    elseif g:php_cs=='psr2'
        ! /usr/bin/php -l "%" && /usr/bin/phpcs --standard=PSR2 "%"
        let g:phpcsed='psr2'
    else
        ! /usr/bin/php -l "%" && /usr/bin/phpcs --standard=PEAR "%"
        let g:phpcsed='default'
    endif
    cwindow
    echom g:phpcsed
endfunction

if !exists("autocommands_loaded")
    let autocommands_loaded = 1
    "autocmd BufWritePost *.php call Phpcs()
    "autocmd BufWritePre *.php call PreWriteTidyUp()
endif
" {{{ abbreviations for common keypresses

abb fh <BACKSPACE><ESC>:r ~/config/vim/phpdocheader.txt<RETURN>
"iab .d var_dump
iab .e var_export
iab .r print_r
iab .? echo
iab ab abstract
iab bo boolean
iab brk break;
iab ca catch
iab catchnone catch(Exception $e) {}
iab cl class
iab cn continue
iab df default:
iab dowhile do {<CR>} while ();
iab Ex Exception
iab ex extends
iab g global
iab iflist if(cond){<CR>pass;<CR>} else {<CR>pass;<CR>}
iab ifunction function foo(){<CR>}<CR>
iab iselect <select name=""><CR></select>
iab pcg pgc
iab pe protected
iab pf public function
iab prfn protected function
iab pro protected
iab pr private
iab pub public
iab pu public
iab pvn private function
iab ret return
iab st static
iab trycatch try {<CR>} catch(Exception $e) {<CR>}
iab 'place-holder' placeholder
iab __L __LINE__
iab __F __FILE__
iab __FL __FILE__ . ":" . __LINE__ .

let g:syntastic_ignore_files = ['.*/Zend/.*', '.*\.phtml$', '.*/Twitter/Bootstrap/.*']
