from faker import Faker
fake = Faker()
city = fake.country().strip("'")
keyboard.send_keys(city)