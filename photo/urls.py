from django.urls import path
from photo.views import PhotoListView, PhotoCreateView, PhotoUpdateView, PhotoDeleteView

urlpatterns = [
    path("", PhotoListView.as_view(), name="photo_list"),
    path("create/", PhotoCreateView.as_view(), name="photo_create"),
    path("<int:pk>/edit/", PhotoUpdateView.as_view(), name="photo_edit"),
    path("delete/<int:pk>/", PhotoDeleteView.as_view(), name="photo_delete"),
]
