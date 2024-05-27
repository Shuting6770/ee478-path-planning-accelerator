module bsg_cgol_cell_array #(
  parameter board_width_p = 64,  // Assuming 64x64 grid
  parameter `BSG_INV_PARAM(max_game_length_p),
  localparam game_length_width_lp=`BSG_SAFE_CLOG2(max_game_length_p+1),
  localparam num_total_cells_lp = board_width_p * board_width_p,
  parameter addr_width_lp = $clog2(num_total_cells_lp),
  parameter row_width_lp = board_width_p
)
(
  input clk_i,
  input [num_total_cells_lp-1:0] data_i,
  input [23:0] start_end_point_i,
  input en_i,
  input update_i,
  output logic [num_total_cells_lp-1:0] data_o
);

logic [23:0] start_end_point;

// Zero extend the input to 24 bits
// assign padded_start_end_point = {{(24-game_length_width_lp){1'b0}}, start_end_point_i};

logic [num_total_cells_lp-1:0] data_r;
logic [num_total_cells_lp-1:0] data_n;
logic [board_width_p-1:0][row_width_lp-1:0] data_2d_r;
logic [board_width_p-1:0][row_width_lp-1:0] data_2d_n;

// File handle
integer file;

// Initialize the file
initial begin
  file = $fopen("data_output.txt", "w");
  if (!file) begin
    $display("Error opening file.");
    $finish;
  end else begin
    $display("File opened successfully.");
  end
end

always_comb begin
  // Convert 1D to 64-bit chunks
  integer i;
  for (i = 0; i < board_width_p; i = i + 1) begin
    data_2d_r[i] = data_r[i * row_width_lp +: row_width_lp];
  end

  data_2d_n = data_2d_r;
  if (en_i) begin
    // Arnold Cat Transform (Encryption)
    // Add your specific transform logic here if needed
  end else if (update_i) begin
    // Update 2D data array
    for (i = 0; i < board_width_p; i = i + 1) begin
      data_2d_n[i] = data_i[i * row_width_lp +: row_width_lp];
    end
  end

  // Convert 64-bit chunks back to 1D
  for (i = 0; i < board_width_p; i = i + 1) begin
    data_n[i * row_width_lp +: row_width_lp] = data_2d_n[i];
  end
end

always_ff @ (posedge clk_i) begin
  data_r <= data_n;
  if (update_i) begin
  start_end_point <= start_end_point_i;
  end
end

assign data_o = data_r;

// Write the final state to the file at the end of the simulation
final begin
  integer i;
  for (i = 0; i < num_total_cells_lp; i = i + 1) begin
    $fwrite(file, "%b", data_r[i]);
  end
  $fclose(file);
  $display("File closed.");
end

endmodule
