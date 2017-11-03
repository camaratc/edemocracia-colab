FROM labhackercd/alpine-python2-nodejs

ENV BUILD_PACKAGES python-dev python3 python3-dev linux-headers \
    git ca-certificates gcc postgresql-dev build-base bash \
    postgresql-client gettext libxml2-dev libxslt-dev zlib-dev jpeg-dev

RUN apk add --update --no-cache $BUILD_PACKAGES
RUN mkdir -p /etc/colab /etc/colab/settings.d /etc/colab/plugins.d \
    /etc/colab/widgets.d /var/labhacker/colab-plugins /var/labhacker/colab/public/media

ADD . /var/labhacker/colab
WORKDIR /var/labhacker/colab

RUN pip install . psycopg2 gunicorn elasticsearch python-memcached easy_thumbnails && \
    rm -r /root/.cache

RUN pip install colab-edemocracia colab-audiencias colab-discourse colab-wikilegis

COPY ./misc/etc/colab/settings.py ./misc/etc/colab/gunicorn.py /etc/colab/
COPY ./misc/etc/colab/settings.d/01-database.py \
     ./misc/etc/colab/settings.d/02-staticfiles.py \
     ./misc/etc/colab/settings.d/02-staticfiles.py \
     ./misc/etc/colab/settings.d/03-memcached.py \
     /etc/colab/settings.d/

COPY ./misc/etc/colab/plugins.d/edemocracia.py /etc/colab/plugins.d/

RUN npm install -g bower &&\
    colab-admin bower_install --allow-root && \
    colab-admin collectstatic --noinput && \
    colab-admin compilemessages
