vim9script

if exists('b:current_syntax')
  finish
endif

syntax case match

syntax keyword scalaTodo TODO FIXME XXX NOTE contained

# Follow the conventional initial capital for type names. Syntax highlighting
# cannot distinguish these from capitalized term names without semantic data.
syntax match scalaType "\<[A-Z][A-Za-z0-9_$]*\>"

# Literals.  More specific numeric forms precede the decimal fallback.
syntax match scalaNumber "\<0[xX][0-9A-Fa-f_]\+[lL]\?\>"
syntax match scalaNumber "\<0[bB][01_]\+[lL]\?\>"
syntax match scalaNumber "\<\d[0-9_]*\%([eE][+-]\?[0-9_]\+\)[fFdD]\?\>"
syntax match scalaNumber "\<\d[0-9_]*\.[0-9_]*\%([eE][+-]\?[0-9_]\+\)\?[fFdD]\?"
syntax match scalaNumber "\<\d[0-9_]*[fFdDlL]\?\>"
syntax match scalaEscape "\\\%([btnfr\"'\\]\|u\+[0-9A-Fa-f]\{4}\)" contained
syntax region scalaChar start=+'+ skip=+\\.+ end=+'+ contains=scalaEscape
syntax region scalaString start=+"+ skip=+\\.+ end=+"+ contains=scalaEscape
syntax region scalaTripleString start=+"""+ end=+"""+ keepend

# Interpolated strings keep interpolation expressions visible as a distinct
# group without attempting semantic highlighting inside the expression.
syntax match scalaInterpolation "\$[A-Za-z_$][A-Za-z0-9_$]*" contained
syntax region scalaInterpolation matchgroup=scalaInterpolationDelimiter start="\${" end="}" contained contains=ALLBUT,scalaString,scalaTripleString
syntax region scalaInterpolatedString matchgroup=scalaStringPrefix start="\<[A-Za-z_$][A-Za-z0-9_$]*\zs\%(\"\|\"\"\"\)" skip="\\." end="\%(\"\|\"\"\"\)" contains=scalaEscape,scalaInterpolation

syntax region scalaBacktickIdentifier start="`" end="`"

# Generic operators are defined before their more specific keyword forms so
# that the contextual groups below win at the same start position.
syntax match scalaOperator "[!%&*+\-/:<=>?@\\^|~]\+"

# Scala 3 regular keywords, divided by the standard Vim highlight roles.
syntax keyword scalaConditional case else if match then
syntax keyword scalaRepeat do for while yield
syntax keyword scalaException catch finally throw try
syntax keyword scalaStructure class enum extends new object trait with
syntax keyword scalaDeclaration def given val var
syntax keyword scalaTypedef type
syntax keyword scalaModifier abstract final implicit lazy override private protected sealed
syntax keyword scalaInclude export import package
syntax keyword scalaStatement return
syntax keyword scalaKeyword super this
syntax keyword scalaBoolean true false
syntax keyword scalaNull null

# Soft modifiers when they introduce/modifiy a definition.
syntax match scalaModifier "\<\%(infix\|inline\|open\|transparent\)\>\ze\%([[:space:]]\+\%(infix\|inline\|opaque\|open\|transparent\)\>\)*[[:space:]]\+\%(def\|val\|var\|type\|given\|class\|trait\|object\|enum\|case\s\+\%(class\|object\)\)\>"
syntax match scalaTypedef "\<opaque\>\ze\%([[:space:]]\+\%(infix\|inline\|open\|transparent\)\>\)*[[:space:]]\+type\>"
syntax match scalaModifier "^\s*\zs\<inline\>\ze[[:space:]]\+\S"
syntax match scalaDeclaration "\<extension\>\ze[[:space:]]*[[(]"
syntax match scalaStatement "^\s*\zs\<end\>\ze[[:space:]]\+\S\+[[:space:]]*$"
syntax match scalaModifier "[(,]\s*\zs\<using\>"
syntax match scalaTypeKeyword "\<derives\>\ze[[:space:]]\+[A-Za-z_$]"
syntax match scalaException "\<throws\>\ze[[:space:]]\+[A-Za-z_$]"
syntax match scalaInclude "\<as\>" containedin=scalaImportClause
syntax region scalaImportClause start="\<\%(import\|export\)\>" end="$" transparent contains=scalaInclude,scalaBacktickIdentifier,scalaType

# Symbolic regular keywords and context-dependent soft symbols.
syntax match scalaKeywordOperator "=>>\|?=>\|=>\|<-\|<:\|>:"
syntax match scalaKeywordOperator "[#@]"
syntax match scalaAnnotation "@[A-Za-z_$][A-Za-z0-9_$.]*"
syntax match scalaVariance "[+-]\ze\s*[A-Za-z_$][A-Za-z0-9_$]*" containedin=scalaTypeParameters
syntax region scalaTypeParameters start="\[" end="\]" transparent contains=scalaVariance,scalaModifier,scalaAnnotation,scalaType,scalaTypeParameters
syntax match scalaWildcardImport "\.\zs\*"
syntax match scalaVarargSplice "\<[A-Za-z_$][A-Za-z0-9_$]*\zs\*"
syntax match scalaPatternAlternative "\s\zs|\ze\s"

# Quotes and splices used by Scala 3 metaprogramming.
syntax match scalaQuote "'\ze[{[]"
syntax match scalaSplice "\$\ze[{]"

# Define comments after operators and keywords so their opening delimiters win.
syntax match scalaLineComment "//.*$" contains=scalaTodo,@Spell
syntax region scalaBlockComment start="/\*" end="\*/" contains=scalaBlockComment,scalaTodo,@Spell fold
# Keep the opener out of nested matches; leave the third star available to
# close an empty documentation comment (/**/).
syntax region scalaDocComment matchgroup=scalaDocComment start="/\*\ze\*" end="\*/" contains=scalaBlockComment,scalaTodo,@Spell fold

highlight default link scalaType Type
highlight default link scalaTodo Todo
highlight default link scalaLineComment Comment
highlight default link scalaBlockComment Comment
highlight default link scalaDocComment SpecialComment
highlight default link scalaNumber Number
highlight default link scalaEscape SpecialChar
highlight default link scalaChar Character
highlight default link scalaString String
highlight default link scalaTripleString String
highlight default link scalaInterpolatedString String
highlight default link scalaStringPrefix Identifier
highlight default link scalaInterpolationDelimiter Delimiter
highlight default link scalaInterpolation Special
highlight default link scalaBacktickIdentifier Identifier
highlight default link scalaAnnotation PreProc
highlight default link scalaConditional Conditional
highlight default link scalaRepeat Repeat
highlight default link scalaException Exception
highlight default link scalaStructure Structure
highlight default link scalaDeclaration Function
highlight default link scalaTypedef Typedef
highlight default link scalaModifier StorageClass
highlight default link scalaInclude Include
highlight default link scalaStatement Statement
highlight default link scalaTypeKeyword Type
highlight default link scalaKeyword Keyword
highlight default link scalaBoolean Boolean
highlight default link scalaNull Constant
highlight default link scalaKeywordOperator Operator
highlight default link scalaVariance StorageClass
highlight default link scalaWildcardImport Include
highlight default link scalaVarargSplice Special
highlight default link scalaPatternAlternative Conditional
highlight default link scalaOperator Operator
highlight default link scalaQuote Special
highlight default link scalaSplice Special

b:current_syntax = 'scala'
