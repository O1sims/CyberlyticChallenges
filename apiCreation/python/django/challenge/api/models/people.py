from rest_framework import serializers


ROLES = (
    "data scientist",
    "developer",
    "intern",
)


class LocationModel(serializers.Serializer):
    city = serializers.CharField(required=False)
    address = serializers.CharField(required=False)


class PeopleModel(serializers.Serializer):
    firstname = serializers.CharField(required=False)
    lastname = serializers.CharField(required=True)
    location = LocationModel(required=False)
    role = serializers.ChoiceField(
        choices=ROLES,
        required=False
    )
