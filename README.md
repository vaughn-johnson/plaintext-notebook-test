---
jupytext:
  formats: md:myst,ipynb
  text_representation:
    extension: .md
    format_name: myst
    format_version: 0.13
    jupytext_version: 1.13.7
kernelspec:
  display_name: Python 3 (ipykernel)
  language: python
  name: python3
---

# Plaintext Jupyter Notebooks


## Why it's great
Jupyter notebooks are well suited for data science work:
- Typeset explanations immediately adjacent to code
- Built-in caching
- Results are reproducible and easily extended
- Supports interactive plots



## Install
You'll need to begin by installing
- [Docker](https://docs.docker.com/get-docker/)
- [Jupyter](https://jupyter.org/install)
- [Jupyter Book](https://jupyterbook.org/start/overview.html)
- [Anaconda](https://docs.anaconda.com/anaconda/install/)



## Virtual environments and kernels

### Anaconda
Anaconda is a virtual environment manager. Virtual environments (venvs) allow
you to encapsulate the development environment of your project so you can easily
switch between using different versions of Python and Python packages. You can
easily export these venvs to guarantee everyone who is developing or reviewing a
particular project has an identical environment.

Unfortunately Anaconda is somewhat "bloated", but we can take advantage of drop in replacements like [mamba](https://github.com/mamba-org/mamba) (this is what is used in the Dockerfile).

Make sure [Anaconda](https://docs.anaconda.com/anaconda/install/) is installed
and ready to go:

```shell
conda --version
```

You can create a new virtual environment with `create` and start using that
environment using `activate`. 

```shell
conda create --name myenv dependency1 dependency2
conda activate myenv
```

You can stop using it with `deactivate`. The the environment you switch to when
you deactivate is called `base`.

## Jupyter and Jupytext

### Jupyter
Jupyter is software that enables you to interact with notebooks. At its core, it
is a server. You can check that you have installed it correctly by initiating a
server instance on your local machine

```shell
jupyter notebook
```

In your browser, this should open automatically open the localhost url that the
server is running on.

#### Kernels
A Jupyter kernel is the runtime environment used by Jupyter to execute code
in the notebook.

##### IPython kernel
The IPython kernel is used to execute Python in the notebook. 

In a conda venv that includes `ipykernel` as a dependency you can create a new
kernel using

```shell
python -m ipykernel install --user --name ... --display-name ...
```

It is sufficient to include `jupyter` as dependency, since `ipykernel` is one of
its own dependencies.

The Python version of the kernel is determined by what version of Python is used
to create the kernel (or venv).

##### IR kernel
The [IR kernel](https://irkernel.github.io/) is the runtime environment used by
Jupyter to execute R in the notebook.

You can install the kernel in R by following the instructions
[here](https://irkernel.github.io/installation/)

```shell
conda install -c conda-forge r-irkernel
R -e 'IRkernel::installspec()'
```
### Jupytext
Notebooks are great, but the major drawback is that the data representation of
Jupyter notebooks do not lend themselves to the traditional code-review process.
Jupyter represents all of its data using JSON, which makes diffs difficult to
read and inline PR comments impossible.

However, using `jupytext` we can use **Markedly Structured Text (MyST)**,
which extends the syntax of Markdown to support being interpreted _as_ a Jupyter
notebook. This enables us to represent notebooks as a plaintext markdown file,
not JSON!


## Docker
[Docker](https://www.docker.com/) is software that abstracts the runtime environment into things called "containers". The environment is defined by what's called a Docker image (see [Dockerfile](./Dockerfile)) There are [public repositores](https://hub.docker.com/) for Docker images, including [images for Jupyter](https://jupyter-docker-stacks.readthedocs.io/en/latest/). Docker images are built into containers which can be run from anywhere.

We can leverage a docker container to

1. Prescribe the environment the notebook is run in
1. Define the kernel we use

### Docker and Kernels
In Jupyter, you can select between these kernels in the `Kernel` tab under
`Change Kernel`.

You can enable switching between _all_ the kernels on your container for any
notebook using

```shell
conda install nb_conda_kernels
```

This enables you to decouple the environment the Jupyter server is running in
from the environment of the kernel you're using.

This is relevant because unfortunately there are problems with `jupytext` and `conda`.

```shell
pip install jupytext --upgrade --user
```

 We also don't actually _want_ `jupytext` to be a part of our kernel's dependencies. For these reasons, we can create a special, one-off `conda` venv to _define_ our kernel _in the Dockerfile_.

 ```Dockerfile
 RUN cd "/home/${NB_USER}/tmp/" && \
    conda env create -p "${CONDA_DIR}/envs/${KERNEL_NAME}" -f venv.yml && \
    conda clean --all -f -y

 RUN "${CONDA_DIR}/envs/${KERNEL_NAME}/bin/python" -m ipykernel install --user --name="${KERNEL_NAME}" && \
    fix-permissions "${CONDA_DIR}" && \
    fix-permissions "/home/${NB_USER}"
```

Now we can abstract all of the dependencies we want our _kernel_ to have access to to the venv defined by [venv.yml](./venv.yml).

## Creating a notebook
The first thing you'll need to do is initialize a markdown file that will house our new notebook.

```shell
echo "# Hello World\n👋👋👋" > README.md
```

You can [optionally include YAML metadata](https://jupytext.readthedocs.io/en/latest/formats.html) at the top of the markdown file
```markdown
---
jupyter:
  jupytext:
    text_representation:
      extension: .md
      format_name: markdown
      format_version: '1.1'
      jupytext_version: 1.1.0
  kernelspec:
    display_name: Python 3
    language: python
    name: python3
---
# Hello World
👋👋👋
```

The next step is create a `Dockerfile` that will define the Docker Image that we will use to build the container that will run the jupyter server. Something as simple as this can suffice

```Dockerfile
# Dockerfile
FROM jupyter/datascience-notebook:latest

RUN mamba install -c conda-forge jupytext
```

We can use Docker's CLI to build the image into a container. Here we name it `notebook`.

```shell
docker build -t notebook .
```

- `-t` means tag, and defines the name of the container we're building
- This can be time consuming, but the results are cached, so iterating on a Dockerfile won't take as long as building it the first time


Once the image is built, we can run the container!

```shell
docker run -p 8888:8888 -v "${PWD}":/home/jovyan notebook
```

-  The image we're building off of (`FROM jupyter/datascience-notebook:latest`) will automatically start the jupyter server when the container is run
- We need to map the port in the container to a port on our machine (this what `-p 8888:8888` does)
- The image we're using defines a directory `/home/jovyan/`. In order to smoothly move files from our present directory to the container we include the argument `-v "${PWD}":/home/jovyan`. Changes made to files in the container will be saved locally. 

### Sharing the notebook
It is important that other people are able to reproduce the venv you use are using to define the your kernel. In order to do this, you'll need to define a `venv.yml` file. You can create one for the your current conda venv with the command:

```shell
conda env export > venv.yml
```

The person wishing to reproduce the results of the notebook can now recreate the
environment with

```shell
conda env create --file venv.yml
```

This is abstracted away by the `Dockerfile`

```Dockerfile
COPY --chown=${NB_UID}:${NB_GID} venv.yml "/home/${NB_USER}/tmp/"

RUN cd "/home/${NB_USER}/tmp/" && \
    mamba env create -p "${CONDA_DIR}/envs/${KERNEL_NAME}" -f venv.yml && \
    mamba clean --all -f -y
```

If you'd like to make a dependency available to your kernel, the easiest way is to directly add it to `venv.yml`.

```{code-cell} ipython3
import numpy as np
import pandas as pd
import plotly.express as px
import plotly.io as pio

pio.renderers.default = "iframe"
```

```{code-cell} ipython3
def simulate(N):
    np.random.seed(0)

    return pd.DataFrame({
        'x': np.random.normal(size=N),
        'y': np.random.exponential(size=N),
        'z':np.random.choice(list('abc'), N)
    })
```

```{code-cell} ipython3
results = simulate(1000)

px.scatter(x=results.x, y=results.y, color=results.z)
```
