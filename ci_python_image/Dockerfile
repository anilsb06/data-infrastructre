FROM python:3.8-slim-buster

# Copy in required files
COPY requirements.txt ./

# Install Python Requirements
RUN pip install -U pip
RUN pip install -r requirements.txt

# Upgrade git to latest
RUN touch /etc/apt/sources.list.d/sources.list
RUN echo "deb http://deb.debian.org/debian buster-backports main" >> /etc/apt/sources.list.d/sources.list
RUN apt-get update && apt-get -t buster-backports install -y git
