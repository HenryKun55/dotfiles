#!/usr/bin/env python3
"""Download all themes from alacritty/alacritty-theme into ~/.config/alacritty/themes/"""
import urllib.request, json, os, sys

API = "https://api.github.com/repos/alacritty/alacritty-theme/contents/themes"
RAW = "https://raw.githubusercontent.com/alacritty/alacritty-theme/master/themes"

def main():
    themes_dir = os.path.join(os.path.expanduser("~/.config/alacritty"), "themes")
    os.makedirs(themes_dir, exist_ok=True)

    print("Buscando lista de temas...")
    try:
        req = urllib.request.Request(API, headers={"User-Agent": "alacritty-theme-fetcher"})
        with urllib.request.urlopen(req) as r:
            entries = json.loads(r.read())
    except Exception as e:
        print(f"Erro ao buscar lista: {e}", file=sys.stderr)
        sys.exit(1)

    files = [e for e in entries if e["name"].endswith(".toml")]
    total = len(files)
    print(f"{total} temas encontrados\n")

    downloaded, skipped, failed = 0, 0, 0
    for i, entry in enumerate(files, 1):
        name = entry["name"]
        dest = os.path.join(themes_dir, name)
        if os.path.exists(dest):
            print(f"  [{i:3}/{total}] skip  {name}")
            skipped += 1
            continue
        try:
            url = f"{RAW}/{urllib.parse.quote(name)}"
            req = urllib.request.Request(url, headers={"User-Agent": "alacritty-theme-fetcher"})
            with urllib.request.urlopen(req) as r:
                open(dest, "wb").write(r.read())
            print(f"  [{i:3}/{total}] ✓     {name}")
            downloaded += 1
        except Exception as e:
            print(f"  [{i:3}/{total}] ✗     {name}: {e}")
            failed += 1

    print(f"\nPronto — {downloaded} baixados, {skipped} já existiam, {failed} erros")
    print(f"Temas em: {themes_dir}")
    print("Use 'alacritty-theme' para escolher.")

import urllib.parse
main()
