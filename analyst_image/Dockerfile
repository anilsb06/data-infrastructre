FROM jupyter/tensorflow-notebook:350928623d27


USER root

RUN apt-get update
RUN apt-get install -y unixodbc-dev
RUN apt-get install --reinstall -y build-essential

#


USER ${NB_UID}
# Install from requirements.txt file
COPY --chown=${NB_UID}:${NB_GID} requirements.txt /tmp/

RUN pip install --no-cache-dir --requirement /tmp/requirements.txt && \
    fix-permissions "${CONDA_DIR}" && \
    fix-permissions "/home/${NB_USER}"

RUN conda create -n py-earth-env
# Make RUN commands use the new environment:
SHELL ["conda", "run", "-n", "py-earth-env", "/bin/bash", "-c"]
RUN conda install -y -c conda-forge/label/cf202003 sklearn-contrib-py-earth
