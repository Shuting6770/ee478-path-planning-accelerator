module map_memory #(parameter WIDTH = 1000, parameter HEIGHT = 1000)(
    input wire clk,
    input wire w_en,            // Write enable
    input wire [$clog2(WIDTH)-1:0] x_addr,  // Address bits depend on the width
    input wire [$clog2(HEIGHT)-1:0] y_addr, // Address bits depend on the height
    input wire data_in,       // Data to be written
    output reg data_out       // Data read
);
    reg [0:0] ram [0:WIDTH-1][0:HEIGHT-1];

    always @(posedge clk) begin
        if (w_en) begin
            // Write operation
            ram[x_addr][y_addr] <= data_in;
        end
        // Read operation
        data_out <= ram[x_addr][y_addr];
    end
endmodule