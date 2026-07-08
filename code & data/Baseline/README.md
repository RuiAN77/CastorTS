# CastorTS Baseline Sources

This folder collects open-source implementations for the baseline methods compared in the CastorTS paper. The code is organized by the categories used in the experimental section.

These repositories are provided as reference implementations. They are not vendored into the CastorTS training pipeline, and their dependencies, checkpoints, data preprocessing, and licenses remain governed by their original projects. Large pretrained weights are not downloaded here.

## Directory Layout

```text
Baseline/
+-- foundation_models/
|   +-- Time-MoE/
|   +-- Timer_Large-Time-Series-Model/
|   +-- Moirai_uni2ts/
|   +-- Chronos/
|   +-- TimesFM/
|   +-- MOMENT/
+-- llm_based/
|   +-- Time-LLM/
|   +-- GPT4TS_One-Fits-All/
|   +-- S2IP-LLM/
+-- lightweight_tsfm/
|   +-- SEMPO/
|   +-- TTM_granite-tsfm/
+-- task_specific_forecasters/
|   +-- iTransformer/
|   +-- DLinear_LTSF-Linear/
|   +-- PatchTST/
|   +-- TimesNet/
|   +-- FEDformer/
+-- shared_frameworks/
    +-- Time-Series-Library/
```

## Sources

| Paper Baseline | Folder | Source Repository | Retrieval |
| --- | --- | --- | --- |
| Time-MoE | `foundation_models/Time-MoE` | https://github.com/Time-MoE/Time-MoE | shallow git clone |
| Timer | `foundation_models/Timer_Large-Time-Series-Model` | https://github.com/thuml/Large-Time-Series-Model | shallow git clone |
| Moirai | `foundation_models/Moirai_uni2ts` | https://github.com/SalesforceAIResearch/uni2ts | shallow git clone |
| Chronos | `foundation_models/Chronos` | https://github.com/amazon-science/chronos-forecasting | shallow git clone |
| TimesFM | `foundation_models/TimesFM` | https://github.com/google-research/timesfm | shallow git clone |
| MOMENT | `foundation_models/MOMENT` | https://github.com/moment-timeseries-foundation-model/moment | shallow git clone |
| Time-LLM | `llm_based/Time-LLM` | https://github.com/KimMeen/Time-LLM | shallow git clone |
| GPT4TS / One Fits All | `llm_based/GPT4TS_One-Fits-All` | https://github.com/DAMO-DI-ML/NeurIPS2023-One-Fits-All | shallow git clone |
| S2IP-LLM | `llm_based/S2IP-LLM` | https://github.com/panzijie825/S2IP-LLM | shallow git clone |
| SEMPO | `lightweight_tsfm/SEMPO` | https://github.com/mala-lab/SEMPO | GitHub archive |
| TTM | `lightweight_tsfm/TTM_granite-tsfm` | https://github.com/ibm-granite/granite-tsfm | GitHub archive |
| iTransformer | `task_specific_forecasters/iTransformer` | https://github.com/thuml/iTransformer | GitHub archive |
| DLinear | `task_specific_forecasters/DLinear_LTSF-Linear` | https://github.com/cure-lab/LTSF-Linear | GitHub archive |
| PatchTST | `task_specific_forecasters/PatchTST` | https://github.com/yuqinie98/PatchTST | GitHub archive |
| TimesNet | `task_specific_forecasters/TimesNet` | https://github.com/thuml/TimesNet | GitHub archive |
| FEDformer | `task_specific_forecasters/FEDformer` | https://github.com/MAZiqing/FEDformer | GitHub archive |
| Time-Series-Library | `shared_frameworks/Time-Series-Library` | https://github.com/thuml/Time-Series-Library | GitHub archive |

## Notes

- `Time-Series-Library` is included as a shared experiment framework because several task-specific forecasting baselines are commonly maintained or reproduced through the THUML time-series codebase.
- `TTM_granite-tsfm` was extracted from GitHub archive on Windows. `Expand-Archive` reported a few long-path warnings, but the main project files and `tsfm_public/` source directory are present.
- Archive-based folders do not include `.git` history. Use the source URLs above to refresh them if exact revision tracking is required.
- Each baseline may require its own Python environment and pretrained checkpoint. The CastorTS `requirements.txt` is not expected to satisfy all baseline dependencies.
