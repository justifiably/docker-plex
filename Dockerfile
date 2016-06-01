FROM debian:jessie

# 1. Create plex user
# 2. Download and install Plex
# 3. Create writable config directory in case the volume isn't mounted

# Note: We created a dummy /bin/start to avoid install to fail due to
# upstart not being installed.  We won't use upstart anyway.
RUN useradd --system --uid 797 -M --shell /usr/sbin/nologin plex \
 && apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install -y \
        ca-certificates \
        curl

# RUN DOWNLOAD_URL=`curl -Ls http://plex.baconopolis.net/latest.php` \
#  && echo $DOWNLOAD_URL \
# Justifiably: update this next URL manually myself for plexpass version

ENV DOWNLOAD_URL=https://downloads.plex.tv/plex-media-server/0.9.16.6.1993-5089475/plexmediaserver_0.9.16.6.1993-5089475_amd64.deb

RUN curl -L $DOWNLOAD_URL -o plexmediaserver.deb \
 && touch /bin/start \
 && chmod +x /bin/start \
 && dpkg -i plexmediaserver.deb \
 && rm -f plexmediaserver.deb \
 && rm -f /bin/start \
 && apt-get purge -y --auto-remove \
        curl \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* \
 && mkdir /config \
 && chown plex:plex /config

VOLUME /config
VOLUME /media

USER plex

EXPOSE 32400

# the number of plugins that can run at the same time
ENV PLEX_MEDIA_SERVER_MAX_PLUGIN_PROCS 6

# ulimit -s $PLEX_MEDIA_SERVER_MAX_STACK_SIZE
ENV PLEX_MEDIA_SERVER_MAX_STACK_SIZE 3000

# location of configuration, default is
# "${HOME}/Library/Application Support"
ENV PLEX_MEDIA_SERVER_APPLICATION_SUPPORT_DIR /config

ENV PLEX_MEDIA_SERVER_HOME /usr/lib/plexmediaserver
ENV LD_LIBRARY_PATH /usr/lib/plexmediaserver
ENV TMPDIR /tmp

WORKDIR /usr/lib/plexmediaserver
CMD test -f /config/Plex\ Media\ Server/plexmediaserver.pid && rm -f /config/Plex\ Media\ Server/plexmediaserver.pid; \
    ulimit -s $PLEX_MAX_STACK_SIZE && ./Plex\ Media\ Server
