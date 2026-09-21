vim9script

import './helpers.vim' as h

h.NewScala(['object Main:', 'def value =', 'println(1)'])
h.Reindent(2)
h.Reindent(3)
assert_equal(2, indent(2))
assert_equal(4, indent(3))

h.NewScala(['object Main:', '      def deep = 1'])
h.Reindent(2)
assert_equal(6, indent(2), 'valid deeper indentation must be preserved')

var starters = [
  'if ready then', 'while ready do', 'for', 'try', 'else', 'finally',
  'throw', 'yield', 'val x =', 'case x =>', 'case x ?=>', 'x <-',
  'class C:', 'extension (x: X)', 'given X with', 'if (ready)', 'for (x <- xs)',
]
for starter in starters
  h.NewScala([starter, 'body'])
  h.Reindent(2)
  assert_equal(2, indent(2), starter)
endfor

for starter in ['value match', 'catch', 'return']
  h.NewScala([starter, 'case X => 1'])
  h.Reindent(2)
  assert_equal(0, indent(2), $'{starter} permits an unindented continuation')
endfor

h.NewScala(['call(', 'argument', ')'])
h.Reindent(2)
assert_equal(0, indent(2), 'parenthesis indentation is a user choice')
h.NewScala(['if ready {', 'body', '}'])
h.Reindent(2)
assert_equal(0, indent(2), 'brace indentation is a user choice')
h.NewScala(['val text = "then"', 'next'])
h.Reindent(2)
assert_equal(0, indent(2), 'tokens in strings do not trigger indentation')
setline(1, 'val text =')
h.Reindent(2)
assert_equal(2, indent(2), 'editing invalidates the lexical cache')
h.NewScala(['/* then', 'still comment */', 'next'])
h.Reindent(2)
h.Reindent(3)
assert_equal(0, indent(3), 'tokens in multiline comments do not trigger indentation')

h.NewScala(['if ready then', '  yes()', '  else', 'no()'])
h.Reindent(3)
assert_equal(0, indent(3))
h.Reindent(4)
assert_equal(2, indent(4))

h.NewScala(['try', '  work()', '  catch', '  case e => recover(e)'])
h.Reindent(3)
assert_equal(0, indent(3))

h.NewScala(['object O:', '  val x = 1', '  end O'])
h.Reindent(3)
assert_equal(0, indent(3))
