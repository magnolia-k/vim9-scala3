# vim9-scala3

A clean-room Vim9 plugin for the stable Scala 3.9 syntax. It provides
filetype detection, syntax highlighting, and deliberately conservative support
for Scala 3 significant indentation. No source from existing Scala Vim plugins
is used.

## Requirements

- Vim 9.1 or newer
- Scala 3.9 only when validating the compiler fixture; normal use and the Vim
  test suite do not require a Scala installation

The plugin recognizes `.scala`, `.sc`, and `.sbt` files as the `scala`
filetype.

Pressing Enter in Insert mode or `o` on a comment line continues `//` and
block-comment leaders using Vim's standard comment handling.

## Installation

Install the repository with a Vim package manager, or clone it below a native
package directory such as:

```text
~/.vim/pack/plugins/start/vim9-scala3
```

Enable Vim's standard filetype and syntax support if your vimrc does not do so:

```vim
filetype plugin indent on
syntax enable
```

## Type highlighting

Identifiers beginning with an ASCII capital letter, such as `Int`, `String`,
`User`, and `A` in `List[A]`, use the `scalaType` group (linked to `Type`).
This naming-based rule also colors capitalized objects and values; lowercase
and backtick-quoted type names are not recognized as types.

## Indentation policy

The indenter adds one `shiftwidth()` only when the Scala grammar makes a deeper
next line necessary. If a line is already deeper, that user-selected
indentation is retained. Layout choices that are legal at more than one depth
are left unchanged. This includes delimiter blocks, leading operators,
continuation lines, unindented `case` clauses after `match` or `catch`, and bare
`return`.

An `else`, `catch`, `finally`, `yield`, or `end` line is moved left only when
its owner can be identified unambiguously. The plugin never changes
`shiftwidth`, `tabstop`, or `expandtab`.

## Development

Run the self-contained Vim suite and whitespace checks with:

```sh
make check
```

With Scala 3.9's `scalac` installed, validate the compiler fixture with:

```sh
make test-scala
```

The implementation follows the official
[Scala 3.9 syntax summary](https://docs.scala-lang.org/scala3/reference/syntax.html),
[soft-keyword rules](https://docs.scala-lang.org/scala3/reference/soft-modifier.html),
and [optional-braces rules](https://docs.scala-lang.org/scala3/reference/other-new-features/indentation.html).

## License

MIT. See [LICENSE](LICENSE).
