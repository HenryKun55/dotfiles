#!/usr/bin/env python3
import sys, re

def hex_to_rgb(h):
    h = h.lstrip('#')
    return int(h[0:2], 16), int(h[2:4], 16), int(h[4:6], 16)

def swatch(h, w=5):
    r, g, b = hex_to_rgb(h)
    return f"\033[48;2;{r};{g};{b}m{' ' * w}\033[0m"

def parse(path):
    colors, section = {}, ""
    try:
        with open(path) as f:
            for line in f:
                line = line.strip()
                m = re.match(r'^\[([^\]]+)\]', line)
                if m:
                    section = m.group(1)
                    continue
                m = re.match(r'^(\w+)\s*=\s*"(#[0-9a-fA-F]{6})"', line)
                if m:
                    colors[f"{section}.{m.group(1)}"] = m.group(2)
    except Exception:
        pass
    return colors

def main():
    if len(sys.argv) < 2:
        sys.exit(1)

    path = sys.argv[1]
    name = path.split("/")[-1]
    if name.endswith(".toml"):
        name = name[:-5]

    c = parse(path)

    bg = c.get("colors.primary.background", "#1a1a1a")
    fg = c.get("colors.primary.foreground", "#f0f0f0")
    r, g, b = hex_to_rgb(bg)
    fr, fg2, fb = hex_to_rgb(fg)

    print(f"\033[1m  {name}\033[0m")
    print()

    sample = "  Hello, World! · 0123456789 · #%@!  "
    print(f"  \033[48;2;{r};{g};{b}m\033[38;2;{fr};{fg2};{fb}m{sample}\033[0m")
    print()
    print(f"  {swatch(bg, 4)} bg {bg}    {swatch(fg, 4)} fg {fg}")
    print()

    palette = ["black", "red", "green", "yellow", "blue", "magenta", "cyan", "white"]

    for label, prefix in [("Normal", "colors.normal"), ("Bright", "colors.bright")]:
        has_section = any(f"{prefix}.{k}" in c for k in palette)
        if not has_section:
            continue
        print(f"  \033[2m{label}\033[0m")
        swatches = "  "
        hexes = "  "
        for k in palette:
            color = c.get(f"{prefix}.{k}", "#888888")
            swatches += swatch(color, 5)
            hexes += f"\033[2m{color}\033[0m "
        print(swatches)
        print(hexes)
        print()

main()
