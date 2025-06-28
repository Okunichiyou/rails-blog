# メール認証

- メールアドレスとパスワードを登録して認証する
- メールアドレスの存在確認用のメールを送信して、認証用URLにアクセスされたら初めてユーザーを登録出来るようになる

## ER図

- user_registrations
  - 認証が完了したらすぐに破棄するのでusersテーブルとは紐付けない
  - unconfirmed_emailはメールの認証がされると、deviseの処理の中でnilとして保存され直すのでnullableになっている
- ユーザーは複数の認証手段を用意する想定なので、database_authenticationとusersテーブルは分離している

```mermaid
  erDiagram
      users {
          INTEGER id PK
          STRING name UK "NOT NULL"
          DATETIME created_at "NOT NULL"
          DATETIME updated_at "NOT NULL"
      }

      user_database_authentications {
          INTEGER id PK
          INTEGER user_id FK "NOT NULL"
          STRING email UK "NOT NULL"
          STRING encrypted_password "NOT NULL"
          DATETIME created_at "NOT NULL"
          DATETIME updated_at "NOT NULL"
      }

      user_registrations {
          INTEGER id PK
          STRING confirmation_token UK "NOT NULL"
          DATETIME confirmed_at
          DATETIME confirmation_sent_at
          STRING unconfirmed_email UK
          STRING email
          DATETIME created_at "NOT NULL"
          DATETIME updated_at "NOT NULL"
      }

      users ||--|| user_database_authentications : "has"
```


## シーケンス図

### Sign Up (新規登録)
- 「メール送信機構」はActionMailerやSMTPサーバーなどメール送信に関わるもの
  - フローに含めると煩雑になるのでひとまとめにしている

```mermaid
sequenceDiagram
    participant User as ユーザー
    participant Browser as ブラウザ
    participant App as Railsアプリ
    participant DB as データベース
    participant Mailer as メール送信機構

    User->>Browser: メールアドレス・パスワード入力
    Browser->>App: POST /users/sign_up
    App->>DB: user_registrationsテーブルに仮登録
    App->>Mailer: 確認メール送信
    Mailer-->>User: 確認メール受信
    User->>Browser: 確認メール内のURLクリック
    Browser->>App: GET /users/confirmation?confirmation_token=xxx
    App->>DB: user_registrationsから該当レコード取得
    App->>DB: usersテーブルにユーザー作成
    App->>DB: user_database_authenticationsテーブルに認証情報作成
    App->>DB: user_registrationsレコード削除
    App-->>Browser: 認証完了・ログイン状態
```

### Sign In (ログイン)

```mermaid
sequenceDiagram
    participant User as ユーザー
    participant Browser as ブラウザ
    participant App as Railsアプリ
    participant DB as データベース

    User->>Browser: メールアドレス・パスワード入力
    Browser->>App: POST /users/sign_in
    App->>DB: user_database_authenticationsテーブルから認証情報取得
    App->>App: パスワード検証
    alt パスワード正しい
        App->>App: セッション作成
        App-->>Browser: ログイン成功・リダイレクト
    else パスワード間違い
        App-->>Browser: エラーメッセージ表示
    end
```

## エラーハンドリング

### Sign Up時のエラー
- メールアドレス重複 → `user_database_authentications.email`のユニーク制約違反
- バリデーションエラー → パスワード要件未満、メール形式不正
- メール送信失敗 → SMTP設定エラー、ネットワーク障害

### Sign In時のエラー
- メールアドレス未登録 → `user_database_authentications`テーブルにレコード不存在
- パスワード不一致 → `encrypted_password`との照合失敗
- アカウントロック → 連続ログイン失敗（実装予定）

### 確認メール関連のエラー
- トークン期限切れ → `confirmation_sent_at`から一定時間経過
- 無効なトークン → `confirmation_token`が存在しない

## セキュリティ仕様

### パスワード要件
- 最小6文字以上

### 確認トークン
- 確認トークン有効期限：30分
  - メールアドレス認証は確認メール送信から30分を超えるとトークンが無効になる
