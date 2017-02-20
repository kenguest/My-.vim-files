" Vim filetype plugin
" Language:     Blade (Laravel)
" Maintainer:   Jason Walton <jwalton512@gmail.com>

if exists('b:did_ftplugin')
    finish
endif

runtime! ftplugin/html.vim
let b:did_ftplugin = 1

setlocal iskeyword+=@-@
