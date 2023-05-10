FROM python:3.9.2-alpine

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

# Set working directory
WORKDIR /app

# System dependencies
RUN apk update && apk add --no-cache \
  mariadb-connector-c-dev \
  mysql-client \
  bind-tools

# Python dependencies
COPY requirements.txt .
RUN apk add --no-cache --virtual .build-deps \
  gcc \
  musl-dev \
  libffi-dev \
  openssl-dev \
  && pip install --upgrade pip \
  && pip install --no-cache-dir -r requirements.txt \
  && apk del .build-deps

# Copy application code
COPY . .

# Configure ssh for Azure App Service
COPY sshd_config /etc/ssh/
COPY entrypoint.sh /usr/bin/

RUN apk add openssh \
  && echo "root:Docker!" | chpasswd \
  && chmod +x /usr/bin/entrypoint.sh \
  && cd /etc/ssh/ \
  && ssh-keygen -A

EXPOSE 8000 2222

ENTRYPOINT ["entrypoint.sh"]

CMD ["python", "manage.py", "runserver", "0.0.0.0:8000"]
