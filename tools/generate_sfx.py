"""Generate original short digital sounds; no copyrighted audio samples."""
from pathlib import Path
import math,wave,struct,random
rng=random.Random(32026)
rate=22050
out=Path(__file__).resolve().parents[1]/'assets/audio'
out.mkdir(parents=True,exist_ok=True)
def render(name,duration,voice,gain=.30):
    frames=[]
    total=int(duration*rate)
    for i in range(total):
        t=i/rate
        v=max(-1,min(1,voice(t)*min(1,t/.002)*max(0,1-t/duration)**2.2))
        frames.append(struct.pack('<h',round(v*gain*32767)))
    with wave.open(str(out/(name+'.wav')),'wb') as f:
        f.setparams((1,2,rate,total,'NONE','not compressed'))
        f.writeframes(b''.join(frames))
def sine(t,f):return math.sin(2*math.pi*f*t)
render('pixel',.031,lambda t:.66*sine(t,1580-12000*t)+.12*rng.uniform(-1,1),.22)
render('wall',.045,lambda t:.55*sine(t,1060-2300*t)+.15*rng.uniform(-1,1),.26)
render('paddle',.066,lambda t:.7*sine(t,560+2500*t)+.23*sine(t,940),.30)
render('launch',.11,lambda t:.65*sine(t,500+6000*t)+.17*sine(t,1000+8000*t),.25)
render('powerup',.20,lambda t:.57*sine(t,680+(int(t/.045)%4)*170)+.19*sine(t,1360),.23)
render('lost',.20,lambda t:.7*sine(t,520-1200*t)+.2*sine(t,240-330*t),.25)
render('victory',.36,lambda t:sum(.22*sine(t,f) for f in (523,659,784,1046)),.30)
print('Generated seven original crisp arcade sound cues')
