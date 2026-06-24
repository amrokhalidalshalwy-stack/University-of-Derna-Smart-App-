import os
import re
import json

BASE_DIR = r"c:\Users\AL-Reada\Desktop\omar khaled alkhawga\My_App\flutter_project"
DIRS_TO_SCAN = [os.path.join(BASE_DIR, "lib", "features"), os.path.join(BASE_DIR, "lib", "core")]
ARB_AR_PATH = os.path.join(BASE_DIR, "lib", "l10n", "app_ar.arb")
ARB_EN_PATH = os.path.join(BASE_DIR, "lib", "l10n", "app_en.arb")

def load_arb(filepath):
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            return json.load(f)
    except Exception:
        return {}

arb_ar = load_arb(ARB_AR_PATH)
arb_en = load_arb(ARB_EN_PATH)

ar_values = {str(v).strip(): k for k, v in arb_ar.items() if not k.startswith('@')}
en_values = {str(v).strip(): k for k, v in arb_en.items() if not k.startswith('@')}

ui_params_pattern = re.compile(
    r"(?:Text\s*\(\s*|title\s*:\s*|label\s*:\s*|hint\s*:\s*|hintText\s*:\s*|labelText\s*:\s*|tooltip\s*:\s*|buttonText\s*:\s*).*?(['\"])(.*?[^\\]?)\1"
)
arabic_pattern = re.compile(r"(['\"])(.*?[^\\]?)\1")

def generate_key(text, is_arabic, counter):
    if not is_arabic:
        words = re.sub(r'[^a-zA-Z0-9 ]', '', text).split()
        if not words:
            return f"uiKey_{counter}"
        key = words[0].lower() + ''.join(word.capitalize() for word in words[1:5])
        return key
    else:
        return f"arabicString_{counter}"

results = []
missing_keys_dict = {}

files_scanned = 0
files_with_strings = set()
total_strings_found = 0
already_in_arb = 0
missing_from_arb = 0
counter = 1

for scan_dir in DIRS_TO_SCAN:
    if not os.path.exists(scan_dir):
        continue
    for root, _, files in os.walk(scan_dir):
        for file in files:
            if not file.endswith('.dart'):
                continue
            
            filepath = os.path.join(root, file)
            files_scanned += 1
            
            with open(filepath, 'r', encoding='utf-8') as f:
                lines = f.readlines()
                
            in_build = False
            brace_level = 0
            
            for line_no, line in enumerate(lines, 1):
                clean_line = line.strip()
                if clean_line.startswith('//'):
                    continue
                
                if 'Widget build(' in clean_line:
                    in_build = True
                    brace_level = 0
                    
                if in_build:
                    brace_level += line.count('{') - line.count('}')
                    if brace_level <= 0 and '}' in line:
                        in_build = False
                        
                found_strings = []
                
                # Check for Arabic strings anywhere in the line
                for match in arabic_pattern.finditer(line):
                    text = match.group(2)
                    if re.search(r'[\u0600-\u06FF]', text):
                        found_strings.append((text, True))
                        
                # Check for English UI strings
                for match in ui_params_pattern.finditer(line):
                    text = match.group(2)
                    if not text or len(text.strip()) < 2:
                        continue
                    if re.search(r'[\u0600-\u06FF]', text):
                        continue
                    if not re.search(r'[A-Za-z]', text):
                        continue
                    if text.startswith('$'):
                        continue
                    found_strings.append((text, False))
                    
                seen = set()
                for text, is_ar in found_strings:
                    if text in seen:
                        continue
                    seen.add(text)
                    
                    # Also ignore some generic programmatic strings like route names or asset paths
                    if text.startswith('/') or text.startswith('assets/') or text.endswith('.png'):
                        continue
                        
                    total_strings_found += 1
                    files_with_strings.add(filepath)
                    
                    is_in_arb = False
                    suggested_key = ""
                    
                    if is_ar:
                        if text in ar_values:
                            is_in_arb = True
                            suggested_key = ar_values[text]
                    else:
                        if text in en_values:
                            is_in_arb = True
                            suggested_key = en_values[text]
                            
                    if is_in_arb:
                        already_in_arb += 1
                    else:
                        missing_from_arb += 1
                        suggested_key = generate_key(text, is_ar, counter)
                        counter += 1
                        
                        if is_ar:
                            missing_keys_dict[suggested_key] = f"[ARABIC] {text}"
                            missing_keys_dict[f"@{suggested_key}"] = {"description": "Auto-extracted Arabic string"}
                        else:
                            missing_keys_dict[suggested_key] = text
                            missing_keys_dict[f"@{suggested_key}"] = {"description": "Auto-extracted English string"}
                    
                    rel_path = os.path.relpath(filepath, BASE_DIR).replace('\\', '/')
                    results.append(f"FILE: {rel_path}\nLINE: {line_no}\nSTRING: \"{text}\"\nSUGGESTED_KEY: {suggested_key}\nALREADY_IN_ARB: {'YES' if is_in_arb else 'NO'}\n")

with open(os.path.join(BASE_DIR, 'scan_report.txt'), 'w', encoding='utf-8') as f:
    for res in results:
        f.write(res + "\n")
    f.write("=" * 40 + "\n")
    f.write("SUMMARY:\n")
    f.write(f"Total files scanned: {files_scanned}\n")
    f.write(f"Files with hardcoded strings: {len(files_with_strings)}\n")
    f.write(f"Total hardcoded strings found: {total_strings_found}\n")
    f.write(f"Already in ARB: {already_in_arb}\n")
    f.write(f"Missing from ARB: {missing_from_arb}\n")
    f.write("=" * 40 + "\n")
    f.write("MISSING KEYS JSON BLOCK:\n")
    f.write(json.dumps(missing_keys_dict, indent=2, ensure_ascii=False) + "\n")
