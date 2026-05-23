import random

# Define time range in seconds
start = 8 * 3600 + 20 * 60      # 08:20:00
end = 9 * 3600 + 20 * 60        # 09:20:00

# Generate random time in that range
rand_seconds = random.randint(start, end)

# Convert back to hh:mm:ss
hours = rand_seconds // 3600
minutes = (rand_seconds % 3600) // 60
seconds = rand_seconds % 60

# Format with leading zeros
time_str = f"{hours:02d}:{minutes:02d}:{seconds:02d}"

# Output (for AutoKey)
keyboard.send_keys(time_str)