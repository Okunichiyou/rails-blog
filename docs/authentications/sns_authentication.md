# SNS認証

- SNSのアカウントを利用してログインする機能
- パスワードを登録してログインする必要がない

## ER図

```mermaid
erDiagram
  users {
    INTEGER id PK
    STRING name UK "NOT NULL"
    DATETIME created_at "NOT NULL"
    DATETIME updated_at "NOT NULL"
  }

  sns_credentials {
    INTEGER id PK
    INTEGER user_id FK
    STRING provider "NOT NULL"
    STRING uid "NOT NULL, UK(provider,uid)"
    STRING email "NOT NULL, UK(provider,email)"
    DATETIME created_at "NOT NULL"
    DATETIME updated_at "NOT NULL"
  }

  users ||--o{ sns_credentials : "SNS認証情報を持つ"
```

## シーケンス図

### SNS認証フロー（Google / Apple共通）

```mermaid
sequenceDiagram
    participant User as ユーザー
    participant Browser as ブラウザ
    participant App as Railsアプリ
    participant SNS as SNS認証サーバー<br/>(Google/Apple)
    participant DB as データベース

    User->>Browser: SNSでログインボタンをクリック
    Browser->>App: GET /user/auth/{provider}
    Note over App: provider: google または apple
    App-->>Browser: SNSの認証画面へリダイレクト
    Browser->>SNS: 認証リクエスト
    User->>SNS: SNSアカウントでログイン・認可
    SNS-->>Browser: 認証コード付きでコールバック
    Browser->>App: GET /user/auth/{provider}/callback?code=xxx
    App->>SNS: 認証コードを使ってアクセストークン取得
    SNS-->>App: アクセストークン・ユーザー情報返却
    App->>DB: sns_credentialsテーブルからuid検索

    alt 既存のSNS認証ユーザー
        App->>App: セッション作成（ログイン）
        App-->>Browser: GET root_path にリダイレクト
        Browser-->>User: ログイン完了

    else 新規ユーザー
        App->>DB: database_authenticationsとsns_credentialsからメールアドレスが一致するユーザーを検索

        alt メールアドレスが一致するユーザが見つかった
          App-->>Browser: /sign_inにリダイレクト。フラッシュメッセージにて、「既に同じメールアドレスでアカウントが連携されている」と表示
          Browser-->>User: ログイン失敗
        else メールアドレスが一致するユーザーが見つからなかった
          App->>DB: usersテーブルとsns_credentialsテーブルにデータを作成
          App->>App: セッション作成（ログイン）
          App-->>Browser: GET root_path にリダイレクト
          Browser-->>User: ログイン完了
        end
    end
```

## エラーハンドリング

### SNS認証時のエラー

- メールアドレス未認証 → SNSプロバイダー側でメールアドレスが未認証の場合、認証失敗として処理
- APIエラー → Googleの認証APIがエラーを返した場合
  - ネットワークエラー
  - 無効な認証コード
  - トークン取得失敗
- ユーザーが認証をキャンセル → SNSプロバイダーの認証画面でキャンセルした場合
- メールアドレス重複 → `sns_credentials.email`のユニーク制約違反

### 認証失敗時の挙動

- 認証が失敗した場合はサインイン画面（`/sign_in`）にリダイレクト
- エラーメッセージをフラッシュメッセージで表示

## リダイレクトURI設定

### Google認証

- 認証開始URI: `/user/auth/google`
- コールバックURI: `/user/auth/google/callback`

### Apple認証

- 認証開始URI: `/user/auth/apple`
- コールバックURI: `/user/auth/apple/callback`

## 認証成功・失敗時の遷移先

- 認証成功(既存ユーザー): `root_path` へリダイレクト
- 認証成功(新規ユーザー): 登録画面に行き、ユーザー名の入力を行う
- 認証失敗: `/sign_up` （新規登録画面）へリダイレクト
