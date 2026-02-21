vim9script

var output: list<string> = []
var failures: list<string> = []

output->add('=== Filetype & Settings ===')
output->add('filetype=' .. &filetype)
output->add('syntax=' .. (exists('b:current_syntax') ? b:current_syntax : '(not set)'))
output->add('indentexpr=' .. &indentexpr)
output->add('shiftwidth=' .. string(&shiftwidth))
output->add('expandtab=' .. string(&expandtab))
output->add('commentstring=' .. &commentstring)

# ---- Settings checks ----
var settings_ok = 0
var settings_fail = 0

def CheckSetting(name: string, actual: string, expected: string)
  if actual == expected
    settings_ok += 1
  else
    settings_fail += 1
    failures->add(printf('SETTING: %s expected=%s actual=%s', name, expected, actual))
  endif
enddef

CheckSetting('filetype', &filetype, 'scala3')
CheckSetting('syntax', exists('b:current_syntax') ? b:current_syntax : '', 'scala3')
CheckSetting('indentexpr', &indentexpr, 'GetScala3Indent()')
CheckSetting('shiftwidth', string(&shiftwidth), '2')
CheckSetting('expandtab', string(&expandtab), 'true')
CheckSetting('commentstring', &commentstring, '// %s')
CheckSetting('softtabstop', string(&softtabstop), '2')
CheckSetting('suffixesadd', &suffixesadd, '.scala')

output->add('')
output->add('=== Syntax Highlight Test ===')

# Test syntax at specific positions [line, col, expected_syngroup, description]
var syn_tests = [
  # Keywords
  [1, 1, 'scalaKeyword', 'package'],
  [3, 1, 'scalaKeyword', 'import'],
  [7, 1, 'scalaKeyword', 'enum'],
  [8, 3, 'scalaKeyword', 'case'],
  [10, 1, 'scalaKeyword', 'enum'],
  [15, 3, 'scalaKeyword', 'def'],
  [24, 1, 'scalaKeyword', 'given'],
  [33, 1, 'scalaKeyword', 'trait'],
  [37, 1, 'scalaKeyword', 'class'],
  [38, 3, 'scalaKeyword', 'override'],
  [42, 3, 'scalaKeyword', 'def'],
  [47, 6, 'scalaKeyword', 'class (after case)'],
  [49, 5, 'scalaKeyword', 'val'],
  [62, 3, 'scalaKeyword', 'def'],
  [63, 5, 'scalaKeyword', 'case (in match)'],
  [75, 5, 'scalaKeyword', 'for'],
  [79, 5, 'scalaKeyword', 'yield'],
  [83, 5, 'scalaKeyword', 'try'],
  [85, 5, 'scalaKeyword', 'catch'],
  [87, 5, 'scalaKeyword', 'finally'],
  [121, 5, 'scalaKeyword', 'val (after doc comment)'],
  [127, 1, 'scalaKeyword', 'type'],
  [130, 1, 'scalaKeyword', 'val (numeric)'],
  # Soft keywords
  [16, 1, 'scalaSoftKeyword', 'end'],
  [19, 1, 'scalaSoftKeyword', 'opaque'],
  [20, 1, 'scalaKeyword', 'object'],
  [28, 1, 'scalaSoftKeyword', 'extension'],
  [52, 3, 'scalaSoftKeyword', 'end (method)'],
  [53, 1, 'scalaSoftKeyword', 'end (class)'],
  [58, 3, 'scalaSoftKeyword', 'inline'],
  [123, 3, 'scalaSoftKeyword', 'end run'],
  [124, 1, 'scalaSoftKeyword', 'end Main'],
  # Booleans
  [65, 33, 'scalaString', '"a boolean" (string)'],
  # Types
  [4, 22, 'scalaType', 'Success'],
  [84, 7, 'scalaType', 'Some'],
  # Comments
  [6, 1, 'scalaLineComment', '// line comment'],
  [111, 5, 'scalaBlockComment', '/* block comment'],
  [113, 6, 'scalaBlockComment', 'nested comment'],
  [116, 5, 'scalaDocComment', '/** scaladoc'],
  [118, 8, 'scalaDocComment', '@param (inside doc)'],
  # Strings
  [43, 5, 'scalaInterpolString', 's"..." interpolated'],
  [141, 17, 'scalaMultilineString', 'triple-quoted start'],
  [142, 3, 'scalaMultilineString', 'triple-quoted body'],
  # Annotation
  [102, 3, 'scalaAnnotation', '@main'],
  # Numbers
  [130, 15, 'scalaNumber', '1_000_000 decimal'],
  [131, 11, 'scalaNumber', '0xFF_FF hex'],
  [132, 14, 'scalaNumber', '0b1010 binary'],
  [133, 15, 'scalaNumber', '42L long'],
  [134, 16, 'scalaFloat', '3.14f float'],
  [135, 17, 'scalaFloat', '2.718e10 sci'],
  # Characters
  [136, 15, 'scalaCharacter', "char 'A'"],
  [137, 19, 'scalaCharacter', "escape '\\n'"],
  [138, 18, 'scalaCharacter', "unicode '\\u0041'"],
]

var syn_ok = 0
var syn_miss = 0
var syn_wrong = 0

for [lnum, col, expected, desc] in syn_tests
  var synname = synIDattr(synID(lnum, col, true), 'name')
  var status: string
  if synname == expected
    status = 'OK'
    syn_ok += 1
  elseif synname == ''
    status = 'MISS'
    syn_miss += 1
    failures->add(printf('SYNTAX MISS: Line %d Col %d: %s (expected %s)', lnum, col, desc, expected))
  else
    status = 'WRONG'
    syn_wrong += 1
    failures->add(printf('SYNTAX WRONG: Line %d Col %d: %s (expected %s, got %s)', lnum, col, desc, expected, synname))
  endif
  output->add(printf('  %3d:%2d %-25s expected=%-22s actual=%-22s %s', lnum, col, desc, expected, synname, status))
endfor

output->add('')
output->add('=== Indent Test (file indentation verification) ===')

# Verify existing indentation matches expectations
var indent_checks = [
  [1, 0, 'package (top)'],
  [7, 0, 'enum Color: (top)'],
  [8, 2, 'case inside enum:'],
  [15, 2, 'def inside enum'],
  [16, 0, 'end Planet'],
  [19, 0, 'opaque type (top)'],
  [21, 2, 'def inside object:'],
  [25, 2, 'def inside given'],
  [29, 2, 'def inside extension'],
  [34, 2, 'def inside trait:'],
  [38, 2, 'override inside class{'],
  [43, 4, 's"" inside def ='],
  [49, 4, 'val inside def ='],
  [52, 2, 'end inside class:'],
  [58, 2, 'inline def inside object:'],
  [59, 4, 'println inside def ='],
  [63, 4, 'case inside match'],
  [76, 6, 'x <- inside for'],
  [79, 4, 'yield (same as for)'],
  [83, 4, 'try inside def ='],
  [84, 6, 'Some inside try'],
  [85, 4, 'catch (same as try)'],
  [86, 6, 'case inside catch'],
  [87, 4, 'finally (same as try)'],
  [96, 4, 'input (chain start)'],
  [97, 6, '.filter (chain)'],
  [104, 4, 'val inside def ='],
  [123, 2, 'end run'],
  [124, 0, 'end Main'],
]

var ind_pass = 0
var ind_fail = 0

for [lnum, expected, desc] in indent_checks
  var actual = indent(lnum)
  if actual == expected
    ind_pass += 1
    output->add(printf('  %3d: indent=%2d  PASS  %s', lnum, actual, desc))
  else
    ind_fail += 1
    output->add(printf('  %3d: indent=%2d (expected %2d)  FAIL  %s', lnum, actual, expected, desc))
    failures->add(printf('INDENT: Line %d: %s (expected %d, got %d)', lnum, desc, expected, actual))
  endif
endfor

output->add('')
output->add('=== Summary ===')
output->add(printf('Settings: %d OK, %d FAIL', settings_ok, settings_fail))
output->add(printf('Syntax:   %d OK, %d MISS, %d WRONG (of %d)', syn_ok, syn_miss, syn_wrong, len(syn_tests)))
output->add(printf('Indent:   %d PASS, %d FAIL (of %d)', ind_pass, ind_fail, len(indent_checks)))

if len(failures) > 0
  output->add('')
  output->add('=== Failures ===')
  for f in failures
    output->add('  ' .. f)
  endfor
endif

writefile(output, '/tmp/vim9-scala3-test.txt')
qa!
