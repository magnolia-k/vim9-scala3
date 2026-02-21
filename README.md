# vim9-scala3

Scala 3 用の Vim プラグイン。Vim9Script で記述されています。

Scala 3 の Optional Braces（インデントベース構文）と従来の Scala 2 スタイルの両方をサポートします。

## 動作要件

- Vim 9.2 以降

> **Note:** Vim9Script で記述されているため、Neovim では動作しません。

## インストール

### vim-plug

```vim
Plug 'your-name/vim9-scala3'
```

### Vim パッケージ機能

```sh
mkdir -p ~/.vim/pack/plugins/start
cd ~/.vim/pack/plugins/start
git clone https://github.com/your-name/vim9-scala3.git
```

## 機能

### ファイルタイプ検出

| 拡張子 | ファイルタイプ |
|--------|---------------|
| `*.scala` | `scala3` |
| `*.sc` | `scala3`（Scala スクリプト） |
| `*.sbt` | `scala3`（sbt ビルドファイル） |

### シンタックスハイライト

- **ハードキーワード**: `abstract`, `case`, `catch`, `class`, `def`, `do`, `else`, `enum`, `export`, `extends`, `final`, `finally`, `for`, `given`, `if`, `implicit`, `import`, `lazy`, `match`, `new`, `null`, `object`, `override`, `package`, `private`, `protected`, `return`, `sealed`, `super`, `then`, `throw`, `trait`, `true`, `try`, `type`, `val`, `var`, `while`, `with`, `yield`
- **ソフトキーワード**: `as`, `derives`, `end`, `extension`, `infix`, `inline`, `opaque`, `open`, `transparent`, `using`
- **組み込み型**: `Int`, `String`, `Boolean`, `Option`, `List`, `Map`, `Future`, `Either` など
- **リテラル**: 整数（10進/16進/2進）、浮動小数点、文字、文字列（通常/三重引用符/補間 `s""`, `f""`, `raw""`)
- **コメント**: 行コメント `//`、ブロックコメント `/* */`（ネスト対応）、Scaladoc `/** */`
- **アノテーション**: `@annotation`
- **シンボル演算子**: `=>`, `<-`, `<:`, `>:`, `=>>`, `?=>`, `#`

### インデント

Scala 2（中括弧ベース）と Scala 3（Optional Braces）の両方をサポートします。

```scala
// Scala 3 スタイル（Optional Braces）
enum Color:
  case Red, Green, Blue
end Color

// Scala 2 スタイル（中括弧）
class Person(name: String) {
  def greet(): String = s"Hello, $name"
}
```

対応するインデントパターン:

- 開き/閉じ括弧 `{}`, `()`, `[]`
- コロンブロック（Optional Braces）
- `=>`, `<-`, `=` 後の継続
- 制御構文（`if`, `for`, `match`, `try`/`catch`/`finally` など）
- `end` マーカー
- `case` の整列
- メソッドチェーン（`.` で始まる行）

### エディタ設定

| 設定 | 値 |
|------|-----|
| `shiftwidth` | 2 |
| `softtabstop` | 2 |
| `expandtab` | 有効 |
| `commentstring` | `// %s` |

## ライセンス

MIT
