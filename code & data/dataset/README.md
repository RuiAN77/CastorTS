# CastorTS Data Organization

This folder is organized around the two data groups used by the CastorTS paper:

- `pretrain/`: open-domain pretraining datasets grouped by domain.
- `evaluation/`: seven TSLib downstream datasets for zero-shot and few-shot evaluation.

The original script-compatible folders such as `ETT-small/` and `weather/` may still exist at the top level. They are kept for backward compatibility with existing shell scripts.

## Current Audit

The local data folder now matches the CastorTS paper data list.

- Present locally: all 16 open-domain pretraining datasets.
- Present locally: all seven evaluation datasets: ETTh1, ETTh2, ETTm1, ETTm2, Weather, Electricity, and Traffic.
- Download sources and exact commands are tracked in `DATA_SOURCES.md` and `download_datasets.ps1`.

Run the audit command from the project root:

```bash
python -m data_provider.data_manifest --root ./dataset
```

Use `--strict` if you want the command to return a non-zero exit code when required datasets are missing:

```bash
python -m data_provider.data_manifest --root ./dataset --strict
```

## Expected Layout

```text
dataset/
+-- dataset_manifest.yaml
+-- pretrain/
|   +-- energy/
|   |   +-- aus_electricity_demand/
|   |   +-- wind/
|   |   +-- prsa/
|   +-- nature/
|   |   +-- sunspot/
|   |   +-- temperature_rain/
|   |   +-- saugeen_river_flow/
|   |   +-- kdd_cup_2018/
|   |   +-- us_births/
|   +-- health/
|   |   +-- self_regulation_scp1/
|   |   +-- self_regulation_scp2/
|   |   +-- pigcvp/
|   +-- transport/
|       +-- pems03/
|       +-- pems04/
|       +-- pems07/
|       +-- pems08/
|       +-- pedestrian_counts/
+-- evaluation/
    +-- ETT-small/
    +-- weather/
    +-- electricity/
    +-- traffic/
```

## Pretraining Datasets

Place each dataset under the folder specified by `dataset_manifest.yaml`. The pretraining loader recursively scans `dataset/pretrain/` and accepts `.npy`, `.npz`, `.csv`, `.txt`, `.parquet`, `.arrow`, and `.tsf` files.

The CastorTS paper reports 16 open-domain pretraining datasets from Energy, Nature, Health, and Transport domains, totaling about 91M time points. The current folder uses:

- Monash Forecasting Repository `.tsf` files for Aus. Electricity Demand, Wind, Sunspot, Temperature Rain, Saugeen River Flow, KDD Cup 2018, US Births, and Pedestrian Counts.
- UCI PRSA station CSV files for PRSA.
- UEA/UCR `.ts` archives converted to per-case `.npy` files under `npy_cases/` for SelfRegulationSCP1, SelfRegulationSCP2, and PigCVP.
- STD-MAE processed `.npz` files for PEMS03, PEMS04, PEMS07, and PEMS08.

Keep pretraining data separate from downstream evaluation data to avoid leakage.

For full pretraining, use:

```bash
--data UTSD --root_path ./dataset/pretrain/
```

## Evaluation Datasets

The evaluation benchmark contains:

| Dataset | Expected file | Legacy file |
| --- | --- | --- |
| ETTh1 | `evaluation/ETT-small/ETTh1.csv` | `ETT-small/ETTh1.csv` |
| ETTh2 | `evaluation/ETT-small/ETTh2.csv` | `ETT-small/ETTh2.csv` |
| ETTm1 | `evaluation/ETT-small/ETTm1.csv` | `ETT-small/ETTm1.csv` |
| ETTm2 | `evaluation/ETT-small/ETTm2.csv` | `ETT-small/ETTm2.csv` |
| Weather | `evaluation/weather/weather.csv` | `weather/weather.csv` |
| Electricity | `evaluation/electricity/electricity.csv` | `electricity/electricity.csv` |
| Traffic | `evaluation/traffic/traffic.csv` | `traffic/traffic.csv` |

The data provider resolves both the canonical path and the legacy path. New data should be placed under `evaluation/`.

## Source Notes

- CastorTS `main.pdf`: defines the open-domain pretraining table and TSLib evaluation table.
- ROSE arXiv 2405.17478: provides public dataset links used to map the benchmark sources.
- SEMPO arXiv 2510.19710: uses compact pretraining data and points to UTSD-style numpy pretraining data.
- TTM arXiv 2401.03955v8 and the Granite TSFM codebase motivate manifest-driven metadata, fixed context length, and reproducible benchmark organization.

## Upload Notes

The local folder is ready at `C:\Users\86131\Desktop\CastorTS\dataset`. Direct upload to Google Drive requires an authenticated Drive client or browser login. No `rclone`, `gdrive`, `gcloud`, `gdown`, `datasets`, or `huggingface_hub` CLI/library was available in the current environment, so the upload step must be run from an authenticated Drive session.
