#!/bin/bash

# Function that asks for a string input and returns it
ask() {
  local prompt="$1"  # Capture the prompt passed as an argument
  local input
  read -p "$prompt" input
  echo "$input"   # Return the entered value
}

# Function that asks for a numeric input and returns it
ask_number() {
  local prompt="$1"  # Capture the prompt passed as an argument
  local input
  # Keep asking for input until a valid number is entered
  while true; do
    read -p "$prompt" input
    # Check if the input is a valid number (integer)
    if [[ "$input" =~ ^[0-9]+$ ]]; then
      echo "$input"  # Return the entered value if it's a number
      return
    else
      echo "Please enter a valid number."  # Error message if not a valid number
    fi
  done
}

# Function that asks for an IP address and returns it
ask_ip() {
  local prompt="$1"  # Capture the prompt passed as an argument
  local input
  # Keep asking for input until a valid IP address is entered
  while true; do
    read -p "$prompt" input
    # Check if the input matches the IPv4 format
    if [[ "$input" =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]] &&
       [[ "$input" != *[[:space:]]* ]] &&
       [[ "${input//[^0-9]/}" =~ ^[0-9]+$ ]] &&
       [ $(echo "$input" | tr '.' '\n' | awk '{if ($1 >= 0 && $1 <= 255) print "valid"; else print "invalid"}' | grep -q "invalid"; echo $?) -eq 1 ]; then
      echo "$input"  # Return the entered value if it's a valid IP address
      return
    else
      echo "Please enter a valid IPv4 address."  # Error message if not a valid IP address
    fi
  done
}

# Check if the script is running as root or with sudo
if [ "$EUID" -ne 0 ]; then
  echo -e "\nThis script is not running as root. You might need sudo privileges.\n"
  exit
fi

pihost=$(ask "Please enter a HostName that you like to use, please it need to be a single word without special chars or spaces: ")
model=$(ask "Please enter the model of your device: ")
manufacturer=$(ask "Please enter the Manufacturer of your hardware: ")

mqtt_user=$(ask "Please enter a MQTT >> User: ")
mqtt_password=$(ask "Please enter a MQTT >> Password: ")
mqtt_server=$(ask_ip "Please enter a MQTT >> Server IP: ")
mqtt_port=$(ask_number "Please enter a MQTT >> Server Port: ")

update_time=$(ask_number "Please enter delay in seconds that server contact with MQTT Broker: ")

# Create the .env file with the collected information
env_file="outFiles/environment"
# Write the environment variables to the file
echo "Creating environment file at $env_file"
echo "MQTT_USER=\"$mqtt_user\"" > $env_file
echo "MQTT_PASSWORD=\"$mqtt_password\"" >> $env_file
echo "MQTT_SERVER=\"$mqtt_server\"" >> $env_file
echo "MQTT_PORT=$mqtt_port" >> $env_file
echo "PIHOST=\"$pihost\"" >> $env_file
echo "MODEL=\"$model\"" >> $env_file
echo "MANUFACTURER=\"$manufacturer\"" >> $env_file
echo "UPDATE_TIME=$update_time" >> $env_file

# Service file
SERVICE_PATH="outFiles/mqtt-ha.service"

# add specific content to file
cat <<EOF > $SERVICE_PATH
[Unit]
Description=Update groups from HA via MQTT service
After=multi-user.target

[Service]
Type=simple
Restart=always
ExecStart=/usr/bin/python3 /root/mqtt-service.py

[Install]
WantedBy=multi-user.target
EOF

