from django.contrib.sites.shortcuts import get_current_site
from django.urls import reverse
from django.conf import settings
from allauth.account.views import PasswordResetView
from allauth.account.forms import ResetPasswordForm
from allauth.account.adapter import get_adapter
from allauth.account.utils import (
    user_username,
    user_pk_to_url_str,
)
from django.contrib.auth.tokens import default_token_generator
from allauth.account import app_settings


class CustomResetPasswordForm(ResetPasswordForm):
    def _send_password_reset_mail(self, request, email, users, **kwargs):
        token_generator = kwargs.get("token_generator", default_token_generator)

        for user in users:
            temp_key = token_generator.make_token(user)

            uid = user_pk_to_url_str(user)
            path = reverse(
                "account_reset_password_from_key",
                kwargs=dict(uidb36=uid, key=temp_key),
            )

            # Use the CUSTOM_DOMAIN setting
            url = f"{settings.CUSTOM_DOMAIN}{path}"

            context = {
                "current_site": get_current_site(request),
                "user": user,
                "password_reset_url": url,
                "uid": uid,
                "key": temp_key,
                "request": request,
            }

            if (
                app_settings.AUTHENTICATION_METHOD
                != app_settings.AuthenticationMethod.EMAIL
            ):
                context["username"] = user_username(user)
            get_adapter(request).send_mail(
                "account/email/password_reset_key", email, context
            )


class CustomPasswordResetView(PasswordResetView):
    form_class = CustomResetPasswordForm
