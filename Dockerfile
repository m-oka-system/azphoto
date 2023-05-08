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

# Azure App ServiceにSSH接続できるようにする
ENV SSH_PASSWD "root:Docker!"
RUN apt-get update \
  && apt-get install -y --no-install-recommends dialog \
  && apt-get update \
  && apt-get install -y --no-install-recommends openssh-server \
  && echo "$SSH_PASSWD" | chpasswd
COPY sshd_config /etc/ssh/

COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]
EXPOSE 8000 2222

CMD ["python", "manage.py", "runserver", "0.0.0.0:8000"]
