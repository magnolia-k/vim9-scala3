vim9script

export def NewScala(lines: list<string>)
  enew!
  setlocal filetype=scala
  setlocal shiftwidth=2 tabstop=8 expandtab
  setline(1, lines)
  if line('$') > len(lines)
    deletebufline('%', len(lines) + 1, '$')
  endif
  syntax sync fromstart
enddef

export def SyntaxAt(lnum: number, needle: string): string
  var col = getline(lnum)->match(needle) + 1
  assert_true(col > 0, $'missing syntax needle: {needle}')
  return synIDattr(synID(lnum, col, true), 'name')
enddef

export def Reindent(lnum: number)
  execute $'normal! {lnum}G=='
enddef
