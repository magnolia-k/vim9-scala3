# テスト手順

## テストファイル

| ファイル | 内容 |
|----------|------|
| `sample.scala` | シンタックス・設定・インデントのテスト用サンプル |
| `scala3_indent.scala` | Scala 3 スタイル（Optional Brace）のインデントテスト |
| `scala2_indent.scala` | Scala 2 スタイル（ブレース）のインデントテスト |
| `run_test.vim` | シンタックス・設定のテストスクリプト |
| `run_indent_test.vim` | インデントのテストスクリプト |

## テストの実行方法

```sh
# シンタックス・設定テスト
vim -n --clean --cmd "set rtp^=/path/to/vim9-scala3" \
    -c "edit test/sample.scala" \
    -c "source test/run_test.vim"
cat /tmp/vim9-scala3-test.txt

# インデントテスト
vim -n --clean --cmd "set rtp^=/path/to/vim9-scala3" \
    -c "edit test/scala3_indent.scala" \
    -c "source test/run_indent_test.vim"
cat /tmp/vim9-scala3-indent-test.txt
```

## 注意事項

- `-n` フラグを付けてスワップファイルを無効にする
- `rtp^=` でプラグインのパスをランタイムパスの先頭に追加する
- `-c` オプションはコマンド数の上限（約10個）があるため、複雑なテストはスクリプトファイルに書いて `source` する
- テスト内で `syntax list` を使うとページャが起動するため、シンタックスの確認には `synID()` を使う
