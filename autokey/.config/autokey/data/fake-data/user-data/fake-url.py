from faker import Faker
fake = Faker(['es_ES','de_CH', 'en_GB'])
domain_word = fake.domain_word().strip("'")
slug = fake.slug().strip("'")
url = "http://" + domain_word + ".local.test/"+slug
keyboard.send_keys(url)