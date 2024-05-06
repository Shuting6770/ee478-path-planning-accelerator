module collision_checker #(parameter WIDTH = 1000, parameter HEIGHT = 1000)(
    input wire [$clog2(WIDTH)-1:0] check_x,
    input wire [$clog2(HEIGHT)-1:0] check_y,
    output wire is_obstacle
);

    // Instance of the map memory module
    map_memory #(WIDTH, HEIGHT) map_instance (
        .clk(clk),
        .w_en(0),
        .x_addr(check_x),
        .y_addr(check_y),
        .data_in(0),
        .data_out(is_obstacle)
    );

endmodule
