from django.views.generic import ListView, CreateView, UpdateView, DeleteView

from photo.models import Photo


class PhotoListView(ListView):
    model = Photo

    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)
        context["photo_count"] = Photo.objects.count()
        return context


class PhotoCreateView(CreateView):
    model = Photo
    fields = "__all__"
    success_url = "/"


class PhotoUpdateView(UpdateView):
    model = Photo
    fields = "__all__"
    success_url = "/"


class PhotoDeleteView(DeleteView):
    model = Photo
    success_url = "/"
