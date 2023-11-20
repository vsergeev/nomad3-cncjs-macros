#!/usr/bin/env python
import json

macros = {
    'Change Tool': 'bitsetter-change-tool.macro.nc',
    'Clear Tool Reference': 'bitsetter-clear-tool-reference.macro.nc',
    'Probe Z': 'bitzero-v2-probe-z.macro.nc',
    'Probe XY': 'bitzero-v2-probe-xy.macro.nc',
    'Probe XYZ': 'bitzero-v2-probe-xyz.macro.nc',
    'Go to X0Y0 Z5': 'goto-x0y0-z5.macro.nc',
}

if __name__ == "__main__":
    obj = []

    for (name, filename) in macros.items():
        with open(filename) as f:
            content = f.read().strip()
            obj.append({'name': name, 'content': content})

    print(json.dumps(obj, indent=1))
