from django.contrib import admin
from django.urls import path, include
from django.conf import settings
from django.conf.urls.static import static
from allauth.account.views import LoginView

urlpatterns = [
    path("admin/", admin.site.urls),
    path("", include("photo.urls")),
    path("accounts/", include("allauth.urls")),
    path("", LoginView.as_view(), name="account_login"),
]

urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)
