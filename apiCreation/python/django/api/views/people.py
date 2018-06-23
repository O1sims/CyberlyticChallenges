import os
import re

import pymongo as pm

from bson import ObjectId

from rest_framework.response import Response
from rest_framework.renderers import JSONRenderer
from rest_framework.generics import ListCreateAPIView, ListAPIView, DestroyAPIView

from api.models.people import PeopleModel


class PeopleView(ListCreateAPIView, DestroyAPIView):
    renderer_classes = (JSONRenderer,)
    serializer_class = PeopleModel

    def __init__(self):
        self.people_collection = pm.MongoClient(
            host=os.environ.get('DB_HOST'),
            port=int(os.environ.get('DB_PORT'))
        )[os.environ.get('DB_NAME')]['people']

    def get(self, request, *args, **kwargs):
        people_list = list(self.people_collection.find())
        for person in people_list:
            person["_id"] = str(person["_id"])
        return Response(
            data=people_list,
            status=200)

    def post(self, request, *args, **kwargs):
        PeopleModel(
            data=request.data).is_valid(
            raise_exception=True)
        self.people_collection.insert(request.data)
        return Response(status=201)

    def delete(self, request, *args, **kwargs):
        self.people_collection.drop()
        return Response(status=204)


class PeopleLastNameView(ListAPIView):
        renderer_classes = (JSONRenderer,)
        serializer_class = PeopleModel

        def __init__(self):
            self.people_collection = pm.MongoClient(
                host=os.environ.get('DB_HOST'),
                port=int(os.environ.get('DB_PORT'))
            )[os.environ.get('DB_NAME')]['people']

        def get(self, request, *args, **kwargs):
            people_list = list(self.people_collection.find({
                'lastname': re.compile(
                    self.kwargs['lastname'],
                    re.IGNORECASE)}))
            for person in people_list:
                person["_id"] = str(person["_id"])
            return Response(
                data=people_list,
                status=200)


class PeopleIdView(ListAPIView, DestroyAPIView):
    renderer_classes = (JSONRenderer,)
    serializer_class = PeopleModel

    def __init__(self):
        self.people_collection = pm.MongoClient(
            host=os.environ.get('DB_HOST'),
            port=int(os.environ.get('DB_PORT'))
        )[os.environ.get('DB_NAME')]['people']

    def get(self, request, *args, **kwargs):
        person = self.people_collection.find_one({
            '_id': ObjectId(self.kwargs['id'])})
        person["_id"] = str(person["_id"])
        return Response(
            data=person,
            status=200)

    def delete(self, request, *args, **kwargs):
        self.people_collection.delete_one({
            '_id': ObjectId(self.kwargs['id'])})
        return Response(status=204)
