# 環境構築方法

1. `git clone`
1. `.env`ファイル作成して # env の中身 を記載
1. `docker compose build`
1. `docker compose run --rm web /bin/bash -c "bundle config set --local path vendor/bundle && bundle install"`
1. `docker compose run --rm web yarn install`
1. `docker compose up`

`http://localhost:3000`でアクセス可能

# `env`の中身

```
GITHUB_KEY=
GITHUB_SECRET=
GITHUB_ACCESS_TOKEN=
OPENAI_API_KEY=
```

各キーの中身は DM で送ります
