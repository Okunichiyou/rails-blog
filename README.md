# README

## セットアップ

### 1. 依存関係のインストール

```bash
bundle install
```

### 2. 設定ファイルのコピー

```bash
cp -n config/samples/*.yml config/
```

その後、各設定ファイルを編集して自分の認証情報を設定してください。

- `config/google_auth.yml`

### 3. データベースのセットアップ

```bash
bundle exec rails db:prepare
```

### 4. サーバーの起動

```bash
# Tailwind CSSの変更をサーバー再起動なしで反映させる
bin/dev
```

```bash
# Railsサーバーを立ち上げる
bundle exec rails server
```
