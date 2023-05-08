from .base import *
from .base import env
from azure.identity import DefaultAzureCredential

# GENERAL
DEBUG = env.bool("DJANGO_DEBUG", False)

SECRET_KEY = env("DJANGO_SECRET_KEY")

ALLOWED_HOSTS = [env("DJANGO_ALLOWED_HOSTS")]
if env("WEBSITE_HOSTNAME"):
    ALLOWED_HOSTS += env.list("WEBSITE_HOSTNAME")


# SECURITY
CSRF_TRUSTED_ORIGINS = [f"https://{host}" for host in ALLOWED_HOSTS]
SECURE_SSL_REDIRECT = env.bool("DJANGO_SECURE_SSL_REDIRECT", default=True)


# DATABASE
DATABASES = {
    "default": {
        "ENGINE": "django.db.backends.mysql",
        "NAME": env("DB_NAME"),
        "HOST": env("DB_HOST"),
        "USER": env("DB_USERNAME"),
        "PASSWORD": env("DB_PASSWORD"),
        "PORT": env("DB_PORT"),
    }
}


# CACHES
REDIS_HOST = env("REDIS_HOST")
REDIS_PORT = env("REDIS_PORT")
REDIS_KEY = env("REDIS_KEY")

SESSION_ENGINE = "django.contrib.sessions.backends.cache"

CACHES = {
    "default": {
        "BACKEND": "django.core.cache.backends.redis.RedisCache",
        "LOCATION": f"rediss://:{REDIS_KEY}@{REDIS_HOST}:{REDIS_PORT}/0",
    }
}


# STORAGES
INSTALLED_APPS += ["storages"]
AZURE_ACCOUNT_NAME = env("DJANGO_AZURE_ACCOUNT_NAME")
AZURE_STATIC_CONTAINER = env("DJANGO_AZURE_STATIC_CONTAINER")
AZURE_MEDIA_CONTAINER = env("DJANGO_AZURE_MEDIA_CONTAINER")
AZURE_TOKEN_CREDENTIAL = DefaultAzureCredential()
AZURE_CUSTOM_DOMAIN = env("DJANGO_ALLOWED_HOSTS")

# STATIC
STATICFILES_STORAGE = "config.settings.custom_storages.StaticAzureStorage"
STATIC_URL = (
    f"https://{AZURE_ACCOUNT_NAME}.blob.core.windows.net/{AZURE_STATIC_CONTAINER}/"
)

# MEDIA
DEFAULT_FILE_STORAGE = "config.settings.custom_storages.MediaAzureStorage"
MEDIA_URL = (
    f"https://{AZURE_ACCOUNT_NAME}.blob.core.windows.net/{AZURE_MEDIA_CONTAINER}/"
)


# AUTHENTICATION (django-allauth)
ACCOUNT_EMAIL_VERIFICATION = "mandatory"
