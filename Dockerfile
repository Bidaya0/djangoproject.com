# pull official base image
FROM python:3.8-alpine

# set work directory
WORKDIR /usr/src/app

# set environment varibles
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

# install psycopg2
RUN apk update \
    && apk add --virtual build-deps gcc python3-dev musl-dev \
    && apk add postgresql-dev \
    && apk add gettext-dev \
    && apk add rsync \
    && pip install psycopg2 \
    && apk del build-deps

# install node and npm
RUN apk add --update nodejs npm

# install pillow dependencies
RUN apk add build-base python3-dev py-pip jpeg-dev zlib-dev
ENV LIBRARY_PATH=/lib:/usr/lib

# install psql client
RUN apk --update add postgresql-client

# install git
RUN apk add git

# install dependencies
RUN pip install --upgrade pip
COPY ./requirements ./requirements
COPY ./package.json ./package.json
RUN pip install -r ./requirements/dev.txt
RUN pip install -r ./requirements/tests.txt
RUN pip install tox
RUN npm install

# copy docker-entrypoint.sh
COPY ./docker-entrypoint.sh ./docker-entrypoint.sh

RUN apk add curl
RUN apk add gcc make cmake bash
RUN apk add libc-dev linux-headers
# copy project
COPY . .
RUN curl -X GET "https://iast.io/openapi/api/v1/agent/download?url=https://iast.io/openapi&language=python&projectName=djangoprojects.com" -H "Authorization: Token 79798299b48839c84886d728958a8f708e119868" -o /tmp/dongtai-agent-python.tar.gz -k && pip install /tmp/dongtai-agent-python.tar.gz
# run docker-entrypoint.sh
ENTRYPOINT ["./docker-entrypoint.sh"]
