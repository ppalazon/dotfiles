from faker import Faker
fake = Faker()
city = fake.city().strip("'")
keyboard.send_keys(city)