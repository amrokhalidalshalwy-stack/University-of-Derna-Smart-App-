import os
import re

root = os.path.join(os.path.dirname(__file__), '..', 'lib')

patterns = [
    (re.compile(r"Colors\.white70"), "Theme.of(context).colorScheme.onPrimary.withOpacity(0.7)"),
    (re.compile(r"Colors\.white60"), "Theme.of(context).colorScheme.onPrimary.withOpacity(0.6)"),
    (re.compile(r"Colors\.grey\.shade700"), "Theme.of(context).colorScheme.onSurfaceVariant"),
    (re.compile(r"Colors\.grey\.shade500"), "Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.7)"),
    (re.compile(r"Colors\.grey\.shade400"), "Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.7)"),
    (re.compile(r"Colors\.grey(?![A-Za-z0-9_])"), "Theme.of(context).colorScheme.onSurfaceVariant"),
    (re.compile(r"Colors\.black54"), "Theme.of(context).colorScheme.onSurface.withOpacity(0.7)"),
    (re.compile(r"Colors\.black87"), "Theme.of(context).colorScheme.onSurface"),
    (re.compile(r"Color\(0xFF64748B\)"), "Theme.of(context).colorScheme.onSurfaceVariant"),
    (re.compile(r"AppTheme\.onSurfaceVariantColor"), "Theme.of(context).colorScheme.onSurfaceVariant"),
    (re.compile(r"AppTheme\.onSurfaceColor"), "Theme.of(context).colorScheme.onSurface"),
]

textstyle_line = re.compile(r"TextStyle\([^\)]*color\s*:\s*(?:Colors\.[A-Za-z0-9_]+|Color\(0x[0-9A-Fa-f]+\)|AppTheme\.[A-Za-z0-9_]+)[^\)]*\)")

changed_files = []

for dirpath, dirnames, filenames in os.walk(root):
    for filename in filenames:
        if not filename.endswith('.dart'):
            continue
        path = os.path.join(dirpath, filename)
        with open(path, 'r', encoding='utf-8') as fh:
            lines = fh.readlines()

        new_lines = []
        modified = False

        for line in lines:
            if 'TextStyle' in line and 'color:' in line:
                original_line = line
                for pat, repl in patterns:
                    line = pat.sub(repl, line)
                if line != original_line:
                    modified = True
            new_lines.append(line)

        if modified:
            with open(path, 'w', encoding='utf-8') as fh:
                fh.writelines(new_lines)
            changed_files.append(path)

print('changed_files:', len(changed_files))
for p in changed_files:
    print(p)
