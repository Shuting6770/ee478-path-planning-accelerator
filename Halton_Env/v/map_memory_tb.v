`timescale 1ns / 1ps

module testbench;
    // Inputs
    reg clk;
    reg we;
    reg [9:0] x_addr;
    reg [9:0] y_addr;
    reg data_in;

    // Outputs
    wire data_out;

    // Instantiate the Unit Under Test (UUT)
    image_ram uut (
        .clk(clk),
        .we(we),
        .x_addr(x_addr),
        .y_addr(y_addr),
        .data_in(data_in),
        .data_out(data_out)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = !clk; // Generate a clock with period 10 ns
    end

    // Read the trace file and apply tests
    initial begin
        // Initialize inputs
        we = 0;
        x_addr = 0;
        y_addr = 0;
        data_in = 0;

        // Wait for global reset
        #100;

        // Open the trace file
        $display("Reading trace file...");
        $readmemb("trace_file.txt", data_array); // Adjust this line based on your file's path and name

        // Apply each command from the trace file
        for (int i = 0; i < data_count; i++) begin
            {x_addr, y_addr, data_in} = data_array[i];
            we = 1; // Enable writing
            #10;    // Wait for one clock cycle
            we = 0; // Disable writing
            #10;    // Wait for one clock cycle
        end

        // Add more commands if needed
        $display("Test completed.");
    end
endmodule
