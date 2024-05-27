module bsg_cgol_ctrl #(
   parameter `BSG_INV_PARAM(max_game_length_p)
  ,localparam game_len_width_lp=`BSG_SAFE_CLOG2(max_game_length_p+1)
) (input clk_i
  ,input reset_i

  ,input en_i

  // Input Data Channel
  ,input  [game_len_width_lp-1:0] frames_i
  ,input  v_i
  ,output ready_o

  // Output Data Channel
  ,input yumi_i
  ,output v_o

  // Cell Array
  ,output update_o
  ,output en_o
);

  wire unused = en_i; // for clock gating, unused
  
  // TODO: Design your control logic
  // reg [1:0] state, state_next;

  
/// State encoding
localparam IDLE = 2'b00,
           INIT_GAME = 2'b01,
           RUNNING_GAME = 2'b10,
           DATA_READY = 2'b11;

reg [1:0] state, next_state;
reg [game_len_width_lp-1:0] frame_counter, frame_counter_next;

// State transition logic
always @(posedge clk_i or posedge reset_i) begin
    if (reset_i) begin
        state <= IDLE;
    end else begin
        state <= next_state;
    end
end

//assign outputs
assign ready_o = (state == IDLE);
assign update_o = v_i;//(state == INIT_GAME);
assign en_o = (state == RUNNING_GAME);
assign v_o = (state == DATA_READY);

// Next state logic
always @(*) begin
    next_state = state;

    case (state)
        IDLE: begin
            if (v_i) begin
                next_state = INIT_GAME;
            end
        end
        INIT_GAME: begin
            next_state = RUNNING_GAME;
        end
        RUNNING_GAME: begin
            if (frame_counter == 0) begin
                next_state = DATA_READY;
            end
        end
        DATA_READY: begin
            if (yumi_i) begin
                next_state = IDLE;
            end
        end
    endcase

frame_counter_next = frame_counter;
    case (state)
        IDLE:
        if (v_i) begin
            frame_counter_next = frames_i -1;
        end
        RUNNING_GAME:begin
            if (frame_counter != 0) begin
                frame_counter_next = frame_counter -1;
            end
            else begin
                frame_counter_next = frame_counter;
            end
        end
        default:
            frame_counter_next = frame_counter;
    endcase
end

// Frame counter management
always @(posedge clk_i) begin
    if (reset_i) begin
        frame_counter <= 0;
    end
    else begin
        frame_counter <= frame_counter_next;
    end
end

endmodule
