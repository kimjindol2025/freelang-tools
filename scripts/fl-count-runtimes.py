#!/usr/bin/env python3
import os, re, sys
root = sys.argv[1]
exec_api = re.compile(r'\b(?:process_spawn|shell(?:[-_]exec(?:[-_]stdout|[-_]result)?|[-_]run|[-_]capture)?|exec|execve)\b', re.I)
node_re = re.compile(r'(?<![A-Za-z0-9_"\'])\b(?:node|npx|npm|deno|bun)\b', re.I)
direct_runtime = re.compile(r'(?<![A-Za-z0-9_])(?:node|npx|npm|deno|bun)\s+(?:--|-[^\s]|[^\s])', re.I)
js_token = re.compile(r'(?<![A-Za-z0-9_])([A-Za-z0-9_./$-]+\.(?:js|ts|mjs|cjs))(?![A-Za-z0-9_])', re.I)
afj_re = re.compile(r'freelang-afj|bootstrap-native\.js|AFJ_ROOT|FREELANG_AFJ|\bafj\b', re.I)
inline_js = re.compile(r'\bnode\s+(?:-e\b|-)')

def files():
    for sub in ("scripts", "native", "tests"):
        base = os.path.join(root, sub)
        for dirpath, _, names in os.walk(base):
            for name in names:
                yield os.path.join(dirpath, name)

node_lines = []
js_lines = []
afj_lines = []
for path in sorted(files()):
    try:
        raw = open(path, "rb").read()
    except OSError:
        continue
    if b"\x00" in raw[:200]:
        continue
    text = raw.decode("utf-8", "replace")
    first_line = text.splitlines()[0] if text.splitlines() else ""
    is_shell = os.path.splitext(path)[1].lower() in (".sh", ".bash") or (first_line.startswith("#!") and re.search(r'\b(?:bash|sh)\b', first_line))
    for i, line in enumerate(text.splitlines(), 1):
        stripped = line.lstrip()
        if stripped.startswith("#") or stripped.startswith(";;"):
            continue
        rel = os.path.relpath(path, root)
        is_call = bool(exec_api.search(line)) or (is_shell and bool(direct_runtime.search(line)))
        is_node = is_call and bool(node_re.search(line))
        if is_node:
            node_lines.append((rel, i, line.strip()))
            tokens = [t for t in js_token.findall(line) if not t.endswith("bootstrap-native.js")]
            if tokens or inline_js.search(line):
                js_lines.append((rel, i, line.strip()))
        if is_call and afj_re.search(line):
            afj_lines.append((rel, i, line.strip()))

kind = sys.argv[2] if len(sys.argv) > 2 else "summary"
if kind == "node":
    for rel, i, line in node_lines:
        print(f"{rel}:{i}:{line}")
elif kind == "js":
    for rel, i, line in js_lines:
        print(f"{rel}:{i}:{line}")
elif kind == "afj":
    for rel, i, line in afj_lines:
        print(f"{rel}:{i}:{line}")
else:
    print(f"NODE {len(node_lines)} files {len({r for r,_,_ in node_lines})}")
    print(f"JS {len(js_lines)} files {len({r for r,_,_ in js_lines})}")
    print(f"AFJ {len(afj_lines)} files {len({r for r,_,_ in afj_lines})}")
