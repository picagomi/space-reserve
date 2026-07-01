# SpaceReserve — Supabase 接続手順

このアプリは **未設定ならデモモード**（データはブラウザ内 LocalStorage）で動きます。
複数端末で予約を共有し、管理画面にログインを付けたい場合は、以下で Supabase に接続します。

## 1. Supabase プロジェクトを作成
1. https://supabase.com にサインアップ／ログイン
2. 「New project」でプロジェクトを作成（リージョンは Tokyo 推奨）

## 2. テーブルと権限(RLS)を作成
1. 左メニュー **SQL Editor** を開く
2. 同梱の [`schema.sql`](schema.sql) の中身を貼り付けて **Run**
   - facilities / reservations テーブル、RLSポリシー、施設シード(8件)が作成されます

## 3. 接続情報をアプリに設定
1. 左メニュー **Project Settings → API** を開く
2. 次の2つをコピー
   - **Project URL**（例：`https://xxxx.supabase.co`）
   - **anon public** key（`eyJ...`）
3. `index.html` の先頭スクリプト内、この2行に貼り付け：
   ```js
   const SUPABASE_URL = 'ここにProject URL';
   const SUPABASE_ANON_KEY = 'ここにanon public key';
   ```
   > anon key は RLS で保護される公開鍵なので、クライアントに埋め込んで問題ありません。

設定後にページを開くと、上部バーが緑の **「Supabaseに接続中」** に変わります。

## 4. 管理者アカウントを作成（管理画面ログイン用）
1. 左メニュー **Authentication → Users → Add user**
2. メールとパスワードを設定（「Auto Confirm」を有効に）
3. アプリの **管理** タブを開くとログイン画面が出るので、そのアカウントでログイン

## できること
- 予約・施設データが Supabase に保存され、**どの端末からでも同じ状態**に
- 施設の追加/編集/削除・予約の取消は **ログインした運営者のみ**
- 予約作成・空き確認・閲覧は誰でも可能（一般利用者向け）

## セキュリティ補足（本番化する場合）
- 現状 `reservations` の閲覧を全公開にしています（空き状況表示のため）。
  予約者の個人情報を守るには、busy時間帯だけ返す **ビュー** か **RPC関数** を用意し、
  `reservations` の select ポリシーを運営者のみに絞ってください。
- 「ログイン済み＝運営者」という単純な権限です。複数権限が必要なら
  ユーザーごとの role 列＋ポリシー分岐を追加してください。
