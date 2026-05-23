from faker import Faker
fake = Faker()
last_name = fake.last_name().strip("'")
keyboard.send_keys(last_name)