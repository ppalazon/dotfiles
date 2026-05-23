from faker import Faker
fake = Faker()
first_name = fake.first_name().strip("'")
keyboard.send_keys(first_name)