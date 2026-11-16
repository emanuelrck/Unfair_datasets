# Associations Between Data Complexity and Group Fairness Metrics Across Tabular Benchmark Datasets

Code and pre-processed datasets for the experiments reported in the paper
*Associations Between Data Complexity and Group Fairness Metrics Across Tabular Benchmark Datasets*
(Roque, Santos, Veloso, Machado and Abreu, submitted to *Scientific Reports*).

The experimental protocol extends the real-data case study of
[Brzeziński et al. (2024)](https://github.com/Rasalrai/analysis-of-fairness-measures),
from whose repository the fairness-measure computation and plotting code is derived,
to seven benchmark datasets and adds the computation of data complexity measures.

## Contents

| File | Purpose |
|---|---|
| `adult.py`, `bank.py`, `compas.py`, `creditCard.py`, `crime.py`, `law.py`, `stalog.py` | One script per dataset. Each one generates the subdatasets with controlled group ratio (GR) and imbalance ratio (IR), trains the six classifiers, computes the six group fairness metrics on the test partition, computes the complexity measures, and writes the results and figures. |
| `complexity.py` | Data complexity measures (Feature, Instance and Structural Overlap). This is a copy of the `complexity.py` module of the [pycol](https://github.com/DiogoApostolo/pycol) library (MIT licence), kept here so that the exact version used in the experiments is archived. |
| `utils.py` | Timer helper used by the scripts. |
| `preprocessing/preprocess_compas.R`, `preprocess_crime.R`, `preprocess_law.R` | R scripts that produce `compasTransformed.data`, `crimeTransformed.data` and `lawTransformed.data` from the original files (ProPublica `cox-parsed.csv`, UCI `communities.data`, `law_dataset.arff`). |
| `table_gr_ir.py` | Computes the group ratio, imbalance ratio and number of instances of every dataset / sensitive attribute combination with the binarisation used in the experiments (Table 2 of the paper). |
| `data/` | The pre-processed datasets read by the scripts (see below). |
| `requirements.txt` | Package versions used in the experiments. |

## Datasets

The files in `data/` are the versions of the public datasets used in the experiments.
`adult.data` (the training partition of the UCI Adult data), `bank-full.csv`, `german.data` and
`default of credit card clients.csv` are the original UCI files; `compasTransformed.data`,
`crimeTransformed.data` and `lawTransformed.data` are the ProPublica COMPAS (`cox-parsed.csv`),
UCI Communities and Crime and Law School datasets after the pre-processing done by the scripts in
`preprocessing/` (removal of rows with missing values, selection of attributes, binarisation of the
sensitive attribute and, where needed, of the target; for Crime every retained attribute is binarised
at 0.7). The original sources are given
in the Data Availability Statement of the paper. Any remaining binarisation of sensitive attributes
(e.g. `race` into White / not White, `age` into adult / not adult) is done at the top of each script.

## Running the experiments

Install the dependencies (Python 3.10 was used):

```
pip install -r requirements.txt
```

and run the script of the dataset of interest from the repository root, e.g.

```
python adult.py
```

Each script runs all sensitive attributes of its dataset in sequence. For every
dataset–attribute combination it creates a directory named
`<dataset>_<seed>_<attribute>_size<n>` containing:

* `fairness_results_cv.pkl` / `clf_results_cv.pkl`: the raw fairness metric values and
  performance scores for every (GR, IR) condition, repetition and classifier;
* `clf_fairness_agg_<metric>.csv` / `clf_results_agg_<score>.csv`: mean and standard
  deviation over the 50 repetitions, per condition and classifier;
* `metricas_complexidade.csv`: the complexity measures per (GR, IR) condition;
* `plots/`: the figures (the panels of the paper are produced by `plot_line_all`).

## Experimental settings (as used in the paper)

* Total sample size `n` of the subdatasets, per dataset and sensitive attribute
  (`sizes_samples` in each script): Adult race 1400, sex 2100; Bank Marketing age 1500;
  COMPAS sex 1000, race 2000, age 2800; Credit Card Default age 1500, sex 5000;
  Crime race 102; Law School sex 1500, race 800; German Credit sex 200, age 150.
* Grid of ratios: 0.01, 0.02, 0.05, 0.1, 0.2, ..., 0.9, 0.95, 0.98, 0.99 (the two smallest
  datasets, Crime and German Credit, use 0.05 to 0.95).
* 50 repetitions per condition, with the 50 fixed seeds listed in `seeds_split_data`;
  classifier seed `2137` (`1000` for Crime).
* Train/test split: random 67/33 hold-out (`ShuffleSplit`, `test_size=0.33`).
* Pipeline: `KNNImputer` -> `StandardScaler` -> classifier, fitted on the training partition;
  categorical attributes are ordinally encoded; all classifiers use the scikit-learn defaults.
* Fairness metrics: difference between the unprotected (majority) and the protected (minority)
  group, computed on the test partition; undefined values (zero denominators) are stored as NaN
  and excluded from the aggregates.
* Complexity measures: computed with `complexity.py` on the test partition of the first
  repetition of each condition (`if c == 0` in the scripts).
