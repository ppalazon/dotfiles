import datetime

utcdt = datetime.datetime.utcnow().replace(microsecond=0).isoformat() + "Z"
keyboard.send_keys(utcdt)