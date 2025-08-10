FROM nextcloud:31-fpm

RUN <<EOT
  set -ex
  apt-get update -y
  apt-get upgrade -y
  apt-get install -y --no-install-recommends ffmpeg ghostscript libmagickcore-6.q16-6-extra
  apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false
  rm -rf /var/lib/apt/lists/*
EOT
