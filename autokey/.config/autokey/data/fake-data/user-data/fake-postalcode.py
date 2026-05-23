from faker import Faker
fake = Faker()
postcode = fake.postcode().strip("'")
keyboard.send_keys(postcode)