from .base import *
from .base import env

# GENERAL
DEBUG = True

SECRET_KEY = env("DJANGO_SECRET_KEY")

ALLOWED_HOSTS = ["localhost", "0.0.0.0", "127.0.0.1"]


# DATABASE
DATABASES = {
    "default": {
        "ENGINE": "django.db.backends.mysql",
        "NAME": env("MYSQL_DATABASE"),
        "HOST": "db",
        "USER": "root",
        "PASSWORD": env("MYSQL_ROOT_PASSWORD"),
        "PORT": "3306",
    }
}


# CACHES
SESSION_ENGINE = "django.contrib.sessions.backends.cache"

CACHES = {
    "default": {
        "BACKEND": "django.core.cache.backends.redis.RedisCache",
        "LOCATION": "redis://redis:6379",
    }
}
