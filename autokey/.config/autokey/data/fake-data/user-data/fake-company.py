from faker import Faker
fake = Faker()
company = fake.company().strip("'")
keyboard.send_keys(company)