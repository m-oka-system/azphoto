from .base import *
from .base import env

# GENERAL
DEBUG = env.bool("DJANGO_DEBUG", False)

SECRET_KEY = env("DJANGO_SECRET_KEY")

ALLOWED_HOSTS = [env("DJANGO_ALLOWED_HOSTS")]
if env("WEBSITE_HOSTNAME"):
    ALLOWED_HOSTS += env.list("WEBSITE_HOSTNAME")


# SECURITY
CSRF_TRUSTED_ORIGINS = [f"https://{host}" for host in ALLOWED_HOSTS]
SECURE_SSL_REDIRECT = env.bool("DJANGO_SECURE_SSL_REDIRECT", default=True)
