FROM ruby:2.6

RUN apt-get -y update && \
    apt-get -y install nodejs mariadb-client git gettext

RUN useradd -r -m -d /opt/postal -s /bin/bash postal
RUN setcap 'cap_net_bind_service=+ep' $(which ruby)

RUN gem install bundler
RUN gem install procodile

RUN mkdir -p /opt/postal/app
RUN wget https://postal.atech.media/packages/stable/latest.tgz -O - | tar zxpv -C /opt/postal/app

WORKDIR /opt/postal/app

RUN chown -R postal:postal .

RUN ln -s /opt/postal/app/bin/postal /usr/bin/postal

RUN postal bundle /opt/postal/vendor/bundle


COPY run.sh /run.sh
COPY postal.env.yml /postal.env.yml

# Convert DOS/Windows newline (CRLF) to Unix newline (LF)
RUN sed -i "s/\r$/ /g" /run.sh
RUN chmod +x /run.sh


EXPOSE 5000

CMD ["/run.sh", "run"]