vim9script

set nocp
execute 'set runtimepath^=' .. fnameescape(getcwd())
filetype plugin indent on
syntax enable

for testfile in ['test/filetype.vim', 'test/syntax.vim', 'test/indent.vim']
  execute 'source ' .. fnameescape(testfile)
endfor

if !empty(v:errors)
  for error in v:errors
    echomsg error
  endfor
  cquit
endif
qa!
