import challenge.config as config

from django.conf.urls import url

from rest_framework.urlpatterns import format_suffix_patterns

from api.views.people import PeopleView, PeopleNameView


urlpatterns = format_suffix_patterns([
    url(r'^people/$'.format(
        config.API_VERSION),
        PeopleView.as_view()),

    url(r'^people/(?P<lastname>.+)/$'.format(
        config.API_VERSION),
        PeopleNameView.as_view()),
])
