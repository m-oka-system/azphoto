from .base import *
from .base import env

DEBUG = True

SECRET_KEY = env("DJANGO_SECRET_KEY")

ALLOWED_HOSTS = ["localhost", "0.0.0.0", "127.0.0.1"]


# DATABASE
DATABASES = {
    "default": {
        "ENGINE": "django.db.backends.sqlite3",
        "NAME": BASE_DIR / "db.sqlite3",
        "ATOMIC_REQUESTS": True,
    }
}
