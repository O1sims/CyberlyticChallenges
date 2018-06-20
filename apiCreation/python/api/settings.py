import os
from models.people import people

DOMAIN = {
    'people': people
}


MONGO_HOST = os.environ.get('DB_HOSTNAME')
MONGO_PORT = int(os.environ.get('DB_PORT'))
MONGO_DBNAME = os.environ.get('DB_NAME')
