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
- [Jupyter](https://jupyter.org/install)
- [Jupyter Book](https://jupyterbook.org/start/overview.html)
- [Anaconda](https://docs.anaconda.com/anaconda/install/)



## Virtual enviornments and kernels

### Anaconda
Anaconda is a virtual environment manager. Virtual environments (venvs) allow
you to encapsulate the development environment of your project so you can easily
switch between using different versions of different Python packages. You can
easily export these venvs to guarantee everyone who is developing or reviewing a
particular project has an identical environment.

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

### IPython kernel
The IPython kernel is the runtime environment used by Jupyter to execute Python
in the notebook. 

In a conda venv that includes `ipykernel` as a dependency you can create a new
kernel using

```shell
python -m ipykernel install --user --name ... --display-name ...
```

It is sufficient to include `jupyter` as dependency, since `ipykernel` is one of
its own dependencies.

The Python version of the kernel is determined by what version of Python is used
to create the kernel (or venv).


## Jupyter and Jupyter Book

### Jupyter
Jupyter is software that enables you to interact with notebooks. At its core, it
is a server. You can check that you have it installed correctly by initiating a
server instance on your local machine

```shell
jupyter notebook
```

### Jupytext and Kernels
Notebooks are great, but the major drawback is that the data representation of
Jupyter notebooks do not lend themselves to the traditional code-review process.
Jupyter represents all of its data using JSON, which makes diffs difficult to
read and inline PR comments impossible.

However, using `jupyter-book` we can use **Markedly Structured Text (MyST)**,
which extends the syntax of Markdown to support being interpreted _as_ a Jupyter
notebook. This enables us to represent notebooks as a plaintext markdown file,
not JSON!

In Jupyter, you can select between these kernels in the `Kernel` tab under
`Change Kernel`. Check that you have access to at least one kernel using

```shell
jupyter kernelspec list
```

You can enable switching between _all_ the kernels on your machine for any
notebook using

```shell
conda install nb_conda_kernels
```

This enables you to decouple the environment the Jupyter server is running in
from the environment you're working in _within_ the IPKernel. You can add
extensions (e.g. `Jupytext`) to your `base` environment.

This is relevant because you may find that you find that you're only able to use
`jupytext` in Jupyter notebooks if you install it using `pip`

```shell
pip install jupytext --upgrade
```



## Creating a notebook
The first thing you'll need to do is create a new virtual environment that has
IPython kernel as a dependency

```shell
conda create --name my-venv jupyter ipykernel
conda activate my-venv
```

Then you'll need to add `jupyter book`

```shell
conda install -c conda-forge jupyter-book
```

You can then create your first Jupyter book and initialize a markdown file that
will house our new notebook.
```shell
jupyter-book create my-notebook
jupyter-book myst init my-notebook/README.md
```

You can then launch `jupyter` in your `base` environment to view that notebook
in the Jupyter UI.

```shell
juputer notebook
```

If everything has gone right, you should be able to open the markdown file as a
notebook! As you make changes to `README.me`, jupyter-book will automatically
update `README.ipynb` to reflect to those changes. Make sure to select the
`my-env` venv from the list of kernels in the notebook.

### Sharing the notebook
`jupyter-book create` will add certain files that will soemtimes not be
relevant. `README.md` is all you _strictly_ need, though without `README.ipynb`
your output will not be cached so others will have to rerun your notebook to see
your outputs. `_config.yml` will have some configurations that may or may not be
relevant ot what you're working on. Check
[here](https://jupyterbook.org/customize/config.html) to see what you should
keep. Everything else has its place, but for most projects can be removed
without issue.

It is important, however, that other people are able to reproduce your venv. In
order to export your venv, run

```shell
conda conda env export > venv.yml
```

The person wishing to reproduce the results of the notebook can now recreate the
enviornment with

```shell
conda env create --file venv.yml
```

```{code-cell} ipython3
import numpy as np
import pandas as pd
import plotly.express as px
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
