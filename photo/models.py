from django.db import models


class Photo(models.Model):
    image = models.ImageField(verbose_name="画像", upload_to="photos/")
    title = models.CharField(verbose_name="タイトル", max_length=100, blank=True, null=True)
    uploaded_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return self.title if self.title else f"Photo {self.pk}"
