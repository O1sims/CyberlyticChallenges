import os
from eve import Eve


Eve().run(
    host=os.environ.get('API_HOSTNAME'),
    port=os.environ.get('API_PORT'),
    debug=os.environ.get('DEBUG_MODE'))
