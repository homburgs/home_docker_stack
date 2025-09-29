FROM ubuntu:24.04

RUN <<EOT
  set -ex
  apt-get update
  apt-get upgrade -y
  apt-get install -y dovecot-imapd locales
  apt-get clean
  apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false
  locale-gen de_DE.UTF-8
  update-locale LANG=de_DE.UTF-8 LC_MESSAGES=POSIX
EOT

COPY ./dovecot/dovecot.conf /etc/dovecot/dovecot.conf
COPY ./dovecot/addDovecotUser.sh /addDovecotUser.sh

RUN chmod +x /addDovecotUser.sh

ENV LANG=de_DE.utf8

EXPOSE 143

ENTRYPOINT ["dovecot", "-F"]
