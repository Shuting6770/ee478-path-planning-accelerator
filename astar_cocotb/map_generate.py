import math
import time
import random
from PIL import Image
import numpy as np # Not installed by default
import os.path as osp


def print_2d_array(array):
    # 打印开头的双花括号
    print("{{")
    # 迭代每一行
    for i, row in enumerate(array):
        # 打印行的开头花括号
        print("    {", end="")
        # 打印行的每一个元素
        for j, val in enumerate(row):
            if j < len(row) - 1:
                # 元素之间用逗号分隔
                print(f"{val}, ", end="")
            else:
                # 行末尾的元素后不加逗号和空格
                print(f"{val}", end="")
        # 打印行的结尾花括号
        if i < len(array) - 1:
            print("},")
        else:
            print("}")
    # 打印结尾的双花括号
    print("}};")


set_user_path = '/homes/stshao'  # + os.getlogin()
work_dir_path = osp.join(set_user_path, 'ee478/ee478-path-planning-accelerator')
img_name = 'map2.jpg'
img_path = osp.join(work_dir_path, ('astar_cocotb/' + img_name))
img_name = img_path.split('/')[-1].split('.')[0]
img = Image.open(img_path).resize((32, 32))
# 將圖片轉換為灰度模式
gray_img = img.convert('L')
# 將灰度圖片轉換為 NumPy 陣列
gray_array = np.array(gray_img)
# 定義閾值，大於此值的設為 1，否則設為 0
threshold = 128
bw_array = np.where(gray_array > threshold, 0, 1)
# bw_array = bw_array[::-1,::-1]
# print(bw_array)
print_2d_array(bw_array)
# bw_flattened_array = bw_array.flatten()
# bw_binary_string = ''.join(map(str, bw_flattened_array))
# bw_integer = int(bw_binary_string, 2)
# print(bw_integer)
