import json
import re
from pathlib import Path

base = Path(__file__).resolve().parent.parent
out_path = base / "tools" / "faculty_l10n_audit_output.txt"

faculty_paths = [
    base / "lib/features/faculty/presentation",
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
for p in faculty_paths:
    if p.is_dir():
        dart_files.extend(sorted(p.rglob("*.dart")))
    elif p.is_file():
        dart_files.append(p)

# User-facing string literal patterns
literal_re = re.compile(
    r"(?:Text|title|subtitle|label|hintText|labelText|helperText|errorText|"
    r"tooltip|semanticsLabel|message|placeholder|child)\s*(?:\([^)]*\))?\s*:\s*"
    r"(?:const\s+)?(?:Text\s*\(\s*)?['\"]([^'\"\\n]+)['\"]"
    r"|(?:const\s+)?Text\s*\(\s*['\"]([^'\"\\n]+)['\"]"
    r"|SnackBar\s*\([^;]*?Text\s*\(\s*['\"]([^'\"\\n]+)['\"]"
    r"|validator:\s*\([^)]*\)\s*=>\s*[^?]*\?\s*['\"]([^'\"\\n]+)['\"]"
    r"|throw\s+Exception\s*\(\s*['\"]([^'\"\\n]+)['\"]"
    r"|(?:showDialog|AlertDialog)[^;{]*?['\"]([^'\"\\n]+)['\"]"
)

arabic_re = re.compile(r"[\u0600-\u06FF]")
english_re = re.compile(r"[A-Za-z]{3,}")

skip_values = {
    "Cairo",
    "yyyy-MM-dd",
    "MM/dd",
    "mm/dd/yyyy",
    "system",
    "faculty",
    "uid_1",
    "uid_2",
    "uid_3",
    "uid_4",
    "uid_5",
    "uid_6",
    "EEEE، d MMMM yyyy",
    "--",
    "Notifications",
    "Error: $e",
    "English",
    "PDF",
    "https://lh3.googleusercontent.com/aida-public/AB6AXuAHewZag3NThmir6306uS3Y-biuEehalBuohIoKKQFn-pvLycYe3LTXQ1mNhI1w9kZ0Pr57fNQTWig-9a6Fi49qoBA_PWP0GEg42er_xyUYwGf5iU90E_xdMVnkWDeP1fb4hL0YMW4ttZ4aR_RhEY3fkdEXLVbzVYizJTA5SE5ryNY2aFoydCOXozZ5N9moHgBr57LZi8Y4uatXaUgO9feKZYcMUQFJg6bE81eCIlFzgxk2WzYmEpt_rp_U67cYjgFeLutJBU3Z6m5A",
}


def is_user_facing(s: str) -> bool:
    s = s.strip()
    if not s or s in skip_values:
        return False
    if s.startswith("$") or "${" in s:
        return False
    if re.fullmatch(r"[\d\s.,:%+-]+", s):
        return False
    if re.fullmatch(r"[a-z_]+", s):
        return False
    if arabic_re.search(s):
        return True
    if english_re.search(s) and not re.fullmatch(r"[A-Z][a-zA-Z0-9]*", s):
        return True
    return False


def classify(s: str) -> str:
    if arabic_re.search(s):
        return "عربي"
    return "إنجليزي"


hardcoded: list[tuple[str, int, str, str]] = []
l10n_calls: dict[str, list[str]] = {}
l10n_pat = re.compile(r"(?:AppLocalizations\.of\(context\)!?\.|l10n\.)([a-zA-Z0-9_]+)")

for fp in dart_files:
    rel = fp.relative_to(base).as_posix()
    lines = fp.read_text(encoding="utf-8").splitlines()
    for i, line in enumerate(lines, 1):
        stripped = line.strip()
        if stripped.startswith("//"):
            continue
        for m in l10n_pat.finditer(line):
            l10n_calls.setdefault(m.group(1), []).append(f"{rel}:{i}")
        # Simple Text('...')
        for m in re.finditer(r"Text\s*\(\s*['\"]([^'\"]+)['\"]", line):
            s = m.group(1)
            if is_user_facing(s):
                hardcoded.append((rel, i, "Text()", s))
        for prop in ("title", "subtitle", "label", "hintText", "labelText", "helperText", "errorText", "tooltip"):
            pm = re.search(rf"{prop}\s*:\s*['\"]([^'\"]+)['\"]", line)
            if pm and is_user_facing(pm.group(1)):
                hardcoded.append((rel, i, prop, pm.group(1)))
        for m in re.finditer(r"SnackBar[^;]*Text\s*\(\s*['\"]([^'\"]+)['\"]", line):
            s = m.group(1)
            if is_user_facing(s):
                hardcoded.append((rel, i, "SnackBar", s))
        for m in re.finditer(r"\?\s*['\"]([^'\"]+)['\"]\s*:\s*null", line):
            s = m.group(1)
            if is_user_facing(s):
                hardcoded.append((rel, i, "validator", s))
        for m in re.finditer(r"throw\s+Exception\s*\(\s*['\"]([^'\"]+)['\"]", line):
            s = m.group(1)
            if is_user_facing(s):
                hardcoded.append((rel, i, "Exception", s))

# Deduplicate while preserving order
seen = set()
unique_hardcoded = []
for item in hardcoded:
    key = item
    if key not in seen:
        seen.add(key)
        unique_hardcoded.append(item)

missing_l10n_in_code = sorted(k for k in l10n_calls if k not in en_keys or k not in ar_keys)

lines_out = []
lines_out.append("=" * 70)
lines_out.append("تقرير فحص l10n — بوابة هيئة التدريس")
lines_out.append("=" * 70)
lines_out.append("")
lines_out.append("1) المسار الرئيسي (النشط في faculty_routes.dart):")
lines_out.append("   lib/features/faculty/presentation/")
lines_out.append("   (+ lib/features/attendance/.../professor_absence_dashboard.dart إن وُجد)")
lines_out.append("")
lines_out.append(f"   عدد ملفات Dart المفحوصة: {len(dart_files)}")
lines_out.append("")
lines_out.append("2) مقارنة app_en.arb ↔ app_ar.arb (على مستوى المشروع كاملًا):")
lines_out.append(f"   app_en.arb: {len(en_keys)} مفتاح")
lines_out.append(f"   app_ar.arb: {len(ar_keys)} مفتاح")
lines_out.append("")
lines_out.append(f"   مفاتيح موجودة في app_en.arb وغير موجودة في app_ar.arb ({len(missing_in_ar)}):")
for k in missing_in_ar:
    lines_out.append(f"     - {k}")
lines_out.append("")
lines_out.append(f"   مفاتيح موجودة في app_ar.arb وغير موجودة في app_en.arb ({len(missing_in_en)}):")
if missing_in_en:
    for k in missing_in_en:
        lines_out.append(f"     - {k}")
else:
    lines_out.append("     (لا يوجد)")
lines_out.append("")
lines_out.append("3) مفاتيح AppLocalizations المستخدمة في بوابة هيئة التدريس وغير موجودة في ARB:")
if missing_l10n_in_code:
    for k in missing_l10n_in_code:
        lines_out.append(f"     - {k} → {', '.join(l10n_calls[k])}")
else:
    lines_out.append(f"     (لا يوجد — {len(l10n_calls)} مفتاحًا مستخدمًا وكلها موجودة في كلا الملفين)")
lines_out.append("")
lines_out.append(f"4) النصوص Hardcoded ({len(unique_hardcoded)} حالة):")
lines_out.append("")

by_file: dict[str, list[tuple[int, str, str]]] = {}
for rel, ln, kind, s in unique_hardcoded:
    by_file.setdefault(rel, []).append((ln, kind, s))

for rel in sorted(by_file):
    lines_out.append(f"   📄 {rel}")
    for ln, kind, s in sorted(by_file[rel], key=lambda x: x[0]):
        lines_out.append(f"      س{ln} [{kind}] [{classify(s)}] {s}")
    lines_out.append("")

with open(out_path, "w", encoding="utf-8") as f:
    f.write("\n".join(lines_out))

print(str(out_path))
