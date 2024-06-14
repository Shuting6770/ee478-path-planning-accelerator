# Import python libraries
import math
import time
import random
from PIL import Image
import numpy as np # Not installed by default
import os.path as osp

# Import cocotb libraries
import cocotb
from cocotb.clock import Clock, Timer
from cocotb.triggers import RisingEdge, FallingEdge, Timer


CLK_PERIOD = 10
DATA_WIDTH_P = 8


async def input_side_testbench(dut,map):
    """Handle input traffic"""

    # Initialize DUT interface values
    dut.startx_i.value = 5
    dut.starty_i.value = 0
    dut.goalx_i.value = 10
    dut.goaly_i.value = 18
    # dut.map_i.value = map

    # Wait for reset deassertion
    while 1:
        await RisingEdge(dut.sync); await Timer(1, units="ps")
        if dut.reset_i == 0: break

    await RisingEdge(dut.clk_i); await Timer(1, units="ps")
    num = int(len(map)/DATA_WIDTH_P)
    if num*DATA_WIDTH_P < map:
        for n in range(num+1):
            if n*DATA_WIDTH_P+7 > len(map):
                input_data = map[len(map)-1:n*DATA_WIDTH_P]
            else:
                input_data = map[n*DATA_WIDTH_P+7:n*DATA_WIDTH_P]
            dut.data_i.setimmediatevalue(input_data)
            await RisingEdge(dut.sync); await Timer(1, units="ps")
    else:
        for n in range(num):
            if n*DATA_WIDTH_P+7 > len(map):
                input_data = map[len(map)-1:n*DATA_WIDTH_P]
            else:
                input_data = map[n*DATA_WIDTH_P+7:n*DATA_WIDTH_P]
            dut.data_i.setimmediatevalue(input_data)
            await RisingEdge(dut.sync); await Timer(1, units="ps")

    dut.data_i.value = 0




@cocotb.test()
async def test_astar(dut):
    """ Test that d propagates to q """

    clock = Clock(dut.sync, CLK_PERIOD, units="ps")  
    cocotb.start_soon(clock.start())

    set_user_path = '/homes/stshao'  # + os.getlogin()
    work_dir_path = osp.join(set_user_path, 'ee478/ee478-path-planning-accelerator')

    img_name = 'map4.jpg'
    img_path = osp.join(work_dir_path, ('astar_cocotb/' + img_name))
    img_name = img_path.split('/')[-1].split('.')[0]
    # print(img_path, img_name)
    # print("Mark1!")

    img = Image.open(img_path).resize((20, 20))
    # 將圖片轉換為灰度模式
    gray_img = img.convert('L')
    # 將灰度圖片轉換為 NumPy 陣列
    gray_array = np.array(gray_img)
    # 定義閾值，大於此值的設為 1，否則設為 0
    threshold = 128
    bw_array = np.where(gray_array > threshold, 0, 1)
    bw_array = bw_array[::-1,::-1]
    bw_flattened_array = bw_array.flatten()
    bw_binary_string = ''.join(map(str, bw_flattened_array))
    bw_integer = int(bw_binary_string, 2)
    print(bw_integer)
    # print(bw_array)
    # bw_array = bw_array.tolist()

    input_thread = cocotb.start_soon(input_side_testbench(dut, bw_integer))

    # Reset initialization
    dut.reset_i.value = 1

    # Wait for 5 clock cycles
    await Timer(50, units="ps")
    await RisingEdge(dut.sync); await Timer(1, units="ps")

    # Deassert reset
    dut.reset_i.value = 0
    await input_thread

    # await Timer(100000, units="ps")
    await RisingEdge(dut.all_done_o)



