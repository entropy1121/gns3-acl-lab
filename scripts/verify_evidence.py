"""只检查原始附件的 SHA-256，不连接或修改实验设备。"""
from pathlib import Path
import csv
import hashlib
import sys

root = Path(__file__).resolve().parents[1]
failed = []
with (root / "evidence/source-index.csv").open(encoding="utf-8-sig", newline="") as f:
    rows = list(csv.DictReader(f))
for row in rows:
    path = root / row["repository_path"]
    actual = hashlib.sha256(path.read_bytes()).hexdigest() if path.is_file() else "MISSING"
    if actual != row["sha256"]:
        failed.append(row["repository_path"])
print(f"Checked {len(rows)} source files; mismatches: {len(failed)}")
for path in failed:
    print(path)
sys.exit(1 if failed else 0)
