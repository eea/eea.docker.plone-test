FROM plone:5
MAINTAINER "EEA: IDM2 A-Team" <eea-edw-a-team-alerts@googlegroups.com>

USER root

RUN runDeps="curl git gcc libc-dev ImageMagick ghostscript libmagickcore-6.q16-2-extra graphviz libjpeg62-turbo-dev" \
 && apt-get update \
 && apt-get install -y --no-install-recommends $runDeps \
 && rm -rf /var/lib/apt/lists/* \
 && mv develop.cfg develop-plone.cfg \
 && mv /docker-entrypoint.sh /plone-entrypoint.sh

USER plone
COPY develop.cfg /plone/instance/
RUN bin/pip install --upgrade zc.buildout \
 && bin/buildout -c develop.cfg
COPY docker-entrypoint.sh /
