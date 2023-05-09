# AZ Photo

シンプルな写真投稿サイトです。レスポンシブ対応しています。<br>
インフラの学習目的で制作したサイトのため、必要最低限の機能のみを実装しています。<br>
![image](https://user-images.githubusercontent.com/22112831/235562779-1886d2d8-611e-40a1-9715-a27fc4b23b38.png)

# インフラ構成図

![image](infra.drawio.svg)

# 機能一覧

- ユーザー認証機能 (django-allauth)
  - ログイン
  - ログアウト
  - サインアップ（電子メール検証）
  - パスワード再設定
- 画像投稿機能
  - 新規登録
  - 一覧表示
  - 編集
  - 削除

# 使用技術

- バックエンド
  - Python 3.9.2
  - Django 4.0.2
  - MySQL 8.0.21
  - Redis 6
- フロントエンド
  - HTML, CSS, JavaScript
  - Bootstrap5 (django-bootstrap5)
- インフラ
  - Docker, Docker Compose
  - Terraform, TerraformCloud
  - GithubActions
  - Azure Container Registy
  - Azure Front Door
  - Azure App Service
  - Azure Database for MySQL Flexible Server
  - Azure Cache for Redis
  - Azure BLOB Storage
  - Azure Key Vault
  - Private Endpoint
  - Azure DNS
  - Log Analytics
  - SendGrid
