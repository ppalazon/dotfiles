from faker import Faker
fake = Faker()
first_name = fake.job().strip("'")
keyboard.send_keys(first_name)