from faker import Faker
import random
words = random.randint(3,6)
fake = Faker()
sentence = fake.sentence(words).strip("'.")
keyboard.send_keys(sentence)