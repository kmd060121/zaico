# zaico_webbackend_codingtest

ローカル開発向けに最小構成の Docker Compose を用意した Rails 8.1.2 のスキャフォールドです。

## ローカル開発（Docker Compose）

1. `docker compose build`
2. `docker compose up`
3. `http://localhost:3000` を開く

コンテナのエントリーポイントで、起動時に `bin/rails db:prepare` が自動実行されます。

## テストデータの投入

環境変数を指定して `db:seed` を実行すると、データセットの件数を調整できます。

```bash
docker compose run --rm web bin/rails db:seed \
  ACCOUNTS=1 \
  INVENTORIES_PER_ACCOUNT=1000 \
  PURCHASES_PER_ACCOUNT=5000 \
  DELIVERIES_PER_ACCOUNT=5000 \
  ITEMS_BATCH_SIZE=1000
```

省略時のデフォルト値:

- `ACCOUNTS=3`
- `INVENTORIES_PER_ACCOUNT=1000`
- `PURCHASES_PER_ACCOUNT=5000`
- `DELIVERIES_PER_ACCOUNT=5000`
- `ITEMS_BATCH_SIZE=1000`

## データのリセット

データベースを再作成した後、再度シードを実行します。

```bash
docker compose run --rm web bin/rails db:drop db:create db:migrate
docker compose run --rm web bin/rails db:seed \
  ACCOUNTS=1 \
  INVENTORIES_PER_ACCOUNT=1000 \
  PURCHASES_PER_ACCOUNT=5000 \
  DELIVERIES_PER_ACCOUNT=5000 \
  ITEMS_BATCH_SIZE=1000
```
