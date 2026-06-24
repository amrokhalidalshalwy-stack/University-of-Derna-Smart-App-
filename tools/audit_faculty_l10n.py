import json
import re
from pathlib import Path

base = Path(__file__).resolve().parent.parent
faculty_dirs = [
    base / "lib/features/faculty/presentation",
    base / "lib/features/faculty/providers",
    base / "lib/features/attendance/presentation/pages/professor_absence_dashboard.dart",
]


def load_arb_keys(path: Path) -> set[str]:
    with open(path, encoding="utf-8") as f:
        data = json.load(f)
    return {k for k in data.keys() if not k.startswith("@")}


en_keys = load_arb_keys(base / "lib/l10n/app_en.arb")
ar_keys = load_arb_keys(base / "lib/l10n/app_ar.arb")

missing_in_ar = sorted(en_keys - ar_keys)
missing_in_en = sorted(ar_keys - en_keys)

dart_files: list[Path] = []
for d in faculty_dirs:
    if d.is_dir():
        dart_files.extend(d.rglob("*.dart"))
    elif d.is_file():
        dart_files.append(d)

patterns = [
    (r"Text\s*\(\s*['\"]([^'\"]+)['\"]", "Text"),
    (r"title\s*:\s*['\"]([^'\"]+)['\"]", "title"),
    (r"hintText\s*:\s*['\"]([^'\"]+)['\"]", "hintText"),
    (r"labelText\s*:\s*['\"]([^'\"]+)['\"]", "labelText"),
    (r"label\s*:\s*['\"]([^'\"]+)['\"]", "label"),
    (r"tooltip\s*:\s*['\"]([^'\"]+)['\"]", "tooltip"),
    (r"semanticsLabel\s*:\s*['\"]([^'\"]+)['\"]", "semanticsLabel"),
    (r"helperText\s*:\s*['\"]([^'\"]+)['\"]", "helperText"),
    (r"errorText\s*:\s*['\"]([^'\"]+)['\"]", "errorText"),
    (r"placeholder\s*:\s*['\"]([^'\"]+)['\"]", "placeholder"),
    (r"message\s*:\s*['\"]([^'\"]+)['\"]", "message"),
    (r"subtitle\s*:\s*['\"]([^'\"]+)['\"]", "subtitle"),
    (r"child\s*:\s*Text\s*\(\s*['\"]([^'\"]+)['\"]", "child Text"),
    (r"SnackBar\s*\(\s*content\s*:\s*Text\s*\(\s*['\"]([^'\"]+)['\"]", "SnackBar"),
]


def has_arabic(s: str) -> bool:
    return bool(re.search(r"[\u0600-\u06FF]", s))


def has_english_words(s: str) -> bool:
    return bool(re.search(r"[A-Za-z]{3,}", s))


def should_report(s: str) -> bool:
    s = s.strip()
    if len(s) < 2:
        return False
    if s.startswith("$") or ("{" in s and "}" in s):
        return False
    if re.match(r"^[\d\s.,:%+-]+$", s):
        return False
    if re.match(r"^[a-z_]+$", s):
        return False
    if has_arabic(s):
        return True
    if has_english_words(s) and not re.match(r"^[A-Z][a-zA-Z0-9]*$", s):
        return True
    return False


hardcoded: list[tuple[str, int, str, str, str]] = []
l10n_calls: list[tuple[str, int, str]] = []

l10n_pattern = re.compile(r"AppLocalizations\.of\(context\)!?\.([a-zA-Z0-9_]+)")
l10n_pattern2 = re.compile(r"\bl10n\.([a-zA-Z0-9_]+)")

for fp in sorted(set(dart_files)):
    try:
        text = fp.read_text(encoding="utf-8")
    except OSError:
        continue
    rel = fp.relative_to(base).as_posix()
    for i, line in enumerate(text.splitlines(), 1):
        stripped = line.strip()
        if stripped.startswith("//") or stripped.startswith("*"):
            continue
        for pat, kind in patterns:
            for m in re.finditer(pat, line):
                s = m.group(1)
                if should_report(s):
                    hardcoded.append((rel, i, kind, s, line.strip()[:140]))
        for m in l10n_pattern.finditer(line):
            l10n_calls.append((rel, i, m.group(1)))
        for m in l10n_pattern2.finditer(line):
            l10n_calls.append((rel, i, m.group(1)))

used_keys = sorted({k for _, _, k in l10n_calls})
missing_keys = sorted({k for k in used_keys if k not in en_keys or k not in ar_keys})

print("=== ARB COMPARISON ===")
print(f"app_en.arb keys: {len(en_keys)}")
print(f"app_ar.arb keys: {len(ar_keys)}")
print(f"Missing in app_ar.arb ({len(missing_in_ar)}):")
for k in missing_in_ar:
    print(f"  {k}")
print(f"Missing in app_en.arb ({len(missing_in_en)}):")
for k in missing_in_en:
    print(f"  {k}")

print("\n=== MISSING L10N KEYS IN FACULTY CODE ===")
for k in missing_keys:
    files = sorted({f"{r}:{ln}" for r, ln, key in l10n_calls if key == k})
    print(f"{k} -> {', '.join(files)}")

print("\n=== HARDCODED STRINGS ===")
for rel, ln, kind, s, ctx in hardcoded:
    print(f"{rel}:{ln} [{kind}] {s!r}")
