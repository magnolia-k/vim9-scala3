vim9script

# Indent rules for Scala 3
# Supports both Scala 2 (brace-based) and Scala 3 (Optional Braces) indentation

if v:version < 902
  finish
endif

if exists('b:did_indent')
  finish
endif
b:did_indent = true

setlocal indentexpr=GetScala3Indent()
setlocal indentkeys=0{,0},0),0],!^F,o,O,e,0=end,0=else,0=catch,0=finally,0=case,0=then,0=yield

setlocal autoindent

if exists('*GetScala3Indent')
  finish
endif

# Pattern for colon-based block start (Scala 3 Optional Braces)
const COLON_BLOCK_PATTERN = '^\s*\(class\|trait\|object\|enum\|def\|val\|var\|given\|extension\|if\|else\|for\|while\|match\|try\|catch\|finally\|then\|new\)\>.*:\s*$'

const MATCH_PATTERN = '\<match\>\s*$'
const CONTINUATION_PATTERN = '^\s*\.'

# Check if a line is inside a comment or string
def IsInSyntaxGroup(lnum: number, col: number): bool
  var synname = synIDattr(synID(lnum, col, true), 'name')
  return synname =~? 'comment\|string\|multiline'
enddef

# Get the previous non-blank, non-comment line
def GetPrevCodeLine(lnum: number): number
  var prev = prevnonblank(lnum - 1)
  while prev > 0 && getline(prev) =~ '^\s*\(//\|/\*\|\*\|$\)'
    prev = prevnonblank(prev - 1)
  endwhile
  return prev
enddef

# Count net bracket balance on a line (positive = more opens)
def BracketBalance(line: string, open: string, close: string): number
  var count = 0
  for ch in split(line, '\zs')
    if ch == open
      count += 1
    elseif ch == close
      count -= 1
    endif
  endfor
  return count
enddef

def GetScala3Indent(): number
  var lnum = v:lnum
  var line = getline(lnum)
  var prev_lnum = GetPrevCodeLine(lnum)

  # First line
  if prev_lnum == 0
    return 0
  endif

  var prev_line = getline(prev_lnum)
  var prev_indent = indent(prev_lnum)
  var sw = shiftwidth()
  var ind = prev_indent

  # Skip if current position is inside a multiline comment or string
  if lnum > 1 && IsInSyntaxGroup(lnum, 1) && line !~ '^\s*\(/\|\*\)'
    return ind
  endif

  # Strip trailing comments from previous line for analysis
  var prev_code = substitute(prev_line, '//.*$', '', '')
  var prev_trimmed = substitute(prev_code, '\s*$', '', '')

  # ---- Indent increase rules ----

  var increased = false

  # Increase indent after unmatched opening brackets
  var brace_bal = BracketBalance(prev_code, '{', '}')
  var paren_bal = BracketBalance(prev_code, '(', ')')
  var bracket_bal = BracketBalance(prev_code, '[', ']')

  if brace_bal > 0 || paren_bal > 0 || bracket_bal > 0
    ind += sw
    increased = true
  endif

  if !increased
    # Increase indent after =>, <-, = at end of line
    if prev_trimmed =~ '=>\s*$' || prev_trimmed =~ '<-\s*$' || prev_trimmed =~ '=\s*$'
      ind += sw
      increased = true
    endif
  endif

  if !increased
    # Scala 3 colon-based block start (Optional Braces)
    if prev_trimmed =~ COLON_BLOCK_PATTERN
      ind += sw
      increased = true
    endif
  endif

  if !increased
    # Control flow keywords alone on a line start a block
    if prev_trimmed =~ '^\s*\(if\|else\|for\|while\|do\|then\|yield\|return\|throw\)\s*$'
      ind += sw
      increased = true
    endif
  endif

  if !increased
    # match keyword at end of line
    if prev_trimmed =~ MATCH_PATTERN
      ind += sw
      increased = true
    endif
  endif

  if !increased
    # try/catch/finally alone on a line
    if prev_trimmed =~ '^\s*\(try\|catch\|finally\)\s*$'
      ind += sw
      increased = true
    endif
  endif

  # ---- Indent decrease rules ----

  # Decrease indent for closing brackets on current line
  var cur_brace_bal = BracketBalance(line, '{', '}')
  var cur_paren_bal = BracketBalance(line, '(', ')')
  var cur_bracket_bal = BracketBalance(line, '[', ']')

  if cur_brace_bal < 0
    ind += cur_brace_bal * sw
  endif
  if cur_paren_bal < 0
    ind += cur_paren_bal * sw
  endif
  if cur_bracket_bal < 0
    ind += cur_bracket_bal * sw
  endif

  # 'end' keyword decreases indent
  if line =~ '^\s*end\>'
    ind -= sw
  endif

  # 'else' aligns with 'if'
  if line =~ '^\s*else\>'
    if prev_line !~ '^\s*\(if\|else\s\+if\)\>' && prev_line !~ '{\s*$'
      ind -= sw
    endif
  endif

  # 'catch' / 'finally' align with 'try'
  if line =~ '^\s*\(catch\|finally\)\>'
    if prev_line !~ '^\s*\(try\|catch\)\>' && prev_line !~ '{\s*$'
      ind -= sw
    endif
  endif

  # 'case' inside match block - align with prior cases
  if line =~ '^\s*case\>' && prev_line !~ MATCH_PATTERN
    var check_lnum = prev_lnum
    while check_lnum > 0
      var check_line = getline(check_lnum)
      if check_line =~ '^\s*case\>'
        ind = indent(check_lnum)
        break
      elseif check_line =~ MATCH_PATTERN
        ind = indent(check_lnum) + sw
        break
      elseif indent(check_lnum) <= 0 && check_line !~ '^\s*$'
        break
      endif
      check_lnum -= 1
    endwhile
  endif

  # 'then' keyword (Scala 3) aligns with 'if'
  if line =~ '^\s*then\>'
    var check_lnum = prev_lnum
    while check_lnum > 0
      if getline(check_lnum) =~ '^\s*if\>'
        ind = indent(check_lnum)
        break
      endif
      check_lnum -= 1
    endwhile
  endif

  # ---- Continuation lines ----

  # Method chain continuation: indent when starting a chain
  if line =~ CONTINUATION_PATTERN && prev_line !~ CONTINUATION_PATTERN
    ind += sw
  elseif line !~ CONTINUATION_PATTERN && prev_line =~ CONTINUATION_PATTERN
    # End of method chain - find the line before chain started
    var check_lnum = prev_lnum
    while check_lnum > 0 && getline(check_lnum) =~ CONTINUATION_PATTERN
      check_lnum -= 1
    endwhile
    if check_lnum > 0
      ind = indent(check_lnum)
    endif
  endif

  # Never return negative indent
  return ind < 0 ? 0 : ind
enddef
