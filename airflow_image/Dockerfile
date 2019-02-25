FROM python:3.6

# Airflow Config
ARG AIRFLOW_VERSION=1.10.2
ARG AIRFLOW_HOME=/usr/local/airflow
ARG AIRFLOW_DEPS="crypto,gcp_api,google_auth,kubernetes,password,slack"
ENV AIRFLOW_GPL_UNIDECODE yes

# Kubectl Installation
ARG K8S_VERSION=v1.11.5
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

# Listening Server
COPY repo_watcher.py ${AIRFLOW_HOME}/repo_watcher.py
RUN chmod 777 -R ${AIRFLOW_HOME}/repo_watcher.py

# Env Config
EXPOSE 8080
ENV PATH "${AIRFLOW_HOME}:${PATH}"
ENV AIRFLOW_HOME=${AIRFLOW_HOME}
WORKDIR ${AIRFLOW_HOME}
