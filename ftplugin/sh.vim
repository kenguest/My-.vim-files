" bash.vim
" @Author:      Ken Guest (mailto:ken@guest.cx)
" @Website:     <+WWW+>
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Created:     14-Nov-2007.
" @Last Change: 19-Mai-2005.
" @Revision:    0.0

if &cp || exists("loaded_bash")
    finish
endif
let loaded_bash = 1


" turn off spell check
if has("spell")
  set nospell
endif

