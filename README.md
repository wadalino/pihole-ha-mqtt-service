# pihole-ha-mqtt-service
Pihole service that exposes group management (enable/disable) to Home Assistant with autoconfiguration.
It also exposes statistics as sensors, and it updates automatically (every 5 second if not set otherwise) when a group is enabled/disabled from the PiHole front-end itself.

![Parental control](https://github.com/Andrec83/pihole-ha-mqtt-service/blob/main/Parent%20Control.PNG)
![Pihole reporting](https://github.com/Andrec83/pihole-ha-mqtt-service/blob/main/PiHole%20reports.PNG)



## automated installation
1) exec .sh file from github with sudo or as root
   ```
   sudo bash <(curl -s https://raw.githubusercontent.com/wadalino/pihole-ha-mqtt-service/main/configure.sh)
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
   
4) Variables will be stored into file **'/env/ha-mqtt-environment'**, this file will be loaded by **'ha-mqtt-service.py'**  
  
  
5) There are two variables into downloaded **'mqtt-service.py'** file placed on **'ha-mqtt-service'** directory, called *DEBUG* and *TRACE* set as False by default. You can change them to True if you want to set in Debug or Trace MODE. Please note that write much information and log can grow too much -- remember to set to False when set to Production.  
 
  
6) The script check if Python3 is installed in the system, also check for required python packages required.


7) After script execution there are two new directories created in '/root/' folder:
   ```
   - ha-mqtt-service : this folder contents the python3 script and .env
      - mqtt-service.py : main script
      - .env : file with variables 
   - outFiles : this folder contents two files
      - mqtt-ha.service : this file controls the daemon execution
      - mqtt.yaml : the content of this file needs to be included in mqtt section of Home Assistant
      - card.yaml : this is a card sample that can be included to Home Assistant panel
   ```

8) File mqtt-ha.service is necessary to be moved to /etc/systemd/system to be installed as service (taken from https://medium.com/codex/setup-a-python-script-as-a-service-through-systemctl-systemd-f0cc55a42267):
   ```
   sudo mv /root/outFiles/mqtt-ha.service /etc/systemd/system/
   ```
   
9) Enable and start the service:
   ```
   sudo systemctl daemon-reload
   sudo systemctl enable mqtt-ha.service
   sudo systemctl start mqtt-ha.service
   ```   

10) check that everything is working well:
    ```
    sudo systemctl status mqtt-ha.service
    ```
    
*****************

## Requeriments
Please note that to use this software is necessary to have installed Python3 with packages specified in file  
[requirements.txt](https://raw.githubusercontent.com/wadalino/pihole-ha-mqtt-service/refs/heads/main/requirements.txt):
  ```
- paho-mqtt
- colorama
  ```

## Thanks to 
Thanks to [@Andrec83](https://github.com/Andrec83) for creation of this script.

### ToDo
The script can certainly be improved and generalised, happy for any contribution to come along. 
~~I need to improve the way I read info from the env file and manage cases where MQTT user and PWD are not necessary.~~ 
I also need to find a way to update PiHole front-end when a group i enabled/disabled from HomeAssistant.

Credit to https://community.home-assistant.io/t/pihole-5-enable-disable-groups-block-internet/268927 for the insipration on how to manage PiHole via bash, 
and https://medium.com/codex/setup-a-python-script-as-a-service-through-systemctl-systemd-f0cc55a42267 for the service management aspect. 
   
   

