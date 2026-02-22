vim9script

# Syntax highlighting for Scala 3
# Supports both Scala 2 and Scala 3 syntax including Optional Braces

if v:version < 902
  finish
endif

if exists('b:current_syntax')
  finish
endif

# Sync from start for accurate highlighting of multiline constructs
syntax sync fromstart

# ============================================================================
# Comments
# ============================================================================

# Line comments
syntax match scalaLineComment "//.*$" contains=scalaTodo,@Spell

# Block comments (nestable)
syntax region scalaBlockComment start="/\*" end="\*/" contains=scalaBlockComment,scalaTodo,@Spell

# Scaladoc comments
syntax region scalaDocComment start="/\*\*" end="\*/" contains=scalaDocComment,scalaDocTag,scalaTodo,@Spell

# Scaladoc tags
syntax match scalaDocTag "@\(param\|return\|throws\|tparam\|see\|note\|example\|constructor\|since\|version\|author\|deprecated\|todo\|inheritdoc\)\>" contained

# TODO/FIXME/XXX in comments
syntax keyword scalaTodo TODO FIXME XXX NOTE HACK contained

# ============================================================================
# String literals
# ============================================================================

# Character literal
syntax match scalaCharacter "'[^'\\]'"
syntax match scalaCharacter "'\\[btnfr\"'\\]'"
syntax match scalaCharacter "'\\u[0-9a-fA-F]\{4}'"

# Single-line string
syntax region scalaString start='"' skip='\\"' end='"' contains=scalaStringEscape,@Spell

# String escape sequences
syntax match scalaStringEscape '\\[btnfr"\\]' contained
syntax match scalaStringEscape '\\u[0-9a-fA-F]\{4}' contained

# Triple-quoted string (multi-line raw string)
syntax region scalaMultilineString start='"""' end='"""' contains=@Spell

# Interpolated strings: s"...", f"...", raw"..."
syntax region scalaInterpolString start='\<s"' skip='\\"' end='"' contains=scalaInterpolExpr,scalaInterpolVar,scalaStringEscape,@Spell
syntax region scalaInterpolString start='\<f"' skip='\\"' end='"' contains=scalaInterpolExpr,scalaInterpolVar,scalaStringEscape,scalaFormatSpecifier,@Spell
syntax region scalaInterpolString start='\<raw"' skip='\\"' end='"' contains=scalaInterpolExpr,scalaInterpolVar,@Spell

# Interpolated multi-line strings
syntax region scalaInterpolMultiString start='\<s"""' end='"""' contains=scalaInterpolExpr,scalaInterpolVar,@Spell
syntax region scalaInterpolMultiString start='\<f"""' end='"""' contains=scalaInterpolExpr,scalaInterpolVar,scalaFormatSpecifier,@Spell
syntax region scalaInterpolMultiString start='\<raw"""' end='"""' contains=scalaInterpolExpr,scalaInterpolVar,@Spell

# Interpolation expressions: ${...}
syntax region scalaInterpolExpr matchgroup=scalaInterpolDelim start='\${'  end='}' contained contains=TOP

# Interpolation variable: $identifier
syntax match scalaInterpolVar '\$[a-zA-Z_][a-zA-Z0-9_]*' contained

# Format specifier in f-strings
syntax match scalaFormatSpecifier '%[#0\- +]*\(\*\|\d\+\)\?\(\.\(\*\|\d\+\)\)\?[diouxXeEfgGaAcspn%]' contained

# ============================================================================
# Numeric literals
# ============================================================================

# Integer literals
syntax match scalaNumber '\<\d[0-9_]*[lL]\?\>'
syntax match scalaNumber '\<0[xX][0-9a-fA-F_]\+[lL]\?\>'
syntax match scalaNumber '\<0[bB][01_]\+[lL]\?\>'

# Floating-point literals
syntax match scalaFloat '\<\d[0-9_]*\.\d[0-9_]*\([eE][+-]\?\d[0-9_]*\)\?[fFdD]\?\>'
syntax match scalaFloat '\<\d[0-9_]*[eE][+-]\?\d[0-9_]*[fFdD]\?\>'
syntax match scalaFloat '\<\d[0-9_]*[fFdD]\>'

# ============================================================================
# Keywords
# ============================================================================

# Hard keywords
syntax keyword scalaKeyword abstract case catch class def do else extends
syntax keyword scalaKeyword final finally for if implicit import lazy match
syntax keyword scalaKeyword new object override package private protected return
syntax keyword scalaKeyword sealed super throw trait try type val var while
syntax keyword scalaKeyword with yield
syntax keyword scalaKeyword enum export given then

# Soft keywords (Scala 3)
syntax keyword scalaSoftKeyword as derives end extension infix inline opaque
syntax keyword scalaSoftKeyword open transparent using

# Boolean literals
syntax keyword scalaBoolean true false

# Null literal
syntax keyword scalaNull null

# Special identifiers
syntax keyword scalaSpecial this
syntax match scalaSpecial '\<self\>\ze\s*=>'

# ============================================================================
# Types
# ============================================================================

# Built-in types
syntax keyword scalaType Int String Boolean Double Float Long Short Byte
syntax keyword scalaType Char Unit Nothing Null Any AnyRef AnyVal BigInt BigDecimal

# Common collection and effect types
syntax keyword scalaType Option Some None List Map Set Seq Vector
syntax keyword scalaType Either Left Right Future Try Success Failure Tuple
syntax keyword scalaType Array ArrayBuffer ListBuffer Iterator
syntax keyword scalaType LazyList Stream Range

# User-defined type names (capitalized identifiers)
syntax match scalaTypeRef '\<[A-Z][a-zA-Z0-9_]*\>' contained

# ============================================================================
# Annotations
# ============================================================================

syntax match scalaAnnotation '@[a-zA-Z_][a-zA-Z0-9_.]*'

# ============================================================================
# Unimplemented placeholder
# ============================================================================

# ??? is Scala's standard "not implemented" expression (throws NotImplementedError)
syntax match scalaUnimplemented '???'

# ============================================================================
# Symbol operators
# ============================================================================

syntax match scalaOperator '=>'
syntax match scalaOperator '<-'
syntax match scalaOperator '<:'
syntax match scalaOperator '>:'
syntax match scalaOperator '=>>'
syntax match scalaOperator '?=>'
syntax match scalaOperator '#'
syntax match scalaOperator '\<_\>'

# ============================================================================
# Highlight links
# ============================================================================

highlight default link scalaKeyword        Keyword
highlight default link scalaSoftKeyword    Keyword
highlight default link scalaBoolean        Boolean
highlight default link scalaNull           Constant
highlight default link scalaSpecial        Special
highlight default link scalaType           Type
highlight default link scalaTypeRef        Type
highlight default link scalaAnnotation     PreProc
highlight default link scalaOperator       Operator

highlight default link scalaString         String
highlight default link scalaMultilineString String
highlight default link scalaInterpolString String
highlight default link scalaInterpolMultiString String
highlight default link scalaInterpolExpr   Special
highlight default link scalaInterpolDelim  Delimiter
highlight default link scalaInterpolVar    Special
highlight default link scalaFormatSpecifier Special
highlight default link scalaStringEscape   SpecialChar
highlight default link scalaCharacter      Character

highlight default link scalaNumber         Number
highlight default link scalaFloat          Float

highlight default link scalaLineComment    Comment
highlight default link scalaBlockComment   Comment
highlight default link scalaDocComment     Comment
highlight default link scalaDocTag         SpecialComment
highlight default link scalaTodo           Todo

# ??? is highlighted prominently as unimplemented code
highlight default scalaUnimplemented cterm=bold,underline ctermfg=9 gui=bold,underline guifg=#FF4500

b:current_syntax = 'scala3'
