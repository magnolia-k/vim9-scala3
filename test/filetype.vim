vim9script

for extension in ['scala', 'sc', 'sbt']
  execute $'edit Xfile.{extension}'
  assert_equal('scala', &l:filetype)
  assert_match('Vim9Scala3Indent', &l:indentexpr)
  assert_equal('// %s', &l:commentstring)
  assert_true(stridx(&l:formatoptions, 'r') >= 0)
  assert_true(stridx(&l:formatoptions, 'o') >= 0)
  bwipe!
endfor

enew!
setlocal filetype=text
execute 'doautocmd vim9_scala3_filetype BufRead Xfile.scala'
assert_equal('text', &l:filetype, 'setfiletype must not overwrite an existing filetype')
bwipe!

edit Xcomment.scala
setline(1, '// comment')
execute "normal! ggA\<CR>continued\<Esc>"
assert_equal('// continued', getline(2), 'Enter continues a line comment')

setline(1, '// comment')
deletebufline('%', 2, '$')
execute "normal! ggoopened\<Esc>"
assert_equal('// opened', getline(2), 'o continues a line comment')

setline(1, ['/* comment', ' * body', ' */'])
deletebufline('%', 4, '$')
execute "normal! 2GA\<CR>continued\<Esc>"
assert_equal(' * continued', getline(3), 'Enter continues a block comment leader')
bwipe!
