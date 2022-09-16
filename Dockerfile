FROM jupyter/datascience-notebook:latest

# This has nothing to do whatsoever with the kernel (i.e., the code being run in
# the notebook itself). Jupytext is a dependency for the jupyter server
RUN mamba install -c conda-forge jupytext nb_conda_kernels

# All of the folloiwng code has nothing to do with the jupyter server being run.
# It simply takes what's in venv.yml, creates a new venv, and then uses that
# venv to create a new jupyter kenerl (which we will use in the notebook)
ARG KERNEL_NAME=python39

COPY --chown=${NB_UID}:${NB_GID} venv.yml "/home/${NB_USER}/tmp/"

RUN cd "/home/${NB_USER}/tmp/" && \
    mamba env create -p "${CONDA_DIR}/envs/${KERNEL_NAME}" -f venv.yml && \
    mamba clean --all -f -y

RUN "${CONDA_DIR}/envs/${KERNEL_NAME}/bin/python" -m ipykernel install --user --name="${KERNEL_NAME}" && \
    fix-permissions "${CONDA_DIR}" && \
    fix-permissions "/home/${NB_USER}"

# Have markdowns automatically open as notebooks
COPY ./jupyter_settings.json .jupyter/lab/user-settings/@jupyterlab/docmanager-extension/plugin.jupyterlab-settings
