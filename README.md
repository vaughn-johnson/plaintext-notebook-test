---
jupytext:
  formats: md:myst,ipynb
  text_representation:
    extension: .md
    format_name: myst
    format_version: 0.13
    jupytext_version: 1.11.5
kernelspec:
  display_name: Python 3
  language: python
  name: python3
---

```{code-cell} ipython3
import numpy as np
import pandas as pd
import plotly.express as px
```

# PDRs in Jupyter Notebooks

## Why it's great
Jupyter notebooks are well suited for the use-cases data-scientists run into
- Inline explanations immediately adjacent to code
- Integrated caching to easily share results _as_ plot definitions
- Integrated kernel so results are reproducible
- Supports interactivity

## Drawback
The major drawback that has lead us to _not_ adopting Jupyter is our review process in Github. Jupyter represents all of its data using JSON, which makes diffs difficult to read and inline PR comments impossible.

## Solution
Using `jupyter-book`, we can use **Markedly Structured Text (MyST)**

```shell
python3 -m ipykernel install --user
pip install -U jupyter
pip install -U jupyter-book
jupyter-book create [XYZ]
jupyter-book myst init [XYZ]/markdown.md --kernel python3
juputer notebook
```

You can navigate to `markdown.md`, and open it _as a Jupyter notebook_. Saving chnages to the notebook saves changes to `markdown.md` that are readily legible as a git diff. 

You can export the requirements for your project using `pipreqs`

```
jupytext --from md --to ipynb $1.md
jupyter nbconvert --to python $1.ipynb
pipreqs reqs --force --print > requirements.txt
rm -r reqs
```

TODO: elaborate on virtual environments

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
