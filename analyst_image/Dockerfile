FROM jupyter/tensorflow-notebook:350928623d27


USER root

RUN apt-get update
RUN apt-get install -y unixodbc-dev
RUN apt-get install --reinstall -y build-essential

USER ${NB_UID}
# Install from requirements.txt file
COPY --chown=${NB_UID}:${NB_GID} requirements.txt /tmp/

RUN pip install --no-cache-dir --requirement /tmp/requirements.txt && \
    fix-permissions "${CONDA_DIR}" && \
    fix-permissions "/home/${NB_USER}"

USER root

# Ignore the crazy errors from this build, they are expected.
RUN cd /home/jovyan && git clone -b issue191 git://github.com/jcrudy/py-earth.git  && \
    cd py-earth && python setup.py -q install --cythonize
RUN mkdir /opt/conda/lib/python3.9/site-packages/pyearth
RUN mv /home/jovyan/py-earth/pyearth /opt/conda/lib/python3.9/site-packages/pyearth/

USER ${NB_UID}
