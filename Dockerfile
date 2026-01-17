# Usamos la imagen base de Pi-hole
FROM pihole/pihole:latest

# Instalar s6-overlay
# ADD https://github.com/just-containers/s6-overlay/releases/download/v3.2.0.2/s6-overlay-amd64.tar.gz /
ADD https://github.com/just-containers/s6-overlay/releases/download/v3.2.0.2/s6-overlay-i686.tar.xz /

# Copiar y configurar los servicios (esto depende de tu configuración)
#COPY services /etc/services.d/

# Instalamos Python3 y pip
RUN apt-get update && \
    apt-get install -y python3 python3-pip

# Instalamos los paquetes necesarios
RUN pip3 install paho-mqtt==2.1.0 \
                pycrypto==2.6.1 \
                typing-extensions==4.7.1 \
                colorama

# copy python file
COPY ./mqtt-service.py /root/mqtt-service.py

# copy new service
COPY ./mqtt-ha.service  /etc/services.d/

# copy envorinment
COPY ./environment /etc/environment

RUN chmod +x /etc/services.d/mqtt-ha.service
