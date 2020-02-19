FROM python:3.6

# Airflow Config
ARG AIRFLOW_VERSION=1.10.4
ARG AIRFLOW_HOME=/usr/local/airflow
ARG AIRFLOW_DEPS="crypto,gcp_api,google_auth,kubernetes,password,slack"
ENV AIRFLOW_GPL_UNIDECODE yes

ENV AIRFLOW_HOME=${AIRFLOW_HOME}

COPY prometheus_config.yml "${AIRFLOW_HOME}/prometheus_config.yml"

# Kubectl Installation
ARG K8S_VERSION=v1.15.7
RUN curl -LO https://storage.googleapis.com/kubernetes-release/release/$K8S_VERSION/bin/linux/amd64/kubectl
RUN chmod +x ./kubectl
RUN mv ./kubectl /usr/local/bin/kubectl

# Airflow Installation
RUN pip install -U pip
RUN pip install apache-airflow[${AIRFLOW_DEPS}]==${AIRFLOW_VERSION}
COPY airflow.cfg ${AIRFLOW_HOME}/airflow.cfg


# Python Deps
COPY requirements.txt .
RUN pip install -r requirements.txt

# Install Google SQL Proxy
RUN wget https://dl.google.com/cloudsql/cloud_sql_proxy.linux.amd64 -O /usr/bin/cloud_sql_proxy
RUN chmod +x /usr/bin/cloud_sql_proxy

# Install Google Cloud SDK
ENV CLOUD_SDK_REPO="cloud-sdk-stretch"
RUN echo "deb http://packages.cloud.google.com/apt $CLOUD_SDK_REPO main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
RUN curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
RUN apt-get update && apt-get install -y google-cloud-sdk

# Listening Server
COPY repo_watcher.py ${AIRFLOW_HOME}/repo_watcher.py
RUN chmod 777 -R ${AIRFLOW_HOME}/repo_watcher.py

# Env Config
EXPOSE 8080
ENV PATH "${AIRFLOW_HOME}:${PATH}"
WORKDIR ${AIRFLOW_HOME}
