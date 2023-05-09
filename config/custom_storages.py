from config.settings.base import env
from storages.backends.azure_storage import AzureStorage


class StaticAzureStorage(AzureStorage):
    azure_container = env("DJANGO_AZURE_STATIC_CONTAINER")


class MediaAzureStorage(AzureStorage):
    azure_container = env("DJANGO_AZURE_MEDIA_CONTAINER")
