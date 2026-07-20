from __future__ import annotations

import colorsys
import json
import glob
import math
from pathlib import Path

from PIL import Image, ImageDraw, ImageFilter, ImageFont


ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "store_assets" / "iphone_6_9_landscape" / "ja"
ICON_OUT = ROOT / "store_assets" / "app_icon"
IOS_ICON_SET = ROOT / "ios" / "Runner" / "Assets.xcassets" / "AppIcon.appiconset"
SIZE = (2868, 1320)

BG = (9, 10, 15)
CLOCK = (244, 242, 255)
MUTED = (186, 185, 205)
RIPPLE = (191, 239, 255)
PANEL = (23, 24, 33)
PANEL_2 = (31, 32, 43)
LINE = (65, 66, 86)
ACCENT = (140, 123, 255)


def font(path: Path | str, size: int, index: int = 0) -> ImageFont.FreeTypeFont:
    return ImageFont.truetype(str(path), size=size, index=index)


def japanese_font(weight: str = "W6", size: int = 80) -> ImageFont.FreeTypeFont:
    matches = glob.glob(f"/System/Library/Fonts/ヒラギノ角ゴシック {weight}.ttc")
    if matches:
        return font(matches[0], size)
    return font("/System/Library/Fonts/AppleSDGothicNeo.ttc", size)


FONT_JP_BOLD = lambda size: japanese_font("W8", size)
FONT_JP = lambda size: japanese_font("W5", size)
FONT_UI = lambda size: japanese_font("W4", size)
FONT_CLOCK = lambda size: font(ROOT / "assets/fonts/BitcountGridDouble-Regular.ttf", size)


def new_canvas() -> Image.Image:
    return Image.new("RGB", SIZE, BG)


def rounded_mask(size: tuple[int, int], radius: int) -> Image.Image:
    mask = Image.new("L", size, 0)
    draw = ImageDraw.Draw(mask)
    draw.rounded_rectangle((0, 0, size[0], size[1]), radius=radius, fill=255)
    return mask


def text_size(draw: ImageDraw.ImageDraw, text: str, fnt: ImageFont.FreeTypeFont) -> tuple[int, int]:
    box = draw.textbbox((0, 0), text, font=fnt)
    return box[2] - box[0], box[3] - box[1]


def draw_headline(draw: ImageDraw.ImageDraw, title: str, subtitle: str | None = None) -> None:
    x, y = 118, 92
    title_font = FONT_JP_BOLD(72)
    shadow = (0, 0, 0)
    draw.text((x + 3, y + 5), title, font=title_font, fill=shadow)
    draw.text((x, y), title, font=title_font, fill=CLOCK)
    if subtitle:
        sub_font = FONT_JP(30)
        draw.text((x + 2, y + 102), subtitle, font=sub_font, fill=shadow)
        draw.text((x, y + 100), subtitle, font=sub_font, fill=MUTED)


def draw_clock_text(draw: ImageDraw.ImageDraw, text: str, center: tuple[int, int], size: int = 284) -> None:
    fnt = FONT_CLOCK(size)
    width, height = text_size(draw, text, fnt)
    x = center[0] - width // 2
    y = center[1] - height // 2 - 18
    draw.text((x + 5, y + 9), text, font=fnt, fill=(0, 0, 0))
    draw.text((x, y), text, font=fnt, fill=CLOCK)


def hsv_color(hue: int, saturation: float = 0.55, value: float = 1.0) -> tuple[int, int, int]:
    r, g, b = colorsys.hsv_to_rgb(hue / 360, saturation, value)
    return int(r * 255), int(g * 255), int(b * 255)


def alpha(color: tuple[int, int, int], a: int) -> tuple[int, int, int, int]:
    return color[0], color[1], color[2], a


def draw_glow_circle(base: Image.Image, center: tuple[int, int], color: tuple[int, int, int], radius: int = 78) -> None:
    canvas_size = base.size
    glow = Image.new("RGBA", canvas_size, (0, 0, 0, 0))
    gd = ImageDraw.Draw(glow)
    for scale, opacity, blur in [(2.4, 34, 30), (1.45, 52, 16)]:
        layer = Image.new("RGBA", canvas_size, (0, 0, 0, 0))
        ld = ImageDraw.Draw(layer)
        r = int(radius * scale)
        ld.ellipse((center[0] - r, center[1] - r, center[0] + r, center[1] + r), fill=alpha(color, opacity))
        glow.alpha_composite(layer.filter(ImageFilter.GaussianBlur(blur)))
    gd.ellipse((center[0] - radius, center[1] - radius, center[0] + radius, center[1] + radius), outline=alpha(color, 205), width=6)
    inner = int(radius * 0.54)
    gd.ellipse((center[0] - inner, center[1] - inner, center[0] + inner, center[1] + inner), fill=alpha(color, 235))
    base.paste(Image.alpha_composite(base.convert("RGBA"), glow).convert("RGB"))


def draw_ripple(base: Image.Image, center: tuple[int, int], radii: list[int], opacity: int = 72) -> None:
    layer = Image.new("RGBA", SIZE, (0, 0, 0, 0))
    draw = ImageDraw.Draw(layer)
    for i, radius in enumerate(radii):
        draw.ellipse(
            (center[0] - radius, center[1] - radius, center[0] + radius, center[1] + radius),
            outline=alpha(RIPPLE, max(20, opacity - i * 16)),
            width=max(2, 6 - i),
        )
    base.paste(Image.alpha_composite(base.convert("RGBA"), layer).convert("RGB"))


def draw_settings_icon(draw: ImageDraw.ImageDraw) -> None:
    cx, cy = 2746, 74
    draw.ellipse((cx - 23, cy - 23, cx + 23, cy + 23), outline=(116, 114, 135), width=4)
    for angle in range(0, 360, 45):
        rad = math.radians(angle)
        x1 = cx + math.cos(rad) * 30
        y1 = cy + math.sin(rad) * 30
        x2 = cx + math.cos(rad) * 39
        y2 = cy + math.sin(rad) * 39
        draw.line((x1, y1, x2, y2), fill=(116, 114, 135), width=4)
    draw.ellipse((cx - 7, cy - 7, cx + 7, cy + 7), fill=(116, 114, 135))


def draw_clock_screen(
    title: str,
    subtitle: str,
    filename: str,
    *,
    time: str,
    objects: list[tuple[int, int, int]],
    ripples: list[tuple[int, int, list[int]]] | None = None,
) -> None:
    image = new_canvas()
    draw = ImageDraw.Draw(image)
    if ripples:
        for x, y, radii in ripples:
            draw_ripple(image, (x, y), radii)
    for index, (x, y, hue) in enumerate(objects):
        draw_glow_circle(image, (x, y), hsv_color(hue), radius=76 if index else 82)
    draw_clock_text(draw, time, (SIZE[0] // 2, SIZE[1] // 2 + 28))
    draw_settings_icon(draw)
    draw_headline(draw, title, subtitle)
    image.save(OUT / filename)


def draw_switch(draw: ImageDraw.ImageDraw, box: tuple[int, int, int, int], on: bool) -> None:
    fill = ACCENT if on else (72, 72, 86)
    draw.rounded_rectangle(box, radius=(box[3] - box[1]) // 2, fill=fill)
    knob_r = (box[3] - box[1]) // 2 - 7
    cx = box[2] - knob_r - 8 if on else box[0] + knob_r + 8
    cy = (box[1] + box[3]) // 2
    draw.ellipse((cx - knob_r, cy - knob_r, cx + knob_r, cy + knob_r), fill=(247, 247, 250))


def draw_settings_image() -> None:
    image = new_canvas()
    draw = ImageDraw.Draw(image)
    draw_headline(draw, "秒表示やオブジェクト数を調整", "12/24時間表記、秒表示、テーマ、光の数を保存")

    x, y, w, h = 760, 218, 1500, 850
    draw.rounded_rectangle((x, y, x + w, y + h), radius=32, fill=PANEL)
    draw.rectangle((x, y, x + w, y + 128), fill=(28, 29, 39))
    draw.line((x, y + 128, x + w, y + 128), fill=LINE, width=2)
    draw.text((x + 54, y + 38), "設定", font=FONT_JP_BOLD(50), fill=CLOCK)

    row_y = y + 168
    rows = [
        ("24時間表記", "オフにするとAM/PM付きの12時間表記にします", "switch_on"),
        ("秒を表示", "時計に秒を含めます", "switch_on"),
        ("表示モード", "端末設定に合わせるか、ライト / ダークを固定します", "segments"),
        ("移動オブジェクト数", "3個", "stepper"),
    ]
    for title, subtitle, control in rows:
        draw.rectangle((x + 34, row_y, x + w - 34, row_y + 150), fill=PANEL)
        draw.text((x + 58, row_y + 28), title, font=FONT_JP_BOLD(34), fill=CLOCK)
        draw.text((x + 58, row_y + 78), subtitle, font=FONT_UI(24), fill=MUTED)
        if control == "switch_on":
            draw_switch(draw, (x + w - 178, row_y + 44, x + w - 70, row_y + 100), True)
        elif control == "segments":
            sx, sy = x + w - 468, row_y + 38
            draw.rounded_rectangle((sx, sy, sx + 390, sy + 76), radius=38, outline=LINE, width=2)
            labels = ["Auto", "Light", "Dark"]
            for idx, label in enumerate(labels):
                lx = sx + idx * 130
                if idx == 2:
                    draw.rounded_rectangle((lx + 4, sy + 4, lx + 126, sy + 72), radius=34, fill=ACCENT)
                draw.text((lx + 34, sy + 23), label, font=font("/System/Library/Fonts/HelveticaNeue.ttc", 26), fill=CLOCK if idx == 2 else MUTED)
                if idx:
                    draw.line((lx, sy + 12, lx, sy + 64), fill=LINE, width=1)
        else:
            sx, sy = x + w - 338, row_y + 44
            for bx, label in [(sx, "-"), (sx + 198, "+")]:
                draw.rounded_rectangle((bx, sy, bx + 64, sy + 64), radius=32, fill=PANEL_2, outline=LINE, width=2)
                draw.text((bx + 21, sy + 10), label, font=font("/System/Library/Fonts/HelveticaNeue.ttc", 42), fill=CLOCK)
            draw.text((sx + 122, sy + 14), "3", font=font("/System/Library/Fonts/HelveticaNeue.ttc", 34), fill=CLOCK)
        row_y += 164
        draw.line((x + 58, row_y - 12, x + w - 58, row_y - 12), fill=(45, 46, 60), width=1)

    draw_glow_circle(image, (2440, 900), hsv_color(346), radius=72)
    draw_ripple(image, (2440, 900), [110, 172, 238], opacity=54)
    image.save(OUT / "04_settings.png")


def make_contact_sheet() -> None:
    files = sorted(OUT.glob("0*.png"))
    thumb_w = 574
    thumb_h = 264
    sheet = Image.new("RGB", (thumb_w * 2 + 72, thumb_h * 3 + 132), (18, 19, 26))
    draw = ImageDraw.Draw(sheet)
    for i, path in enumerate(files):
        image = Image.open(path).resize((thumb_w, thumb_h), Image.Resampling.LANCZOS)
        x = 24 + (i % 2) * (thumb_w + 24)
        y = 72 + (i // 2) * (thumb_h + 24)
        sheet.paste(image, (x, y))
        draw.text((x, y - 34), path.name, font=font("/System/Library/Fonts/HelveticaNeue.ttc", 22), fill=(225, 224, 235))
    sheet.save(OUT / "_contact_sheet.png")


def draw_app_icon(size: int = 1024) -> Image.Image:
    image = Image.new("RGB", (size, size), BG)
    layer = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(layer)

    # Gentle corner vignette.
    for radius, opacity in [(920, 42), (660, 36), (440, 28)]:
        draw.ellipse(
            (size - radius, -radius * 0.18, size + radius * 0.18, radius),
            fill=(42, 54, 92, opacity),
        )

    def local_ripple(cx: int, cy: int, radii: list[int]) -> None:
        for i, radius in enumerate(radii):
            draw.ellipse(
                (cx - radius, cy - radius, cx + radius, cy + radius),
                outline=alpha(RIPPLE, 78 - i * 17),
                width=max(3, 8 - i * 2),
            )

    cx, cy = int(size * 0.62), int(size * 0.43)
    local_ripple(cx, cy, [172, 252, 334])

    dot_font = FONT_CLOCK(96)
    draw.text((118, 724), "22", font=dot_font, fill=(244, 242, 255, 88))
    draw.text((708, 154), "48", font=dot_font, fill=(244, 242, 255, 66))

    image = Image.alpha_composite(image.convert("RGBA"), layer).convert("RGB")
    draw_glow_circle(image, (cx, cy), hsv_color(210), radius=118)
    draw_glow_circle(image, (int(size * 0.28), int(size * 0.72)), hsv_color(278), radius=64)
    return image


def make_app_icons() -> None:
    ICON_OUT.mkdir(parents=True, exist_ok=True)
    master = draw_app_icon()
    master.save(ICON_OUT / "idle_clock_app_icon_1024.png")

    with (IOS_ICON_SET / "Contents.json").open() as file:
        contents = json.load(file)

    for entry in contents["images"]:
        filename = entry.get("filename")
        if not filename:
            continue
        point_size = float(entry["size"].split("x")[0])
        scale = int(entry["scale"].replace("x", ""))
        pixel_size = int(point_size * scale)
        resized = master.resize((pixel_size, pixel_size), Image.Resampling.LANCZOS)
        resized.save(IOS_ICON_SET / filename)

    preview = Image.new("RGB", (1280, 760), (18, 19, 26))
    preview_draw = ImageDraw.Draw(preview)
    preview_draw.text((48, 40), "Idle Clock App Icon", font=font("/System/Library/Fonts/HelveticaNeue.ttc", 42), fill=CLOCK)
    for i, sample_size in enumerate([512, 256, 128, 64]):
        icon = master.resize((sample_size, sample_size), Image.Resampling.LANCZOS)
        x = 64 + i * 292
        y = 150 + (512 - sample_size) // 2
        preview.paste(icon, (x, y))
        preview_draw.text((x, 690), f"{sample_size}px", font=font("/System/Library/Fonts/HelveticaNeue.ttc", 28), fill=MUTED)
    preview.save(ICON_OUT / "idle_clock_app_icon_preview.png")


def main() -> None:
    OUT.mkdir(parents=True, exist_ok=True)
    draw_clock_screen(
        "置いて眺める、静かな時計",
        "横向きに置くためのミニマルなデジタル時計",
        "01_main_clock.png",
        time="22:48:16",
        objects=[(390, 280, 210), (2380, 940, 278)],
    )
    draw_clock_screen(
        "反射のたびに、光と音が広がる",
        "壁やオブジェクトに触れる瞬間、波紋と色が残ります",
        "02_ripple_moment.png",
        time="22:48:16",
        objects=[(2520, 360, 210), (620, 965, 278), (1980, 940, 346)],
        ripples=[(2868, 360, [92, 158, 232]), (1980, 940, [86, 145, 218])],
    )
    draw_clock_screen(
        "横向きに置いて、時間を眺める",
        "作業机やベッドサイドに、そのまま置ける横画面",
        "03_sideways_clock.png",
        time="22:48",
        objects=[(2350, 302, 210), (520, 1010, 278)],
        ripples=[(2350, 302, [130, 206, 284])],
    )
    draw_settings_image()
    draw_clock_screen(
        "画面の中で、光が跳ね返る",
        "最大4つの移動オブジェクトで、静かな動きに変化を",
        "05_four_objects.png",
        time="22:48:16",
        objects=[(420, 280, 210), (2360, 350, 278), (700, 980, 346), (2140, 940, 54)],
        ripples=[(2868, 350, [90, 152, 230]), (1420, 860, [72, 126, 190])],
    )
    make_contact_sheet()
    make_app_icons()


if __name__ == "__main__":
    main()
