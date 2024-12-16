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

ask_yes_no() {
  local prompt="$1"
  local answer

  while true; do
    # Ask the user for input
    read -p "$prompt (y/n): " answer
    answer=$(echo "$answer" | tr '[:upper:]' '[:lower:]')

    if [[ "$answer" == "y" || "$answer" == "yes" ]]; then
      return 0  # Return success (0 for yes)
    elif [[ "$answer" == "n" || "$answer" == "no" ]]; then
      return 1  # Return failure (1 for no)
    else
      echo "Invalid response. Please answer with 'y' or 'n'."
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

check_if_file_exists() {
  if [ -f "$1" ]; then
    return 0  # File exists, return success
  else
    return 1  # File doesn't exist, return failure
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

    # Check if requests is installed via pip3
    if ! pip3 show requests &>/dev/null; then
        pip_requests_installed=false
    else
        pip_requests_installed=true
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

    # Check if python3-requests is installed via apt
    if ! dpkg -l | grep -q python3-requests; then
        apt_requests_installed=false
    else
        apt_requests_installed=true
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
    if [ "$pip_requests_installed" = false ] && [ "$apt_requests_installed" = false ]; then
        echo -e "Package 'requests' is not installed, \033[1;33mcan't continue\033[0m\n"
        exit 1
    fi
}

get_info() {
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
}

create_env_file() {
  local root_dir="$1"
  local ha_mqtt_dir="$2"
  local env_file="$3"
  local mqtt_user="$4"
  local mqtt_password="$5"
  local mqtt_server="$6"
  local mqtt_port="$7"
  local pihost="$8"
  local model="$9"
  local manufacturer="${10}"
  local update_time="${11}"

  # Ruta completa del archivo .env
  local env_file_path="$root_dir/$ha_mqtt_dir/$env_file"

  # Crear y escribir las variables de entorno en el archivo
  echo "Creating environment file at $env_file_path"
  echo "MQTT_USER=\"$mqtt_user\"" > "$env_file_path"
  echo "MQTT_PASSWORD=\"$mqtt_password\"" >> "$env_file_path"
  echo "MQTT_SERVER=\"$mqtt_server\"" >> "$env_file_path"
  echo "MQTT_PORT=$mqtt_port" >> "$env_file_path"
  echo "PIHOST=\"$pihost\"" >> "$env_file_path"
  echo "MODEL=\"$model\"" >> "$env_file_path"
  echo "MANUFACTURER=\"$manufacturer\"" >> "$env_file_path"
  echo "UPDATE_TIME=$update_time" >> "$env_file_path"

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

check_if_file_exists "$ROOT_DIR/$HA_MQTT_DIR/.env"

if [ $? -eq 0 ]; then
    ask_yes_no "File with variables exists, would you like to rewrite it?"
    if [ $? -eq 0 ]; then
        get_info
        create_env_file $ROOT_DIR $HA_MQTT_DIR ".env" $mqtt_user $mqtt_password $mqtt_server $mqtt_port $pihost $model $manufacturer $update_time
    else
        source "$ROOT_DIR/$HA_MQTT_DIR/.env"
        mqtt_user=$MQTT_USER
        mqtt_password=$MQTT_PASSWORD
        mqtt_server=$MQTT_SERVER
        mqtt_port=$MQTT_PORT
        pihost=$PIHOST
        model=$MODEL
        manufacturer=$MANUFACTURER
        update_time=$UPDATE_TIME
    fi
else
    get_info
    create_env_file $ROOT_DIR $HA_MQTT_DIR $ENV_FILE $mqtt_user $mqtt_password $mqtt_server $mqtt_port $pihost $model $manufacturer $update_time
fi

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
if curl -s https://raw.githubusercontent.com/wadalino/pihole-ha-mqtt-service/refs/heads/main/card.yaml -o temp.yaml; then
    sed "s/{HOST}/$pihost/g" temp.yaml > "$ROOT_DIR/$OUTFILES_DIR/card.yaml"
    rm temp.yaml  # Clean up temporary file
else
    echo "Error downloading the file 'card.yaml'."
fi
echo
sleep 3
if curl -s https://raw.githubusercontent.com/wadalino/pihole-ha-mqtt-service/refs/heads/main/card.switches.yaml -o temp.yaml; then
    sed "s/{HOST}/$pihost/g" temp.yaml > "$ROOT_DIR/$OUTFILES_DIR/card.switches.yaml"
    rm temp.yaml  # Clean up temporary file
    echo "Create YAML File 'card.switches.yaml'."
else
    echo "Error downloading the file 'card.switches.yaml'."
fi
echo
sleep 3
if curl -s https://raw.githubusercontent.com/wadalino/pihole-ha-mqtt-service/refs/heads/main/card.apex.char.yaml -o temp.yaml; then
    sed "s/{HOST}/$pihost/g" temp.yaml > "$ROOT_DIR/$OUTFILES_DIR/card.apex.char.yaml"
    rm temp.yaml  # Clean up temporary file
    echo "Create YAML File 'card.apex.char.yaml'."
else
    echo "Error downloading the file 'card.apex.char.yaml'."
fi
echo
sleep 3
if curl -s https://raw.githubusercontent.com/wadalino/pihole-ha-mqtt-service/refs/heads/main/mqtt.yaml -o temp.yaml; then
    sed "s/{HOST}/$pihost/g" temp.yaml > "$ROOT_DIR/$OUTFILES_DIR/mqtt.yaml"
    rm temp.yaml  # Clean up temporary file
    echo "Create YAML File 'mqtt.yaml'."
else
    echo "Error downloading the file 'mqtt.yaml'."
fi
echo
sleep 3
if curl -s https://raw.githubusercontent.com/wadalino/pihole-ha-mqtt-service/refs/heads/main/templates.yaml -o temp.yaml; then
    sed "s/{HOST}/$pihost/g" temp.yaml > "$ROOT_DIR/$OUTFILES_DIR/templates.yaml"
    rm temp.yaml  # Clean up temporary file
    echo "Create YAML File 'templates.yaml'."
else
    echo "Error downloading the file 'templates.yaml'."
fi
echo
sleep 3
if curl -s https://raw.githubusercontent.com/wadalino/pihole-ha-mqtt-service/refs/heads/main/automation.yaml -o temp.yaml; then
    sed "s/{HOST}/$pihost/g" temp.yaml > "$ROOT_DIR/$OUTFILES_DIR/automation.yaml"
    rm temp.yaml  # Clean up temporary file
    echo "Create YAML File 'automation.yaml'."
else
    echo "Error downloading the file 'automation.yaml'."
fi
echo
sleep 3
echo "Script finished and will be removed now!"
rm -- "$0" &

sleep 0.2
