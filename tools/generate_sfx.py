"""Generate original short arcade WAV cues with Python standard library."""
from pathlib import Path
import math, wave, struct, random
random.seed(20261101)
path = Path(__file__).resolve().parents[1] / "assets/audio"
path.mkdir(parents=True, exist_ok=True)
RATE = 22050
def make(name, duration, voice):
    data = []
    for i in range(int(RATE * duration)):
        t = i / RATE
        envelope = min(1.0, t / 0.009) * max(0.0, 1 - t / duration) ** 2
        value = max(-1.0, min(1.0, voice(t) * envelope))
        data.append(struct.pack("<h", int(32767 * value * 0.35)))
    with wave.open(str(path / f"{name}.wav"), "wb") as f:
        f.setnchannels(1)
        f.setsampwidth(2)
        f.setframerate(RATE)
        f.writeframes(b"".join(data))
def sine(t, freq):
    return math.sin(2 * math.pi * freq * t)
make("launch", .17, lambda t: sine(t, 380 + 980*t) + .18*sine(t, 760 + 1200*t))
make("pixel", .048, lambda t: .55*sine(t, 1180 - 6000*t) + .22*random.uniform(-1, 1))
make("wall", .095, lambda t: .75*sine(t, 760 - 1000*t) + .25*sine(t, 1420))
make("paddle", .10, lambda t: sine(t, 300 + 600*t) + .25*sine(t, 560 + 700*t))
make("powerup", .43, lambda t: sine(t, 440 + (int(t/.10)%4)*130) + .27*sine(t, 880 + (int(t/.10)%4)*260))
make("lost", .35, lambda t: sine(t, 650 - 1100*t) + .18*sine(t, 250 - 300*t))
make("victory", .70, lambda t: sum(.4*sine(t, f) for f in (523, 659, 784, 1046)))
print("Generated", len(list(path.glob("*.wav"))), "original WAV cues")
