/**
* Halton Sequence
*
* numVertices_i[31:0] is the number of nodes, representing the density of nodes instead of the extract num of vertices in graph
* base_i[1:0] is the base of the sequence, can be 2 or 3
* sequence_o[numNode-1:0] is the halton value array
* 
*
* the max size of input map can be set in the parameters
**/


module halton_sequence_value #(parameter MAP_WIDTH = 1000)  // map size = 1000*1000
  (
    input reset
   ,input clk
   ,input [1:0] base_i
   ,input [15:0] numNode_i

   ,output logic [$clog2(MAP_WIDTH+1)-1:0] value_o // each value is 0~1000, modify it according to the map_width
   ,output logic [15:0] index_o // index of the value
   ,output logic valid_o // 1 when the value_o is valid, otherwise is 0
  );

  enum {WAIT, ONE, TWO, THREE, NEXT, DONE} state_r, state_n;

  logic [31:0] n_r, n_n;
  logic [31:0] d_r, d_n;
  logic [31:0] x;
  logic [15:0] cnt_r, cnt_n;
  logic [31:0] y_r, y_n;

  assign x = d_r - n_r;

  always_comb begin
    case(state_r)
      WAIT: begin
        if x == 1 begin
          state_n = ONE;
          n_n = 1;
          d_n = d_r * base_i;
        end
        else begin
          state_n = TWO;
          y_n = d_r / base_i;
        end
      end
      ONE: state_n = NEXT;
      TWO: begin
        if x > y begin
          state_n = THREE;
          n_n = (base_i + 1) * y_r - x;
        end
        else begin
          state_n = TWO;
          y_n = y_r / base_i;
        end
      end
      THREE: state_n = NEXT;
      NEXT: begin 
        if cnt_r < numNode_i state_n = WAIT;
        else state_n = DONE;
      end
      DONE: state_n = DONE;
    endcase 
  end

  assign valid_o = (state_r==NEXT);//输出一个有效数字
  assign cnt_n = (state_n==NEXT)? cnt_r + 1'b1 : cnt_r;
  assign index_o = cnt_r;
  assign value_o = n_r * MAP_WIDTH / d_r;

  always_ff @(posedge clk) begin
    if reset begin
      state_r <= WAIT;
      cnt_r <= '0;
      n_r <= '0;
      d_r <= '1;
      y_r <= '0;
    end else begin
      state_r <= state_n;
      cnt_r <= cnt_n;
      n_r <= n_n;
      d_r <= d_n;
      y_r <= y_n;
    end
  end

endmodule