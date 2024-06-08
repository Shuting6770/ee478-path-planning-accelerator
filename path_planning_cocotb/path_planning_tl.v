module path_planning_tl #(board_width_p = 20)
(   input clk_i
    ,input reset_i
    ,input [7:0] startx_i
    ,input [7:0] starty_i
    ,input [7:0] goalx_i
    ,input [7:0] goaly_i
    ,input [data_width_p-1:0] data_i);

    localparam data_width_p = 8;
    localparam row_width_lp = board_width_p;
    localparam num_total_cells_lp = board_width_p*row_width_lp;

    logic map_empty_li, map_load_li, map_done_lo, run_astar_lo, astar_done_lo;
    logic [num_total_cells_lp-1:0] map_data_lo;

    map_memory #(
        .board_width_p(board_width_p)
    ) map_mem (
        .clk_i(clk_i)
        ,.empty_i(map_empty_li)
        ,.load_i(map_load_li)
        ,.data_i(data_i)
        ,.done_o(map_done_lo)
        ,.data_o(map_data_lo)
    );

    astar_ctrl ac (
        .clk_i(clk_i)
        ,.reset_i(reset_i)
        ,.map_load_done_i(map_done_lo)
        ,.map_empty_o(map_empty_li)
        ,.map_load_o(map_load_li)
        ,.run_astar_o(run_astar_lo)
    );

    astar_algorithm #(
        .board_width_p(board_width_p)
    ) aa (
        .sync(clk_i)
        ,.reset(run_astar_lo)
        ,.startx_i(startx_i)
        ,.starty_i(starty_i)
        ,.goalx_i(goalx_i)
        ,.goaly_i(goaly_i)
        ,.map_i(map_data_lo)
        ,.done_o(astar_done_lo)
    );



endmodule