import os
import pymongo as pm


DEFAULT_PEOPLE_DATA = [
    {
        "firstname": "John",
        "lastname": "Smith"
    },
    {
        "firstname": "Jane",
        "lastname": "Smith"
    },
    {
        "firstname": "Captain",
        "lastname": "Birdseye",
        "role": "developer"
    }
]


def load_people_data():
    people_collection = pm.MongoClient(
        host=os.environ.get('DB_HOST'),
        port=int(os.environ.get('DB_PORT'))
    )[os.environ.get('DB_NAME')]['people']
    people_collection.drop()
    people_collection.insert(DEFAULT_PEOPLE_DATA)
