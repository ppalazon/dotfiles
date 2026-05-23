from faker import Faker
fake = Faker()
first_name = fake.name().strip("'")
keyboard.send_keys(first_name)