FROM python:3.9.2

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

# Set working directory
WORKDIR /app

# System dependencies
RUN apt update \
  && pip install --upgrade pip \
  && apt install -y default-mysql-client-core dnsutils

# Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY . .
