# vim9-scala3 開発ガイド

## プロジェクト概要

Scala 3 用の Vim プラグイン（Vim9Script で実装）

### ファイル構成

```
ftdetect/scala3.vim   - ファイルタイプ検出
syntax/scala3.vim     - シンタックスハイライト
indent/scala3.vim     - インデント
ftplugin/scala3.vim   - ファイルタイプ設定
doc/vim9-scala3.txt   - ヘルプドキュメント
test/                 - テストファイル群（test/README.md 参照）
```

## コーディングルール

- コードは全て **Vim9Script** で書く（Vim 9.2 以降対象）
  - バージョンチェック: `if v:version < 902`
- コードのコメントは**英語**で書く
- ドキュメント（doc/, CLAUDE.md 等）は**日本語**で書く
- 仕様は全て `doc/` ディレクトリにまとめ、コードと必ず一致させる

## テスト

- テストしたファイルに `scalafmt` を実行し、差分が出ないようにする
- テスト手順の詳細は `test/README.md` を参照

## 重要な実装上の決定事項

- **ファイルタイプ名**: `scala3`（`scala` ではない。Vim 組み込みの scala サポートとの衝突を避けるため）
- **ftdetect**: `setfiletype` でなく `set filetype=scala3` を使う（Vim 組み込みの検出を上書きするため）
- **インデント関数名**: `GetScala3Indent()`（組み込みの `GetScalaIndent()` との衝突を避けるため）

## 対応する Scala 構文

- Scala 3 の Optional Brace スタイル（インデントベース）
- 従来の Scala 2 ベースのブレーススタイル

## 参照ドキュメント

- Vim ヘルプ: https://vim-jp.org/vimdoc-ja/
- Scala 3 シンタックス: https://docs.scala-lang.org/scala3/reference/syntax.html
- Optional Brace: https://docs.scala-lang.org/scala3/reference/other-new-features/indentation.html
