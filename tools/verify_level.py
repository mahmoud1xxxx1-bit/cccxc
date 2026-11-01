"""Deterministic map verification, including flood-fill reachability."""
import json,collections
from pathlib import Path
layout=json.loads((Path(__file__).resolve().parents[1]/'assets/level_desert_gate.json').read_text())
rows=layout['rows']; assert len(rows)==45 and all(len(r)==60 for r in rows)
assert sum(r.count('B')+r.count('G')+r.count('P') for r in rows)==2300
assert sum(r.count('#') for r in rows)==140
assert sum(r.count('.') for r in rows)==260
assert sum(r.count('P') for r in rows)==12
start=(30,44);seen={start};queue=collections.deque([start]);assert rows[44][30]!='#'
while queue:
    x,y=queue.popleft()
    for xx,yy in [(x+1,y),(x-1,y),(x,y+1),(x,y-1)]:
        if 0<=xx<60 and 0<=yy<45 and rows[yy][xx]!='#' and (xx,yy) not in seen:
            seen.add((xx,yy));queue.append((xx,yy))
assert len(seen)==2560,('blocked access',2560-len(seen))
print('PASS: 2300 pixels, 260 empty, 140 walls, all 2560 reachable nonwall cells')
