#!/usr/bin/env python3
"""Deterministic orthographic 3D MK0 tank wagon renderer (numpy + Pillow).

python3 -m venv .cache/mk0/venv
.cache/mk0/venv/bin/pip install numpy==2.0.2 Pillow==11.3.0
.cache/mk0/venv/bin/python mods/JunkTrain3/tools/render-fluid-wagon.py

One world-space mesh, a fixed NW light and camera projection are used for all
128 full directions. North is frame 0; rotations run clockwise. Coordinates
are rail tiles, with 32 pixels/tile. The rail origin is (128,148) in each cell,
compensating the prototype's -20 px drawing shift. No external render service.
"""
from pathlib import Path
import argparse
import math
import numpy as np
from PIL import Image, ImageDraw, ImageFilter

ROOT = Path(__file__).resolve().parents[3]
MOD = ROOT / 'mods/JunkTrain3'
TEXTURE = MOD / 'tools/rust-metal.png'
TRIS = []
RUST = (102, 74, 58)
IRON = (56, 53, 48)
RIM = (90, 83, 70)
WOOD = (58, 46, 33)

def triangle(a,b,c, color, texture=False, normals=None):
    v=np.array([a,b,c],dtype=float)
    normal=np.cross(v[1]-v[0],v[2]-v[0]); normal/=max(np.linalg.norm(normal),1e-9)
    TRIS.append((v,np.array(normals) if normals is not None else np.tile(normal,(3,1)),color,texture))

def quad(a,b,c,d,color,texture=False):
    triangle(a,b,c,color,texture); triangle(a,c,d,color,texture)

def box(center, size, color, texture=False):
    p=np.array(center); h=np.array(size)/2
    v=[p+np.array([x,y,z])*h for x,y,z in [(-1,-1,-1),(1,-1,-1),(1,1,-1),(-1,1,-1),(-1,-1,1),(1,-1,1),(1,1,1),(-1,1,1)]]
    for face in [(0,3,2,1),(4,5,6,7),(0,1,5,4),(1,2,6,5),(2,3,7,6),(3,0,4,7)]:quad(*(v[i] for i in face),color,texture)

def cylinder(center, radius, length, axis, color, texture=False, segments=40):
    p=np.array(center); axis=np.array(axis,dtype=float);axis/=np.linalg.norm(axis)
    u=np.cross(axis,[0,0,1] if abs(axis[2])<.9 else [0,1,0]);u/=np.linalg.norm(u);v=np.cross(axis,u)
    rings=[];normals=[]
    for i in range(segments):
        t=i*2*math.pi/segments; n=u*math.cos(t)+v*math.sin(t);normals.append(n)
        rings.append((p-axis*length/2+n*radius,p+axis*length/2+n*radius))
    for i in range(segments):
        j=(i+1)%segments
        a,b=rings[i];d,c=rings[j];ni,nj=normals[i],normals[j]
        triangle(a,d,c,color,texture,[ni,nj,nj]);triangle(a,c,b,color,texture,[ni,nj,ni])
        triangle(p-axis*length/2,rings[j][0],a,color,texture,[-axis]*3)
        triangle(p+axis*length/2,b,rings[j][1],color,texture,[axis]*3)

def build():
    # Two narrow-gauge axles, exposed wheel rims and iron bearing housings.
    for y in [-.82,.82]:
        cylinder((0,y,.26),.075,1.65,(1,0,0),IRON,segments=12)
        for x in [-.70,.70]:
            cylinder((x,y,.27),.27,.14,(1,0,0),IRON,segments=24)
            cylinder((x+math.copysign(.075,x),y,.27),.21,.025,(1,0,0),RIM,segments=24)
            cylinder((x+math.copysign(.095,x),y,.27),.09,.04,(1,0,0),IRON,segments=16)
            box((x,y,.43),(.19,.34,.20),IRON)
    # Short frame, cross beams, wooden deck and coupling buffers.
    for x in [-.62,.62]:box((x,0,.47),(.15,2.65,.22),IRON,True)
    for y in [-1.19,0,1.19]:box((0,y,.48),(1.45,.15,.19),IRON)
    box((0,0,.57),(1.38,2.5,.10),WOOD,True)
    for y in [-1.36,1.36]:
        box((0,y,.5),(1.5,.13,.22),IRON,True)
        box((0,math.copysign(1.58,y),.46),(.20,.36,.13),IRON)
        cylinder((0,math.copysign(1.77,y),.46),.13,.12,(0,1,0),RIM,segments=16)
        for x in [-.51,.51]:
            cylinder((x,math.copysign(1.49,y),.48),.055,.24,(0,1,0),IRON,segments=12)
            cylinder((x,math.copysign(1.63,y),.48),.105,.05,(0,1,0),RIM,segments=20)
    # One horizontal riveted barrel, separate end plates and two straps.
    for y in [-.75,.75]:box((0,y,.64),(1.24,.18,.21),IRON,True)
    cylinder((0,0,.98),.51,2.27,(0,1,0),RUST,True,64)
    for y in [-1.15,1.15]:
        cylinder((0,y,.98),.505,.055,(0,1,0),(88,65,53),True,64)
        cylinder((0,y,.98),.474,.070,(0,1,0),RUST,True,64)
        for i in range(20):
            t=i*math.tau/20
            cylinder((.46*math.cos(t),y+math.copysign(.042,y),.98+.46*math.sin(t)),.023,.022,(0,1,0),RIM,segments=8)
    for y in [-.73,.73]:
        cylinder((0,y,.98),.524,.085,(0,1,0),IRON,True,64)
        for i in range(18):
            t=i*math.tau/18;n=(math.cos(t),0,math.sin(t))
            cylinder((.532*n[0],y,.98+.532*n[2]),.020,.025,n,RIM,segments=8)
    # Narrow longitudinal riveted seam along the visible crown.
    for y in np.linspace(-1,1,15):
        cylinder((.18,y,1.459),.019,.018,(0,0,1),RIM,segments=8)
    # Central fill hatch, with valve at z=1.56 (projected height 1.25).
    cylinder((0,0,1.47),.21,.12,(0,0,1),IRON,True,32)
    cylinder((0,0,1.54),.25,.055,(0,0,1),RUST,True,32)
    box((0,0,1.59),(.23,.055,.045),RIM)
    for x in [-.18,.18]:box((x,0,1.575),(.035,.12,.035),IRON)
    # Small access step and asymmetric hand brake: all 128 views are real renders.
    box((.82,.84,.40),(.28,.48,.08),IRON)
    box((.76,.84,.66),(.045,.045,.48),RIM)
    cylinder((.76,.84,.91),.13,.03,(0,0,1),(113,67,45),segments=24)
    for x in [-.12,.12]:box((.76+x/2,.84,.91),(.12,.025,.025),IRON)

def rotate(a,theta):
    c,s=math.cos(theta),math.sin(theta)
    return a@np.array([[c,s,0],[-s,c,0],[0,0,1]])

def project(v,scale):
    return np.stack((128*scale+v[:,0]*32*scale,148*scale+(.6*v[:,1]-.8*v[:,2])*32*scale),axis=1)

def render(theta, texture, supersample=2):
    scale=supersample;size=256*scale
    rgba=np.zeros((size,size,4),dtype=np.uint8);depth=np.full((size,size),-np.inf)
    shadow=Image.new('L',(size,size));draw=ImageDraw.Draw(shadow)
    light=np.array([-.6,-.8,1.6]);light/=np.linalg.norm(light)
    for vertices,normals,color,textured in TRIS:
        v=rotate(vertices,theta);n=rotate(normals,theta)
        sh=v.copy();sh[:,0]+=sh[:,2]*.48;sh[:,1]+=sh[:,2]*.34;sh[:,2]=0
        draw.polygon([tuple(p) for p in project(sh,scale)],fill=65)
        screen=project(v,scale)
        lo=np.maximum(np.floor(screen.min(axis=0)).astype(int),0);hi=np.minimum(np.ceil(screen.max(axis=0)).astype(int),size-1)
        if np.any(hi<lo):continue
        x,y=np.meshgrid(np.arange(lo[0],hi[0]+1)+.5,np.arange(lo[1],hi[1]+1)+.5)
        a,b,c=screen
        den=(b[1]-c[1])*(a[0]-c[0])+(c[0]-b[0])*(a[1]-c[1])
        if abs(den)<1e-8:continue
        w0=((b[1]-c[1])*(x-c[0])+(c[0]-b[0])*(y-c[1]))/den
        w1=((c[1]-a[1])*(x-c[0])+(a[0]-c[0])*(y-c[1]))/den;w2=1-w0-w1
        z=v[:,2]*.6+v[:,1]*.8;zz=w0*z[0]+w1*z[1]+w2*z[2]
        old=depth[lo[1]:hi[1]+1,lo[0]:hi[0]+1]
        mask=(w0>=-1e-6)&(w1>=-1e-6)&(w2>=-1e-6)&(zz>old)
        if not mask.any():continue
        ww=np.stack((w0,w1,w2),axis=-1)
        normal=ww@n;normal/=np.maximum(np.linalg.norm(normal,axis=-1,keepdims=True),1e-9)
        lightness=.55+.65*np.maximum(normal@light,0)
        base=np.broadcast_to(np.array(color,dtype=float),(*x.shape,3)).copy()
        if textured:
            world=ww@vertices
            uvx=(world[:,:,0]*.65+world[:,:,1]*.24)%1
            uvy=(world[:,:,2]*.8+world[:,:,1]*.61)%1
            sample=texture[(uvy*(texture.shape[0]-1)).astype(int),(uvx*(texture.shape[1]-1)).astype(int)]
            base*=.65+sample/255*.8
        rgb=np.clip(base*lightness[:,:,None],0,255).astype(np.uint8)
        target=rgba[lo[1]:hi[1]+1,lo[0]:hi[0]+1];target[mask,:3]=rgb[mask];target[mask,3]=255;old[mask]=zz[mask]
    sh=Image.new('RGBA',(size,size),(20,16,12,0));sh.putalpha(shadow.filter(ImageFilter.GaussianBlur(1.1*scale)))
    sh.alpha_composite(Image.fromarray(rgba));return sh.resize((256,256),Image.Resampling.LANCZOS)

def main():
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('--preview-only',action='store_true');a=p.parse_args()
    build();texture=np.array(Image.open(TEXTURE).convert('RGB'))
    out=MOD/'graphics/train/t0';out.mkdir(parents=True,exist_ok=True)
    angles=[0,16,32,48,64,80,96,112] if a.preview_only else range(128)
    frames={}
    for i in angles:
        frames[i]=render(i*math.tau/128,texture)
        if i%16==0:print(f'Rendered direction {i}/128',flush=True)
    preview=Image.new('RGBA',(1024,512),(38,40,35,255))
    for j,i in enumerate([0,16,32,48,64,80,96,112]):preview.alpha_composite(frames[i],((j%4)*256,(j//4)*256))
    cache=ROOT/'.cache/mk0';cache.mkdir(parents=True,exist_ok=True);preview.save(cache/'fluid-wagon-preview.png')
    if a.preview_only:return
    for sheet in range(2):
        atlas=Image.new('RGBA',(2048,2048))
        for cell in range(64):atlas.paste(frames[sheet*64+cell],((cell%8)*256,(cell//8)*256))
        atlas.save(out/f'usfw_sheet-{sheet}.png',optimize=True)
    # Icon uses the same geometry in a three-quarter view, cropped to its footprint.
    icon=frames[48];bbox=icon.getbbox();icon=icon.crop(bbox)
    icon.thumbnail((60,57),Image.Resampling.LANCZOS)
    small=Image.new('RGBA',(64,64));small.alpha_composite(icon,((64-icon.width)//2,(64-icon.height)//2));small.save(out/'usfw_icon.png')
    tech=Image.new('RGBA',(256,256));hero=frames[48].crop(bbox);hero.thumbnail((238,220),Image.Resampling.LANCZOS)
    tech.alpha_composite(hero,((256-hero.width)//2,(256-hero.height)//2))
    target=MOD/'graphics/technology';target.mkdir(exist_ok=True);tech.save(target/'scrap-fluid-handling.png')

if __name__=='__main__':main()
