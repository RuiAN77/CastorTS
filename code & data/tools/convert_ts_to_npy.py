import argparse
from pathlib import Path

import numpy as np


def _to_float_array(values):
    parsed = []
    for value in values.split(","):
        value = value.strip()
        if not value:
            continue
        if value == "?":
            parsed.append(np.nan)
        else:
            parsed.append(float(value))
    return np.asarray(parsed, dtype=np.float32)


def parse_ts_file(path):
    dimensions = None
    class_label = False
    data_started = False
    cases = []

    with Path(path).open("r", encoding="utf-8", errors="ignore") as f:
        for raw_line in f:
            line = raw_line.strip()
            if not line:
                continue
            lower = line.lower()
            if not data_started:
                if lower.startswith("@dimensions"):
                    dimensions = int(line.split()[-1])
                elif lower.startswith("@classlabel"):
                    parts = line.split()
                    class_label = len(parts) > 1 and parts[1].lower() == "true"
                elif lower.startswith("@data"):
                    data_started = True
                continue

            parts = line.split(":")
            if class_label:
                parts = parts[:-1]
            if dimensions is not None and len(parts) != dimensions:
                raise ValueError(f"{path}: expected {dimensions} dimensions, got {len(parts)}")

            dims = [_to_float_array(part) for part in parts]
            lengths = {len(dim) for dim in dims}
            if len(lengths) != 1:
                raise ValueError(f"{path}: unequal dimension lengths {sorted(lengths)}")
            cases.append(np.stack(dims, axis=1))

    return cases


def convert_folder(root):
    root = Path(root)
    for ts_path in sorted(root.rglob("*.ts")):
        out_dir = ts_path.parent / "npy_cases" / ts_path.stem
        out_dir.mkdir(parents=True, exist_ok=True)
        cases = parse_ts_file(ts_path)
        for i, case in enumerate(cases):
            np.save(out_dir / f"case_{i:05d}.npy", case)
        print(f"{ts_path}: wrote {len(cases)} npy cases to {out_dir}")


def main():
    parser = argparse.ArgumentParser(description="Convert UEA/UCR .ts files to per-case .npy files.")
    parser.add_argument("root", help="Folder containing .ts files.")
    args = parser.parse_args()
    convert_folder(args.root)


if __name__ == "__main__":
    main()
