vim9script

import './helpers.vim' as h

h.NewScala([
  'abstract case catch class def do else enum export extends final finally for given if implicit import',
  'lazy match new object override package private protected return sealed super then throw trait try type val var while with yield',
  'true false null',
])

var regularGroups = {
  scalaConditional: ['case', 'else', 'if', 'match', 'then'],
  scalaRepeat: ['do', 'for', 'while', 'yield'],
  scalaException: ['catch', 'finally', 'throw', 'try'],
  scalaStructure: ['class', 'enum', 'extends', 'new', 'object', 'trait', 'with'],
  scalaDeclaration: ['def', 'given', 'val', 'var'],
  scalaTypedef: ['type'],
  scalaModifier: ['abstract', 'final', 'implicit', 'lazy', 'override', 'private', 'protected', 'sealed'],
  scalaInclude: ['export', 'import', 'package'],
  scalaStatement: ['return'],
  scalaKeyword: ['super'],
}
for [group, words] in items(regularGroups)
  for word in words
    var lnum = index(split(getline(1)), word) >= 0 ? 1 : 2
    assert_equal(group, h.SyntaxAt(lnum, '\<' .. word .. '\>'), word)
  endfor
endfor
assert_equal('scalaBoolean', h.SyntaxAt(3, 'true'))
assert_equal('scalaNull', h.SyntaxAt(3, 'null'))

h.NewScala([
  'inline transparent infix def f = 1',
  'opaque type Id = Int',
  'open class C',
  'extension (x: Int)',
  'class D derives Eq',
  'def f(using x: X): Unit throws E = ()',
  'import a.b as c',
  'end f',
  'val inline = 1',
  'val extension = 2',
])
for [lnum, word, group] in [[1, 'inline', 'scalaModifier'], [1, 'transparent', 'scalaModifier'],
    [1, 'infix', 'scalaModifier'], [2, 'opaque', 'scalaTypedef'], [3, 'open', 'scalaModifier'],
    [4, 'extension', 'scalaDeclaration'], [5, 'derives', 'scalaTypeKeyword'],
    [6, 'using', 'scalaModifier'], [6, 'throws', 'scalaException'],
    [7, 'as', 'scalaInclude'], [8, 'end', 'scalaStatement']]
  assert_equal(group, h.SyntaxAt(lnum, $'\<{word}\>'), $'{word} on line {lnum}')
endfor
assert_notequal('scalaModifier', h.SyntaxAt(9, '\<inline\>'))
assert_notequal('scalaDeclaration', h.SyntaxAt(10, '\<extension\>'))

h.NewScala([
  'val hex = 0xCA_FE',
  'val bin = 0b1010_0011',
  'val dec = 12_345L',
  'val flt = 1.25e-2F',
  'val c = ''\n''',
  'val s = "then \\n"',
  'val t = """match',
  'still a string"""',
  'val i = s"value=$hex ${dec + 1}"',
  'val `match` = 1',
  '@main def run() = ()',
  '// then TODO',
  '/* outer match /* nested if */ end */ val x = 1',
  'val q = ''{ 1 }',
  'val sp = ${ Expr(1) }',
])
for lnum in range(1, 4)
  assert_equal('scalaNumber', h.SyntaxAt(lnum, lnum == 1 ? '0x' : lnum == 2 ? '0b' : lnum == 3 ? '12_' : '1\.25'))
endfor
assert_equal('scalaChar', h.SyntaxAt(5, 'val c = \zs.'))
assert_equal('scalaString', h.SyntaxAt(6, 'then'))
assert_equal('scalaTripleString', h.SyntaxAt(7, 'match'))
assert_equal('scalaTripleString', h.SyntaxAt(8, 'still'))
assert_equal('scalaInterpolation', h.SyntaxAt(9, '\$hex'))
assert_equal('scalaBacktickIdentifier', h.SyntaxAt(10, 'match'))
assert_equal('scalaAnnotation', h.SyntaxAt(11, '@main'))
assert_equal('scalaLineComment', h.SyntaxAt(12, 'then'))
assert_equal('scalaTodo', h.SyntaxAt(12, 'TODO'))
assert_match('scalaBlockComment', h.SyntaxAt(13, 'match'))
assert_equal('scalaQuote', h.SyntaxAt(14, "'"))
assert_equal('scalaSplice', h.SyntaxAt(15, '\$'))

h.NewScala([
  'type F = A => B',
  'type C = A ?=> B',
  'type L = [X] =>> List[X]',
  'for x <- xs yield x',
  'type T = A <: B',
  'type U >: Null',
  'import a.*',
  'def f(xs: Int*) = f(xs*)',
  'case A | B =>',
  'type V[+A, -B] = A',
])
for [lnum, needle] in [[1, '=>'], [2, '?=>'], [3, '=>>'], [4, '<-'], [5, '<:'], [6, '>:']]
  assert_equal('scalaKeywordOperator', h.SyntaxAt(lnum, needle), needle)
endfor
assert_equal('scalaWildcardImport', h.SyntaxAt(7, '\*'))
assert_equal('scalaVarargSplice', h.SyntaxAt(8, 'xs\zs\*'))
assert_equal('scalaPatternAlternative', h.SyntaxAt(9, '|'))
assert_equal('scalaVariance', h.SyntaxAt(10, '+'))
assert_equal('scalaVariance', h.SyntaxAt(10, '-'))

# Comment terminators must restore highlighting, including the overlapping
# documentation opener/closer in an empty /**/ comment.
for comment in ['/**/', '/** documentation */', '/* comment */',
    '/* outer /* nested */ outer */', '/** outer /* nested */ outer */']
  h.NewScala([comment .. ' val after = 1', 'val next = 2'])
  assert_equal('scalaDeclaration', h.SyntaxAt(1, '\<val\>'), comment)
  assert_equal('scalaNumber', h.SyntaxAt(1, '1'), comment)
  assert_equal('scalaDeclaration', h.SyntaxAt(2, '\<val\>'), comment)
endfor

h.NewScala([
  '/** documentation',
  ' * outer /* nested',
  ' * nested */ still documentation',
  ' */',
  'val after = 1',
])
assert_equal('scalaBlockComment', h.SyntaxAt(3, 'nested'))
assert_equal('scalaDocComment', h.SyntaxAt(3, 'still'))
assert_equal('scalaDeclaration', h.SyntaxAt(5, 'val'))

h.NewScala([
  'class User[A] extends Base derives Eq',
  'def find(id: Int): Option[List[User]] = None',
  'type Result = String | Throwable',
  'type Handler = User => Unit',
  'val items: scala.collection.immutable.Map[String, List[User]] = Map.empty',
  'import example.User',
  'val userName = "User Int"',
  '// User Int',
  '/* User Int */',
  '/** User Int */',
  'val `User` = 1',
  '@User def run(): Unit = ()',
])
for [lnum, names] in [[1, ['User', 'A', 'Base', 'Eq']],
    [2, ['Int', 'Option', 'List', 'User', 'None']],
    [3, ['Result', 'String', 'Throwable']], [4, ['Handler', 'User', 'Unit']],
    [5, ['Map', 'String', 'List', 'User']], [6, ['User']], [12, ['Unit']]]
  for name in names
    assert_equal('scalaType', h.SyntaxAt(lnum, '\<' .. name .. '\>'), $'{name} on line {lnum}')
  endfor
endfor
assert_equal('Type', synIDattr(synIDtrans(hlID('scalaType')), 'name'))
assert_notequal('scalaType', h.SyntaxAt(7, 'userName'))
for [lnum, group] in [[7, 'scalaString'], [8, 'scalaLineComment'],
    [9, 'scalaBlockComment'], [10, 'scalaDocComment'],
    [11, 'scalaBacktickIdentifier'], [12, 'scalaAnnotation']]
  assert_equal(group, h.SyntaxAt(lnum, 'User'))
endfor
