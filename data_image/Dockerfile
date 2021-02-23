FROM python:3.7

# Copy in required files
COPY requirements.txt ./

# Install Python Requirements
RUN pip install -U pip
RUN pip install -r requirements.txt

# Install Google SQL Proxy
RUN wget https://dl.google.com/cloudsql/cloud_sql_proxy.linux.amd64 -O /usr/bin/cloud_sql_proxy
RUN chmod +x /usr/bin/cloud_sql_proxy

# Install Google Cloud SDK
ENV CLOUD_SDK_REPO="cloud-sdk-stretch"
RUN echo "deb http://packages.cloud.google.com/apt $CLOUD_SDK_REPO main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
RUN curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
RUN apt-get update && apt-get install -y google-cloud-sdk

# Install VIM
RUN apt-get install -y vim

# Install yq v4.6.0 https://mikefarah.gitbook.io/yq/
RUN wget https://github.com/mikefarah/yq/releases/download/v4.6.0/yq_linux_arm64 -O /usr/bin/yq && chmod +x /usr/bin/yq

# Upgrade git to latest
RUN touch /etc/apt/sources.list.d/sources.list
RUN echo "deb http://deb.debian.org/debian buster-backports main" >> /etc/apt/sources.list.d/sources.list
RUN apt-get update && apt-get -t buster-backports install -y git
