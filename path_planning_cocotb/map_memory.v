module map_memory #(
    parameter board_width_p = 64,
    parameter data_width_p = 8,
    localparam row_width_lp = board_width_p,
    localparam num_total_cells_lp = board_width_p*row_width_lp
)
(
    input clk_i,
    input empty_i, // empty the map info in mem
    input load_i, // load the map info into mem
    input [data_width_p-1:0] data_i,
    output done_o,
    output [num_total_cells_lp-1:0] data_o
);
    reg [num_total_cells_lp-1:0] mem; 
    enum {EMPTY, LOAD, DONE} state_n, state_r;

    always_comb begin
        case (state_r)
            EMPTY: if load_i state_n = LOAD;
            else state_n = EMPTY;
            LOAD: if (cnt >= num_total_cells_lp-1) state_n <= DONE;
            else state_n <= LOAD;
            DONE: state_n <= DONE;
        endcase
    end

    assign done_o = (state_n==DONE); // output 1'b1 for only one cycle
    assign data_o = mem;

    always_ff @(posedge clk_i or posedge empty_i) begin
        if empty_i begin
            state_r <= EMPTY;
            mem <= num_total_cells_lp'd0;
            cnt <= 0;
        end else if state_r==LOAD begin
            cnt <= cnt + data_width_p;
            mem[cnt+data_width_p-1:cnt] <= data_i;
            state_r <= state_n;
        end else
            cnt <= cnt;
            state_r <= state_n;
    end
endmodule