from PIL import Image
import numpy as np

# 加載上傳的圖像
img_path = '/mnt/data/image.png'

# 讀取圖像
img = Image.open(img_path).convert('L').resize((1000, 1000))
ary = np.array(img)

# 檢查圖像數據的前幾個像素值
ary[:10, :10]
