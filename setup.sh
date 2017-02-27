#!/bin/bash
# setup.sh -- created 18-May-2012, Ken Guest
# @Last Change: 18-May-2012
# @Revision:    0.0

if [ ! -f ~/.vimrc ] ; then
	ln -sv `pwd`/vimrc ~/.vimrc
else
	echo "~/.vimrc already exists"
fi
if [ ! -f ~/.vim ] ; then
	ln -sv `pwd` ~/.vim
else
	echo "~/.vim already exists"
fi
