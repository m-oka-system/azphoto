from django.views.generic import ListView, CreateView, UpdateView, DeleteView
from django.contrib.auth.mixins import LoginRequiredMixin

from photo.models import Photo


class PhotoListView(LoginRequiredMixin, ListView):
    model = Photo

    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)
        context["photo_count"] = Photo.objects.count()
        return context


class PhotoCreateView(LoginRequiredMixin, CreateView):
    model = Photo
    fields = "__all__"
    success_url = "/"


class PhotoUpdateView(LoginRequiredMixin, UpdateView):
    model = Photo
    fields = "__all__"
    success_url = "/"


class PhotoDeleteView(LoginRequiredMixin, DeleteView):
    model = Photo
    success_url = "/"
