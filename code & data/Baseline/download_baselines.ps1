$ErrorActionPreference = "Stop"

$Root = Split-Path -Parent $MyInvocation.MyCommand.Path
$ArchiveDir = Join-Path $Root ".archives"
New-Item -ItemType Directory -Force -Path $ArchiveDir | Out-Null

$Repos = @(
    @{ Category = "foundation_models"; Name = "Time-MoE"; Url = "https://github.com/Time-MoE/Time-MoE.git"; Method = "git" },
    @{ Category = "foundation_models"; Name = "Timer_Large-Time-Series-Model"; Url = "https://github.com/thuml/Large-Time-Series-Model.git"; Method = "git" },
    @{ Category = "foundation_models"; Name = "Moirai_uni2ts"; Url = "https://github.com/SalesforceAIResearch/uni2ts.git"; Method = "git" },
    @{ Category = "foundation_models"; Name = "Chronos"; Url = "https://github.com/amazon-science/chronos-forecasting.git"; Method = "git" },
    @{ Category = "foundation_models"; Name = "TimesFM"; Url = "https://github.com/google-research/timesfm.git"; Method = "git" },
    @{ Category = "foundation_models"; Name = "MOMENT"; Url = "https://github.com/moment-timeseries-foundation-model/moment.git"; Method = "git" },
    @{ Category = "llm_based"; Name = "Time-LLM"; Url = "https://github.com/KimMeen/Time-LLM.git"; Method = "git" },
    @{ Category = "llm_based"; Name = "GPT4TS_One-Fits-All"; Url = "https://github.com/DAMO-DI-ML/NeurIPS2023-One-Fits-All.git"; Method = "git" },
    @{ Category = "llm_based"; Name = "S2IP-LLM"; Url = "https://github.com/panzijie825/S2IP-LLM.git"; Method = "git" },
    @{ Category = "lightweight_tsfm"; Name = "SEMPO"; Url = "https://github.com/mala-lab/SEMPO/archive/HEAD.zip"; Method = "archive" },
    @{ Category = "lightweight_tsfm"; Name = "TTM_granite-tsfm"; Url = "https://github.com/ibm-granite/granite-tsfm/archive/HEAD.zip"; Method = "archive" },
    @{ Category = "task_specific_forecasters"; Name = "iTransformer"; Url = "https://github.com/thuml/iTransformer/archive/HEAD.zip"; Method = "archive" },
    @{ Category = "task_specific_forecasters"; Name = "DLinear_LTSF-Linear"; Url = "https://github.com/cure-lab/LTSF-Linear/archive/HEAD.zip"; Method = "archive" },
    @{ Category = "task_specific_forecasters"; Name = "PatchTST"; Url = "https://github.com/yuqinie98/PatchTST/archive/HEAD.zip"; Method = "archive" },
    @{ Category = "task_specific_forecasters"; Name = "TimesNet"; Url = "https://github.com/thuml/TimesNet/archive/HEAD.zip"; Method = "archive" },
    @{ Category = "task_specific_forecasters"; Name = "FEDformer"; Url = "https://github.com/MAZiqing/FEDformer/archive/HEAD.zip"; Method = "archive" },
    @{ Category = "shared_frameworks"; Name = "Time-Series-Library"; Url = "https://github.com/thuml/Time-Series-Library/archive/HEAD.zip"; Method = "archive" }
)

foreach ($Repo in $Repos) {
    $CategoryDir = Join-Path $Root $Repo.Category
    $Target = Join-Path $CategoryDir $Repo.Name
    New-Item -ItemType Directory -Force -Path $CategoryDir | Out-Null

    if (Test-Path -LiteralPath $Target) {
        Write-Host "SKIP existing $($Repo.Name)"
        continue
    }

    if ($Repo.Method -eq "git") {
        Write-Host "CLONE $($Repo.Name)"
        git clone --depth 1 --filter=blob:none $Repo.Url $Target
        continue
    }

    Write-Host "DOWNLOAD $($Repo.Name)"
    $Zip = Join-Path $ArchiveDir ($Repo.Name + ".zip")
    $Extract = Join-Path $ArchiveDir ($Repo.Name + "_extract")
    if (Test-Path -LiteralPath $Extract) {
        Remove-Item -LiteralPath $Extract -Recurse -Force
    }
    Invoke-WebRequest -Uri $Repo.Url -OutFile $Zip
    New-Item -ItemType Directory -Force -Path $Extract | Out-Null
    Expand-Archive -LiteralPath $Zip -DestinationPath $Extract -Force
    $Top = Get-ChildItem -LiteralPath $Extract -Directory | Select-Object -First 1
    if ($null -eq $Top) {
        throw "Archive extract failed for $($Repo.Name)"
    }
    Move-Item -LiteralPath $Top.FullName -Destination $Target
}

Write-Host "Done. Large model checkpoints are not downloaded by this script."
