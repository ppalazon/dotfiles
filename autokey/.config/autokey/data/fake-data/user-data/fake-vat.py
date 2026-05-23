from faker import Faker
fake = Faker(['es_ES','de_CH', 'en_GB'])
vat_id = fake.vat_id().strip("'")
keyboard.send_keys(vat_id)