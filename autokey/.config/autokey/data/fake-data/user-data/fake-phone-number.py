from faker import Faker
fake = Faker()
phone_number = fake.phone_number().strip("'")
keyboard.send_keys(phone_number)