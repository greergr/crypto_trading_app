from PIL import Image, ImageDraw, ImageFont
import os

# إنشاء صورة جديدة
size = 1024
image = Image.new('RGB', (size, size), '#2E7D32')
draw = ImageDraw.Draw(image)

# رسم دائرة في الخلفية
circle_color = '#1B5E20'
circle_radius = size // 2 - 50
circle_center = (size // 2, size // 2)
draw.ellipse(
    [
        circle_center[0] - circle_radius,
        circle_center[1] - circle_radius,
        circle_center[0] + circle_radius,
        circle_center[1] + circle_radius
    ],
    fill=circle_color
)

# رسم رمز البيتكوين
bitcoin_color = '#FFFFFF'
bitcoin_size = size // 2
bitcoin_pos = ((size - bitcoin_size) // 2, (size - bitcoin_size) // 2)
draw.rectangle(
    [
        bitcoin_pos[0],
        bitcoin_pos[1],
        bitcoin_pos[0] + bitcoin_size,
        bitcoin_pos[1] + bitcoin_size
    ],
    fill=bitcoin_color,
    outline=None
)

# حفظ الصورة
icon_path = os.path.join('assets', 'icon', 'icon.png')
image.save(icon_path, 'PNG')
