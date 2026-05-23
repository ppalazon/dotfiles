from faker import Faker
fake = Faker()
email = fake.email().strip("'")
keyboard.send_keys(email)