# Laboratory material

Code and slides from laboratories run as a teaching assistant at the Institute of Computer Science, University of Wrocław. Comments and slides are partly in Polish.

## neural-networks (Matlab, 2005–2006)

Scripts and functions for a neural networks course: multilayer perceptrons initialised from discriminant directions (`turbo2lp*.m`, `turbo3lp*.m`, `cascdiscr.m`), simulated annealing for network weights (`simannealing_cl.m`, `puresimann_cl.m`), error visualisation (`errorviz*.m`), and a tutorial on Bayesian networks over the Spambase data (`bayesnet*.m`, `bayesask.m`). The `.jpg` files are result plots.

`bayes-nets-earlier/` holds earlier generations of the Bayesian network scripts; `nowsze` is Polish for "newer" and `najnowsze` for "newest".

The code calls two toolboxes that are not included: Netlab by Ian Nabney and the Bayes Net Toolbox by Kevin Murphy. `efficiency.m` is modified from Netlab's `confmat` and keeps its copyright line; `mlp3lfwd.m` follows Netlab's `mlpfwd`. The Spambase dataset is not included.

## data-mining (R and Octave, undated)

- `introOctaveR.pdf` (source `.tm`): "Wprowadzenie do języków Octave i R", an introduction that sets Octave and R side by side, command by command.
- `zadania_DM.pdf`: the exercise sheet. `analiza_opisowa.pdf`, `analiza_danych.tm`: slides on descriptive analysis.
- `exercises/`: R scripts for three of the exercises, with a written-up analysis of the iris data in `zad1`.

The datasets used by the scripts are not included.

## evolutionary-algorithms (Matlab and Octave, undated)

Genetic algorithms (`SSGA.m`, `SSGAM.m`, `CGA.m`, `PBIL.m`), an evolution strategy (`SES.m`), simulated annealing (`SA.m`), objective functions (`ObjFunc_*.m`), encodings (`bit2gray.m`, `real2bit.m` and their inverses) and exercise scripts (`Ex01.m` onward). `later/` is a second, later set of the same files with more exercises.

## Licences

Apart from the Netlab line noted above, the files carry no licence notice.
