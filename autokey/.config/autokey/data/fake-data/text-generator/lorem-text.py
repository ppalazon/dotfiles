from faker import Faker
import random
nb = random.randint(3,6)
fake = Faker()
sentences = [s.strip("'") for s in fake.paragraphs(nb)]
paragraph = "".join(sentences)
keyboard.send_keys(paragraph)