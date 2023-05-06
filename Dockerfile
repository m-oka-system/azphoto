FROM python:3.9.2

# 環境変数を設定
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

# 作業ディレクトリを設定
WORKDIR /app

# 依存関係をインストール
COPY requirements.txt .
RUN apt update \
  && pip install --upgrade pip \
  && apt install -y default-mysql-client-core dnsutils

RUN pip install --no-cache-dir -r requirements.txt

# アプリケーションコードをコピー
COPY . .

