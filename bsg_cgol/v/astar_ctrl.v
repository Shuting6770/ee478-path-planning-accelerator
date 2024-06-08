module astar_ctrl ( input clk_i
   ,input reset_i
   ,input map_load_done_i
   ,output map_empty_o
   ,output map_load_o
   ,output run_astar_o
);

assign run_astar_o = map_load_done_i;

always_ff @(posedge clk_i) begin
    if reset_i begin
        map_empty_o <= 1'b1;
        map_load_o <= 1'b0;
    end else if map_empty_o begin
        map_load_o <= 1'b1;
        map_empty_o <= 1'b0;
    end
end

endmodule