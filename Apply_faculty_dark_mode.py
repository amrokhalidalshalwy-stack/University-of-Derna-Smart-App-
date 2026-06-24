#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
╔══════════════════════════════════════════════════════════════════════╗
║     DUSPS — Faculty Portal Dark Mode Patcher                        ║
║     جامعة درنة الذكي — تطبيق الوضع الداكن على بوابة هيئة التدريس  ║
╚══════════════════════════════════════════════════════════════════════╝

الاستخدام:
    python apply_faculty_dark_mode.py [مسار_المشروع]

    إذا لم يُحدَّد مسار يُستخدَم المجلد الحالي تلقائياً.

مثال:
    python apply_faculty_dark_mode.py C:/Users/Omar/flutter_project
    python apply_faculty_dark_mode.py
"""

import os
import sys
import re
import shutil
import textwrap
from pathlib import Path
from datetime import datetime

# ─────────────────────────────────────────────────────────────
# الإعدادات العامة
# ─────────────────────────────────────────────────────────────

BACKUP_SUFFIX = ".bak_darkmode"

# مسارات الملفات نسبةً لجذر المشروع
TARGET_FILES = {
    "schedule":    "lib/features/faculty/pages/faculty_schedule_page.dart",
    "students":    "lib/features/faculty/pages/faculty_students_page.dart",
    "attendance":  "lib/features/faculty/pages/faculty_attendance_sheet_page.dart",
    "assignments": "lib/features/faculty/pages/faculty_assignments_page.dart",
    "profile":     "lib/features/faculty/pages/faculty_profile_page.dart",
    "settings":    "lib/features/faculty/pages/faculty_settings_page.dart",
    "reports":     "lib/features/faculty/pages/faculty_reports_page.dart",
    "class":       "lib/features/faculty/pages/class_detail_page.dart",
}

# ─────────────────────────────────────────────────────────────
# الدوال المساعدة
# ─────────────────────────────────────────────────────────────

def log(msg: str, level: str = "INFO"):
    icons = {"INFO": "ℹ", "OK": "✅", "WARN": "⚠", "ERR": "❌", "STEP": "🔧", "DONE": "🎉"}
    print(f"  {icons.get(level,'·')} {msg}")

def backup_file(path: Path):
    bak = path.with_suffix(path.suffix + BACKUP_SUFFIX)
    shutil.copy2(path, bak)
    log(f"نسخة احتياطية: {bak.name}", "OK")

def read_file(path: Path) -> str:
    return path.read_text(encoding="utf-8")

def write_file(path: Path, content: str):
    path.write_text(content, encoding="utf-8")

def count_changes(original: str, modified: str) -> int:
    orig_lines = original.splitlines()
    mod_lines  = modified.splitlines()
    return sum(1 for a, b in zip(orig_lines, mod_lines) if a != b) + abs(len(mod_lines) - len(orig_lines))

# ─────────────────────────────────────────────────────────────
# أدوات التعديل الذكية
# ─────────────────────────────────────────────────────────────

def ensure_is_dark_in_build(code: str) -> str:
    """يضيف `final isDark = ...` بعد كل build() التي لا تحتوي عليه."""
    is_dark_line = "    final isDark = Theme.of(context).brightness == Brightness.dark;"

    def inject_if_missing(m: re.Match) -> str:
        body_start = m.end()
        # ابحث عن نهاية الـ build method (أول } على مستوى المسافة نفسها)
        # بدلاً من ذلك نتحقق هل التالي 200 حرف تحتوي على isDark
        following = code[body_start:body_start + 600]
        if "isDark = Theme.of(context).brightness" in following:
            return m.group(0)  # موجود بالفعل في هذا الـ build
        return m.group(0) + f"\n{is_dark_line}"

    pattern = r'Widget build\(BuildContext context(?:,\s*WidgetRef ref)?\)\s*\{'
    return re.sub(pattern, inject_if_missing, code)

def replace_scaffold_bg(code: str, light_color: str) -> str:
    """يستبدل backgroundColor ثابتة في Scaffold"""
    # استبدال Color ثابتة
    pattern = rf'(Scaffold\s*\([\s\S]{{0,200}}?backgroundColor:\s*)const Color\(0xFF{light_color}\)'
    replacement = rf'\1isDark ? const Color(0xFF071A18) : const Color(0xFF{light_color})'
    new_code = re.sub(pattern, replacement, code)
    # استبدال Colors.white
    if light_color == "FFFFFF":
        pattern2 = r'(Scaffold\s*\([\s\S]{0,200}?backgroundColor:\s*)Colors\.white'
        new_code = re.sub(pattern2, r'\1isDark ? const Color(0xFF071A18) : Colors.white', new_code)
    return new_code

def replace_appbar_bg(code: str, keep_light: str = "001835") -> str:
    """يحوّل backgroundColor ثابتة في AppBar إلى ديناميكية"""
    def repl(m):
        val = m.group(2)
        if "isDark" in val:
            return m.group(0)
        # استخراج اللون
        hex_match = re.search(r'0xFF([0-9A-Fa-f]{6})', val)
        light = hex_match.group(1) if hex_match else keep_light
        return f"{m.group(1)}isDark ? const Color(0xFF0D2420) : const Color(0xFF{light})"
    pattern = r'(backgroundColor:\s*)(const\s+Color\(0xFF[0-9A-Fa-f]{6}\))'
    # نطبق فقط داخل AppBar — نحدد نطاق AppBar
    appbar_pattern = r'(AppBar\((?:[^()]*|\((?:[^()]*|\([^()]*\))*\))*\))'
    def fix_appbar(m):
        inner = m.group(0)
        inner = re.sub(r'(backgroundColor:\s*)(const\s+Color\(0xFF[0-9A-Fa-f]{6}\))', repl, inner)
        return inner
    return re.sub(appbar_pattern, fix_appbar, code, flags=re.DOTALL)

def add_brand_vars_after_is_dark(code: str) -> str:
    """يضيف متغيرات Brand بعد isDark إذا لم تكن موجودة"""
    brand_block = textwrap.dedent("""\
        final brandTeal = isDark ? const Color(0xFF4DFFD6) : const Color(0xFF00A694);
        final brandNavy = isDark ? const Color(0xFF071A18) : const Color(0xFF001835);
        final cardBg    = isDark ? const Color(0xFF0D2420) : Colors.white;
        final inputBg   = isDark ? const Color(0xFF0A3330) : Colors.white;""")

    if "brandTeal = isDark" in code:
        return code  # موجودة بالفعل

    target = "final isDark = Theme.of(context).brightness == Brightness.dark;"
    if target not in code:
        return code
    # أضف بعد سطر isDark
    indent = "    "
    indented_block = "\n".join(indent + line for line in brand_block.splitlines())
    return code.replace(target, target + "\n" + indented_block)

def replace_hardcoded_brand_vars(code: str) -> str:
    """يستبدل تعريفات البراند المثبّتة بنسخ ديناميكية"""
    replacements = [
        # brandTeal ثابت
        (r'final brandTeal\s*=\s*const Color\(0xFF[0-9A-Fa-f]{6}\);',
         'final brandTeal = isDark ? const Color(0xFF4DFFD6) : const Color(0xFF00A694);'),
        # brandNavy / brandDark ثابت
        (r'final brandNavy\s*=\s*const Color\(0xFF[0-9A-Fa-f]{6}\);',
         'final brandNavy = isDark ? const Color(0xFF071A18) : const Color(0xFF001835);'),
        (r'final brandDark\s*=\s*const Color\(0xFF[0-9A-Fa-f]{6}\);',
         'final brandDark = isDark ? const Color(0xFF0D2420) : const Color(0xFF0b2447);'),
    ]
    for pattern, repl in replacements:
        code = re.sub(pattern, repl, code)
    return code

def make_input_decoration_dynamic(code: str) -> str:
    """يحوّل fillColor ثابتة في حقول الإدخال إلى ديناميكية"""
    # fillColor: Colors.white → ديناميكي
    code = re.sub(
        r'fillColor:\s*Colors\.white(?!\s*:)',
        'fillColor: isDark ? const Color(0xFF0A3330) : Colors.white',
        code
    )
    # fillColor: const Color(0xFF1E293B) (نمط قديم من login)
    code = re.sub(
        r"fillColor:\s*isDark\s*\?\s*const Color\(0xFF1E293B\)\s*:\s*Colors\.white",
        "fillColor: isDark ? const Color(0xFF0A3330) : Colors.white",
        code
    )
    # filled: true إذا غائبة نضيف (بعد fillColor)
    return code

def fix_card_colors(code: str) -> str:
    """يحوّل Card(child: ...) لإضافة color ديناميكية إذا لم تكن موجودة"""
    # Card بدون color محددة — نضيف color
    def card_replacer(m):
        inner = m.group(0)
        if "color:" in inner and "isDark" in inner:
            return inner  # معدّل بالفعل
        if re.search(r'\bcolor:\s*(?!isDark)', inner):
            # color موجودة لكنها ثابتة — نحوّلها
            inner = re.sub(
                r'(\bcolor:\s*)Colors\.white(?!\s*[,)].*isDark)',
                r'\1isDark ? const Color(0xFF0D2420) : Colors.white',
                inner
            )
        return inner
    # نطبق على Card widgets فقط (محدودة النطاق)
    return re.sub(r'Card\((?:[^()]*|\((?:[^()]*|\([^()]*\))*\))*\)', card_replacer, code, flags=re.DOTALL)

# ─────────────────────────────────────────────────────────────
# التعديلات الخاصة بكل ملف
# ─────────────────────────────────────────────────────────────

def patch_schedule(code: str) -> str:
    log("faculty_schedule_page.dart ...", "STEP")

    # 1. إضافة isDark + brand vars
    code = ensure_is_dark_in_build(code)
    code = add_brand_vars_after_is_dark(code)

    # 2. خلفية Scaffold
    code = re.sub(
        r"backgroundColor:\s*const Color\(0xFFF8FAFC\)",
        "backgroundColor: isDark ? const Color(0xFF071A18) : const Color(0xFFF8FAFC)",
        code
    )

    # 3. Day Selector Container color: Colors.white
    code = re.sub(
        r"(// Day Selector[\s\S]{0,50}?Container\([\s\S]{0,100}?)color:\s*Colors\.white",
        r"\1color: isDark ? const Color(0xFF0D2420) : Colors.white",
        code
    )
    # أيضاً الـ Container الأبيض العام في قسم اليوم
    code = re.sub(
        r"(padding:\s*const EdgeInsets\.all\(16\),\s*)color:\s*Colors\.white",
        r"\1color: isDark ? const Color(0xFF0D2420) : Colors.white",
        code
    )

    # 4. بطاقة اليوم المحدد — decoration في GestureDetector
    old_day_deco = r"color:\s*isSelected\s*\?\s*brandTeal\s*:\s*Colors\.grey\.shade100"
    new_day_deco = ("color: isSelected\n"
                    "                      ? (isDark ? const Color(0xFF4DFFD6).withValues(alpha: 0.2) : brandTeal)\n"
                    "                      : (isDark ? const Color(0xFF0A3330) : Colors.grey.shade100)")
    code = re.sub(old_day_deco, new_day_deco, code)

    # 5. نص اسم اليوم
    old_day_text = r"color:\s*isSelected\s*\?\s*Colors\.white\s*:\s*Colors\.grey"
    new_day_text = ("color: isSelected\n"
                    "                                ? (isDark ? const Color(0xFF4DFFD6) : Colors.white)\n"
                    "                                : (isDark ? Colors.white54 : Colors.grey)")
    code = re.sub(old_day_text, new_day_text, code)

    # 6. نص التاريخ (fontWeight bold بعده)
    old_date_text = r"color:\s*isSelected\s*\?\s*Colors\.white\s*:\s*brandNavy"
    new_date_text = ("color: isSelected\n"
                     "                                ? (isDark ? const Color(0xFF4DFFD6) : Colors.white)\n"
                     "                                : (isDark ? Colors.white70 : brandNavy)")
    code = re.sub(old_date_text, new_date_text, code)

    # 7. AppBar background
    code = re.sub(
        r"(appBar:[\s\S]{0,300}?backgroundColor:\s*)brandNavy",
        r"\1isDark ? const Color(0xFF0D2420) : const Color(0xFF001835)",
        code,
        count=1
    )

    # 8. Card المحاضرات — color ديناميكية
    code = re.sub(
        r"(Card\(\s*\n?\s*child:)",
        r"Card(\n              color: isDark ? const Color(0xFF0D2420) : Colors.white,\n              child:",
        code
    )

    # 9. Scaffold backgroundColor الثانية (schedule_page يستخدم const Color مباشرة)
    code = code.replace(
        "backgroundColor: const Color(0xFFF8FAFC),",
        "backgroundColor: isDark ? const Color(0xFF071A18) : const Color(0xFFF8FAFC),"
    )

    log("faculty_schedule_page.dart ✓", "OK")
    return code


def patch_students(code: str) -> str:
    log("faculty_students_page.dart ...", "STEP")

    code = ensure_is_dark_in_build(code)
    code = add_brand_vars_after_is_dark(code)

    # 1. Scaffold background
    code = re.sub(
        r"backgroundColor:\s*const Color\(0xFFF8FAFC\)",
        "backgroundColor: isDark ? const Color(0xFF071A18) : const Color(0xFFF8FAFC)",
        code
    )

    # 2. AppBar
    code = re.sub(
        r"(AppBar\([\s\S]{0,100}?backgroundColor:\s*)brandNavy",
        r"\1isDark ? const Color(0xFF0D2420) : const Color(0xFF001835)",
        code,
        count=1
    )

    # 3. DropdownButton — إضافة dropdownColor و style
    code = re.sub(
        r"(DropdownButton<String>\()",
        r"\1\n                dropdownColor: isDark ? const Color(0xFF0D2420) : Colors.white,\n                style: TextStyle(fontFamily: 'Cairo', color: isDark ? Colors.white : Colors.black87),",
        code
    )

    # 4. حقل البحث — fillColor
    code = re.sub(
        r"(TextField\([\s\S]{0,50}?controller:\s*_searchCtrl[\s\S]{0,300}?border:\s*OutlineInputBorder)",
        lambda m: m.group(0),  # placeholder — نعدّل الـ InputDecoration يدوياً أسفله
        code
    )
    # استبدال أبسط: أضف fillColor وfilled داخل InputDecoration لـ search
    code = re.sub(
        r"(hintText:\s*l10n\.studentsSearch,\s*\n\s*prefixIcon:[\s\S]{0,100}?border:\s*OutlineInputBorder\(borderRadius:\s*BorderRadius\.circular\(12\)\),\s*\n\s*)",
        (r"\1"
         r"filled: true,\n                "
         r"fillColor: isDark ? const Color(0xFF0A3330) : Colors.white,\n                "
         r"enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: isDark ? BorderSide(color: const Color(0xFF4DFFD6).withValues(alpha: 0.2)) : const BorderSide(color: Color(0xFFE2E8F0))),\n                "
         r"focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF4DFFD6), width: 1.5)),\n                "),
        code
    )

    # 5. بطاقات الطلاب Card
    code = re.sub(
        r"(return Card\(\s*\n?\s*child:\s*ListTile\()",
        r"return Card(\n                          color: isDark ? const Color(0xFF0D2420) : Colors.white,\n                          child: ListTile(",
        code
    )

    # 6. CircleAvatar
    code = re.sub(
        r"leading:\s*CircleAvatar\(child:\s*Text\(student\.fullName\[0\]\)\)",
        ("leading: CircleAvatar(\n"
         "                              backgroundColor: isDark\n"
         "                                  ? const Color(0xFF4DFFD6).withValues(alpha: 0.2)\n"
         "                                  : const Color(0xFF00A694).withValues(alpha: 0.1),\n"
         "                              child: Text(\n"
         "                                student.fullName[0],\n"
         "                                style: TextStyle(\n"
         "                                  color: isDark ? const Color(0xFF4DFFD6) : const Color(0xFF00A694),\n"
         "                                  fontFamily: 'Cairo',\n"
         "                                  fontWeight: FontWeight.bold,\n"
         "                                ),\n"
         "                              ),\n"
         "                            )"),
        code
    )

    log("faculty_students_page.dart ✓", "OK")
    return code


def patch_attendance(code: str) -> str:
    log("faculty_attendance_sheet_page.dart ...", "STEP")

    code = ensure_is_dark_in_build(code)
    code = add_brand_vars_after_is_dark(code)

    # 1. Scaffold background (0xFFF3F7F9)
    code = re.sub(
        r"backgroundColor:\s*const Color\(0xFFF3F7F9\)",
        "backgroundColor: isDark ? const Color(0xFF071A18) : const Color(0xFFF3F7F9)",
        code
    )

    # 2. AppBar
    code = re.sub(
        r"(AppBar\([\s\S]{0,100}?backgroundColor:\s*)brandNavy",
        r"\1isDark ? const Color(0xFF0D2420) : const Color(0xFF001835)",
        code,
        count=1
    )

    # 3. بطاقة الطالب Card
    code = re.sub(
        r"(return Card\(\s*\n?\s*child:\s*Padding\()",
        r"return Card(\n                    color: isDark ? const Color(0xFF0D2420) : Colors.white,\n                    child: Padding(",
        code
    )

    # 4. زر الحالة — لون الخلفية عندما غير نشط
    code = re.sub(
        r"color:\s*active\s*\?\s*activeColor\s*:\s*const Color\(0xFFF1F5F9\)",
        "color: active ? activeColor : (isDark ? const Color(0xFF0A3330) : const Color(0xFFF1F5F9))",
        code
    )

    # 5. نص زر الحالة عندما غير نشط
    code = re.sub(
        r"color:\s*active\s*\?\s*Colors\.white\s*:\s*Colors\.grey",
        "color: active ? Colors.white : (isDark ? Colors.white54 : Colors.grey)",
        code
    )

    # 6. Container الحفظ السفلي
    code = re.sub(
        r"(// Save Button\s*\n\s*Container\(\s*\n\s*padding:[\s\S]{0,50}?\n\s*)color:\s*Colors\.white",
        r"\1color: isDark ? const Color(0xFF0D2420) : Colors.white",
        code
    )
    # fallback إذا لم يكن هناك comment
    code = re.sub(
        r"(padding:\s*const EdgeInsets\.all\(16\),\s*\n\s*)color:\s*Colors\.white(\s*\n\s*child:\s*ElevatedButton\.icon)",
        r"\1color: isDark ? const Color(0xFF0D2420) : Colors.white\2",
        code
    )

    # 7. Stat chip — خلفية أكثر وضوحاً في الداكن
    code = re.sub(
        r"color:\s*color\.withValues\(alpha:\s*0\.08\)",
        "color: isDark ? color.withValues(alpha: 0.12) : color.withValues(alpha: 0.08)",
        code
    )

    # 8. Save button — لون ديناميكي
    code = re.sub(
        r"(ElevatedButton\.icon\(\s*\n?\s*onPressed:.*?_saveAll[\s\S]{0,50}?backgroundColor:\s*)brandTeal",
        r"\1isDark ? const Color(0xFF00695C) : brandTeal",
        code,
        count=1
    )

    log("faculty_attendance_sheet_page.dart ✓", "OK")
    return code


def patch_assignments(code: str) -> str:
    log("faculty_assignments_page.dart ...", "STEP")

    code = ensure_is_dark_in_build(code)

    # 1. استبدال تعريفات البراند المثبّتة
    code = re.sub(
        r"final brandTeal\s*=\s*const Color\(0xFF00837a\);",
        "final brandTeal = isDark ? const Color(0xFF4DFFD6) : const Color(0xFF00837a);",
        code
    )
    code = re.sub(
        r"final brandDark\s*=\s*const Color\(0xFF0b2447\);",
        "final brandDark = isDark ? const Color(0xFF0D2420) : const Color(0xFF0b2447);",
        code
    )
    # إضافة cardBg و inputBg بعد brandDark
    code = re.sub(
        r"(final brandDark\s*=\s*isDark.*?;)",
        r"\1\n    final cardBg    = isDark ? const Color(0xFF0D2420) : Colors.white;\n    final inputBg   = isDark ? const Color(0xFF0A3330) : Colors.white;",
        code
    )

    # 2. Scaffold background
    code = re.sub(
        r"backgroundColor:\s*const Color\(0xFFF8FAFC\)",
        "backgroundColor: isDark ? const Color(0xFF071A18) : const Color(0xFFF8FAFC)",
        code
    )

    # 3. AppBar
    code = re.sub(
        r"(AppBar\([\s\S]{0,100}?backgroundColor:\s*)brandDark",
        r"\1isDark ? const Color(0xFF0D2420) : const Color(0xFF0b2447)",
        code,
        count=1
    )

    # 4. _buildWaitingCard — Container
    code = re.sub(
        r"(// _buildWaitingCard[\s\S]{0,50}?|Widget _buildWaitingCard[\s\S]{0,100}?)"
        r"decoration:\s*BoxDecoration\(color:\s*Colors\.white,\s*borderRadius:\s*BorderRadius\.circular\(16\)\)",
        r"\1decoration: BoxDecoration(\n      color: cardBg,\n      borderRadius: BorderRadius.circular(16),\n      border: isDark ? Border.all(color: const Color(0xFF4DFFD6).withValues(alpha: 0.25)) : null,\n    )",
        code
    )
    # fallback بسيط
    code = code.replace(
        "decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),",
        "decoration: BoxDecoration(\n      color: cardBg,\n      borderRadius: BorderRadius.circular(16),\n      border: isDark ? Border.all(color: const Color(0xFF4DFFD6).withValues(alpha: 0.25)) : null,\n    ),"
    )

    # 5. نص الأرقام في WaitingCard
    code = re.sub(
        r"(Text\('06'[\s\S]{0,50}?color:\s*)brandDark",
        r"\1isDark ? const Color(0xFF4DFFD6) : brandDark",
        code
    )

    # 6. _buildGradedCard — Container داكن
    code = re.sub(
        r"decoration:\s*BoxDecoration\(color:\s*brandDark,\s*borderRadius:\s*BorderRadius\.circular\(16\)\)",
        ("decoration: BoxDecoration(\n"
         "      color: isDark ? const Color(0xFF071A18) : brandDark,\n"
         "      borderRadius: BorderRadius.circular(16),\n"
         "      border: isDark ? Border.all(color: const Color(0xFF4DFFD6).withValues(alpha: 0.4)) : null,\n"
         "    )"),
        code
    )

    # 7. Form Container (نموذج الإضافة)
    code = re.sub(
        r"decoration:\s*BoxDecoration\(\s*\n?\s*color:\s*Colors\.white,\s*\n?\s*borderRadius:\s*BorderRadius\.circular\(16\),\s*\n?\s*border:\s*Border\(right:\s*BorderSide\(color:\s*brandTeal,\s*width:\s*4\)\),\s*\n?\s*\)",
        ("decoration: BoxDecoration(\n"
         "            color: cardBg,\n"
         "            borderRadius: BorderRadius.circular(16),\n"
         "            border: isDark\n"
         "                ? Border.all(color: const Color(0xFF4DFFD6).withValues(alpha: 0.3))\n"
         "                : const Border(right: BorderSide(color: Color(0xFF00837a), width: 4)),\n"
         "          )"),
        code
    )

    # 8. حقول الإدخال
    code = re.sub(
        r"border:\s*OutlineInputBorder\(borderRadius:\s*BorderRadius\.circular\(12\)\)",
        ("border: OutlineInputBorder(\n"
         "                    borderRadius: BorderRadius.circular(12),\n"
         "                    borderSide: isDark ? BorderSide(color: const Color(0xFF4DFFD6).withValues(alpha: 0.3)) : BorderSide.none,\n"
         "                  ),\n"
         "                  filled: true,\n"
         "                  fillColor: inputBg,\n"
         "                  enabledBorder: OutlineInputBorder(\n"
         "                    borderRadius: BorderRadius.circular(12),\n"
         "                    borderSide: isDark ? BorderSide(color: const Color(0xFF4DFFD6).withValues(alpha: 0.2)) : const BorderSide(color: Color(0xFFE2E8F0)),\n"
         "                  ),\n"
         "                  focusedBorder: OutlineInputBorder(\n"
         "                    borderRadius: BorderRadius.circular(12),\n"
         "                    borderSide: const BorderSide(color: Color(0xFF4DFFD6), width: 1.5),\n"
         "                  )"),
        code
    )

    log("faculty_assignments_page.dart ✓", "OK")
    return code


def patch_profile(code: str) -> str:
    log("faculty_profile_page.dart ...", "STEP")

    code = ensure_is_dark_in_build(code)
    code = add_brand_vars_after_is_dark(code)

    # 1. Scaffold background
    code = re.sub(
        r"backgroundColor:\s*const Color\(0xFFF3F7F9\)",
        "backgroundColor: isDark ? const Color(0xFF071A18) : const Color(0xFFF3F7F9)",
        code
    )

    # 2. SliverAppBar gradient
    code = re.sub(
        r"(gradient:\s*LinearGradient\(colors:\s*\[)(brandTeal,\s*brandNavy)(\],\s*begin:\s*Alignment\.topRight,\s*end:\s*Alignment\.bottomLeft,?\s*\))",
        (r"\1isDark\n"
         r"              ? [const Color(0xFF071A18), const Color(0xFF0D2420)]\n"
         r"              : [brandTeal, brandNavy]\3"),
        code
    )

    # 3. SliverAppBar backgroundColor
    code = re.sub(
        r"(SliverAppBar\([\s\S]{0,100}?backgroundColor:\s*)brandNavy",
        r"\1isDark ? const Color(0xFF0D2420) : const Color(0xFF001835)",
        code,
        count=1
    )

    # 4. CircleAvatar الرئيسية (radius: 50)
    code = re.sub(
        r"const CircleAvatar\(radius:\s*50,\s*backgroundColor:\s*Colors\.white,\s*child:\s*Icon\(Icons\.person,\s*size:\s*50,\s*color:\s*brandNavy\)\)",
        ("CircleAvatar(\n"
         "                      radius: 50,\n"
         "                      backgroundColor: isDark\n"
         "                          ? const Color(0xFF4DFFD6).withValues(alpha: 0.15)\n"
         "                          : Colors.white,\n"
         "                      child: Icon(\n"
         "                        Icons.person,\n"
         "                        size: 50,\n"
         "                        color: isDark ? const Color(0xFF4DFFD6) : const Color(0xFF001835),\n"
         "                      ),\n"
         "                    )"),
        code
    )

    # 5. _buildInfoCard — Card color
    code = re.sub(
        r"(Widget _buildInfoCard\([\s\S]{0,50}\)\s*\{[\s\S]{0,100}?return Card\()",
        r"\1\n      color: isDark ? const Color(0xFF0D2420) : Colors.white,",
        code
    )

    # 6. أيقونة داخل InfoCard
    code = re.sub(
        r"(decoration:\s*BoxDecoration\(\s*\n?\s*color:\s*)brandTeal\.withValues\(alpha:\s*0\.08\)",
        r"\1isDark ? const Color(0xFF4DFFD6).withValues(alpha: 0.12) : brandTeal.withValues(alpha: 0.08)",
        code
    )
    code = re.sub(
        r"(child:\s*Icon\(icon,\s*color:\s*)brandTeal\)",
        r"\1isDark ? const Color(0xFF4DFFD6) : brandTeal)",
        code
    )

    # 7. زر الخروج — حدود ديناميكية
    code = re.sub(
        r"OutlinedButton\.styleFrom\(foregroundColor:\s*Colors\.redAccent\)",
        ("OutlinedButton.styleFrom(\n"
         "              foregroundColor: Colors.redAccent,\n"
         "              side: BorderSide(\n"
         "                color: isDark\n"
         "                    ? Colors.redAccent.withValues(alpha: 0.5)\n"
         "                    : Colors.redAccent,\n"
         "              ),\n"
         "            )"),
        code
    )

    log("faculty_profile_page.dart ✓", "OK")
    return code


def patch_settings(code: str) -> str:
    log("faculty_settings_page.dart ...", "STEP")

    code = ensure_is_dark_in_build(code)
    code = add_brand_vars_after_is_dark(code)

    # 1. Scaffold background (0xFFF1F5F9)
    code = re.sub(
        r"backgroundColor:\s*const Color\(0xFFF1F5F9\)",
        "backgroundColor: isDark ? const Color(0xFF071A18) : const Color(0xFFF1F5F9)",
        code
    )

    # 2. AppBar
    code = re.sub(
        r"(AppBar\([\s\S]{0,100}?backgroundColor:\s*)brandNavy",
        r"\1isDark ? const Color(0xFF0D2420) : const Color(0xFF001835)",
        code,
        count=1
    )

    # 3. Card الإعدادات
    code = re.sub(
        r"(Card\(\s*\n?\s*child:\s*Column\()",
        r"Card(\n              color: isDark ? const Color(0xFF0D2420) : Colors.white,\n              child: Column(",
        code
    )

    # 4. أيقونات ListTile
    code = re.sub(
        r"(Icon\(Icons\.person_outline_rounded,\s*color:\s*)brandTeal\)",
        r"\1isDark ? const Color(0xFF4DFFD6) : brandTeal)",
        code
    )
    code = re.sub(
        r"(Icon\(Icons\.language_rounded,\s*color:\s*)brandTeal\)",
        r"\1isDark ? const Color(0xFF4DFFD6) : brandTeal)",
        code
    )
    code = re.sub(
        r"(Icon\(Icons\.dark_mode_outlined,\s*color:\s*)brandTeal\)",
        r"\1isDark ? const Color(0xFF4DFFD6) : brandTeal)",
        code
    )
    code = re.sub(
        r"(Icon\(Icons\.notifications_none_rounded,\s*color:\s*)brandTeal\)",
        r"\1isDark ? const Color(0xFF4DFFD6) : brandTeal)",
        code
    )

    # 5. Switch — activeColor و activeTrackColor
    code = re.sub(
        r"(SwitchListTile\([\s\S]{0,200}?)(\bonChanged:)",
        r"\1activeColor: const Color(0xFF4DFFD6),\n                    activeTrackColor: const Color(0xFF4DFFD6).withValues(alpha: 0.3),\n                    \2",
        code
    )

    # 6. Divider ديناميكي
    code = re.sub(
        r"const Divider\(\)",
        "Divider(color: isDark ? const Color(0xFF4DFFD6).withValues(alpha: 0.15) : Colors.grey.shade200)",
        code
    )

    # 7. زر تسجيل الخروج
    code = re.sub(
        r"ElevatedButton\.styleFrom\(backgroundColor:\s*Colors\.white,\s*foregroundColor:\s*Colors\.red\.shade600\)",
        ("ElevatedButton.styleFrom(\n"
         "              backgroundColor: isDark ? const Color(0xFF1A0A0A) : Colors.white,\n"
         "              foregroundColor: Colors.red.shade600,\n"
         "              side: isDark\n"
         "                  ? BorderSide(color: Colors.red.shade900.withValues(alpha: 0.5))\n"
         "                  : null,\n"
         "            )"),
        code
    )

    # 8. BottomSheet اللغة — backgroundColor
    code = re.sub(
        r"(showModalBottomSheet<String>\(\s*\n?\s*context:\s*ctx,\s*\n?\s*builder:)",
        r"showModalBottomSheet<String>(\n      context: ctx,\n      backgroundColor: isDark ? const Color(0xFF0D2420) : null,\n      builder:",
        code,
        count=1
    )

    log("faculty_settings_page.dart ✓", "OK")
    return code


def patch_reports(code: str) -> str:
    log("faculty_reports_page.dart ...", "STEP")

    code = ensure_is_dark_in_build(code)

    # 1. استبدال تعريفات البراند المثبّتة
    code = re.sub(
        r"final brandNavy\s*=\s*const Color\(0xFF031E39\);",
        "final brandNavy = isDark ? const Color(0xFF0D2420) : const Color(0xFF031E39);",
        code
    )
    code = re.sub(
        r"final brandTeal\s*=\s*const Color\(0xFF0DB5A2\);",
        "final brandTeal = isDark ? const Color(0xFF4DFFD6) : const Color(0xFF0DB5A2);",
        code
    )
    # إضافة cardBg بعد brandTeal
    code = re.sub(
        r"(final brandTeal\s*=\s*isDark.*?;)",
        r"\1\n    final cardBg = isDark ? const Color(0xFF0D2420) : Colors.white;\n    final inputBg = isDark ? const Color(0xFF0A3330) : Colors.white;",
        code
    )

    # 2. Scaffold background
    code = re.sub(
        r"backgroundColor:\s*const Color\(0xFFF5F7FA\)",
        "backgroundColor: isDark ? const Color(0xFF071A18) : const Color(0xFFF5F7FA)",
        code
    )

    # 3. AppBar
    code = re.sub(
        r"(AppBar\([\s\S]{0,100}?backgroundColor:\s*)brandNavy",
        r"\1isDark ? const Color(0xFF0D2420) : brandNavy",
        code,
        count=1
    )

    # 4. Card الفلاتر
    code = re.sub(
        r"(Card\(\s*\n?\s*child:\s*Column\()",
        r"Card(\n          color: cardBg,\n          child: Column(",
        code,
        count=1
    )

    # 5. بطاقة نسبة النجاح — gradient ديناميكي
    code = re.sub(
        r"gradient:\s*LinearGradient\(colors:\s*\[brandTeal,\s*brandNavy\],\s*begin:\s*Alignment\.topLeft,\s*end:\s*Alignment\.bottomRight\)",
        ("gradient: LinearGradient(\n"
         "              colors: isDark\n"
         "                  ? [const Color(0xFF0D2420), const Color(0xFF071A18)]\n"
         "                  : [brandTeal, brandNavy],\n"
         "              begin: Alignment.topLeft,\n"
         "              end: Alignment.bottomRight,\n"
         "            )"),
        code
    )

    # 6. إضافة border للبطاقة في الداكن (بعد gradient)
    code = re.sub(
        r"(borderRadius:\s*BorderRadius\.circular\(16\),\s*\n?\s*\),\s*\n?\s*child:\s*Column\(\s*\n?\s*children:\s*\[\s*\n?\s*Text\(l10n\.reportsSuccessRate)",
        ("borderRadius: BorderRadius.circular(16),\n"
         "              border: isDark\n"
         "                  ? Border.all(color: const Color(0xFF4DFFD6).withValues(alpha: 0.4))\n"
         "                  : null,\n"
         "            ),\n"
         "            child: Column(\n"
         "              children: [\n"
         "                Text(l10n.reportsSuccessRate)"),
        code
    )

    # 7. نص النسبة "84.5%"
    code = re.sub(
        r"(const Text\('84\.5%',\s*style:\s*TextStyle\(fontSize:\s*36,\s*fontWeight:\s*FontWeight\.w900,\s*color:\s*)Colors\.white",
        r"\1isDark ? const Color(0xFF4DFFD6) : Colors.white",
        code
    )

    # 8. زر التصدير
    code = re.sub(
        r"ElevatedButton\.styleFrom\(backgroundColor:\s*brandNavy,\s*foregroundColor:\s*Colors\.white\)",
        ("ElevatedButton.styleFrom(\n"
         "              backgroundColor: isDark ? const Color(0xFF0D2420) : brandNavy,\n"
         "              foregroundColor: isDark ? const Color(0xFF4DFFD6) : Colors.white,\n"
         "              side: isDark\n"
         "                  ? BorderSide(color: const Color(0xFF4DFFD6).withValues(alpha: 0.4))\n"
         "                  : null,\n"
         "            )"),
        code
    )

    log("faculty_reports_page.dart ✓", "OK")
    return code


def patch_class_detail(code: str) -> str:
    log("class_detail_page.dart ...", "STEP")

    code = ensure_is_dark_in_build(code)
    code = add_brand_vars_after_is_dark(code)

    # 1. Scaffold background
    code = re.sub(
        r"backgroundColor:\s*const Color\(0xFFF8FAFC\)",
        "backgroundColor: isDark ? const Color(0xFF071A18) : const Color(0xFFF8FAFC)",
        code
    )

    # 2. AppBar backgroundColor
    code = re.sub(
        r"(AppBar\([\s\S]{0,100}?backgroundColor:\s*)primaryColor",
        r"\1isDark ? const Color(0xFF0D2420) : primaryColor",
        code,
        count=1
    )

    # 3. TabBar — label colors
    code = re.sub(
        r"(bottom:\s*TabBar\()",
        (r"\1\n            labelColor: isDark ? const Color(0xFF4DFFD6) : Colors.white,"
         r"\n            unselectedLabelColor: isDark ? Colors.white54 : Colors.white70,"
         r"\n            indicatorColor: isDark ? const Color(0xFF4DFFD6) : Colors.white,"),
        code,
        count=1
    )

    # 4. حقل البحث
    code = re.sub(
        r"(hintText:\s*l10n\.searchStudent,\s*\n\s*prefixIcon:\s*const\s*Icon\(Icons\.search\),\s*\n\s*border:\s*OutlineInputBorder\(borderRadius:\s*BorderRadius\.circular\(16\)\),\s*\n\s*)",
        (r"\1"
         r"filled: true,\n                    "
         r"fillColor: isDark ? const Color(0xFF0A3330) : Colors.white,\n                    "
         r"enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: isDark ? BorderSide(color: const Color(0xFF4DFFD6).withValues(alpha: 0.2)) : const BorderSide(color: Color(0xFFE2E8F0))),\n                    "
         r"focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFF4DFFD6), width: 1.5)),\n                    "),
        code
    )

    # 5. بطاقات الطلاب في _StudentRosterList
    code = re.sub(
        r"(return Card\(\s*\n?\s*child:\s*ListTile\(\s*\n?\s*leading:\s*CircleAvatar)",
        r"return Card(\n              color: isDark ? const Color(0xFF0D2420) : Colors.white,\n              child: ListTile(\n                leading: CircleAvatar",
        code
    )

    # 6. CircleAvatar في قائمة الطلاب
    code = re.sub(
        r"CircleAvatar\(child:\s*Text\(student\.fullName\[0\]\)\)",
        ("CircleAvatar(\n"
         "                  backgroundColor: isDark\n"
         "                      ? const Color(0xFF4DFFD6).withValues(alpha: 0.2)\n"
         "                      : Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),\n"
         "                  child: Text(\n"
         "                    student.fullName[0],\n"
         "                    style: TextStyle(\n"
         "                      color: isDark ? const Color(0xFF4DFFD6) : Theme.of(context).colorScheme.primary,\n"
         "                      fontFamily: 'Cairo',\n"
         "                    ),\n"
         "                  ),\n"
         "                )"),
        code
    )

    # 7. بطاقات الإعلانات في _AnnouncementsHistory
    code = re.sub(
        r"(return Card\(\s*\n?\s*child:\s*ListTile\(\s*\n?\s*title:\s*Text\(data\['text'\])",
        r"return Card(\n              color: isDark ? const Color(0xFF0D2420) : Colors.white,\n              child: ListTile(\n                title: Text(data['text']",
        code
    )

    # 8. FloatingActionButton
    code = re.sub(
        r"(FloatingActionButton\.extended\(\s*\n?\s*backgroundColor:\s*)accentColor",
        (r"\1isDark ? const Color(0xFF0D2420) : accentColor,\n          foregroundColor: isDark ? const Color(0xFF4DFFD6) : Colors.white,\n          shape: isDark\n              ? RoundedRectangleBorder(\n                  borderRadius: BorderRadius.circular(16),\n                  side: BorderSide(color: const Color(0xFF4DFFD6).withValues(alpha: 0.5)),\n                )\n              : null,\n          //"),
        code,
        count=1
    )
    # تجنب تكرار foregroundColor إذا وُجدت
    code = re.sub(
        r"(foregroundColor:\s*isDark\s*\?.*?\n.*?//\s*\n?\s*foregroundColor:)",
        r"\1",
        code
    )

    # 9. BottomSheet الإعلان
    code = re.sub(
        r"(showModalBottomSheet\(\s*\n?\s*context:\s*context,\s*\n?\s*isScrollControlled:\s*true,\s*\n?\s*builder:)",
        r"showModalBottomSheet(\n      context: context,\n      backgroundColor: isDark ? const Color(0xFF0D2420) : null,\n      isScrollControlled: true,\n      builder:",
        code,
        count=1
    )

    # 10. عنوان الـ BottomSheet
    code = re.sub(
        r"(Text\(l10n\.addAnnouncementTitle,\s*style:\s*TextStyle\(fontSize:\s*18,\s*fontWeight:\s*FontWeight\.bold,\s*color:\s*)primaryColor",
        r"\1isDark ? const Color(0xFF4DFFD6) : primaryColor",
        code
    )

    log("class_detail_page.dart ✓", "OK")
    return code


# ─────────────────────────────────────────────────────────────
# التحقق من السلامة
# ─────────────────────────────────────────────────────────────

def verify_patch(code: str, filename: str) -> list[str]:
    """يتحقق أن الكود المعدَّل سليم"""
    issues = []

    # تحقق من وجود isDark
    if "isDark = Theme.of(context).brightness" not in code:
        issues.append("❌ isDark غير موجود في build()")

    # تحقق من عدم وجود Colors.white ثابتة في Scaffold
    scaffold_bgs = re.findall(r'Scaffold\([\s\S]{0,500}?backgroundColor:\s*([^\n,]+)', code)
    for bg in scaffold_bgs:
        if "Colors.white" in bg and "isDark" not in bg:
            issues.append(f"⚠ backgroundColor ثابتة في Scaffold: {bg.strip()}")

    # تحقق من توازن الأقواس
    open_br  = code.count('{')
    close_br = code.count('}')
    open_p   = code.count('(')
    close_p  = code.count(')')
    if open_br != close_br:
        issues.append(f"❌ عدم توازن الأقواس {{}}: {open_br} فتح / {close_br} إغلاق")
    if abs(open_p - close_p) > 5:  # هامش صغير للأقواس
        issues.append(f"⚠ فرق في الأقواس (): {open_p} / {close_p}")

    # تحقق من عدم وجود isDark مكررة — كل build() يستحق نسخته
    build_count = len(re.findall(r'Widget build\(BuildContext context', code))
    is_dark_count = code.count("isDark = Theme.of(context).brightness")
    if is_dark_count > max(build_count + 1, 4):
        issues.append(f"⚠ isDark مكررة {is_dark_count} مرة مقابل {build_count} build() — تحقق")

    return issues


# ─────────────────────────────────────────────────────────────
# المنطق الرئيسي
# ─────────────────────────────────────────────────────────────

PATCHERS = {
    "schedule":    patch_schedule,
    "students":    patch_students,
    "attendance":  patch_attendance,
    "assignments": patch_assignments,
    "profile":     patch_profile,
    "settings":    patch_settings,
    "reports":     patch_reports,
    "class":       patch_class_detail,
}

def main():
    print()
    print("╔══════════════════════════════════════════════════════════╗")
    print("║  DUSPS Faculty Portal — Dark Mode Patcher               ║")
    print("║  تطبيق الوضع الداكن على بوابة هيئة التدريس             ║")
    print(f"║  {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}                              ║")
    print("╚══════════════════════════════════════════════════════════╝")
    print()

    # تحديد مسار المشروع
    if len(sys.argv) > 1:
        project_root = Path(sys.argv[1])
    else:
        project_root = Path.cwd()

    print(f"  📁 مسار المشروع: {project_root}")
    print()

    if not project_root.exists():
        print(f"  ❌ المسار غير موجود: {project_root}")
        sys.exit(1)

    # التحقق من أنه مشروع Flutter
    pubspec = project_root / "pubspec.yaml"
    if not pubspec.exists():
        print("  ❌ لم يُعثر على pubspec.yaml — تأكد من مسار المشروع")
        sys.exit(1)

    log("تم التحقق من المشروع — Flutter project found ✓", "OK")
    print()

    total_changed = 0
    total_issues  = 0
    results = []

    for key, rel_path in TARGET_FILES.items():
        file_path = project_root / rel_path.replace("/", os.sep)
        print(f"  ─────────────────────────────────────────")
        print(f"  📄 {file_path.name}")

        if not file_path.exists():
            log(f"الملف غير موجود: {rel_path}", "WARN")
            results.append((key, "SKIP", 0, []))
            continue

        # قراءة وحفظ نسخة احتياطية
        original = read_file(file_path)
        backup_file(file_path)

        # تطبيق التعديلات
        try:
            patcher = PATCHERS[key]
            modified = patcher(original)
        except Exception as e:
            log(f"خطأ أثناء معالجة {file_path.name}: {e}", "ERR")
            # استعادة النسخة الاحتياطية
            write_file(file_path, original)
            results.append((key, "ERROR", 0, [str(e)]))
            continue

        # التحقق من السلامة
        issues = verify_patch(modified, file_path.name)
        if issues:
            for issue in issues:
                log(issue, "WARN")
            total_issues += len(issues)

        # حساب التغييرات وكتابة الملف
        changes = count_changes(original, modified)
        write_file(file_path, modified)

        total_changed += changes
        results.append((key, "OK", changes, issues))
        log(f"اكتمل — {changes} سطر مُعدَّل", "OK")

    # ملخص النتائج
    print()
    print("  ══════════════════════════════════════════")
    print("  📊 ملخص التعديلات")
    print("  ══════════════════════════════════════════")
    for key, status, changes, issues in results:
        icon = "✅" if status == "OK" else ("⏭" if status == "SKIP" else "❌")
        filename = TARGET_FILES.get(key, key).split("/")[-1]
        print(f"  {icon}  {filename:<45} {changes:>4} سطر")
        for issue in issues:
            print(f"       ⚠ {issue}")

    print()
    print(f"  📈 إجمالي الأسطر المعدّلة : {total_changed}")
    print(f"  ⚠  تحذيرات                : {total_issues}")
    print()

    if total_issues == 0:
        print("  🎉 تم تطبيق جميع التعديلات بنجاح!")
    else:
        print("  ⚠  اكتملت التعديلات مع بعض التحذيرات — راجع الأعلى")

    print()
    print("  🔍 الخطوة التالية — نفّذ في terminal مشروعك:")
    print("     flutter analyze lib/features/faculty/pages/")
    print()
    print("  💡 لاستعادة ملف معين:")
    print(f"     (استبدل الملف بنسخته الاحتياطية .bak_darkmode)")
    print()


if __name__ == "__main__":
    main()