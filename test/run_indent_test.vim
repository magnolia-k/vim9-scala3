vim9script

# Comprehensive indent test for Scala 3 vim plugin
# Tests both Scala 2 (brace) and Scala 3 (optional braces) styles
#
# Strategy:
#   Scala 2 (brace-based):
#     1. Create a "flattened" copy of the scalafmt-verified file (remove leading spaces)
#     2. Open it in Vim with the scala3 indent plugin active
#     3. Run gg=G to re-indent
#     4. Diff against original -> any diff = indent plugin bug
#
#   Scala 3 (Optional Braces):
#     gg=G is NOT valid for Optional Braces because indentation IS the syntax;
#     flattening destroys structural information that cannot be recovered.
#     Instead, we load the correctly-formatted file and for each line:
#       - Mangle that line's indent to a wrong value
#       - Re-indent it with == (uses indentexpr in its proper script context)
#       - Compare result with original
#       - Restore original line (so subsequent lines have correct context)
#     Known limitation: lines following an unbraced method body (implicit dedent)
#     cannot be correctly computed and are marked as SKIP.
#
# Usage:
#   vim -n --clean --cmd "set rtp^=..." --cmd "filetype plugin indent on" \
#       --cmd "syntax on" -S test/run_indent_test.vim

const PLUGIN_DIR = '/Users/magnolia/dev/vim9-scala3'
const TEST_DIR = PLUGIN_DIR .. '/test'

var summary_output: list<string> = []
var all_failures: list<string> = []
var total_pass = 0
var total_fail = 0
var total_skip = 0

# Flatten a file: remove all leading whitespace from each line
def FlattenFile(src: string, dst: string)
  var lines = readfile(src)
  var flat: list<string> = []
  for line in lines
    flat->add(substitute(line, '^\s*', '', ''))
  endfor
  writefile(flat, dst)
enddef

# Run indent test on one file using gg=G (suitable for brace-based Scala 2)
def TestFileFlatten(original: string, label: string)
  var flat = '/tmp/indent_flat_' .. label .. '.scala'
  var result = '/tmp/indent_result_' .. label .. '.scala'

  FlattenFile(original, flat)

  execute 'silent edit! ' .. fnameescape(flat)
  if &filetype !=# 'scala3'
    set filetype=scala3
  endif

  normal! gg=G

  execute 'silent write! ' .. fnameescape(result)

  var orig_lines = readfile(original)
  var result_lines = readfile(result)

  var pass = 0
  var fail = 0
  var file_output: list<string> = ['']
  file_output->add('--- ' .. label .. ' (' .. fnamemodify(original, ':t') .. ') [flatten+gg=G] ---')

  var total_lines = min([len(orig_lines), len(result_lines)])
  for i in range(total_lines)
    var orig_line = orig_lines[i]
    var result_line = result_lines[i]
    var lnum = i + 1

    if orig_line =~ '^\s*$' && result_line =~ '^\s*$'
      continue
    endif

    var orig_indent = len(matchstr(orig_line, '^\s*'))
    var result_indent = len(matchstr(result_line, '^\s*'))
    var content = substitute(orig_line, '^\s*', '', '')[: 50]

    if orig_indent == result_indent
      pass += 1
      file_output->add(printf('  PASS %3d [%2d]  %s', lnum, orig_indent, content))
    else
      fail += 1
      var msg = printf('%s L%3d: expected=%2d computed=%2d  %s',
        label, lnum, orig_indent, result_indent, content)
      file_output->add(printf('  FAIL %3d [want=%2d got=%2d]  %s',
        lnum, orig_indent, result_indent, content))
      all_failures->add(msg)
    endif
  endfor

  file_output->add(printf('  => %s: %d PASS, %d FAIL', label, pass, fail))
  for line in file_output
    summary_output->add(line)
  endfor
  total_pass += pass
  total_fail += fail
enddef

# Run indent test line-by-line using the = operator (suitable for Scala 3 Optional Braces)
#
# For each non-blank line:
#   1. Detect implicit-dedent lines (SKIP - known plugin limitation)
#   2. Mangle the line's leading spaces to force a re-indent
#   3. Run normal! == to re-indent via indentexpr (respects script context)
#   4. Compare computed indent with expected
#   5. Restore original line so subsequent lines keep correct context
#
# Implicit dedent: a line whose indent is less than the previous non-blank line,
# with no explicit closing signal ({}, end, else, catch, etc.).
# These cannot be computed without brace-based syntax.
def TestFileLineByLine(original: string, label: string)
  execute 'silent edit! ' .. fnameescape(original)
  if &filetype !=# 'scala3'
    set filetype=scala3
  endif

  var pass = 0
  var fail = 0
  var skip = 0
  var file_output: list<string> = ['']
  file_output->add('--- ' .. label .. ' (' .. fnamemodify(original, ':t') .. ') [line-by-line ==] ---')

  var total_lines = line('$')

  for lnum in range(1, total_lines)
    var cur_line = getline(lnum)

    if cur_line =~ '^\s*$'
      continue
    endif

    var expected_indent = indent(lnum)
    var content = substitute(cur_line, '^\s*', '', '')[: 50]

    # Line 1: plugin always returns 0
    if lnum == 1
      if expected_indent == 0
        pass += 1
        file_output->add(printf('  PASS %3d [%2d]  %s', lnum, expected_indent, content))
      else
        fail += 1
        var msg = printf('%s L%3d: expected=%2d computed=0  %s', label, lnum, expected_indent, content)
        file_output->add(printf('  FAIL %3d [want=%2d got= 0]  %s', lnum, expected_indent, content))
        all_failures->add(msg)
      endif
      continue
    endif

    # Find previous non-blank, non-comment line (mirrors GetPrevCodeLine logic
    # in the plugin so the implicit-dedent heuristic matches the plugin's view).
    var prev_lnum = prevnonblank(lnum - 1)
    while prev_lnum > 0 && getline(prev_lnum) =~ '^\s*\(//\|/\*\|\*\|$\)'
      prev_lnum = prevnonblank(prev_lnum - 1)
    endwhile

    # Detect implicit dedent (Scala 3 optional-braces limitation):
    # indent decrease with no explicit closing signal on the current line.
    var is_implicit_dedent = false
    if prev_lnum > 0
      var prev_indent = indent(prev_lnum)
      # 'case' keyword: only skip if the previous code line is also a 'case' line.
      # This handles nested match expressions where the outer case follows inner cases
      # (plugin cannot determine correct indent without lookahead).
      # Other 'case' scenarios (enum members after methods, etc.) are plugin-handled.
      # Exception: 'case class' and 'case object' are declarations, not match branches.
      # The plugin should handle them explicitly, so do NOT skip them here.
      if expected_indent < prev_indent
            && cur_line !~ '^\s*[}\])]'
            && cur_line !~ '^\s*\(end\|else\|catch\|finally\|then\|yield\)\>'
            && (cur_line !~ '^\s*case\>' || getline(prev_lnum) =~ '^\s*case\>')
            && cur_line !~ '^\s*case\s\+\(class\|object\)\>'
        is_implicit_dedent = true
      endif
    endif

    if is_implicit_dedent
      skip += 1
      file_output->add(printf('  SKIP %3d [%2d]  %s  (implicit dedent - optional-braces limitation)',
        lnum, expected_indent, content))
      continue
    endif

    # Mangle this line's indent to ensure == actually recomputes it
    setline(lnum, repeat(' ', 99) .. substitute(cur_line, '^\s*', '', ''))

    # Re-indent using the plugin via normal! == (uses indentexpr in its proper context)
    cursor(lnum, 1)
    normal! ==

    var computed_indent = indent(lnum)

    # Restore original line so subsequent lines have correct context
    setline(lnum, cur_line)

    if expected_indent == computed_indent
      pass += 1
      file_output->add(printf('  PASS %3d [%2d]  %s', lnum, expected_indent, content))
    else
      fail += 1
      var msg = printf('%s L%3d: expected=%2d computed=%2d  %s',
        label, lnum, expected_indent, computed_indent, content)
      file_output->add(printf('  FAIL %3d [want=%2d got=%2d]  %s',
        lnum, expected_indent, computed_indent, content))
      all_failures->add(msg)
    endif
  endfor

  file_output->add(printf('  => %s: %d PASS, %d FAIL, %d SKIP (implicit dedent)', label, pass, fail, skip))
  for line in file_output
    summary_output->add(line)
  endfor
  total_pass += pass
  total_fail += fail
  total_skip += skip
enddef

summary_output->add('=== Scala 3 Indent Test ===')

TestFileFlatten(TEST_DIR .. '/scala2_indent.scala', 'Scala2')
TestFileLineByLine(TEST_DIR .. '/scala3_indent.scala', 'Scala3')

summary_output->add('')
summary_output->add('=== Summary ===')
summary_output->add(printf('Total: %d PASS, %d FAIL, %d SKIP (implicit dedent)',
  total_pass, total_fail, total_skip))

if len(all_failures) > 0
  summary_output->add('')
  summary_output->add('=== Failures ===')
  for f in all_failures
    summary_output->add('  ' .. f)
  endfor
endif

writefile(summary_output, '/tmp/indent_test_result.txt')
qall!
