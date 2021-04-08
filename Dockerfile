FROM ubuntu:20.04
LABEL maintainer="Saliuk Ivan <iwan.salyuk@gmail.com>"

#update & upgrade
RUN apt update
RUN apt upgrade -y

# Configure user
RUN apt install sudo -y
RUN useradd -ms /bin/bash FareOn
RUN rm -f /etc/sudoers
COPY docker/sudoers /etc/sudoers

# Configure ssh
RUN apt install openssh-server -y
RUN rm -f /etc/ssh/sshd_config
COPY docker/ssh/sshd_config /etc/ssh/sshd_config
RUN mkdir -p /run/sshd

#Configure key for user
RUN mkdir -p /home/FareOn/.ssh
COPY docker/ssh/authorized_keys /home/FareOn/.ssh/authorized_keys
RUN chown FareOn:FareOn -R /home/FareOn/.ssh
RUN chmod 700 /home/FareOn/.ssh && chmod 600 /home/FareOn/.ssh/authorized_keys

# Configure Apache
RUN apt install apache2 -y
RUN rm -f /var/www/html/index.html
COPY docker/apache2/index.html /var/www/html/index.html
RUN rm -f /etc/apache2/sites-available/000-default.conf
COPY docker/apache2/000-default.conf /etc/apache2/sites-available/000-default.conf
RUN rm -f /etc/apache2/ports.conf
COPY docker/apache2/ports.conf /etc/apache2/ports.conf

#Configure Tomcat
RUN apt install default-jdk -y
RUN groupadd tomcat
RUN useradd -s /bin/false -g tomcat -d /opt/tomcat tomcat
RUN wget https://apache.ip-connect.vn.ua/tomcat/tomcat-9/v9.0.45/bin/apache-tomcat-9.0.45.tar.gz
RUN mkdir /opt/tomcat
RUN tar xzvf apache-tomcat-*tar.gz -C /opt/tomcat --strip-components=1
RUN chgrp -R tomcat /opt/tomcat && chmod -R g+r /opt/tomcat/conf && chown -R tomcat /opt/tomcat/webapps/ /opt/tomcat/work/ /opt/tomcat/temp/ /opt/tomcat/logs/
RUN apt install systemctl -y
RUN rm -f /opt/tomcat/conf/server.xml
COPY docker/tomcat/server.xml /opt/tomcat/conf/server.xml


# Configure Supervisord
RUN apt install -y supervisor
RUN mkdir -p /var/log/supervisord/
COPY docker/supervisord/apache2.conf /etc/supervisor/conf.d/apache2.conf
COPY docker/supervisord/ssh.conf /etc/supervisor/conf.d/ssh.conf
COPY docker/supervisord/tomcat.conf /etc/supervisor/conf.d/tomcat.conf

#Run Supervisord
CMD ["/usr/bin/supervisord"]


EXPOSE 2021 81 443 8083
