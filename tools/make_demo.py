"""Render docs/demo.gif from the output captured in tools/demo.

The files next to this script are the real stdout of the commands the
animation shows: commands.txt holds the two command lines, cli.txt the output
of the first and tests.txt the summary line of the second.

Run: <python> tools/make_demo.py
"""
import os
from PIL import Image, ImageDraw, ImageFont

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
DEMO = os.path.join(ROOT, "tools", "demo")
OUT = os.path.join(ROOT, "docs", "demo.gif")

W, H = 1280, 620
PAD_X, PAD_Y = 52, 44
LINE_H = 36
SIZE = 24
BG = (13, 16, 21)
BORDER = (34, 40, 50)
CMD = (226, 233, 242)
ERROR = (255, 112, 112)
FRAME = (112, 122, 138)
CODE = (214, 222, 235)
CARET = (198, 148, 234)
OK = (104, 226, 132)


def font_for(size):
    for name in ("consola.ttf", "cour.ttf"):
        path = "C:/Windows/Fonts/" + name
        if os.path.exists(path):
            candidate = ImageFont.truetype(path, size)
            if candidate.getlength("╭") > 0 and candidate.getlength("│") > 0:
                return candidate
    return ImageFont.truetype("C:/Windows/Fonts/msyh.ttc", size)


FONT = font_for(SIZE)
CHAR_W = int(round(FONT.getlength("M")))


def read_lines(name):
    path = os.path.join(DEMO, name)
    with open(path, "r", encoding="utf-8") as handle:
        text = handle.read().replace(chr(13), "")
    rows = text.split(chr(10))
    while rows and rows[len(rows) - 1].strip() == "":
        rows.pop()
    return rows


def colour_for(line):
    if line.startswith("error") or line.startswith("warning"):
        return ERROR
    if "╭─[" in line:
        return FRAME
    if "^" in line:
        return CARET
    if line.startswith("Total tests"):
        return OK
    return CODE


def render(committed, draft, cursor):
    image = Image.new("RGB", (W, H), BG)
    draw = ImageDraw.Draw(image)
    draw.rectangle([0, 0, W - 1, H - 1], outline=BORDER)
    rows = list(committed)
    if draft is not None:
        rows.append(draft)
    y = PAD_Y
    for text, colour in rows:
        draw.text((PAD_X, y), text, font=FONT, fill=colour)
        y += LINE_H
    if cursor is not None:
        line_index, column = cursor
        x = PAD_X + column * CHAR_W
        top = PAD_Y + line_index * LINE_H
        draw.rectangle([x, top + 5, x + CHAR_W - 3, top + LINE_H - 7], fill=CMD)
    return image


frames = []
durations = []


def push(image, ms):
    frames.append(image)
    durations.append(ms)


committed = []
commands = read_lines("commands.txt")
outputs = [read_lines("cli.txt"), read_lines("tests.txt")]
prompt = "$ "

for index in range(len(commands)):
    command = commands[index]
    for cut in range(0, len(command) + 1, 4):
        draft = (prompt + command[:cut], CMD)
        push(render(committed, draft, (len(committed), len(prompt) + cut)), 55)
    committed.append((prompt + command, CMD))
    push(render(committed, None, None), 420)
    for line in outputs[index]:
        committed.append((line, colour_for(line)))
        push(render(committed, None, None), 130)
    push(render(committed, None, None), 700)

push(render(committed, None, None), 1400)

palette = [frame.convert("P", palette=Image.ADAPTIVE, colors=96) for frame in frames]
palette[0].save(OUT, save_all=True, append_images=palette[1:], duration=durations, loop=0, optimize=True, disposal=2)
print("frames=" + str(len(palette)))
print("bytes=" + str(os.path.getsize(OUT)))
