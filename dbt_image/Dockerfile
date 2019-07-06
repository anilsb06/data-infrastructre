From python:3.7

# Copy in required files
COPY requirements.txt ./

# Install Python Requirements
RUN pip install -U pip
RUN pip install -r requirements.txt

# Install dbt completion script
RUN curl https://raw.githubusercontent.com/fishtown-analytics/dbt-completion.bash/master/dbt-completion.bash > ~/.dbt-completion.bash
RUN /bin/bash -c "source ~/.dbt-completion.bash"
RUN echo 'source ~/.dbt-completion.bash' >> ~/.bash_profile

# Install VIM
RUN apt-get update
RUN apt-get install -y vim
