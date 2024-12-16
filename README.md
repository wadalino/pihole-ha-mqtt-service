# pihole-ha-mqtt-service
Pihole service that exposes group management (enable/disable) to Home Assistant with autoconfiguration.
It also exposes statistics as sensors, and it updates automatically (every 5 second if not set otherwise) when a group is enabled/disabled from the PiHole front-end itself.

![Parental control](https://github.com/wadalino/pihole-ha-mqtt-service/blob/main/card.png)
![Pihole reporting](https://github.com/wadalino/pihole-ha-mqtt-service/blob/main/card.switches.png)



## Automated installation
1) download .sh file from github and exec with sudo or as root
   ```
   wget https://raw.githubusercontent.com/wadalino/pihole-ha-mqtt-service/main/configure.sh
   sudo bash configure.sh
   ```
2) script ask for following variables:
   ```
   MQTT_USER: the user that is authorised to interact with the MQTT server
   MQTT_PASSWORD: the password that authenticates the user on the MQTT server
   MQTT_SERVER: server IP address, in the form of X.X.X.X
   MQTT_PORT: the port of the MQTT server
   ```
3) script also ask for variables:
   ```
   HOSTNAME: the hostname to send via mqtt of 'pihole' server
   MODEL: Hardware device model, per example RPI 2
   MANUFACTURER: The manufacturer of the device, per example Raspberry
   UPDATE_TIME: Frequency update time to send a new MQTT messages
   ```  
   
4) Variables will be stored into file **'/root/ha-mqtt-environment/.env'**, this file will be loaded by **'mqtt-service.py'**  
  
  
5) There are two variables into downloaded **'mqtt-service.py'** file placed on **'ha-mqtt-service'** directory, called *DEBUG* and *TRACE* set as False by default. You can change them to True if you want to set in Debug or Trace MODE. Please note that write much information and log can grow too much -- remember to set to False when set to Production.  
 
  
6) The script check if Python3 is installed and also check for required packages.


7) After script execution there are two new directories created in '/root/' folder:
   ```
   - ha-mqtt-service : this folder contents the python3 script and .env
      - mqtt-service.py : main script
      - .env : file with variables 
   - outFiles : this folder contents four files
      - automation.yaml : it contents an automation to switch off pihole during 1 hour
      - mqtt.yaml : the content of this file needs to be included in mqtt section of Home Assistant
      - card.yaml : this is a card sample that can be included to Home Assistant panel
      - switches.yaml : this is a card sample that can be included to Home Assistant panel to change states on pi-hole
   ```
   

8) File mqtt-ha.service will be store under '/etc/systemd/system' folder if 'systemd' package is present, otherwise you need to install 'systemd' package and move it to /etc/systemd/system to be installed as service (taken from https://medium.com/codex/setup-a-python-script-as-a-service-through-systemctl-systemd-f0cc55a42267):
   ```
   # install systemd
   sudo apt install systemd
   
   # move file to systemd directory 
   sudo mv /root/outFiles/mqtt-ha.service /etc/systemd/system/
   
   # reload daemons
   sudo systemctl daemon-reload
   
   # enable service
   sudo systemctl enable mqtt-ha.service
   
   # start service
   sudo systemctl start mqtt-ha.service
   ```
9) check that everything is working well:
    ```
    sudo systemctl status mqtt-ha.service
    ```
## Manual Installation

Please refer installation steps described by [@Andrec83](https://github.com/Andrec83) on his [project](https://github.com/Andrec83/pihole-ha-mqtt-service)  

## Uninstall

If you want to uninstall service and remove all related files you need to execute the uninstall script:  
   ```
    curl -s https://raw.githubusercontent.com/wadalino/pihole-ha-mqtt-service/main/uninstall.sh | sudo bash
   ```   


## Requeriments
Please note that to use this software is necessary to have installed Python3 with packages specified in file  
[requirements.txt](https://raw.githubusercontent.com/wadalino/pihole-ha-mqtt-service/refs/heads/main/requirements.txt):
  ```
- paho-mqtt
- colorama
- dotenv
- requests
  ```

## Thanks to 
Thanks to [@Andrec83](https://github.com/Andrec83) for creation of this script.

### ToDo
The script can certainly be improved and generalised, happy for any contribution to come along. 
~~I need to improve the way I read info from the env file and manage cases where MQTT user and PWD are not necessary.~~ 
I also need to find a way to update PiHole front-end when a group is enabled/disabled from HomeAssistant.

Credit to https://community.home-assistant.io/t/pihole-5-enable-disable-groups-block-internet/268927 for the insipration on how to manage PiHole via bash, 
and https://medium.com/codex/setup-a-python-script-as-a-service-through-systemctl-systemd-f0cc55a42267 for the service management aspect. 
   
   

