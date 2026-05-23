import datetime

localdt = datetime.datetime.now().strftime('%Y%m%d %H:%M:%S')
keyboard.send_keys(localdt)