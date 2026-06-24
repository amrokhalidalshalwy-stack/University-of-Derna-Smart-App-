import re
from pathlib import Path

files = [
    Path(__file__).resolve().parent.parent / "lib/features/faculty/presentation/pages/faculty_excuses_page.dart",
    Path(__file__).resolve().parent.parent / "lib/features/faculty/presentation/pages/class_detail_page.dart",
    Path(__file__).resolve().parent.parent / "lib/features/attendance/presentation/pages/professor_absence_dashboard.dart",
]

def fix_mojibake(s: str) -> str:
    try:
        return s.encode("latin-1").decode("utf-8")
    except UnicodeError:
        return s

out = Path(__file__).resolve().parent / "mojibake_decoded.txt"
lines_out: list[str] = []
pat = re.compile(r"['\"]([^'\"]+)['\"]")
base = Path(__file__).resolve().parent.parent
for fp in files:
    rel = fp.relative_to(base).as_posix()
    lines_out.append(f"FILE {rel}")
    for i, line in enumerate(fp.read_text(encoding="utf-8").splitlines(), 1):
        if "Ø" not in line and "Ù" not in line and "â" not in line:
            continue
        for m in pat.finditer(line):
            s = m.group(1)
            if "Ø" in s or "Ù" in s or "â" in s:
                lines_out.append(f"  L{i}: {fix_mojibake(s)!r}")
out.write_text("\n".join(lines_out), encoding="utf-8")
