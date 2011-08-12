" Visual Basic
au BufNewFile,BufRead *.vb		setf vb
augroup filetypedetect
au BufNewFile,BufRead *.xt  setf xt
augroup END
" Taken from http://en.wikipedia.org/wiki/Wikipedia:Text_editor_support#Vim
" 	Ian Tegebo <ian.tegebo@gmail.com>

augroup filetypedetect
au BufNewFile,BufRead *.wiki setf Wikipedia
augroup END

