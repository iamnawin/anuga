"""Generate AnugaCare icons from the founder's two logo PNGs.

Usage: uv run --with pillow python -I scripts/make-brand-icons.py <symbol.png> <lockup.png> <repo root>
"""
import sys
from pathlib import Path

from PIL import Image, ImageDraw

symbol_src, lockup_src, root = (Path(a) for a in sys.argv[1:4])
WHITE = (255, 255, 255, 255)


def trim(im: Image.Image) -> Image.Image:
    return im.crop(im.getchannel('A').getbbox())


def fit(im: Image.Image, size: int, fill: float) -> Image.Image:
    """im scaled so its longer side is size*fill, centred on a transparent size x size canvas."""
    scale = size * fill / max(im.size)
    w, h = max(1, round(im.width * scale)), max(1, round(im.height * scale))
    # Premultiplied resize avoids dark fringes from transparent black pixels.
    small = im.convert('RGBa').resize((w, h), Image.LANCZOS).convert('RGBA')
    canvas = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    canvas.alpha_composite(small, ((size - w) // 2, (size - h) // 2))
    return canvas


def on_tile(im: Image.Image, size: int, fill: float, radius: float) -> Image.Image:
    tile = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    ImageDraw.Draw(tile).rounded_rectangle((0, 0, size - 1, size - 1), radius=round(size * radius), fill=WHITE)
    tile.alpha_composite(fit(im, size, fill))
    return tile


def save(im: Image.Image, path: Path) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    im.save(path, optimize=True)
    print(path.relative_to(root), im.size)


symbol = trim(Image.open(symbol_src).convert('RGBA'))
lockup = trim(Image.open(lockup_src).convert('RGBA'))

save(fit(symbol, 1024, 0.92), root / 'docs/logo/anugacare-symbol.png')
save(lockup, root / 'docs/logo/anugacare-lockup.png')

mipmaps = {'mdpi': 48, 'hdpi': 72, 'xhdpi': 96, 'xxhdpi': 144, 'xxxhdpi': 192}
for app in ('companion_app', 'family_app', 'anugacare_app'):
    base = root / 'apps' / app
    save(fit(symbol, 32, 0.96), base / 'web/favicon.png')
    for size in (192, 512):
        save(fit(symbol, size, 0.84), base / f'web/icons/Icon-{size}.png')
        # Maskable: full-bleed background, symbol inside the 80% safe zone.
        save(on_tile(symbol, size, 0.56, 0), base / f'web/icons/Icon-maskable-{size}.png')
    for density, size in mipmaps.items():
        save(on_tile(symbol, size, 0.7, 0.22), base / f'android/app/src/main/res/mipmap-{density}/ic_launcher.png')
    save(fit(symbol, 512, 1.0), base / 'assets/brand/anugacare-symbol.png')

save(fit(symbol, 512, 0.96), root / 'apps/ops_console/src/app/icon.png')
save(fit(symbol, 256, 1.0), root / 'apps/ops_console/src/app/login/anugacare-symbol.png')
