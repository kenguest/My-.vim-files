" vb.vim
" @Author:      Ken Guest (mailto:ken@guest.cx)
" @Website:     <+WWW+>
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Created:     22-Mar-2008.
" @Last Change: 19-Mai-2005.
" @Revision:    0.0

if &cp || exists("loaded_vb")
    finish
endif
let loaded_vb = 1

set syntax=vb
" turn off spell check
if has("spell")
  set nospell
endif

set foldmethod=syntax
