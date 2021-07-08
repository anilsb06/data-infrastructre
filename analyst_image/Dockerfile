# Start from a core stack version
FROM jupyter/datascience-notebook

# Install from requirements.txt file
COPY --chown=${NB_UID}:${NB_GID} requirements.txt /tmp/

USER root

RUN apt-get update && apt-get install --reinstall build-essential  -y

USER ${NB_UID}

RUN pip install --quiet --no-cache-dir --requirement /tmp/requirements.txt && \
    fix-permissions "${CONDA_DIR}" && \
    fix-permissions "/home/${NB_USER}"

