#!/usr/bin/env python3
"""Generate square launcher icon sources without black letterbox bars."""

from __future__ import annotations

from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
LOGO = ROOT / "assets" / "images" / "logo.png"
OUT_DIR = ROOT / "assets" / "icon"
BRAND_BG = (255, 255, 255, 255)  # Play Store + adaptive background
FOREGROUND_CANVAS = 1024
PLAY_STORE_SIZE = 512


def trim_non_content(image: Image.Image) -> Image.Image:
    """Trim near-white and near-black padding."""
    rgba = image.convert("RGBA")
    w, h = rgba.size
    pixels = rgba.load()

    def is_content(x: int, y: int) -> bool:
        r, g, b, a = pixels[x, y]
        if a < 16:
            return False
        if r < 24 and g < 24 and b < 24:
            return False
        if r > 245 and g > 245 and b > 245:
            return False
        return True

    min_x, min_y, max_x, max_y = w, h, 0, 0
    for y in range(h):
        for x in range(w):
            if is_content(x, y):
                min_x = min(min_x, x)
                min_y = min(min_y, y)
                max_x = max(max_x, x)
                max_y = max(max_y, y)

    if max_x <= min_x or max_y <= min_y:
        return rgba

    return rgba.crop((min_x, min_y, max_x + 1, max_y + 1))


def fit_on_square(
    image: Image.Image,
    size: int,
    background: tuple[int, int, int, int],
    fill_ratio: float,
) -> Image.Image:
    canvas = Image.new("RGBA", (size, size), background)
    content = trim_non_content(image)
    max_side = int(size * fill_ratio)
    content.thumbnail((max_side, max_side), Image.Resampling.LANCZOS)
    x = (size - content.width) // 2
    y = (size - content.height) // 2
    canvas.paste(content, (x, y), content)
    return canvas


def emblem_foreground(image: Image.Image, size: int, fill_ratio: float) -> Image.Image:
    """Foreground layer: emblem only (top ~62% of trimmed logo), transparent bg."""
    trimmed = trim_non_content(image)
    w, h = trimmed.size
    emblem = trimmed.crop((0, 0, w, int(h * 0.62)))
    canvas = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    max_side = int(size * fill_ratio)
    emblem.thumbnail((max_side, max_side), Image.Resampling.LANCZOS)
    x = (size - emblem.width) // 2
    y = int(size * 0.18)
    canvas.paste(emblem, (x, y), emblem)
    return canvas


def main() -> None:
    if not LOGO.exists():
        raise FileNotFoundError(f"Missing source logo: {LOGO}")

    OUT_DIR.mkdir(parents=True, exist_ok=True)
    logo = Image.open(LOGO)

    app_icon = fit_on_square(logo, FOREGROUND_CANVAS, BRAND_BG, fill_ratio=0.82)
    app_icon.save(OUT_DIR / "app_icon.png", optimize=True)

    foreground = emblem_foreground(logo, FOREGROUND_CANVAS, fill_ratio=0.58)
    foreground.save(OUT_DIR / "app_icon_foreground.png", optimize=True)

    play_store = app_icon.convert("RGB").resize(
        (PLAY_STORE_SIZE, PLAY_STORE_SIZE),
        Image.Resampling.LANCZOS,
    )
    play_store.save(OUT_DIR / "play_store_icon_512.png", optimize=True)

    print("Generated:")
    for path in sorted(OUT_DIR.glob("*.png")):
        img = Image.open(path)
        print(f"  {path.relative_to(ROOT)} -> {img.size[0]}x{img.size[1]} mode={img.mode}")


if __name__ == "__main__":
    main()
