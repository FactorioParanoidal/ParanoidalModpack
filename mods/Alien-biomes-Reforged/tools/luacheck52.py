"""Syntax-check Lua 5.2 sources with luac 5.1 after normalising 5.2-only lexemes.
luacheck52.py LUAC TMPDIR file...
"""
import sys, os, re, subprocess

luac, tmp = sys.argv[1], sys.argv[2]
os.makedirs(tmp, exist_ok=True)
bad = 0
for f in sys.argv[3:]:
    s = open(f, encoding="utf-8").read()
    s = re.sub(r"\\z\s*", "", s)                 # 5.2 \z string escape
    s = re.sub(r"\)\s*\n(\s*)\(", r") \1(", s)   # 5.1 ambiguous-call rule
    t = os.path.join(tmp, "t.lua")
    open(t, "w", encoding="utf-8").write(s)
    r = subprocess.run([luac, "-p", t], capture_output=True, text=True)
    if r.returncode:
        bad += 1
        print("FAIL", f, (r.stderr or r.stdout).strip())
print("checked", len(sys.argv) - 3, "failed", bad)
sys.exit(1 if bad else 0)
