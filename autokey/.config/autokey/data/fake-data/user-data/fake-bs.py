from faker import Faker
fake = Faker()
email = fake.bs().strip("'")
keyboard.send_keys(email)