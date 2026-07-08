import argparse
from pathlib import Path
from typing import Any, Iterable, List, Optional, Union

import yaml


SUPPORTED_DATA_EXTENSIONS = {
    ".npy",
    ".npz",
    ".csv",
    ".txt",
    ".parquet",
    ".arrow",
    ".tsf",
}


class DatasetStatus:
    def __init__(self, stage, dataset_id, domain, expected, available, resolved_path, note=""):
        self.stage = stage
        self.dataset_id = dataset_id
        self.domain = domain
        self.expected = expected
        self.available = available
        self.resolved_path = resolved_path
        self.note = note


def default_repo_root() -> Path:
    return Path(__file__).resolve().parents[1]


def default_manifest_path(repo_root=None):
    root = repo_root or default_repo_root()
    return root / "dataset" / "dataset_manifest.yaml"


def load_manifest(manifest_path=None):
    path = Path(manifest_path) if manifest_path else default_manifest_path()
    with path.open("r", encoding="utf-8") as f:
        return yaml.safe_load(f)


def _contains_supported_file(path: Path) -> bool:
    if path.is_file():
        return path.suffix.lower() in SUPPORTED_DATA_EXTENSIONS
    if not path.is_dir():
        return False
    return any(p.is_file() and p.suffix.lower() in SUPPORTED_DATA_EXTENSIONS for p in path.rglob("*"))


def _candidate_paths(dataset_root, entry):
    path = entry.get("path")
    if path:
        yield dataset_root / path
    legacy_path = entry.get("legacy_path")
    if legacy_path:
        yield dataset_root / legacy_path


def audit_datasets(
    dataset_root,
    manifest_path=None,
    stage="all",
):
    root = Path(dataset_root)
    manifest = load_manifest(manifest_path)
    statuses = []

    stages = ("pretraining", "evaluation") if stage == "all" else (stage,)
    for stage_name in stages:
        for entry in manifest.get(stage_name, []):
            candidates = list(_candidate_paths(root, entry))
            resolved = next((p for p in candidates if _contains_supported_file(p)), None)
            expected = str(candidates[0]) if candidates else ""
            statuses.append(
                DatasetStatus(
                    stage=stage_name,
                    dataset_id=str(entry.get("id", "")),
                    domain=str(entry.get("domain", "")),
                    expected=expected,
                    available=resolved is not None,
                    resolved_path=str(resolved) if resolved else "",
                )
            )
    return statuses


def resolve_runtime_data_path(
    root_path,
    data_path,
    data_key="",
    repo_root=None,
    manifest_path=None,
):
    """Resolve canonical dataset paths while preserving legacy script behavior."""
    root = Path(repo_root) if repo_root else default_repo_root()
    requested_root = Path(root_path)
    requested_file = requested_root / data_path

    if requested_file.exists() or requested_root.exists():
        return root_path, data_path

    dataset_root = root / "dataset"
    manifest = load_manifest(manifest_path or default_manifest_path(root))

    if data_key == "UTSD":
        pretrain_root = dataset_root / "pretrain"
        if _contains_supported_file(pretrain_root):
            return str(pretrain_root), data_path
        legacy_utsd = dataset_root / "utsd"
        if _contains_supported_file(legacy_utsd):
            return str(legacy_utsd), data_path
        return root_path, data_path

    requested_stem = Path(data_path).stem.lower()
    for entry in manifest.get("evaluation", []):
        entry_id = str(entry.get("id", "")).lower()
        entry_path = Path(str(entry.get("path", "")))
        if requested_stem not in {entry_id, entry_path.stem.lower()}:
            continue
        for candidate in _candidate_paths(dataset_root, entry):
            if candidate.is_file():
                return str(candidate.parent), candidate.name
    return root_path, data_path


def print_audit(statuses):
    stage_width = max([len(s.stage) for s in statuses] + [5])
    id_width = max([len(s.dataset_id) for s in statuses] + [7])
    domain_width = max([len(s.domain) for s in statuses] + [6])
    print(f"{'stage':<{stage_width}}  {'dataset':<{id_width}}  {'domain':<{domain_width}}  status  path")
    print(f"{'-' * stage_width}  {'-' * id_width}  {'-' * domain_width}  ------  ----")
    for s in statuses:
        status = "present" if s.available else "missing"
        path = s.resolved_path or s.expected
        print(f"{s.stage:<{stage_width}}  {s.dataset_id:<{id_width}}  {s.domain:<{domain_width}}  {status:<7} {path}")


def main() -> int:
    parser = argparse.ArgumentParser(description="Audit CastorTS dataset availability.")
    parser.add_argument("--root", default=str(default_repo_root() / "dataset"), help="Dataset root directory.")
    parser.add_argument("--manifest", default=None, help="Path to dataset_manifest.yaml.")
    parser.add_argument("--stage", default="all", choices=["all", "pretraining", "evaluation"])
    parser.add_argument("--strict", action="store_true", help="Return non-zero when any dataset is missing.")
    args = parser.parse_args()

    statuses = audit_datasets(args.root, args.manifest, args.stage)
    print_audit(statuses)
    if args.strict and any(not s.available for s in statuses):
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
