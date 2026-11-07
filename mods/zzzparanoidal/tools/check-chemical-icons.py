"""Validate final C2 assignments AFTER every mod has run, not an intermediate data-stage table.
Usage: python check-chemical-icons.py AFTER.json [--before BEFORE.json] [--game-root GAME]
No game launch or writes. Exit 1 on missing/replaced cards, markers, assets, or unrelated prototype changes.
"""
from pathlib import Path
import argparse,json,re,sys
MOD=Path(__file__).resolve().parents[1]
IMAGE_ROOT='__zzzparanoidal__/graphics/technology/chemical-elements/'
MARKERS='__zzzparanoidal__/graphics/technology/icon-markers/'
ICON_FIELDS={'icon','icons','icon_size','icon_mipmaps'}
def registry():
 text=(MOD/'tweaks/technology/chemical-elements-data.lua').read_text(encoding='utf8');out={}
 for name,body in re.findall(r'\["([^"]+)"\]\s*=\s*\{([^}]+)\}',text):
  assert name not in out,name
  out[name]={k:json.loads(v) for k,v in re.findall(r'(\w+)\s*=\s*("[^"]*"|\d+|true|false)',body)}
 assert out and all('element'in e for e in out.values()),'empty/invalid C2 registry'
 return out

def validate(raw,rules,game):
 errors=[]
 for name,rule in rules.items():
  t=raw.get('technology',{}).get(name)
  if not t:errors.append(name+': technology missing');continue
  layers=t.get('icons')or[{'icon':t.get('icon'),'icon_size':t.get('icon_size')}]
  expected=IMAGE_ROOT+rule['element']+'.png'
  if layers[0].get('icon')!=expected or layers[0].get('icon_size')!=256 or layers[0].get('floating') or layers[0].get('tint') or layers[0].get('scale',.5)!=.5 or layers[0].get('shift',[0,0])!=[0,0]:errors.append(name+': C2 base replaced/rescaled/tinted')
  if t.get('enabled',True):
   if 'level'in rule and not any(l.get('icon')==MARKERS+'level-'+str(rule['level'])+'.png' and l.get('floating') for l in layers[1:]):errors.append(name+': level marker missing')
   if 'badge'in rule:
    if not any(l.get('icon')==MARKERS+'badge-frame.png' and l.get('floating') for l in layers[1:]):errors.append(name+': branch frame missing')
    badge=raw.get(rule.get('badge_type','item'),{}).get(rule['badge'])
    if not badge:errors.append(name+': branch product missing')
    else:
     bl=badge.get('icons')or[{'icon':badge.get('icon'),'icon_size':badge.get('icon_size',64)}]
     for source in bl:
      if not any(l.get('icon')==source.get('icon') and l.get('tint')==source.get('tint') and l.get('floating') for l in layers[1:]):errors.append(name+': branch image missing: '+str(source.get('icon')))
  for layer in layers:
   icon=layer.get('icon','');m=re.fullmatch(r'__([^/]+)__/(.+)',icon)
   if not m:errors.append(name+': invalid image path '+str(icon));continue
   p=game/('data'if m[1]in ['base','core','quality','recycler','elevated-rails','space-age']else 'mods')/m[1]/m[2]
   if not p.is_file():errors.append(name+': missing image '+str(p))
 return errors

def compare(before,after,rules):
 errors=[];changed=[]
 for kind in set(before)|set(after):
  a,b=before.get(kind,{}),after.get(kind,{})
  if a==b:continue
  for name in set(a)|set(b):
   x,y=a.get(name),b.get(name)
   if x==y:continue
   if kind=='technology' and name in rules and x is not None and y is not None:
    changed.append(name);x={k:v for k,v in x.items() if k not in ICON_FIELDS};y={k:v for k,v in y.items() if k not in ICON_FIELDS}
    if x!=y:errors.append(kind+'/'+name+': non-icon fields changed')
   else:errors.append(kind+'/'+name+': unexpected prototype change')
 return errors,sorted(changed)

def main():
 p=argparse.ArgumentParser(description=__doc__);p.add_argument('dump',type=Path);p.add_argument('--before',type=Path);p.add_argument('--game-root',type=Path,default=MOD.parent.parent);a=p.parse_args()
 rules=registry();raw=json.loads(a.dump.read_text(encoding='utf8'));errors=validate(raw,rules,a.game_root);changed=None
 if a.before:
  extra,changed=compare(json.loads(a.before.read_text(encoding='utf8')),raw,rules);errors+=extra
 result={'status':'FAIL'if errors else 'PASS','technologies':len(rules),'elements':len({e['element']for e in rules.values()}),'changed_icon_sets':None if changed is None else len(changed),'errors':errors}
 print(json.dumps(result,ensure_ascii=False,indent=2));return bool(errors)
if __name__=='__main__':sys.exit(main())
