# CastorTS Dataset Sources

This file records the public sources used to build `dataset/` for the CastorTS paper setup. The target layout follows `dataset_manifest.yaml`.

## References

- CastorTS main paper: `C:/Users/86131/Downloads/main.pdf`
- ROSE paper with dataset links: https://arxiv.org/pdf/2405.17478
- Monash Forecasting Repository: https://forecastingdata.org/
- Time-Series-Library data mirror: https://huggingface.co/datasets/thuml/Time-Series-Library
- UTSD source list: https://huggingface.co/datasets/thuml/UTSD
- UCI PRSA: https://archive.ics.uci.edu/dataset/501/beijing+multi+site+air+quality+data
- UEA/UCR time series classification archive: https://www.timeseriesclassification.com/
- STD-MAE PEMS mirror: https://github.com/Jimmy-7664/STD-MAE

## Pretraining

| Dataset | Target path | Local format | Source |
| --- | --- | --- | --- |
| Aus. Electricity Demand | `pretrain/energy/aus_electricity_demand` | `.tsf` + source zip | https://zenodo.org/records/4659727 |
| Wind | `pretrain/energy/wind` | `.tsf` + source zip | https://zenodo.org/records/4654858 |
| PRSA | `pretrain/energy/prsa` | station `.csv` + source zip | https://archive.ics.uci.edu/static/public/501/beijing+multi+site+air+quality+data.zip |
| Sunspot | `pretrain/nature/sunspot` | `.tsf` + source zip | https://zenodo.org/records/4654722 |
| Temperature Rain | `pretrain/nature/temperature_rain` | `.tsf` + source zip | https://zenodo.org/records/5129091 |
| Saugeen River Flow | `pretrain/nature/saugeen_river_flow` | `.tsf` + source zip | https://zenodo.org/records/4656058 |
| KDD Cup 2018 | `pretrain/nature/kdd_cup_2018` | `.tsf` + source zip | https://zenodo.org/records/4656756 |
| US Births | `pretrain/nature/us_births` | `.tsf` + source zip | https://zenodo.org/records/4656049 |
| SelfRegulationSCP1 | `pretrain/health/self_regulation_scp1` | `.ts` source + generated `.npy` cases | https://www.timeseriesclassification.com/aeon-toolkit/SelfRegulationSCP1.zip |
| SelfRegulationSCP2 | `pretrain/health/self_regulation_scp2` | `.ts` source + generated `.npy` cases | https://www.timeseriesclassification.com/aeon-toolkit/SelfRegulationSCP2.zip |
| PigCVP | `pretrain/health/pigcvp` | `.ts` source + generated `.npy` cases | https://www.timeseriesclassification.com/aeon-toolkit/PigCVP.zip |
| PEMS03 | `pretrain/transport/pems03` | `.npz` | https://raw.githubusercontent.com/Jimmy-7664/STD-MAE/main/datasets/raw_data/PEMS03/PEMS03.npz |
| PEMS04 | `pretrain/transport/pems04` | `.npz` | https://raw.githubusercontent.com/Jimmy-7664/STD-MAE/main/datasets/raw_data/PEMS04/PEMS04.npz |
| PEMS07 | `pretrain/transport/pems07` | `.npz` | https://raw.githubusercontent.com/Jimmy-7664/STD-MAE/main/datasets/raw_data/PEMS07/PEMS07.npz |
| PEMS08 | `pretrain/transport/pems08` | `.npz` | https://raw.githubusercontent.com/Jimmy-7664/STD-MAE/main/datasets/raw_data/PEMS08/PEMS08.npz |
| Pedestrian Counts | `pretrain/transport/pedestrian_counts` | `.tsf` + source zip | https://zenodo.org/records/4656626 |

## Evaluation

| Dataset | Target path | Local format | Source |
| --- | --- | --- | --- |
| ETTh1 | `evaluation/ETT-small/ETTh1.csv` | `.csv` | https://github.com/zhouhaoyi/ETDataset |
| ETTh2 | `evaluation/ETT-small/ETTh2.csv` | `.csv` | https://github.com/zhouhaoyi/ETDataset |
| ETTm1 | `evaluation/ETT-small/ETTm1.csv` | `.csv` | https://github.com/zhouhaoyi/ETDataset |
| ETTm2 | `evaluation/ETT-small/ETTm2.csv` | `.csv` | https://github.com/zhouhaoyi/ETDataset |
| Weather | `evaluation/weather/weather.csv` | `.csv` | https://www.bgc-jena.mpg.de/wetter/ |
| Electricity | `evaluation/electricity/electricity.csv` | `.csv` | https://huggingface.co/datasets/thuml/Time-Series-Library/tree/main/electricity |
| Traffic | `evaluation/traffic/traffic.csv` | `.csv` | https://huggingface.co/datasets/thuml/Time-Series-Library/tree/main/traffic |

## Notes

- Monash datasets use the without-missing-values release when both variants are available.
- UEA/UCR `.ts` files are retained for provenance. `tools/convert_ts_to_npy.py` generates per-case `.npy` files because the CastorTS pretraining loader reads `.npy` directly.
- PEMS data is the processed `.npz` release from STD-MAE. The original Caltrans PEMS portal may require account access.
- Evaluation data is stored under `evaluation/`; legacy top-level folders are retained where existing scripts expect them.
