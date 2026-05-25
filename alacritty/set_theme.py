#!/usr/bin/env python3
import sys, re

if len(sys.argv) < 3:
    print("Usage: set_theme.py <alacritty.toml> <theme.toml>", file=sys.stderr)
    sys.exit(1)

config, theme = sys.argv[1], sys.argv[2]
try:
    content = open(config).read()
    content = re.sub(r'import\s*=\s*\[[^\]]*\]', f'import = ["{theme}"]', content)
    open(config, 'w').write(content)
except Exception as e:
    print(e, file=sys.stderr)
    sys.exit(1)
