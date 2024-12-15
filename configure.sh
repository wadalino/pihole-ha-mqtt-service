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
      echo -e "Please enter a \033[1;33mvalid\033[0m number."  # Error message if not a valid number
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
      echo -e "Please enter a \033[1;33mvalid\033[0m IPv4 address."  # Error message if not a valid IP address
    fi
  done
}

# Function to check and create directory
check_and_create_dir() {
    local DIR="$1"  # Take directory name as an argument

    # Check if directory exists
    if [ -d "$DIR" ]; then
        echo -e "Directory \033[0;33m'$DIR'\033[0m already exists."
    else
        # Create directory or exit
        mkdir "$DIR" || { echo -e "Failed to create directory \033[0;33m'$DIR'\033[0m. Exiting."; exit 1; }
        echo -e "Directory \033[0;33m'$DIR'\033[0m created successfully."
    fi
}

# Function to download a file
download_file() {
    local URL="$1"           # URL of the file to download
    local OUTPUT="$2"        # Local path to save the file

    # Use curl to download the file
    curl -o "$OUTPUT" "$URL" --fail --silent --show-error
    if [ $? -ne 0 ]; then
        echo -e "Failed to download file from $URL. Exiting."
        return 1
    fi

    echo -e "File downloaded successfully to  \033[0;33m$OUTPUT\033[0m."
    return 0
}


check_python() {
  if ! command -v python3 &>/dev/null; then
      echo -e "Python is \033[0;33mnot installed\033[0m, can't continue."
      exit 1
  fi
}

check_systemctl() {
  if command -v systemctl &>/dev/null; then
      return 0  # true (systemctl is installed)
  else
      return 1  # false (systemctl is not installed)
  fi
}

check_packages() {
    # Check if paho-mqtt is installed via pip3
    if ! pip3 show paho-mqtt &>/dev/null; then
        pip_paho_installed=false
    else
        pip_paho_installed=true
    fi

    # Check if colorama is installed via pip3
    if ! pip3 show colorama &>/dev/null; then
        pip_colorama_installed=false
    else
        pip_colorama_installed=true
    fi

    # Check if dotenv is installed via pip3
    if ! pip3 show python-dotenv &>/dev/null; then
        pip_dotenv_installed=false
    else
        pip_dotenv_installed=true
    fi

    # Check if python3-paho-mqtt is installed via apt
    if ! dpkg -l | grep -q python3-paho-mqtt; then
        apt_paho_installed=false
    else
        apt_paho_installed=true
    fi

    # Check if python3-colorama is installed via apt
    if ! dpkg -l | grep -q python3-colorama; then
        apt_colorama_installed=false
    else
        apt_colorama_installed=true
    fi

    # Check if python3-dotenv is installed via apt
    if ! dpkg -l | grep -q python3-dotenv; then
        apt_dotenv_installed=false
    else
        apt_dotenv_installed=true
    fi

    if [ "$pip_paho_installed" = false ] && [ "$apt_paho_installed" = false ]; then
        echo -e "Package 'paho-mqtt' is not installed, \033[1;33mcan't continue\033[0m\n"
        exit 1
    fi
    if [ "$pip_colorama_installed" = false ] && [ "$apt_colorama_installed" = false ]; then
        echo -e "Package 'colorama' is not installed, \033[1;33mcan't continue\033[0m\n"
        exit 1
    fi
    if [ "$pip_dotenv_installed" = false ] && [ "$apt_dotenv_installed" = false ]; then
        echo -e "Package 'dotenv' is not installed, \033[1;33mcan't continue\033[0m\n"
        exit 1
    fi
}

echo

# Check if the script is running as root or with sudo
if [ "$EUID" -ne 0 ]; then
  echo -e "This script is not running as \033[1;33mroot\033[0m. You might need sudo privileges.\n"
  exit
fi

# Check for python3
check_python
check_packages

ROOT_DIR="/root"
ENV_FILE=".env"
HA_MQTT_DIR="ha-mqtt-service"
OUTFILES_DIR="outFiles"

# check directories [outFiles, ha-mqtt-service]
check_and_create_dir "$ROOT_DIR/$HA_MQTT_DIR"
check_and_create_dir "$ROOT_DIR/$OUTFILES_DIR"

download_file "https://raw.githubusercontent.com/wadalino/pihole-ha-mqtt-service/main/mqtt-service.py" "$ROOT_DIR/$HA_MQTT_DIR/mqtt-service.py"

echo -e "

File named \033[1;34m'mqtt-service.py'\033[0m was downloaded to folder \033[1;34m'ha-mqtt-service'\033[0m
this file contains the \033[31mpython code\033[0m to execute the service that sends updates via mqtt.


"

pihost=$(ask "Please enter a HostName to use, needs to be a single word with no special chars or spaces: ")
echo
model=$(ask "Please enter the model of your device: ")
echo
manufacturer=$(ask "Please enter the Manufacturer of your hardware: ")
echo
mqtt_user=$(ask "Please enter the MQTT User: ")
echo
mqtt_password=$(ask "Please enter the MQTT Password: ")
echo
mqtt_server=$(ask_ip "Please enter the MQTT Server IP: ")
echo
mqtt_port=$(ask_number "Please enter the MQTT Server Port: ")
echo
update_time=$(ask_number "Please enter delay in seconds that server contact with MQTT Broker: ")
echo

# Create the .env file with the collected information
env_file="$ROOT_DIR/$HA_MQTT_DIR/$ENV_FILE"
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
SERVICE_PATH="$ROOT_DIR/$OUTFILES_DIR/mqtt-ha.service"

# add specific content to file
cat <<EOF > $SERVICE_PATH
[Unit]
Description=Update groups from HA via MQTT service
After=multi-user.target

[Service]
Type=simple
Restart=always
ExecStart=/usr/bin/python3 $ROOT_DIR/$HA_MQTT_DIR/mqtt-service.py

[Install]
WantedBy=multi-user.target
EOF

# Call the function
check_systemctl

# Check the return status of the function
if [ $? -eq 0 ]; then
    echo -e "Daemon control file created ..."
    mv $SERVICE_PATH /etc/systemd/system/
    echo -e "Reloading daemons ..."
    systemctl daemon-reload
    echo -e "Enabling daemon ..."
    systemctl enable mqtt-ha.service
    echo -e "Starting daemon ..."
    systemctl start mqtt-ha.service

else
    echo "Systemctl is not installed, service file is located in $SERVICE_PATH"
fi

echo -e "YAML files are located in \033[31m'$ROOT_DIR/$OUTFILES_DIR'\033[0m"
curl -s https://raw.githubusercontent.com/wadalino/pihole-ha-mqtt-service/refs/heads/main/configuration.yaml | sed "s/{HOST}/$pihost/g" > "$ROOT_DIR/$OUTFILES_DIR/mqtt.yaml"
curl -s https://raw.githubusercontent.com/wadalino/pihole-ha-mqtt-service/refs/heads/main/home_assistant_card.yaml | sed "s/{HOST}/$pihost/g" > "$ROOT_DIR/$OUTFILES_DIR/card.yaml"

