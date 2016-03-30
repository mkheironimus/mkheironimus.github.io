#! /bin/bash
#
# https://github.com/parkr/vim-jekyll

CMD='vim'
if [ -n "${DISPLAY}" ] ; then
	CMD='gvim'
fi
exec ${CMD} -c "autocmd VimEnter * Jpost! $@"
