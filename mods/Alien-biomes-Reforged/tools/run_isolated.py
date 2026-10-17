"""One isolated Factorio 2.0 launch of copies of the given mods.

run_isolated.py MODE RUN_DIR MOD_SRC [MOD_SRC ...] [--set NAME=VALUE ...] [--limit SECONDS]
  MODE: dump      --dump-data (headless, prototypes only, no graphics are loaded)
        create    --create RUN_DIR/save.zip
        graphical normal game window; waits until the log shows that the main menu is
                  reached (sprites and atlases loaded), then ends our own process tree.
                  Use only with an explicit permission: it opens a window.
  Each MOD_SRC folder is physically copied into RUN_DIR/mods (the originals are only read).
  mod-list.json: base, quality, elevated-rails on; space-age off; the copied mods on.
  --set NAME=VALUE overrides the default of a startup setting in the copy of the first mod
  (true/false/number/string), so modes such as the economy atlas can be tested without
  writing mod-settings.dat.
  Engine: env FACTORIO_EXE or the default below. Limit 180 s from process start; on timeout
  the PID tree is killed with taskkill /T /F. Result: RUN_DIR/result.json, stdout.txt,
  write-data/factorio-current.log.
"""
import sys, os, json, shutil, subprocess, time
from pathlib import Path

EXE = os.environ.get("FACTORIO_EXE", r"C:\Games\Factorio 2.077 - QUILITY\bin\x64\factorio.exe")
args = sys.argv[1:]
limit = 180
sets = []
while "--set" in args:
    i = args.index("--set"); sets.append(args[i + 1]); del args[i:i + 2]
if "--limit" in args:
    i = args.index("--limit"); limit = min(180, int(args[i + 1])); del args[i:i + 2]
mode, run = args[0], Path(args[1])
srcs = [Path(p) for p in args[2:]]
if mode not in ("dump", "create", "graphical"):
    raise SystemExit("mode must be dump, create or graphical")
if run.exists():
    raise SystemExit("run dir exists: %s" % run)
mods = run / "mods"; mods.mkdir(parents=True)
names = []
for s in srcs:
    info = json.load(open(s / "info.json", encoding="utf-8"))
    shutil.copytree(s, mods / info["name"], ignore=shutil.ignore_patterns("tools", "__pycache__"))
    names.append(info["name"])
if sets:
    lines = ["-- written by run_isolated.py --set (test copy only)"]
    for kv in sets:
        k, v = kv.split("=", 1)
        lit = v if v in ("true", "false") or v.replace(".", "", 1).lstrip("-").isdigit() else json.dumps(v)
        lines.append('for _, t in pairs({"bool-setting","int-setting","double-setting","string-setting"}) do '
                     'local s = data.raw[t] and data.raw[t]["%s"] if s then s.default_value = %s; '
                     'if s.allowed_values then s.allowed_values = nil end end end' % (k, lit))
    with open(mods / names[0] / "settings-final-fixes.lua", "a", encoding="utf-8") as f:
        f.write("\n" + "\n".join(lines) + "\n")
ml = [{"name": "base", "enabled": True}, {"name": "quality", "enabled": True},
      {"name": "elevated-rails", "enabled": True}, {"name": "space-age", "enabled": False}]
ml += [{"name": n, "enabled": True} for n in names]
json.dump({"mods": ml}, open(mods / "mod-list.json", "w"), indent=1)
wd = run / "write-data"; wd.mkdir()
cfg = run / "config.ini"
cfg.write_text("[path]\nread-data=__PATH__executable__/../../data\nwrite-data=%s\n" % wd.as_posix(), encoding="utf-8")
cmd = [EXE, "--config", str(cfg), "--mod-directory", str(mods)]
if mode == "dump":
    cmd += ["--dump-data"]
elif mode == "create":
    cmd += ["--create", str(run / "save.zip")]
log = wd / "factorio-current.log"
MENU_MARKERS = ("Factorio initialised", "Loading main menu", "MainMenu")
t0 = time.time()
status = None; rc = None; reached = None
with open(run / "stdout.txt", "w", encoding="utf-8", errors="replace") as out:
    p = subprocess.Popen(cmd, stdout=out, stderr=subprocess.STDOUT)
    while True:
        try:
            rc = p.wait(timeout=1)
            status = "exit-%d" % rc
            break
        except subprocess.TimeoutExpired:
            pass
        if mode == "graphical" and log.exists() and reached is None:
            txt = log.read_text(encoding="utf-8", errors="replace")
            if any(m in txt for m in MENU_MARKERS):
                reached = round(time.time() - t0, 1)
                time.sleep(5)  # let the log flush the atlas summary
                subprocess.run(["taskkill", "/PID", str(p.pid), "/T", "/F"], capture_output=True)
                p.wait(); status = "menu-reached-closed"
                break
        if time.time() - t0 > limit:
            subprocess.run(["taskkill", "/PID", str(p.pid), "/T", "/F"], capture_output=True)
            p.wait(); status = "timeout"
            break
el = round(time.time() - t0, 1)
res = {"cmd": cmd, "mods": ml, "sets": sets, "pid": p.pid, "elapsed_s": el, "exit": rc, "status": status,
       "menu_reached_s": reached, "limit_s": limit}
json.dump(res, open(run / "result.json", "w"), indent=1)
print(json.dumps({k: res[k] for k in ("pid", "elapsed_s", "exit", "status", "menu_reached_s")}))
