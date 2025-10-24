FROM plone/plone-backend:6
LABEL maintainer="EEA: IDM2 A-Team <eea-edw-a-team-alerts@googlegroups.com>"

RUN mv /app/docker-entrypoint.sh /app/plone-entrypoint.sh \
 && mv /app/constraints.txt /app/plone-constraints.txt

COPY requirements.txt constraints.txt /app/

RUN bin/pip install -r requirements.txt -c plone-constraints.txt -c constraints.txt \
 && find /app -not -user plone -exec chown plone:plone {} \+

COPY docker-entrypoint.sh /app/
USER root
