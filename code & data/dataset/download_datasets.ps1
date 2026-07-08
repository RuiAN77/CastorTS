param(
  [string]$DatasetRoot = (Split-Path -Parent $MyInvocation.MyCommand.Path),
  [switch]$SkipExisting
)

$ErrorActionPreference = "Stop"
$RepoRoot = Split-Path -Parent $DatasetRoot

function Save-Url {
  param(
    [Parameter(Mandatory=$true)][string]$Url,
    [Parameter(Mandatory=$true)][string]$OutFile
  )
  if ($SkipExisting -and (Test-Path -LiteralPath $OutFile)) {
    Write-Host "skip $OutFile"
    return
  }
  New-Item -ItemType Directory -Force -Path (Split-Path -Parent $OutFile) | Out-Null
  Write-Host "download $Url"
  Invoke-WebRequest -Uri $Url -OutFile $OutFile -TimeoutSec 600
}

function Expand-Zip {
  param(
    [Parameter(Mandatory=$true)][string]$ZipFile,
    [Parameter(Mandatory=$true)][string]$Destination
  )
  Write-Host "extract $ZipFile"
  Expand-Archive -LiteralPath $ZipFile -DestinationPath $Destination -Force
}

function Download-ZipDataset {
  param(
    [string]$Path,
    [string]$Url,
    [string]$ZipName
  )
  $dir = Join-Path $DatasetRoot $Path
  $zip = Join-Path $dir $ZipName
  Save-Url -Url $Url -OutFile $zip
  Expand-Zip -ZipFile $zip -Destination $dir
}

# Monash Forecasting Repository pretraining datasets.
Download-ZipDataset "pretrain\energy\aus_electricity_demand" "https://zenodo.org/api/records/4659727/files/australian_electricity_demand_dataset.zip/content" "australian_electricity_demand_dataset.zip"
Download-ZipDataset "pretrain\energy\wind" "https://zenodo.org/api/records/4654858/files/wind_farms_minutely_dataset_without_missing_values.zip/content" "wind_farms_minutely_dataset_without_missing_values.zip"
Download-ZipDataset "pretrain\nature\temperature_rain" "https://zenodo.org/api/records/5129091/files/temperature_rain_dataset_without_missing_values.zip/content" "temperature_rain_dataset_without_missing_values.zip"
Download-ZipDataset "pretrain\nature\sunspot" "https://zenodo.org/api/records/4654722/files/sunspot_dataset_without_missing_values.zip/content" "sunspot_dataset_without_missing_values.zip"
Download-ZipDataset "pretrain\nature\saugeen_river_flow" "https://zenodo.org/api/records/4656058/files/saugeenday_dataset.zip/content" "saugeenday_dataset.zip"
Download-ZipDataset "pretrain\nature\kdd_cup_2018" "https://zenodo.org/api/records/4656756/files/kdd_cup_2018_dataset_without_missing_values.zip/content" "kdd_cup_2018_dataset_without_missing_values.zip"
Download-ZipDataset "pretrain\nature\us_births" "https://zenodo.org/api/records/4656049/files/us_births_dataset.zip/content" "us_births_dataset.zip"
Download-ZipDataset "pretrain\transport\pedestrian_counts" "https://zenodo.org/api/records/4656626/files/pedestrian_counts_dataset.zip/content" "pedestrian_counts_dataset.zip"

# UCI PRSA.
$prsaDir = Join-Path $DatasetRoot "pretrain\energy\prsa"
$prsaOuter = Join-Path $prsaDir "beijing_multi_site_air_quality_data.zip"
Save-Url "https://archive.ics.uci.edu/static/public/501/beijing+multi+site+air+quality+data.zip" $prsaOuter
Expand-Zip $prsaOuter $prsaDir
$prsaInner = Join-Path $prsaDir "PRSA2017_Data_20130301-20170228.zip"
if (Test-Path -LiteralPath $prsaInner) {
  Expand-Zip $prsaInner $prsaDir
}

# UEA/UCR health datasets.
Download-ZipDataset "pretrain\health\self_regulation_scp1" "https://www.timeseriesclassification.com/aeon-toolkit/SelfRegulationSCP1.zip" "SelfRegulationSCP1.zip"
Download-ZipDataset "pretrain\health\self_regulation_scp2" "https://www.timeseriesclassification.com/aeon-toolkit/SelfRegulationSCP2.zip" "SelfRegulationSCP2.zip"
Download-ZipDataset "pretrain\health\pigcvp" "https://www.timeseriesclassification.com/aeon-toolkit/PigCVP.zip" "PigCVP.zip"

$converter = Join-Path $RepoRoot "tools\convert_ts_to_npy.py"
if (Test-Path -LiteralPath $converter) {
  python $converter (Join-Path $DatasetRoot "pretrain\health")
} else {
  Write-Warning "Missing converter: $converter"
}

# STD-MAE PEMS pretraining datasets.
$pems = @(
  @{Path="pretrain\transport\pems03"; Name="PEMS03"; Url="https://raw.githubusercontent.com/Jimmy-7664/STD-MAE/main/datasets/raw_data/PEMS03/PEMS03.npz"; Meta="https://raw.githubusercontent.com/Jimmy-7664/STD-MAE/main/datasets/raw_data/PEMS03/PEMS03.csv"},
  @{Path="pretrain\transport\pems04"; Name="PEMS04"; Url="https://raw.githubusercontent.com/Jimmy-7664/STD-MAE/main/datasets/raw_data/PEMS04/PEMS04.npz"; Meta="https://raw.githubusercontent.com/Jimmy-7664/STD-MAE/main/datasets/raw_data/PEMS04/PEMS04.csv"},
  @{Path="pretrain\transport\pems07"; Name="PEMS07"; Url="https://raw.githubusercontent.com/Jimmy-7664/STD-MAE/main/datasets/raw_data/PEMS07/PEMS07.npz"; Meta="https://raw.githubusercontent.com/Jimmy-7664/STD-MAE/main/datasets/raw_data/PEMS07/PEMS07.csv"},
  @{Path="pretrain\transport\pems08"; Name="PEMS08"; Url="https://raw.githubusercontent.com/Jimmy-7664/STD-MAE/main/datasets/raw_data/PEMS08/PEMS08.npz"; Meta="https://raw.githubusercontent.com/Jimmy-7664/STD-MAE/main/datasets/raw_data/PEMS08/PEMS08.csv"}
)

foreach ($item in $pems) {
  $dir = Join-Path $DatasetRoot $item.Path
  Save-Url $item.Url (Join-Path $dir "$($item.Name).npz")
  Save-Url $item.Meta (Join-Path $dir "$($item.Name)_adjacency.csv")
}

# Evaluation datasets from Time-Series-Library HF mirror. ETT/Weather may already be present.
Save-Url "https://huggingface.co/datasets/thuml/Time-Series-Library/resolve/main/electricity/electricity.csv?download=true" (Join-Path $DatasetRoot "evaluation\electricity\electricity.csv")
Save-Url "https://huggingface.co/datasets/thuml/Time-Series-Library/resolve/main/traffic/traffic.csv?download=true" (Join-Path $DatasetRoot "evaluation\traffic\traffic.csv")

Write-Host "Done. Run: python -m data_provider.data_manifest --root ./dataset --strict"
