// SORT_QUEUE:
//   begin
//      $display("STATE: SORT_QUEUE");
//      state <= BUBBLE_SORT;
//      sort_count = 10'b0; // sort count初始化
//      did_swap <= 1'b0; //重置swap
//      done <= 1'b0;
//   end


// //GET FIRST, DISTANCE
// BUBBLE_SORT:
//   begin
//     total1 <= (1414 * ((openx[sort_count] - goalx < openy[sort_count] - goaly)?openy[sort_count]-goaly:openx[sort_count]-goalx) + (((openy[sort_count] - goaly < 0)? -1*(openy[sort_count]-goaly):openy[sort_count]-goaly) + ((openx[sort_count]-goalx < 0)? -1 *(openx[sort_count]-goalx):openx[sort_count]-goalx) - 2 * ((openx[sort_count] - goalx < openy[sort_count] - goaly)?openy[sort_count]-goaly:openx[sort_count]-goalx))) + distanceFromStart[openx[sort_count]*row_width_lp+openy[sort_count]];
//     total2 <= (1414 * ((openx[sort_count+1] - goalx < openy[sort_count + 1] - goaly)?openy[sort_count + 1]-goaly:openx[sort_count + 1]-goalx) + (((openy[sort_count + 1] - goaly < 0)? -1*(openy[sort_count + 1]-goaly):openy[sort_count + 1]-goaly) + ((openx[sort_count + 1]-goalx < 0)? -1 *(openx[sort_count + 1]-goalx):openx[sort_count + 1]-goalx) - 2 * ((openx[sort_count + 1] - goalx < openy[sort_count + 1] - goaly)?openy[sort_count + 1]-goaly:openx[sort_count + 1]-goalx))) + distanceFromStart[openx[sort_count+1]*row_width_lp+openy[sort_count+1]];
//     state <= COMPARE_BETTER;
//   end // case: BUBBLE_SORT

// COMPARE_BETTER:
//   begin
//      // $display("STATE: COMPARE_BETTER");
	 
// //$display("TOTAL 2 = %d ; TOTAL 1 = %d", total2, total1);	
//      if(total2 > total1) //如果说2nd node's cost小于 1st node's cost, 两个node需要交换
//        state <= SWITCH;
//      else
//        state <= BUBBLE_NEXT;
//   end

// SWITCH:
//   begin
//      //$display("STATE: SWITCH");
//      did_swap <= 1'b1;
//      openx[sort_count] <= openx[sort_count+1];
//      openx[sort_count+1] <= openx[sort_count]; // 同时运行，当前node和后一个node交换
//      openy[sort_count] <= openy[sort_count+1];
//      openy[sort_count+1] <= openy[sort_count];
//      state <= BUBBLE_NEXT;
//   end

// BUBBLE_NEXT:
//   begin
//      //$display("STATE: BUBBLE_NEXT");
//      if(sort_count >= opencounter && did_swap == 1'b1) // 到底了，并且最后一个node是swap过的
//        begin
//         sort_count <= sort_count - 1; // sort count指向倒数第二个node
//         did_swap <= 1'b0;
//         total1 <= 0;
//         total2 <= 0;
//         state <= COCKTAIL_BACK;
//        end
     
//      if(sort_count >= opencounter && did_swap == 1'b0) //到底了，并且最后一个node没有swap过的。最后一个数一定是最小的？
//        begin
//         sort_count <= 0;
//         state <= SORT_DONE;//go to next stage here
//        end
     
//      if(sort_count < opencounter) // 还没sort完，move on to next one
//        begin
//         sort_count <= sort_count + 1;
//         state <= BUBBLE_SORT; //循环
//         total1 <= 0;
//         total2 <= 0;
//        end
//   end // case: BUBBLE_NEXT
// COCKTAIL_BACK:
//   begin
//     total1 <= (1414 * ((openx[sort_count] - goalx < openy[sort_count] - goaly)?openy[sort_count]-goaly:openx[sort_count]-goalx) + (((openy[sort_count] - goaly < 0)? -1*(openy[sort_count]-goaly):openy[sort_count]-goaly) + ((openx[sort_count]-goalx < 0)? -1 *(openx[sort_count]-goalx):openx[sort_count]-goalx) - 2 * ((openx[sort_count] - goalx < openy[sort_count] - goaly)?openy[sort_count]-goaly:openx[sort_count]-goalx))) + distanceFromStart[openx[sort_count]*row_width_lp+openy[sort_count]];
//     total2 <= (1414 * ((openx[sort_count+1] - goalx < openy[sort_count + 1] - goaly)?openy[sort_count + 1]-goaly:openx[sort_count + 1]-goalx) + (((openy[sort_count + 1] - goaly < 0)? -1*(openy[sort_count + 1]-goaly):openy[sort_count + 1]-goaly) + ((openx[sort_count + 1]-goalx < 0)? -1 *(openx[sort_count + 1]-goalx):openx[sort_count + 1]-goalx) - 2 * ((openx[sort_count + 1] - goalx < openy[sort_count + 1] - goaly)?openy[sort_count + 1]-goaly:openx[sort_count + 1]-goalx))) + distanceFromStart[openx[sort_count+1]*row_width_lp+openy[sort_count+1]];
//     state <= COMPARE_COCKTAIL;
//   end
// COMPARE_COCKTAIL:
//   begin
//      if(total2 > total1) // 如果最后一个node 大于 倒数第二个node
//        state <= BACK_SWITCH;
//      else
//        state <= COCKTAIL_NEXT;
//   end
// BACK_SWITCH:
//   begin
//      //$display("STATE: SWITCH");
//      did_swap <= 1'b1;
//      openx[sort_count] <= openx[sort_count+1];
//      openx[sort_count+1] <= openx[sort_count];
//      openy[sort_count] <= openy[sort_count+1];
//      openy[sort_count+1] <= openy[sort_count];
//      state <= COCKTAIL_NEXT;
//   end
// COCKTAIL_NEXT:
//   begin
//      //$display("STATE: BUBBLE_NEXT");
//      if(sort_count <= 0 && did_swap == 1'b1)
//        begin
//         sort_count <= sort_count + 1;
//         did_swap <= 1'b0;
//         total1 <= 0;
//         total2 <= 0;
//         state <= BUBBLE_SORT;
//        end
     
//      if(sort_count <= 0 && did_swap == 1'b0)
//        begin
//         sort_count <= 0;
//         state <= SORT_DONE;//go to next stage here
//        end
     
//      if(sort_count > 0)
//        begin
//         sort_count <= sort_count - 1;
//         state <= COCKTAIL_BACK;
//         total1 <= 0;
//         total2 <= 0;
//        end
//   end 
// SORT_DONE: // 最后得到排列好的open list
//   begin
//      $display("STATE: SORT_DONE");
// 		  done <= 1'b1;
//       state <= CREATE_NEIGHBORS;
//   end