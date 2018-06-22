schema = {
    'id': {
        'type': 'integer',
        'minlength': 1,
        'maxlength': 100,
        'required': True
    },
    'firstname': {
        'type': 'string',
        'minlength': 1,
        'maxlength': 100,
        'required': True,
    },
    'lastname': {
        'type': 'string',
        'minlength': 1,
        'maxlength': 100,
        'required': True,
        'unique': True,
    },
    'role': {
        'type': 'list',
        'allowed': ["author", "contributor", "copy"],
    },
    'location': {
        'type': 'dict',
        'schema': {
            'address': {'type': 'string'},
            'city': {'type': 'string'}
        },
    },
    'born': {
        'type': 'datetime',
    },
}


people = {
    'item_title': 'person',
    'additional_lookup': {
        'url': 'regex("[\w]+")',
        'field': 'id'
    },
    'cache_control': 'max-age=10,must-revalidate',
    'cache_expires': 10,
    'resource_methods': ['GET', 'POST', 'DELETE'],
    'item_methods': ['GET', 'DELETE'],
    'schema': schema
}
