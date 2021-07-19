FROM jupyter/tensorflow-notebook:350928623d27

# Install from requirements.txt file
COPY --chown=${NB_UID}:${NB_GID} requirements.txt /tmp/

USER root

RUN apt-get update
RUN apt-get install -y unixodbc-dev
RUN apt-get install --reinstall -y build-essential

# Ignore the crazy errors from this build, they are expected.
RUN cd /home && git clone -b issue191 git://github.com/jcrudy/py-earth.git  && \
    cd py-earth && python setup.py install --cythonize

RUN cd /home && mv py-earth/ /usr/local/lib/python3.8/site-packages/

USER ${NB_UID}

RUN pip install --no-cache-dir --requirement /tmp/requirements.txt && \
    fix-permissions "${CONDA_DIR}" && \
    fix-permissions "/home/${NB_USER}"

