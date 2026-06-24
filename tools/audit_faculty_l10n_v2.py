import json
import re
from pathlib import Path

base = Path(__file__).resolve().parent.parent

faculty_paths = [
    base / "lib/features/faculty/presentation",
    base / "lib/features/attendance/presentation/pages/professor_absence_dashboard.dart",
]

TECH_SKIP = {
    "Cairo", "system", "faculty", "approved", "rejected", "pending",
    "yyyy-MM-dd", "MM/dd", "mm/dd/yyyy", "EEEE، d MMMM yyyy", "--",
    "Notifications", "English", "PDF", "Error: $e", "uid_1", "uid_2",
    "uid_3", "uid_4", "uid_5", "uid_6", "package:", "import ",
}

UI_PROPS = (
    "Text", "title", "subtitle", "label", "hintText", "labelText",
    "helperText", "errorText", "tooltip", "semanticsLabel", "message",
    "placeholder", "SnackBar", "validator", "Exception", "AppBar",
)

arabic_re = re.compile(r"[\u0600-\u06FF]")
english_ui_re = re.compile(
    r"\b(Error|Loading|Cancel|Save|Delete|Submit|Upload|Download|Search|"
    r"Notifications|Back|Send|Success|Failed|Please|Select|Choose|Remove|"
    r"Confirm|Logout|Settings|Profile|Schedule|Attendance|Grades|Students)\b"
)


def load_arb_keys(path: Path) -> set[str]:
    with open(path, encoding="utf-8") as f:
        return {k for k in json.load(f) if not k.startswith("@")}


en_keys = load_arb_keys(base / "lib/l10n/app_en.arb")
ar_keys = load_arb_keys(base / "lib/l10n/app_ar.arb")

dart_files: list[Path] = []
for p in faculty_paths:
    if p.is_dir():
        dart_files.extend(sorted(p.rglob("*.dart")))
    elif p.is_file():
        dart_files.append(p)

string_lit_re = re.compile(r"['\"]((?:\\.|[^'\"\\])*)['\"]")
l10n_pat = re.compile(r"(?:AppLocalizations\.of\(context\)!?\.|l10n\.)([a-zA-Z0-9_]+)")


def is_user_facing(s: str, line: str) -> bool:
    s = s.strip()
    if len(s) < 2 or s in TECH_SKIP:
        return False
    if s.startswith("package:") or s.startswith("assets/") or s.startswith("/"):
        return False
    if s.startswith("http"):
        return False
    if "${" in s or (s.startswith("$") and len(s) > 1):
        # dynamic but contains user text
        if not arabic_re.search(s) and not english_ui_re.search(s):
            return False
    if re.fullmatch(r"[\d\s.,:%+-]+", s):
        return False
    if re.fullmatch(r"[a-z_]+", s):
        return False
    if re.fullmatch(r"[A-Z][a-zA-Z0-9]*", s):
        return False
    if "fontFamily" in line or "FontWeight" in line:
        pass  # still may be user text on same line
    if arabic_re.search(s):
        return True
    if english_ui_re.search(s):
        return True
    # Single char Arabic like ص
    if re.fullmatch(r"[\u0600-\u06FF؟]", s):
        return True
    return False


def detect_context(line: str) -> str:
    for prop in (
        "hintText", "labelText", "helperText", "errorText", "semanticsLabel",
        "tooltip", "subtitle", "title", "label", "message", "placeholder",
    ):
        if f"{prop}:" in line or f"{prop} :" in line:
            return prop
    if "SnackBar" in line:
        return "SnackBar"
    if "validator" in line:
        return "validator"
    if "throw Exception" in line:
        return "Exception"
    if "Text(" in line:
        return "Text()"
    if "AppBar" in line:
        return "AppBar"
    return "string literal"


hardcoded: list[tuple[str, int, str, str]] = []
l10n_calls: dict[str, list[str]] = {}

for fp in dart_files:
    rel = fp.relative_to(base).as_posix()
    for i, line in enumerate(fp.read_text(encoding="utf-8").splitlines(), 1):
        stripped = line.strip()
        if stripped.startswith("//") or stripped.startswith("*"):
            continue
        if stripped.startswith("import "):
            continue
        for m in l10n_pat.finditer(line):
            l10n_calls.setdefault(m.group(1), []).append(f"{rel}:{i}")
        for m in string_lit_re.finditer(line):
            s = m.group(1)
            if is_user_facing(s, line):
                ctx = detect_context(line)
                hardcoded.append((rel, i, ctx, s))

# dedupe
seen = set()
unique = []
for item in hardcoded:
    if item not in seen:
        seen.add(item)
        unique.append(item)

missing_l10n = sorted(k for k in l10n_calls if k not in en_keys or k not in ar_keys)
missing_in_ar = sorted(en_keys - ar_keys)
missing_in_en = sorted(ar_keys - en_keys)

by_file: dict[str, list[tuple[int, str, str]]] = {}
for rel, ln, ctx, s in unique:
    by_file.setdefault(rel, []).append((ln, ctx, s))

out = base / "tools" / "faculty_l10n_audit_output.txt"
lines = [
    "=" * 70,
    "تقرير فحص l10n — بوابة هيئة التدريس (نسخة موسّعة)",
    "=" * 70,
    "",
    "1) المسارات المفحوصة:",
    "   • lib/features/faculty/presentation/  (النشط — مُعرَّف في faculty_routes.dart)",
    "   • lib/features/attendance/presentation/pages/professor_absence_dashboard.dart",
    "",
    "   ملاحظة: يوجد مجلدات قديمة غير مستخدمة في المسارات:",
    "   lib/features/faculty/pages/ و lib/features/faculty/screens/",
    "",
    f"   عدد ملفات Dart المفحوصة: {len(dart_files)}",
    "",
    "2) مقارنة app_en.arb ↔ app_ar.arb (مستوى المشروع):",
    f"   app_en.arb: {len(en_keys)} مفتاح | app_ar.arb: {len(ar_keys)} مفتاح",
    "",
    f"   ناقص في app_ar.arb ({len(missing_in_ar)}):",
]
for k in missing_in_ar:
    lines.append(f"     • {k}")
lines += [
    "",
    f"   ناقص في app_en.arb ({len(missing_in_en)}):",
    "     (لا يوجد)" if not missing_in_en else "",
]
for k in missing_in_en:
    lines.append(f"     • {k}")
lines += [
    "",
    "3) مفاتيح l10n مستخدمة في بوابة هيئة التدريس وغير موجودة في ARB:",
]
if missing_l10n:
    for k in missing_l10n:
        lines.append(f"     • {k} → {', '.join(l10n_calls[k])}")
else:
    lines.append(f"     (لا يوجد — {len(l10n_calls)} مفتاحًا مستخدمًا وكلها موجودة)")
lines += [
    "",
    f"4) النصوص Hardcoded ({len(unique)} حالة فريدة):",
    "",
]
for rel in sorted(by_file):
    lines.append(f"   📄 {rel}")
    for ln, ctx, s in sorted(by_file[rel], key=lambda x: x[0]):
        lang = "عربي" if arabic_re.search(s) else "إنجليزي"
        lines.append(f"      س{ln} [{ctx}] [{lang}] {s}")
    lines.append("")

out.write_text("\n".join(lines), encoding="utf-8")
print(len(unique), "hardcoded,", len(missing_l10n), "missing l10n keys")
