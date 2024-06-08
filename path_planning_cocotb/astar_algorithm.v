module astar_algorithm #(
	parameter board_width_p = 20
)
(sync,reset, startx_i, starty_i, goalx_i, goaly_i,map_i, done_o);
   
	localparam row_width_lp = board_width_p;
	localparam num_total_nodes = board_width_p*row_width_lp;

	input sync, reset;
	input [7:0] startx_i, starty_i, goalx_i, goaly_i;
	// input [board_width_p-1:0][row_width_lp-1:0] map;
	input [num_total_nodes-1:0] map_i;
	output logic done_o;

	reg [board_width_p-1:0] finished_map [row_width_lp-1:0];
	// reg [board_width_p-1:0][row_width_lp-1:0] map;

	reg [15:0] temp1, temp2, temp3, temp4, temp5, temp6, total1, total2;//temporary calculation registers
	reg 	      did_swap;

	reg [7:0] startx, starty, goalx, goaly;
	reg [7:0]  openx [0:num_total_nodes-1];//open list x cord
	reg [7:0]  openy [0:num_total_nodes-1];//open list y cord
	reg [8:0]  opencounter;//count openx/y reg
	reg [7:0]  closex [0:num_total_nodes-1];//close list x cord
	reg [7:0]  closey [0:num_total_nodes-1];//close list y cord
	reg [8:0]  closecounter;//count closex/y reg

	reg [7:0]  currentx; // 当前node的坐标, x-axis
	reg [7:0]  currenty; // 当前node的坐标, y-axis

	integer    i,j;

	reg [7:0]  tempneighborx [7:0]; // 当前node的8个neighbor nodes, x-axis
	reg [7:0]  tempneighbory [7:0]; // 当前node的8个neighbor nodes, y-axis
	reg [3:0]  neighborcounter; // count neighbor node, 用于更新neighbor信息
	reg [19:0]  neighbor_distance_from_start;

	reg [7:0]   checkx;//searches for this in queue
	reg [7:0] 	checky;
	reg [9:0] 	sort_count;//used for sorting

	reg 	    done;

	reg [7:0]  	state;//current state

   
//    这些localparam全是state的名字
   localparam
     INITIALIZE                  = 8'b00000000,
     INITIALIZE_ARRAY            = 8'b00000001,
     CHECK_DONE                  = 8'b00000011,
     VERIFY                      = 8'b00000010,
     QUEUE_MODS                  = 8'b00000_100,
     QUEUE_MODS_SHIFT            = 8'b00000_101,
     QUEUE_MODS_APPEND           = 8'b00000_110,
     SORT_QUEUE                  = 8'b0000_1000,
     BUBBLE_SORT                 = 8'b0000_1001,
     GET_SECOND_DISTANCE         = 8'b0000_1010,
     COMPARE_BETTER              = 8'b0000_1011,
     SWITCH                      = 8'b0000_1100,
     BUBBLE_NEXT                 = 8'b0000_1101,
     COCKTAIL_BACK               = 8'b0000_1110,
     COMPARE_COCKTAIL            = 8'b00_110001,
     COCKTAIL_NEXT               = 8'b00_110000,
     BACK_SWITCH                 = 8'b00_110010,
     SORT_DONE                   = 8'b0000_1111,
     
     CREATE_NEIGHBORS            = 8'b10010000,
     RESET_NEIGHBORS             = 8'b10010001,
     GENERATE_NEIGHBORS          = 8'b10010010,
     NEIGHBOR_CHECK_LOOP         = 8'b10010011,
     CHECK_IF_IN_CLOSED          = 8'b00_100000,
     SEARCH_CLOSED_COMPARE       = 8'b00_100001,
     SEARCH_CLOSED_NEXT          = 8'b00_100010,
     SEARCH_CLOSED_DONE_FOUND    = 8'b00_100011,
     SEARCH_CLOSED_DONE_NOT_FOUND= 8'b00_100100,
     CHECK_IF_IN_OPEN            = 8'b0_1000000,
     SEARCH_OPEN_COMPARE         = 8'b0_1000001,
     SEARCH_OPEN_NEXT            = 8'b0_1000010,
     SEARCH_OPEN_DONE_FOUND      = 8'b0_1000011,
     SEARCH_OPEN_DONE_NOT_FOUND  = 8'b0_1000100,
     CHECK_IF_NEIGHBOR_IS_BETTER = 8'b10000000,
     NEIGHBOR_IS_BETTER          = 8'b11000000,
     RECONSTRUCT                 = 8'b11100000,
     RECONSTRUCT_PLACE            = 8'b11100001,
     RECONSTRUCT_NEXT            = 8'b11100010,
     RECONSTRUCT_FINISH          = 8'b11100011,
//	 FIND_PREVIOUS=8'b11100001,
//	 CHECK_RECONSTRUCT_DONE=8'b11100010,
//	 ASSIGN_NEW=8'b11100011,
     DONE                        = 8'b11111100,
     OUTPUT_PATH                 = 8'b11111110,
     ERROR                       = 8'b11111111,
     DEBUG                       = 8'b11100111,
     DEBUG_DISTANCE              = 8'b11100110;

//    reg [39:0]  map [39:0];
//    reg [39:0] finished_map [39:0];
	reg [7:0]   previousNodeX [board_width_p-1:0] [row_width_lp-1:0];
	reg [7:0]   previousNodeY [board_width_p-1:0] [row_width_lp-1:0];
	// reg [19:0]  distanceFromStart [board_width_p-1:0] [row_width_lp-1:0];
	reg [19:0]  distanceFromStart [num_total_nodes-1:0];

   		    //COPYPASTE FROM OTHER SOURCE
	reg [8:0] 	search_index; //used to iterate through reg
	reg 	    found;
    reg [7:0] finished_path_x [num_total_nodes-1:0];
    reg [7:0] finished_path_y [num_total_nodes-1:0];
    reg [7:0] current_recon_x;
    reg [7:0] current_recon_y;
    
	reg[9:0] recon_counter;
   
   always @ (posedge sync,posedge reset)
     begin
	if(reset)
	  begin
	     state <= INITIALIZE;
	  end
	else
	  begin
	    case(state)
	    	INITIALIZE:
		 	begin
		 		$display("STATE: INITIALIZE");
				$display("start:(%d,%d), goal:(%d,%d)",startx_i, starty_i, goalx_i, goaly_i);
				// $display("check map:%d", map_i);

				//STATE TRANSITION
				state <= INITIALIZE_ARRAY;
		    	//RTL  
				// `include "map2.v" // 这里改成给mem一个Write信号  
				done_o <= 0;
				opencounter <= 9'b000000000;
				closecounter <= 9'b000000000;
				temp1 <= 16'b0;

				startx <= startx_i;
				starty <= starty_i;
				goalx <= goalx_i;
				goaly <= goaly_i;
				// goalx = 8'b00100111;
				// goaly = 8'b00100111;
		    
			end // case: INITIALIZE
	       INITIALIZE_ARRAY:
		 begin
		    // $display("STATE: INITIALIZE ARRAY");
			// $display("temp1:%d",temp1);
		    // STATE TRANSITION
		    if(temp1 == num_total_nodes-1) begin // 如果==399，表示已经完成初始化，跳到下一个state->VERIFY
		      state <= VERIFY;
			  $display("STATE: INITIALIZE ARRAY");
			  $display("temp1:%d",temp1);
			end
		    //RTL
		    // if(temp1 <= row_width_lp) //如果<=39，继续更新每一个node到起点的距离（一行一行更新?）0~39
			distanceFromStart[temp1] = 20'b11111111111111111111;
		    openx[temp1] <= 8'b11111111;
		    openy[temp1] <= 8'b11111111;
		    closex[temp1] <= 8'b11111111;
		    closey[temp1] <= 8'b11111111; // 初始化open和close list, 0~399
			
			opencounter <= 9'b0;
			closecounter <= 9'b0;
		    
		    // distanceFromStart[startx*row_width_lp+starty] = 0; // 因为默认起点在（0，0）所以start0[0]=0
		    temp1 <= temp1+1;
		 end // case: INITIALIZE_ARRAY
	       
	       VERIFY:
		 begin
		    $display("STATE: VERIFY");
			$display("start:(%d,%d), goal:(%d,%d)",startx_i, starty_i, goalx_i, goaly_i);
			distanceFromStart[startx*row_width_lp+starty] = 0; // 因为默认起点在（0，0）所以start0[0]=0
		    //TRANSITION LOGIC
		    //if(map[0] == 40'b0000000000000000000000000000000000000001)
		    if(map_i[startx*row_width_lp+starty]) // 检查起点是不是ob,如果是就直接报错，结束
		      state <= ERROR;
		    else if(map_i[goalx*row_width_lp+goaly]) // 检查终点是不是ob，如果是就直接报错，结束
		      state <= ERROR;
		    else
		      state <= CHECK_DONE;
		    //RTL
		    openx[0] <= startx; // 如果起点终点都不是ob, 那么把起点放进open list里面。这里默认（0，0）是起点
		    openy[0] <= starty;
		    opencounter <= opencounter + 1; // opencounter是一个pointer指向刚放进去的node，表示这个list里有多少个node
		 end // case: VERIFY

			ERROR:
			begin
				$display("ERROR! start/goal node is in OBSTACLE!!!");
				$display(map_i[startx*row_width_lp+starty],map_i[goalx*row_width_lp+goaly]);
				state <= DONE;
			end


	       CHECK_DONE:
		 begin
//`include "displaygrid.v"
		    $display("STATE: CHECK DONE");
		    $display("Open: %d,%d", openx[0],openy[0]);
		    //TRANSITION LOGIC
		    if(openx[0] == goalx && openy[0] == goaly) // 检查open list第一个node是不是等于goal,如果是，就直接结束。进入下一个state->重建
		      state <= RECONSTRUCT;
		    else if(openx[0] == 8'b11111111 && openy[0] == 8'b11111111) begin // 如果open list第一个node是FF表示list里的所有node都已经pop out了，找不到goal。直接fail
		      state <= DONE;
			  $display("FAIL TO FIND THE PATH!!!");
			end
		    else state <= QUEUE_MODS;
		 end // case: CHECK_DONE
	       QUEUE_MODS:
		 begin
		    $display("STATE: QUEUE MODS");
			$display("Close size: %d" , closecounter);
		    //STATE TRANSITION
		    state <= QUEUE_MODS_SHIFT;
		    //RTL
		    currentx <= openx[0]; // 现在把open list中新加进来的node作为当前节点
		    currenty <= openy[0];
		    closex[closecounter] <= openx[0]; // 把open list中的best node放进close list中
		    closey[closecounter] <= openy[0];
		    closecounter <= closecounter + 1; // close list中增加了一个node, counter+1
		    opencounter <= opencounter - 1; // 准备把open list中最前面的一个node pop out,所以counter先-1
		    temp1 <= 0; // temp1为下一个state做准备
		 end // case: QUEUE_MODS
	       QUEUE_MODS_SHIFT:
		 begin
		    //$display("STATE: QUEUE MODS SHIFT");
		    //STATE TRANSITION
		    if(temp1 == num_total_nodes-2)//equals to 398
		      state <= QUEUE_MODS_APPEND;
		    //RTL
		    openx[temp1] <= openx[temp1+1]; // 遍历open list中全部node,所有node前进一位，即pop out一个node
		    openy[temp1] <= openy[temp1+1]; // open[0] <= open[1], open[1] <= open[2] (这里可不可以用一串shift reg替代呢？现在这种写法需要循环太多遍了)
		    temp1 <= temp1 +1;
		 end // case: QUEUE_MODS_SHIFT
	       QUEUE_MODS_APPEND:
		 begin
		    $display("STATE: QUEUE MODS APPEND");
		    //STATE TRANSITION
		    state <= SORT_QUEUE; // 这个state在sort_standalone里面
		    //RTL
		    openx[num_total_nodes-1] <= 8'b11111111; // 全部往前移动一位之后，open list最后一位设置为初始值，表示‘空’
		    openy[num_total_nodes-1] <= 8'b11111111;
		 end // case: QUEUE_MODS_APPEND

	       CREATE_NEIGHBORS:
		 begin
		    $display("STATE: CREATE NEIGHBORS");
		    //STATE TRANSITIONS
		    state <= RESET_NEIGHBORS;
		    //RTL
		    neighborcounter <= 3'b0;
		 end
	       RESET_NEIGHBORS:
		 begin
		    $display("STATE: RESET NEIGHBORS");
		    //STATE TRANSITIONS
		    if(neighborcounter == 3'b111) // ==9 overflow了，表示以及更新完tempneighbor list里的所有neighbor nodes坐标信息，move on to next state
		      state <= GENERATE_NEIGHBORS;
		    //RTL
		    tempneighborx[neighborcounter] <= 8'b11111111; // 将所有neighbor node坐标初始化
		    tempneighbory[neighborcounter] <= 8'b11111111;
		    neighborcounter <= neighborcounter + 1; // 下一个neighbor
		 end // case: RESET_NEIGHBORS
	       GENERATE_NEIGHBORS:
		 begin
		 $display("STATE: GENERATE NEIGHBORS");
		    //0 - NW
		    //1 - N
		    //2 - NE
		    //3 - E
		    //4 - SE
		    //5 - S
		    //6 - SW
		    //7 - W
		    //STATE TRANSITION
		    state <= NEIGHBOR_CHECK_LOOP;
		    //RTL
		    if(currentx != 0 && currenty != 0)//NW
		      begin
			 tempneighborx[0] <= currentx-1;
			 tempneighbory[0] <= currenty-1;
		      end
		    else
		      begin
			 tempneighborx[0] <= 8'b11111111;
			 tempneighbory[0] <= 8'b11111111;
		      end
		    if(currenty != 0)//N
		      begin
			 tempneighborx[1] <= currentx;
			 tempneighbory[1] <= currenty-1;
		      end
		    else
		      begin
			 tempneighborx[1] <= 8'b11111111;
			 tempneighbory[1] <= 8'b11111111;
		      end
		    if(currentx != 8'b00100111 && currenty != 0)//NE
		      begin
			 tempneighborx[2] <= currentx + 1;
			 tempneighbory[2] <= currenty -1;
		      end
		    else
		      begin
			 tempneighborx[2] <= 8'b11111111;
			 tempneighbory[2] <= 8'b11111111;
		      end
		    if(currentx != 8'b00100111)//E
		      begin
			 tempneighborx[3] <= currentx + 1;
			 tempneighbory[3] <= currenty;
		      end
		    else
		      begin
			 tempneighborx[3] <= 8'b11111111;
			 tempneighbory[3] <= 8'b11111111;
		      end
		    if(currentx != 8'b00100111 && currenty != 8'b00100111)//SE
		      begin
			 tempneighborx[4] <= currentx + 1;
			 tempneighbory[4] <= currenty + 1;
		      end
		    else
		      begin
			 tempneighborx[4] <= 8'b11111111;
			 tempneighbory[4] <= 8'b11111111;
		      end
		    if(currenty != 8'b00100111)//S
		      begin
			 tempneighborx[5] <= currentx;
			 tempneighbory[5] <= currenty + 1;
		      end
		    else
		      begin
			 tempneighborx[5] <= 8'b11111111;
			 tempneighbory[5] <= 8'b11111111;
		      end
		    if(currentx != 8'b0 && currenty != 8'b00100111)
		      begin
			 tempneighborx[6] <= currentx -1;
			 tempneighbory[6] <= currenty + 1;
		      end
		    else
		      begin
			 tempneighborx[6] <= 8'b11111111;
			 tempneighbory[6] <= 8'b11111111;
		      end
		    if(currentx != 8'b0)//W
		      begin
			 tempneighborx[7] <= currentx - 1;
			 tempneighbory[7] <= currenty;
		      end
		    else
		      begin
			 tempneighborx[7] <= 8'b11111111;
			 tempneighbory[7] <= 8'b11111111;
		      end
			  
			  neighborcounter <= 4'b0;
		 end // case: GENERATE_NEIGHBORS
	       NEIGHBOR_CHECK_LOOP:
		 begin	   
		    $display("STATE: NEIGHBOR CHECK LOOP");
   		    if(tempneighborx[neighborcounter] != 8'b11111111 && tempneighbory[neighborcounter] != 8'b11111111 && map_i[tempneighbory[neighborcounter]*row_width_lp+tempneighborx[neighborcounter]] != 1'b1)//exists and is not obstacle
		      begin // 当前counter指向的neighbor node存在，且不是ob
		    	$display("Checking %d,%d", tempneighborx[neighborcounter],tempneighbory[neighborcounter]);
		        $display("NeighborCounter: %d",neighborcounter);
		        state <= CHECK_IF_IN_CLOSED; // 在close list里搜索
		        checkx = tempneighborx[neighborcounter];
			 	checky = tempneighbory[neighborcounter];
			 //HARDCODING!!!
				if(tempneighborx[neighborcounter] == goalx && tempneighbory[neighborcounter] == goaly) // 如果neighbor == goal
				begin
					state <= RECONSTRUCT;
					previousNodeX[goalx][goaly] = currentx; // 因为默认终点是（39，39），
					previousNodeY[goalx][goaly] = currenty;
				end
				// `include "generate_neighbor_distance_from_start.v" //计算当前neighbor count指向的neighbor node到起点的距离
				$display("Current distance from start: %d",distanceFromStart[currentx*row_width_lp+currenty]);
				$display("Current position: %d,%d", currentx, currenty);
				$display("Neighbor position: %d,%d", tempneighborx[neighborcounter], tempneighbory[neighborcounter]);
				neighbor_distance_from_start <= distanceFromStart[currentx*row_width_lp+currenty] + (currentx == tempneighborx[neighborcounter] || currenty == tempneighbory[neighborcounter]) ? 1000 : 1414;
		      end
		    else
		      begin 
				if(neighborcounter == 4'b0111) // 遍历所有neighbor
			   	state <= CHECK_DONE;
				else
			   	neighborcounter <= neighborcounter + 1;
		      end
		    // neighbor_is_better <= 1'b0; // ?
		 end // case: NEIGHBOR_CHECK_LOOP

			CHECK_IF_IN_CLOSED:
			begin 
				$display("STATE: CHECK_IF_IN_CLOSED");
				$display("NEIGHBORDISTANCE: %d",neighbor_distance_from_start);
				search_index <= 9'b0;
				found <= 1'b0;
				if(closecounter == 0)
				state <= SEARCH_CLOSED_DONE_NOT_FOUND;
				else
				state <= SEARCH_CLOSED_COMPARE;
			end

			SEARCH_CLOSED_COMPARE:
			begin
				//$display("STATE: SEARCH_CLOSED_COMPARE");
				if(closex[search_index] == checkx && closey[search_index] == checky)
				begin
				found <= 1'b1;
				state <= SEARCH_CLOSED_DONE_FOUND; //Go to next section
				end
				else
				begin
				search_index <= search_index + 1;
				state <= SEARCH_CLOSED_NEXT;
				end
			end
			SEARCH_CLOSED_NEXT:
			begin
				//$display("STATE: SEARCH_CLOSED_NEXT");
				if(search_index == closecounter)//equals 399
				begin
				found <=1'b0;
				state <= SEARCH_CLOSED_DONE_NOT_FOUND; // Not found, go to next section
				end
				else
				begin
				state <=SEARCH_CLOSED_COMPARE;
				end
			end // case: NEXT
			SEARCH_CLOSED_DONE_FOUND:
			begin
				state <= NEIGHBOR_CHECK_LOOP;
				$display("STATE: SEARCH_CLOSED_DONE_FOUND");
				neighborcounter <= neighborcounter + 1;
				if(neighborcounter == 4'b0111)
				state <= CHECK_DONE;
			end
			SEARCH_CLOSED_DONE_NOT_FOUND:
			begin
				state <= CHECK_IF_IN_OPEN;

				$display("STATE: SEARCH_CLOSED_DONE_NOT_FOUND");
			end

			CHECK_IF_IN_OPEN:
			begin 
				$display("STATE: CHECK_IF_IN_OPEN");
				search_index <= 9'b0;
				found <= 1'b0;
				
				if(opencounter == 0)
				state <= SEARCH_OPEN_DONE_NOT_FOUND;
				else
				state <= SEARCH_OPEN_COMPARE;
			end

			SEARCH_OPEN_COMPARE:
			begin
						//$display("STATE: SEARCH_OPEN_COMPARE");
				if(openx[search_index] == checkx && openy[search_index] == checky)
				begin
				found <= 1'b1;
				state <= SEARCH_OPEN_DONE_FOUND; //Go to next section
				end
				else
						begin
						search_index <= search_index + 1;
						state <= SEARCH_OPEN_NEXT;
						end
			end
			SEARCH_OPEN_NEXT:
			begin
						//$display("STATE: SEARCH_OPEN_NEXT");
				if(search_index >= opencounter)//equals 399
				begin
				found <=1'b0;
				state <= SEARCH_OPEN_DONE_NOT_FOUND; // Not found, go to next section
				end
						else
						begin
						state <=SEARCH_OPEN_COMPARE;
						end
			end // case: NEXT\
			SEARCH_OPEN_DONE_FOUND:
			begin
				$display("STATE: SEARCH_OPEN_DONE_FOUND");
				state <= CHECK_IF_NEIGHBOR_IS_BETTER;
				
			end
			SEARCH_OPEN_DONE_NOT_FOUND:
			begin
				$display("STATE: SEARCH_OPEN_DONE_NOT_FOUND");
				$display("opencounter size: %d",opencounter);
				state <= NEIGHBOR_IS_BETTER;
				openx[opencounter] <= tempneighborx[neighborcounter];
				openy[opencounter] <= tempneighbory[neighborcounter];
				opencounter <= opencounter + 1;
			end

	       
	       CHECK_IF_NEIGHBOR_IS_BETTER:
		 begin
		    $display("STATE: CHECK IF NEIGHBOR IS BETTER"); // neighbor has shorter distance than current node
			if((distanceFromStart[currentx*row_width_lp+currenty]+ ((currentx == tempneighborx[neighborcounter] || currenty == tempneighbory[neighborcounter]) ? 1000 : 1414)) < distanceFromStart[tempneighborx[neighborcounter]*row_width_lp+tempneighbory[neighborcounter]])
		    	state <= NEIGHBOR_IS_BETTER;
		    else begin 
				if(neighborcounter == 4'b0111) state <= CHECK_DONE;
				neighborcounter <= neighborcounter + 1; 
				state <= NEIGHBOR_CHECK_LOOP;
			end
// 		    case(currentx)
// `include "checkIfNeighborIsBetter.v"
// 		    endcase
		    
		    if(neighborcounter == 4'b0111)
		      state <= CHECK_DONE;
		    
		 end

	      NEIGHBOR_IS_BETTER:
		 begin
		    $display("STATE: NEIGHBOR IS BETTER");
		    $display("Checking neighbor position %d,%d", tempneighborx[neighborcounter], tempneighbory[neighborcounter]);
		    //STATE TRANSITION
		    if(neighborcounter == 4'b0111)
		      state <= CHECK_DONE;
		    else
		      begin
      			neighborcounter <= neighborcounter + 1;
			 	state <= NEIGHBOR_CHECK_LOOP;
		      end
		    
			$display("Setting previous node for 0,0");
			previousNodeX[tempneighborx[neighborcounter]][tempneighbory[neighborcounter]] <= currentx;
			previousNodeY[tempneighborx[neighborcounter]][tempneighbory[neighborcounter]] <= currenty;
			distanceFromStart[tempneighborx[neighborcounter]*row_width_lp+tempneighbory[neighborcounter]] <= neighbor_distance_from_start;
// 			case(tempneighborx[neighborcounter])

// `include "neighborIsBetter.v" // 更新previousNode = current node 和 distancefromStart = better neighbor
		      
// 		    endcase  
		    //if there are no neighbors, be sure to set state to check done
	 		end // case: NEIGHBOR_IS_BETTER

		  DONE:
			begin
				temp1 <= 32'b0;
				if(temp1 != 32'b0)
				//DRAW_MAP:
				for(i = 0; i < row_width_lp; i = i +1 )
				begin
					for( j = 0; j < board_width_p; j = j + 1)
					begin
						if ((i==starty && j==startx) || (i==goaly && j==goalx))
							begin
								$write("N");
							end
						else if(map_i[i*row_width_lp+j] == 1)
							begin
							$write("X");
							end
						else if (finished_map[i][j] == 1)
							begin
							$write("P");
							end
						// else if (currentx == j && currenty == i)
						// 	begin
						// 		$write("A");
						// 	end
						else
							$write("O");
					end
					$write("\n");
				end
				$write("\n\n"); 
				done_o <= 1'b1;
			end


			RECONSTRUCT:
			begin
				$display("STATE: RECONSTRUCT");
				//STATE TRANSITION
				state <= RECONSTRUCT_PLACE;
				//RTL
				currentx <= goalx; // 从终点开始
				currenty <= goaly;
				temp1 <= 32'b0;
			end
			RECONSTRUCT_PLACE:
			begin
			$display("STATE: RECONSTRUCT_PLACE");
			$display("Counter: %d",temp1);
			$display("Current node at %d,%d",currentx,currenty);
				//STATE TRANSITION
				if(currentx == startx && currenty == starty) // 倒推至起点
				state <= RECONSTRUCT_FINISH;
				else
				state <= RECONSTRUCT_NEXT;
				
				//RTL
				finished_path_x[temp1] <= currentx; // 最终path存在finished_path里面
				finished_path_y[temp1] <= currenty;
				temp1 <= temp1 + 1;
			end
			RECONSTRUCT_NEXT:
			begin
				$display("STATE: RECONSTRUCT_NEXT");
				state <= RECONSTRUCT_PLACE;
				$display("Previous node: %d,%d",previousNodeX[currentx][currenty],previousNodeY[currentx][currenty]);
				currentx <= previousNodeX[currentx][currenty];
				currenty <= previousNodeY[currentx][currenty];
			// `include "roy_reconstruct_helper.v" // 根据current node反推previous node, 并更新current node
			end
			RECONSTRUCT_FINISH:
			begin
			$display("RECONSTRUCT_FINISH");
			$display("Took %d nodes to reach destination",temp1);
			state <= DONE;
			for(i = 0; i < temp1; i = i + 1)
				finished_map[finished_path_y[i]][finished_path_x[i]] <= 1;
			end

			SORT_QUEUE:
			begin
				$display("STATE: SORT_QUEUE");
				state <= BUBBLE_SORT;
				sort_count = 10'b0; // sort count初始化
				did_swap <= 1'b0; //重置swap
				done <= 1'b0;
			end


			//GET FIRST, DISTANCE
			BUBBLE_SORT:
			begin
				total1 <= (1414 * ((openx[sort_count] - goalx < openy[sort_count] - goaly)?openy[sort_count]-goaly:openx[sort_count]-goalx) + (((openy[sort_count] - goaly < 0)? -1*(openy[sort_count]-goaly):openy[sort_count]-goaly) + ((openx[sort_count]-goalx < 0)? -1 *(openx[sort_count]-goalx):openx[sort_count]-goalx) - 2 * ((openx[sort_count] - goalx < openy[sort_count] - goaly)?openy[sort_count]-goaly:openx[sort_count]-goalx))) + distanceFromStart[openx[sort_count]*row_width_lp+openy[sort_count]];
				total2 <= (1414 * ((openx[sort_count+1] - goalx < openy[sort_count + 1] - goaly)?openy[sort_count + 1]-goaly:openx[sort_count + 1]-goalx) + (((openy[sort_count + 1] - goaly < 0)? -1*(openy[sort_count + 1]-goaly):openy[sort_count + 1]-goaly) + ((openx[sort_count + 1]-goalx < 0)? -1 *(openx[sort_count + 1]-goalx):openx[sort_count + 1]-goalx) - 2 * ((openx[sort_count + 1] - goalx < openy[sort_count + 1] - goaly)?openy[sort_count + 1]-goaly:openx[sort_count + 1]-goalx))) + distanceFromStart[openx[sort_count+1]*row_width_lp+openy[sort_count+1]];
				state <= COMPARE_BETTER;
			end // case: BUBBLE_SORT

			COMPARE_BETTER:
			begin
				// $display("STATE: COMPARE_BETTER");
				
			//$display("TOTAL 2 = %d ; TOTAL 1 = %d", total2, total1);	
				if(total2 > total1) //如果说2nd node's cost小于 1st node's cost, 两个node需要交换
				state <= SWITCH;
				else
				state <= BUBBLE_NEXT;
			end

			SWITCH:
			begin
				//$display("STATE: SWITCH");
				did_swap <= 1'b1;
				openx[sort_count] <= openx[sort_count+1];
				openx[sort_count+1] <= openx[sort_count]; // 同时运行，当前node和后一个node交换
				openy[sort_count] <= openy[sort_count+1];
				openy[sort_count+1] <= openy[sort_count];
				state <= BUBBLE_NEXT;
			end

			BUBBLE_NEXT:
			begin
				//$display("STATE: BUBBLE_NEXT");
				if(sort_count >= opencounter && did_swap == 1'b1) // 到底了，并且最后一个node是swap过的
				begin
					sort_count <= sort_count - 1; // sort count指向倒数第二个node
					did_swap <= 1'b0;
					total1 <= 0;
					total2 <= 0;
					state <= COCKTAIL_BACK;
				end
				
				if(sort_count >= opencounter && did_swap == 1'b0) //到底了，并且最后一个node没有swap过的。最后一个数一定是最小的？
				begin
					sort_count <= 0;
					state <= SORT_DONE;//go to next stage here
				end
				
				if(sort_count < opencounter) // 还没sort完，move on to next one
				begin
					sort_count <= sort_count + 1;
					state <= BUBBLE_SORT; //循环
					total1 <= 0;
					total2 <= 0;
				end
			end // case: BUBBLE_NEXT
			COCKTAIL_BACK:
			begin
				total1 <= (1414 * ((openx[sort_count] - goalx < openy[sort_count] - goaly)?openy[sort_count]-goaly:openx[sort_count]-goalx) + (((openy[sort_count] - goaly < 0)? -1*(openy[sort_count]-goaly):openy[sort_count]-goaly) + ((openx[sort_count]-goalx < 0)? -1 *(openx[sort_count]-goalx):openx[sort_count]-goalx) - 2 * ((openx[sort_count] - goalx < openy[sort_count] - goaly)?openy[sort_count]-goaly:openx[sort_count]-goalx))) + distanceFromStart[openx[sort_count]*row_width_lp+openy[sort_count]];
				total2 <= (1414 * ((openx[sort_count+1] - goalx < openy[sort_count + 1] - goaly)?openy[sort_count + 1]-goaly:openx[sort_count + 1]-goalx) + (((openy[sort_count + 1] - goaly < 0)? -1*(openy[sort_count + 1]-goaly):openy[sort_count + 1]-goaly) + ((openx[sort_count + 1]-goalx < 0)? -1 *(openx[sort_count + 1]-goalx):openx[sort_count + 1]-goalx) - 2 * ((openx[sort_count + 1] - goalx < openy[sort_count + 1] - goaly)?openy[sort_count + 1]-goaly:openx[sort_count + 1]-goalx))) + distanceFromStart[openx[sort_count+1]*row_width_lp+openy[sort_count+1]];
				state <= COMPARE_COCKTAIL;
			end
			COMPARE_COCKTAIL:
			begin
				if(total2 > total1) // 如果最后一个node 大于 倒数第二个node
				state <= BACK_SWITCH;
				else
				state <= COCKTAIL_NEXT;
			end
			BACK_SWITCH:
			begin
				//$display("STATE: SWITCH");
				did_swap <= 1'b1;
				openx[sort_count] <= openx[sort_count+1];
				openx[sort_count+1] <= openx[sort_count];
				openy[sort_count] <= openy[sort_count+1];
				openy[sort_count+1] <= openy[sort_count];
				state <= COCKTAIL_NEXT;
			end
			COCKTAIL_NEXT:
			begin
				//$display("STATE: BUBBLE_NEXT");
				if(sort_count <= 0 && did_swap == 1'b1)
				begin
					sort_count <= sort_count + 1;
					did_swap <= 1'b0;
					total1 <= 0;
					total2 <= 0;
					state <= BUBBLE_SORT;
				end
				
				if(sort_count <= 0 && did_swap == 1'b0)
				begin
					sort_count <= 0;
					state <= SORT_DONE;//go to next stage here
				end
				
				if(sort_count > 0)
				begin
					sort_count <= sort_count - 1;
					state <= COCKTAIL_BACK;
					total1 <= 0;
					total2 <= 0;
				end
			end 
			SORT_DONE: // 最后得到排列好的open list
			begin
				$display("STATE: SORT_DONE");
					done <= 1'b1;
				state <= CREATE_NEIGHBORS;
			end

	       
	     endcase // case (state)
	  end // else: !if(reset)
     end // always @ (posedge sync,posedge reset)


   endmodule;