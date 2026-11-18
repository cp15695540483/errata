import os
from PIL import Image, ImageDraw, ImageFont
ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
DEMO = os.path.join(ROOT, "tools", "demo")
OUT = os.path.join(ROOT, "docs", "demo.gif")
W, H = 1280, 660
PAD_X, PAD_Y, LH, SIZE = 52, 44, 34, 22
BG, BORDER = (13, 16, 21), (34, 40, 50)
CMD, ADD, DEL, HUNK, OK, CODE = (226, 233, 242), (120, 220, 140), (255, 120, 120), (140, 160, 220), (120, 220, 140), (210, 218, 230)
def font(size):
    path = "C:/Windows/Fonts/consola.ttf"
    return ImageFont.truetype(path, size) if os.path.exists(path) else ImageFont.truetype("C:/Windows/Fonts/cour.ttf", size)
FONT = font(SIZE)
CW = int(round(FONT.getlength("M")))
def lines(name):
    with open(os.path.join(DEMO, name), "r", encoding="utf-8") as h:
        return [l for l in h.read().replace(chr(13), "").split(chr(10)) if l.strip() != ""]
def colour(l):
    if l.startswith("+"): return ADD
    if l.startswith("-"): return DEL
    if l.startswith("@@"): return HUNK
    if "Total tests" in l: return OK
    if l.startswith("error") or l.startswith("warning"): return DEL
    return CODE
def frame(rows, draft, cursor):
    im = Image.new("RGB", (W, H), BG)
    d = ImageDraw.Draw(im)
    d.rectangle([0, 0, W - 1, H - 1], outline=BORDER)
    y = PAD_Y
    for text, col in rows:
        d.text((PAD_X, y), text, font=FONT, fill=col)
        y += LH
    if draft is not None:
        d.text((PAD_X, y), draft, font=FONT, fill=CMD)
    if cursor is not None:
        li, col = cursor
        d.rectangle([PAD_X + col * CW, PAD_Y + li * LH + 5, PAD_X + col * CW + CW - 3, PAD_Y + li * LH + LH - 7], fill=CMD)
    return im
frames, durs = [], []
def push(im, ms):
    frames.append(im); durs.append(ms)
cmds = lines("commands.txt")
outs = open(os.path.join(DEMO, "outputs.txt"), encoding="utf-8").read().replace(chr(13), "").split("%%%")
rows = []
for i, c in enumerate(cmds):
    for cut in range(0, len(c) + 1, 4):
        push(frame(rows, "$ " + c[:cut], (len(rows), 2 + cut)), 50)
    rows.append(("$ " + c, CMD))
    push(frame(rows, None, None), 380)
    block = outs[i].strip().split(chr(10)) if i < len(outs) else []
    for l in block:
        if l.strip() == "":
            continue
        rows.append((l, colour(l)))
        push(frame(rows, None, None), 120)
    push(frame(rows, None, None), 650)
push(frame(rows, None, None), 1600)
pal = [f.convert("P", palette=Image.ADAPTIVE, colors=96) for f in frames]
pal[0].save(OUT, save_all=True, append_images=pal[1:], duration=durs, loop=0, optimize=True, disposal=2)
print("frames=" + str(len(pal)))
print("bytes=" + str(os.path.getsize(OUT)))

