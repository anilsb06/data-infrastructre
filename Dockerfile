From python:3.6

COPY requirements.txt ./

RUN pip install -U pip
RUN pip install -r requirements.txt
