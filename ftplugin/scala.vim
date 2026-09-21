vim9script

if exists('b:did_ftplugin')
  finish
endif
b:did_ftplugin = true

setlocal comments=s1:/*,mb:*,ex:*/,://
setlocal commentstring=//\ %s
setlocal suffixesadd=.scala,.sc
setlocal formatoptions+=r
setlocal formatoptions+=o

b:undo_ftplugin = 'setlocal comments< commentstring< suffixesadd< formatoptions<'
    .. ' | unlet! b:did_ftplugin'
