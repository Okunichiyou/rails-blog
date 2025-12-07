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

## 開発Tips

### コンポーネントのデザイン確認

`http://localhost:3000/rails/view_components/page/sample_component/default`にアクセスすると、コンポーネントの一覧が確認できます。

### テストの実行

```shell
bundle exec rails test
```

### リンターの実行

```shell
bundle exec rubocop
```

### データの初期化

テーブルを作り直して、シードを再実行します。

```shell
bundle exec rails db:reset
```

このコマンドでは以下の処理が走ります。

1. テーブルのドロップ
2. テーブルの作成
    - schema.rbをロードしてテーブルを作成するため、マイグレーションは走りません
    - データの初期化後にマイグレーションを実行したい場合は、`bundle exec rails db:reset`をした後に`bundle exec rails db:seed`でデータを作成することを推奨します

3. シードの実行

### 型チェック

このプロジェクトでは、Steepとrbs-inlineを使用して型チェックを行っています。

#### 型定義の生成

テストを実行すると、rbs-inlineで記載された型定義が自動的に生成されます。

```shell
bundle exec rails test
```

型定義が不十分な場合は、以下のいずれかの方法で対応してください:

- コード内のrbs-inlineコメントを修正する
- `sig/manual/`配下に手動で型定義ファイルを作成する

#### 型ファイルのセットアップ

型定義ファイルを生成するには、以下のコマンドを実行します:

```shell
bundle exec rake rbs:setup
```

型定義は以下の優先順位で適用されます:

1. **manual**: `sig/manual/`配下の手動で記載した型定義
2. **generated**: rbs-inlineで生成された型定義
3. **rbs_rails**: Rails用の自動生成された型定義
4. **prototype**: 全てがuntypedな型定義の雛形

#### 型チェックの実行

型チェックを実行するには、以下のコマンドを実行します:

```shell
bundle exec steep check
```

現在、型チェックは以下のディレクトリ配下のみを対象としています:

- `app/models/`
- `app/forms/`
- `app/components/`

#### VSCodeでの型チェック

VSCodeで[Steep for VS Code](https://marketplace.visualstudio.com/items?itemName=soutaro.steep-vscode)拡張機能をインストールすると、エディタ上でリアルタイムに型チェックが行われます。

型検査が有効なディレクトリ（models, forms, components）内では、以下の機能が利用できます:

- コード補完（インテリセンス）
- 型エラーの即座な表示
- ホバーによる型情報の確認
