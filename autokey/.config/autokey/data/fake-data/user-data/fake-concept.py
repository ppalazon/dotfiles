from faker import Faker
fake = Faker()
rn = fake.random_int(0, 5)
str = ''
match rn:
  case 0:
    str = fake.company()
  case 1:
    str = fake.name()
  case 2:
    str = fake.bs()
  case 3:
    str = fake.catch_phrase()
  case _:
    str = fake.sentence(3).replace(".","")
keyboard.send_keys(str.strip("'"))