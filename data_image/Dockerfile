From python:3.7

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

# Install dbt completion script
RUN curl https://raw.githubusercontent.com/fishtown-analytics/dbt-completion.bash/master/dbt-completion.bash > ~/.dbt-completion.bash
RUN /bin/bash -c "source ~/.dbt-completion.bash"
RUN echo 'source ~/.dbt-completion.bash' >> ~/.bash_profile

# Install VIM
RUN apt-get install -y vim

# Install the Snowflake ODBC
COPY snowflake_odbc.txt ./
RUN apt-get install -y unixodbc
RUN curl -o snowflake-odbc-2.19.3.x86_64.deb https://sfc-repo.snowflakecomputing.com/odbc/linux/2.19.3/snowflake-odbc-2.19.3.x86_64.deb
RUN dpkg -i snowflake-odbc-2.19.3.x86_64.deb
RUN apt-get install -y sqitch libdbd-odbc-perl
RUN cat snowflake_odbc.txt >> ./etc/odbcinst.ini

# Install SnowSQL CLI
ARG SnowSQL_Version=1.1.81
RUN curl -o snowsql-${SnowSQL_Version}-linux_x86_64.bash http://s3-us-west-2.amazonaws.com/sfc-snowsql-updates/bootstrap/1.1/linux_x86_64/snowsql-${SnowSQL_Version}-linux_x86_64.bash
RUN SNOWSQL_DEST=~/bin SNOWSQL_LOGIN_SHELL=~/.profile bash snowsql-${SnowSQL_Version}-linux_x86_64.bash
RUN rm snowsql-${SnowSQL_Version}-linux_x86_64.bash
ENV PATH="/root/bin:${PATH}"
RUN snowsql --version
