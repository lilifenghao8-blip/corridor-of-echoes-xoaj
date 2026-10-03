# -*- coding: utf-8 -*-
"""把 assets/face1..3.jpg 重新以 base64 内嵌进 index.html（换鬼脸用）。
用法：  python tools/embed_faces.py
"""
import base64, io, os, re, sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
HTML = os.path.join(ROOT, "index.html")

def main():
    parts = []
    for i in (1, 2, 3):
        p = os.path.join(ROOT, "assets", "face%d.jpg" % i)
        if not os.path.exists(p):
            print("找不到", p); return 1
        b = open(p, "rb").read()
        parts.append('"data:image/jpeg;base64,' + base64.b64encode(b).decode("ascii") + '"')
        print("face%d.jpg  %.0f KB" % (i, len(b) / 1024.0))
    arr = "const GHOST_FACES=[" + ",\n  ".join(parts) + "];\n"
    src = io.open(HTML, encoding="utf-8").read()
    new, n = re.subn(r"const GHOST_FACES=\[.*?\];\n", arr, src, count=1, flags=re.S)
    if n != 1:
        print("没有在 index.html 里找到 GHOST_FACES 数组"); return 1
    io.open(HTML, "w", encoding="utf-8").write(new)
    print("已写入 index.html （现在可以只发这一个文件到手机）")
    return 0

if __name__ == "__main__":
    sys.exit(main())