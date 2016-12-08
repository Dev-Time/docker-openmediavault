FROM debian:stretch

MAINTAINER Wyatt Henke <pcdriverpro@gmail.com>

# Add the OpenMediaVault repository
COPY openmediavault.list /etc/apt/sources.list.d/

ENV DEBIAN_FRONTEND noninteractive
ENV LANG C
ENV APT_LISTCHANGES_FRONTEND none

# Fix resolvconf issues with Docker
RUN echo "resolvconf resolvconf/linkify-resolvconf boolean false" | debconf-set-selections

# Install OpenMediaVault packages and dependencies
RUN apt-get update
RUN apt-get upgrade -y
RUN apt-get --allow-unauthenticated install openmediavault-keyring  -y --force-yes
RUN apt-get update
RUN apt-get --yes --autoremove --show-upgraded --allow-downgrades --allow-change-held-packages --no-install-recommends --option Dpkg::Options::="--force-confdef" --option DPkg::Options::="--force-confold" install postfix locales openmediavault -y --force-yes

# We need to make sure rrdcached uses /data for it's data
COPY defaults/rrdcached /etc/default

# Install omv-extras
RUN apt-get install apt-transport-https; wget http://omv-extras.org/openmediavault-omvextrasorg_latest_all.deb -O /tmp/omv-extras.deb; dpkg -i /tmp/omv-extras.deb; rm /tmp/omv-extras.deb; apt-get update

# Add our startup script last because we don't want changes
# to it to require a full container rebuild
COPY omv-startup /usr/sbin/omv-startup
RUN chmod +x /usr/sbin/omv-startup

EXPOSE 80 443

VOLUME /data

ENTRYPOINT /usr/sbin/omv-startup
