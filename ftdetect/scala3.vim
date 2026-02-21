vim9script

# Filetype detection for Scala 3
# Supports: *.scala, *.sc (Scala script), *.sbt (sbt build file)
# Uses "set filetype" instead of "setfiletype" to override built-in scala detection

if v:version < 902
  finish
endif

autocmd BufNewFile,BufRead *.scala set filetype=scala3
autocmd BufNewFile,BufRead *.sc    set filetype=scala3
autocmd BufNewFile,BufRead *.sbt   set filetype=scala3
