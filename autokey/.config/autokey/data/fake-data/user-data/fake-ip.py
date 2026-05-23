from faker import Faker
fake = Faker(['es_ES','de_CH', 'en_GB'])
ip = fake.ipv4().strip("'")
keyboard.send_keys(ip)