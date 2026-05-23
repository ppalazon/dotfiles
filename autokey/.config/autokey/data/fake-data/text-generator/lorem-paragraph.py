from faker import Faker
fake = Faker()
sentence = fake.paragraph().strip("'")
keyboard.send_keys(sentence)