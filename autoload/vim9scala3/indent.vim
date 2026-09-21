vim9script

# A deliberately conservative Scala 3 indenter.  It recognizes lexical
# boundaries itself so that indentation never depends on :syntax being on.

type LexState = dict<any>

def BlankState(): LexState
  return {mode: 'code', blockDepth: 0}
enddef

def MaskLine(text: string, state: LexState): list<any>
  var out = repeat([' '], strchars(text))
  var chars = text->split('\zs')
  var i = 0

  while i < len(chars)
    if state.mode ==# 'block'
      if i + 1 < len(chars) && chars[i] ==# '/' && chars[i + 1] ==# '*'
        state.blockDepth += 1
        i += 2
      elseif i + 1 < len(chars) && chars[i] ==# '*' && chars[i + 1] ==# '/'
        state.blockDepth -= 1
        i += 2
        if state.blockDepth == 0
          state.mode = 'code'
        endif
      else
        i += 1
      endif
      continue
    elseif state.mode ==# 'triple'
      if i + 2 < len(chars) && join(chars[i : i + 2], '') ==# '"""'
        state.mode = 'code'
        i += 3
      else
        i += 1
      endif
      continue
    endif

    if i + 1 < len(chars) && chars[i] ==# '/' && chars[i + 1] ==# '/'
      break
    elseif i + 1 < len(chars) && chars[i] ==# '/' && chars[i + 1] ==# '*'
      state.mode = 'block'
      state.blockDepth = 1
      i += 2
    elseif i + 2 < len(chars) && join(chars[i : i + 2], '') ==# '"""'
      out[i] = 'X'
      state.mode = 'triple'
      i += 3
    elseif chars[i] ==# '"' || chars[i] ==# "'" || chars[i] ==# '`'
      var quote = chars[i]
      out[i] = 'X'
      i += 1
      while i < len(chars)
        if chars[i] ==# '\\'
          i += 2
        elseif chars[i] ==# quote
          i += 1
          break
        else
          i += 1
        endif
      endwhile
    else
      out[i] = chars[i]
      i += 1
    endif
  endwhile
  return [join(out, ''), state]
enddef

def CodeThrough(last: number): list<string>
  var raw = getline(1, last)
  var cached: dict<any> = get(b:, 'vim9_scala3_lex_cache', {
    raw: [], code: [], states: []})
  var prefix = 0
  while prefix < len(raw) && prefix < len(cached.raw)
      && raw[prefix] ==# cached.raw[prefix]
    prefix += 1
  endwhile

  var result: list<string> = prefix == 0 ? [] : cached.code[0 : prefix - 1]
  var states: list<LexState> = prefix == 0 ? [] : cached.states[0 : prefix - 1]
  var state = prefix == 0 ? BlankState() : deepcopy(states[-1])
  if prefix < last
    for lnum in range(prefix + 1, last)
      var masked = MaskLine(getline(lnum), state)
      result->add(masked[0])
      state = masked[1]
      states->add(deepcopy(state))
    endfor
  endif
  b:vim9_scala3_lex_cache = {raw: raw, code: result, states: states}
  return result
enddef

def PreviousCode(lines: list<string>, before: number): number
  var lnum = before
  while lnum >= 1
    if lines[lnum - 1] =~# '\S'
      return lnum
    endif
    lnum -= 1
  endwhile
  return 0
enddef

def IsRegionStart(code: string): bool
  var s = trim(code)
  if s ==# ''
    return false
  endif

  # A colon at EOL is either a template/argument colon in valid Scala 3 or an
  # incomplete type ascription.  Only the valid case can produce a source line
  # needing indentation, so it is safe to supply the minimum indentation.
  if s =~# ':$'
    return true
  endif

  if s =~# '\%(^\|\s\)extension\>.*[)\]]$'
      || s =~# '\%(^\|\s\)given\>.*\<with$'
    return true
  endif

  if s =~# '\%(=>\|?=>\|<-\|=\)$'
    return true
  endif

  if s =~# '\<\%(then\|do\|else\|finally\|for\|if\|throw\|try\|while\|yield\)$'
    return true
  endif

  # Old control syntax without braces still requires a body/enumerator line.
  if s =~# '^\s*\%(if\|while\)\s*(.*)\s*$'
      || s =~# '^\s*for\s*[({].*[)}]\s*$'
    return true
  endif
  return false
enddef

def FindBranchOwner(lines: list<string>, lnum: number, kind: string): number
  var pattern = kind ==# 'if' ? '\<if\>.*\<then\>'
    : kind ==# 'try' ? '\<try\>' : '\<for\>'
  var candidates: list<number> = []
  var current = indent(lnum)
  for n in reverse(range(1, lnum - 1))
    if lines[n - 1] =~# pattern && indent(n) < current
      candidates->add(n)
      # A second candidate at the same indentation makes ownership ambiguous.
      if len(candidates) > 1 && indent(candidates[0]) == indent(n)
        return -1
      endif
      return indent(n)
    endif
  endfor
  return -1
enddef

def CertainOutdent(lines: list<string>, lnum: number): number
  var target = trim(lines[lnum - 1])
  if target =~# '^else\>'
    return FindBranchOwner(lines, lnum, 'if')
  elseif target =~# '^\%(catch\|finally\)\>'
    return FindBranchOwner(lines, lnum, 'try')
  elseif target =~# '^yield\>'
    return FindBranchOwner(lines, lnum, 'for')
  elseif target =~# '^end\s\+\S\+\s*$'
    var tag = matchstr(target, '^end\s\+\zs\S\+')
    var pattern = tag =~# '^\%(if\|while\|for\|match\|try\)$'
      ? '\<' .. tag .. '\>'
      : '\<\%(class\|trait\|object\|enum\|def\|val\|var\|package\|given\|extension\|new\)\>.*\<' .. escape(tag, '\') .. '\>'
    for n in reverse(range(1, lnum - 1))
      if lines[n - 1] =~# pattern && indent(n) < indent(lnum)
        return indent(n)
      endif
    endfor
  endif
  return -1
enddef

export def Expr(): number
  if v:lnum <= 1
    return -1
  endif

  var code = CodeThrough(v:lnum)
  var outdent = CertainOutdent(code, v:lnum)
  if outdent >= 0
    return outdent
  endif

  var prev = PreviousCode(code, v:lnum - 1)
  if prev == 0
    return -1
  endif

  var previous = trim(code[prev - 1])
  var target = trim(code[v:lnum - 1])

  # Scala explicitly permits case clauses following match/catch at the same
  # indentation as the introducer.  Bare return is also complete by itself.
  if target =~# '^case\>' && previous =~# '\<\%(match\|catch\)$'
    return -1
  endif
  if previous =~# '\<\%(match\|catch\|return\)$'
    return -1
  endif

  if IsRegionStart(previous)
    return max([indent(v:lnum), indent(prev) + shiftwidth()])
  endif
  return -1
enddef
