vim9script

augroup vim9_scala3_filetype
  autocmd!
  autocmd BufNewFile,BufRead,BufReadPost *.scala,*.sc,*.sbt if &l:filetype ==# '' || &l:filetype ==# 'sbt' | setlocal filetype=scala | endif
augroup END
