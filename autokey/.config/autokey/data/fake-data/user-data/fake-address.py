from faker import Faker
fake = Faker(['es_ES', 'en_GB'])
street_address = fake.street_address().strip("'").replace('\n',', ')
keyboard.send_keys(street_address)