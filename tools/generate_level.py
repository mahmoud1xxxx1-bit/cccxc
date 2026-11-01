"""Deterministic Desert Gate 60x45 map generator. Only stdlib required."""
from pathlib import Path
import math, json
C,R=60,45
walls=set()
def line(x0,y0,x1,y1):
    n=max(abs(x1-x0),abs(y1-y0))
    for i in range(n+1):
        t=i/max(1,n)
        walls.add((round(x0+(x1-x0)*t),round(y0+(y1-y0)*t)))
# deliberately non-enclosing sandstone channels, with a large central wedge
for seg in [(6,35,24,13),(24,13,35,13),(35,13,52,33),(11,37,43,37),
            (8,19,8,28),(52,13,52,22),(18,4,18,11),(40,4,40,10),
            (22,27,30,20),(30,20,38,27)]:
    line(*seg)
# ensure no exterior barrier that traps the first ball, and make 140 unique wall cells
walls={(x,y) for x,y in walls if 2<=x<=57 and 2<=y<=42}
# Fine chiseled ridges away from the central launch lane.
for y in range(2,43):
    for x in [3,56,16,43,27,32]:
        if len(walls)>=140: break
        if (x,y) not in walls and ((x*13+y*7)%11==0) and not (24<=x<=36 and y>=38):
            walls.add((x,y))
    if len(walls)>=140:break
assert len(walls)==140,(len(walls), 'wall total')
# empty channels follow some sloping walls, plus carved lower access pockets
candidate=[]
for y in range(R):
  for x in range(C):
    if (x,y) in walls: continue
    prox=min((x-wx)**2+(y-wy)**2 for wx,wy in walls)
    access=(abs(x-30)*0.08 + max(0,35-y)*0.03)
    # Don't remove too much visible brick, preserve blocks for satisfying cascades.
    priority=prox+access+((x*19+y*23)%37)*0.005
    if 23<=x<=37 and 39<=y<=44: priority-=3.5
    candidate.append((priority,x,y))
candidate.sort()
empty=set((x,y) for _,x,y in candidate[:260])
assert len(empty)==260 and not (empty & walls)
grid=[]
for y in range(R):
    s=''
    for x in range(C):
        if (x,y) in walls:c='#'
        elif (x,y) in empty:c='.'
        elif (x,y)==(30,30): c='P'  # deterministic x3 pickup brick
        else: c='G' if ((x*37+y*17)%97==1) else 'B'
        s+=c
    grid.append(s)
assert len(grid)==45 and all(len(x)==60 for x in grid)
assert sum(c in 'BGP' for s in grid for c in s)==2300
out=Path(__file__).resolve().parents[1]
(out/'assets'/'level_desert_gate.json').write_text(json.dumps({'id':'desert_gate_01','version':1,'width':60,'height':45,'rows':grid},indent=2)+'\n')
source='''// GENERATED from tools/generate_level.py; do not edit by hand.
// B/G/P: destroyable (G is gold accent; P drops x3); #: wall; .: empty.
class DesertGateLevel {
  static const id = 'desert_gate_01';
  static const version = 1;
  static const columns = 60;
  static const rows = 45;
  static const totalPixels = 2300;
  static const map = <String>[\n'''+''.join("    '"+s+"',\n" for s in grid)+'''  ];
}
'''
(out/'lib/game/level_data.dart').write_text(source)
print('map counts:', {c:sum(row.count(c) for row in grid) for c in 'BGP#.'})
