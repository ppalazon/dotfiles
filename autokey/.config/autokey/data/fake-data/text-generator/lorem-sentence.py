from faker import Faker
fake = Faker()
sentence = fake.sentence().strip("'")
keyboard.send_keys(sentence)