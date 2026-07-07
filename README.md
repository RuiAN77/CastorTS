# CastorTS: Causality-Guided Siamese Pretraining Model for Efficient Time Series Forecasting

CastorTS is an efficient multivariate time-series foundation model for zero-shot and few-shot forecasting. The paper proposes a causality-guided Siamese pretraining framework that learns transferable knowledge along a temporal -> causal -> domain hierarchy, so the model can generalize across heterogeneous time-series domains with substantially lower model and data cost.

The paper reports that CastorTS uses 18.7M parameters and 91M pretraining time points while achieving state-of-the-art forecasting performance on large-scale benchmarks.

## Reported Results

The paper evaluates CastorTS on the TSLib benchmark with seven datasets: ETTh1, ETTh2, ETTm1, ETTm2, Weather, Electricity, and Traffic. The standard setting uses an input length of 512 and forecasting horizons of 96, 192, 336, and 720.

- **Zero-shot forecasting:** CastorTS achieves the best or tied-best result on 10 of 14 averaged dataset-metric entries while using only 18.7M parameters and 91M pretraining time points.
- **5% few-shot forecasting:** CastorTS achieves the lowest overall averaged error and the best or tied-best performance on 10 of 14 averaged entries.
- **10% few-shot forecasting:** CastorTS keeps the lowest overall averaged error and improves over compact foundation-model baselines on average.
- **Efficiency:** Under the reported batch setting, CastorTS requires 15 ms inference time and 0.18 GB GPU memory per batch, providing a favorable accuracy-efficiency trade-off.

## Supplementary Material

`Supplementary Material.pdf` is the appendix accompanying the paper. It is useful for reproducing the full experimental narrative and for checking details that are only summarized in the main paper. The file contains:

- Preliminaries for SSM, Mamba, and Mamba-2.
- Additional CastorTS details, including the Siamese pair sampler, dynamic tokenization, and temporal decoding/de-tokenization.
- Proofs for the Floor Attention theorem and the hyperspherical proxy theorem.
- Experimental details for pretraining datasets, TSLib datasets, GIFT-Eval datasets, baselines, implementation settings, and computational complexity.
- Additional results for GIFT-Eval, module/objective/proxy ablations, graph corruption robustness, and related work.

## Repository Structure

```text
CastorTS/
+-- README.md
+-- LICENSE
+-- requirements.txt
+-- Supplementary Material.pdf         # Appendix for theory, settings, and extra results
+-- code & data/
    +-- run.py                         # Main experiment entry point
    +-- data_provider/                 # Dataset loading, path resolution, and data audit utilities
    +-- dataset/                       # Organized pretraining and evaluation datasets
    |   +-- README.md
    |   +-- DATA_SOURCES.md
    |   +-- dataset_manifest.yaml
    |   +-- download_datasets.ps1
    |   +-- pretrain/
    |   |   +-- energy/
    |   |   +-- nature/
    |   |   +-- health/
    |   |   +-- transport/
    |   +-- evaluation/
    |       +-- ETT-small/
    |       +-- weather/
    |       +-- electricity/
    |       +-- traffic/
    +-- Baseline/                      # Open-source baseline repositories and manifest
    +-- exp/                           # Training, validation, and testing loops
    +-- layers/                        # Model layers and heads
    +-- models/                        # CastorTS and CastorTS_CL entry points
    +-- scripts/time_series_forecatsing/
    |   +-- pretrain/
    |   +-- zero_shot/
    |   +-- few_shot/
    +-- tools/                         # Data conversion helpers
    +-- utils/                         # Metrics, time features, and training utilities
```

The executable code lives under `code & data/`. The scripts directory is currently named `time_series_forecatsing`; use this path exactly when running the provided commands.

## Installation

The experiments are designed for Python 3.10 and PyTorch 2.1.2 with CUDA 11.8.

```bash
conda create -n castorts python=3.10 -y
conda activate castorts
pip install -r requirements.txt --extra-index-url https://download.pytorch.org/whl/cu118
cd "code & data"
```

The shell scripts use `torchrun` and are intended for a CUDA-enabled Linux or WSL environment. Unless otherwise stated, run the commands below from `code & data/`.

## Data Preparation

Datasets are described by `code & data/dataset/dataset_manifest.yaml` and organized into pretraining and evaluation groups:

```text
code & data/dataset/
+-- dataset_manifest.yaml
+-- pretrain/
|   +-- energy/
|   +-- nature/
|   +-- health/
|   +-- transport/
+-- evaluation/
|   +-- ETT-small/
|   +-- weather/
|   +-- electricity/
|   +-- traffic/
+-- ETT-small/     # legacy script-compatible path
+-- weather/       # legacy script-compatible path
```

When commands are run from `code & data/`, the pretraining loader recursively scans `./dataset/pretrain/` for local `.npy`, `.npz`, `.csv`, `.txt`, `.parquet`, `.arrow`, and `.tsf` files. The evaluation loader supports both canonical paths under `./dataset/evaluation/` and legacy paths used by earlier scripts.

Audit local data availability with:

```bash
python -m data_provider.data_manifest --root ./dataset
```

See `code & data/dataset/README.md` for the exact placement of each pretraining and evaluation dataset.

## Dataset Statistics

The paper uses non-overlapping datasets for open-domain pretraining and downstream evaluation. The pretraining corpus is assembled from public time-series sources and grouped into four domains. It contains about 91M time points in total and is used to learn transferable temporal, causal, and domain-level regularities.

### Open-Domain Pretraining Datasets

| Domain | Dataset | Time Points | Source |
| --- | --- | ---: | --- |
| Energy | Aus. Electricity Demand | 1,155,264 | Monash |
| Energy | Wind | 7,397,147 | Monash |
| Energy | PRSA | 4,628,448 | PRSA |
| Nature | Sunspot | 73,924 | Monash |
| Nature | Temperature Rain | 23,252,200 | Monash |
| Nature | Saugeen River Flow | 23,741 | Monash |
| Nature | KDD Cup 2018 | 2,942,364 | Monash |
| Nature | US Births | 7,305 | Monash |
| Health | SelfRegulationSCP1 | 3,015,936 | UEA |
| Health | SelfRegulationSCP2 | 3,064,320 | UEA |
| Health | PIGCVP | 624,000 | UCR |
| Transport | PEMS03 | 9,382,464 | PEMS |
| Transport | PEMS04 | 5,216,544 | PEMS |
| Transport | PEMS07 | 24,921,792 | PEMS |
| Transport | PEMS08 | 3,035,520 | PEMS |
| Transport | Pedestrian Counts | 3,132,346 | Monash |

### TSLib Downstream Benchmark

The zero-shot and few-shot experiments evaluate on seven TSLib datasets covering electricity, weather, and traffic domains. These datasets range from 7 to 862 variables, 17,420 to 69,680 time points, and 10-minute to hourly sampling resolutions.

| Dataset | Vars. | Time Points | Resolution | Domain |
| --- | ---: | ---: | --- | --- |
| ETTh1 | 7 | 17,420 | Hourly | Electricity |
| ETTh2 | 7 | 17,420 | Hourly | Electricity |
| ETTm1 | 7 | 69,680 | 15 min | Electricity |
| ETTm2 | 7 | 69,680 | 15 min | Electricity |
| Weather | 21 | 52,696 | 10 min | Weather |
| Electricity | 321 | 26,304 | Hourly | Electricity |
| Traffic | 862 | 17,544 | Hourly | Traffic |

## Baselines

Open-source implementations for the paper baselines are organized under `code & data/Baseline`. The folder is grouped by method family:

- `foundation_models`: Time-MoE, Timer, Moirai, Chronos, TimesFM, and MOMENT.
- `llm_based`: Time-LLM, GPT4TS / One Fits All, and S2IP-LLM.
- `lightweight_tsfm`: SEMPO and TTM.
- `task_specific_forecasters`: iTransformer, DLinear, PatchTST, TimesNet, and FEDformer.
- `shared_frameworks`: Time-Series-Library, included as a common reproduction framework for several forecasting baselines.

See `code & data/Baseline/README.md` and `code & data/Baseline/baseline_manifest.csv` for source repositories, retrieval methods, and notes. Baseline repositories are provided as independent reference implementations; their dependencies, checkpoints, preprocessing, and licenses remain governed by the original projects.

## Pretraining

Pretraining uses `CastorTS_CL` and the open-domain pretraining corpus listed in Table I of the paper. The provided script keeps the historical `UTSD` data key, but the data provider resolves it to the organized `dataset/pretrain/` corpus described above.

```bash
bash scripts/time_series_forecatsing/pretrain/CastorTS_utsd.sh
```

This script first runs causality-guided pretraining and then initializes the downstream `CastorTS` model entry point from the learned checkpoint. Logs are written to `logs/Pretrain/`.

## Zero-Shot Forecasting

Zero-shot evaluation runs with `--is_pretraining 0`, `--is_training 0`, and `--is_zeroshot 1`.

```bash
bash scripts/time_series_forecatsing/zero_shot/CastorTS_weather.sh
```

Other zero-shot scripts are available for ETT, Electricity, and Traffic datasets:

```bash
scripts/time_series_forecatsing/zero_shot/
```

## Few-Shot Forecasting

Few-shot tuning runs with `--is_pretraining 0`, `--is_training 1`, and `--is_zeroshot 0`. The paper evaluates two low-resource regimes, 5% and 10% of the available target-domain training data. The provided scripts currently use 5% by default; add `10` to the `percent` loop to reproduce the 10% setting.

```bash
bash scripts/time_series_forecatsing/few_shot/CastorTS_ETTh1.sh
```

Available few-shot scripts:

```bash
scripts/time_series_forecatsing/few_shot/
```

## Common Arguments

- `--model CastorTS_CL`: pretraining model entry point.
- `--model CastorTS`: downstream forecasting model entry point.
- `--data UTSD`: pretraining loader key for the organized open-domain corpus.
- `--data CI`: common downstream forecasting datasets.
- `--seq_len 512`: lookback length used in the paper.
- `--pred_len {96,192,336,720}`: forecasting horizons.
- `--domain_len 128`: domain-proxy length used by the provided scripts.
- `--d_model 256`: hidden dimension used by the provided scripts.
- `--percent`: few-shot data percentage.

## License

This project is released under the Apache-2.0 License.
