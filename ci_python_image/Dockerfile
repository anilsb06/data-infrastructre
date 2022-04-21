FROM python:3.8-slim-buster

# Copy in required files
COPY requirements.txt ./

# Install Python Requirements
RUN pip install -U pip
RUN pip install -r requirements.txt