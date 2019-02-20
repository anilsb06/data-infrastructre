FROM python:3.6

# Airflow
ARG AIRFLOW_VERSION=1.10.2
ARG AIRFLOW_HOME=/usr/local/airflow
ARG AIRFLOW_DEPS="crypto,gcp_api,google_auth,kubernetes,password,slack"
ENV AIRFLOW_GPL_UNIDECODE yes

RUN pip install -U pip
RUN pip install apache-airflow[${AIRFLOW_DEPS}]==${AIRFLOW_VERSION}

COPY airflow.cfg ${AIRFLOW_HOME}/airflow.cfg
COPY requirements.txt .

RUN pip install -r requirements.txt

EXPOSE 8080

ENV AIRFLOW_HOME ${AIRFLOW_HOME}
WORKDIR ${AIRFLOW_HOME}
