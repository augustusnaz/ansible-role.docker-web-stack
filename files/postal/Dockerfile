FROM ruby:2.6

RUN apt-get update

ENV DEBIAN_FRONTEND noninteractive


ENV DOCKERIZE_VERSION v0.6.1



###########################################################################
# Dependencies:
###########################################################################

RUN apt install -y  --no-install-recommends \
	git-core libcap2-bin \
	build-essential rabbitmq-server nodejs mariadb-client git wget


###########################################################################
# Source:
###########################################################################

RUN git clone https://github.com/atech/postal.git /opt/postal \
	&& rm -rf /var/lib/apt/lists/*
RUN ln -s /opt/postal/bin/postal /usr/bin/postal


###########################################################################
# System gems:
###########################################################################

RUN gem install bundler
RUN gem install procodile
RUN gem install tzinfo-data


###########################################################################
# System prep:
###########################################################################

RUN useradd -r -m -d /opt/postal -s /bin/bash postal
RUN setcap 'cap_net_bind_service=+ep' $(which ruby)
RUN chown -R postal:postal /opt/postal/


###########################################################################
# App & Dependencies:
###########################################################################

RUN /opt/postal/bin/postal bundle /opt/postal/vendor/bundle \
	&& apt-get -y purge python-dev git-core \
	&& apt-get -y autoremove \
	&& apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*



###########################################################################
# Install jwilder/dockerize:
###########################################################################

RUN wget https://github.com/jwilder/dockerize/releases/download/$DOCKERIZE_VERSION/dockerize-linux-amd64-$DOCKERIZE_VERSION.tar.gz \
    && tar -C /usr/local/bin -xzvf dockerize-linux-amd64-$DOCKERIZE_VERSION.tar.gz \
    && rm dockerize-linux-amd64-$DOCKERIZE_VERSION.tar.gz



WORKDIR /opt/postal



ADD run.sh /run.sh

# Convert DOS/Windows newline (CRLF) to Unix newline (LF)
RUN sed -i "s/\r$/ /g" /run.sh
RUN chmod +x /run.sh



ARG DB_HOST=mariadb
ARG POSTAL_FNAME
ARG POSTAL_LNAME
ARG POSTAL_PASSWORD
ARG POSTAL_EMAIL

ENV DB_HOST $DB_HOST
ENV POSTAL_FNAME $POSTAL_FNAME
ENV POSTAL_LNAME $POSTAL_LNAME
ENV POSTAL_PASSWORD $POSTAL_PASSWORD
ENV POSTAL_EMAIL $POSTAL_EMAIL



# EXPOSE 80 443 25 110 143 465 587 993 995 4190
EXPOSE 5000

VOLUME [ "/var/lib/mysql", "/opt/postal/log" ]

CMD ["/run.sh"]

