// RECONSTRUCT:
//   begin
//     $display("STATE: RECONSTRUCT");
//     $display("39 39: %d,%d",previousNodeX[39*row_width_lp+39],previousNodeY[39*row_width_lp+39]);
//     $display("39 38: %d,%d",previousNodeX[39*row_width_lp+38],previousNodeY[39*row_width_lp+38]);
//     $display("38 39: %d,%d",previousNodeX[38*row_width_lp+39],previousNodeY[38*row_width_lp+39]);
//     $display("38 38: %d,%d",previousNodeX[38*row_width_lp+38],previousNodeY[38*row_width_lp+38]);
//     $display("38 37: %d,%d",previousNodeX[38*row_width_lp+37],previousNodeY[38*row_width_lp+37]);
// 	 //STATE TRANSITION
// 	  state <= RECONSTRUCT_PLACE;
// 	 //RTL
//     currentx <= goalx; // 从终点开始
//     currenty <= goaly;
//     temp1 <= 32'b0;
//   end
// RECONSTRUCT_PLACE:
//   begin
//   $display("STATE: RECONSTRUCT_PLACE");
//   $display("Counter: %d",temp1);
//   $display("Current node at %d,%d",currentx,currenty);
//      //STATE TRANSITION
//      if(currentx == startx && currenty == starty) // 倒推至起点
//        state <= RECONSTRUCT_FINISH;
//      else
//        state <= RECONSTRUCT_NEXT;
     
//      //RTL
//      finished_path_x[temp1] <= currentx; // 最终path存在finished_path里面
//      finished_path_y[temp1] <= currenty;
// 	 temp1 <= temp1 + 1;
//   end
// RECONSTRUCT_NEXT:
//   begin
//       $display("STATE: RECONSTRUCT_NEXT");
//       state <= RECONSTRUCT_PLACE;
//       $display("Previous node: %d,%d",previousNodeX[currentx*row_width_lp+currenty],previousNodeY[currentx*row_width_lp+currenty]);
//       currentx <= previousNodeX[currentx*row_width_lp+currenty];
//       currenty <= previousNodeY[currentx*row_width_lp+currenty];
// // `include "roy_reconstruct_helper.v" // 根据current node反推previous node, 并更新current node
//   end
// RECONSTRUCT_FINISH:
//   begin
//   $display("RECONSTRUCT_FINISH");
//   $display("Took %d nodes to reach destination",temp1);
//      state <= DONE;

// 	 for(i = 0; i < temp1; i = i + 1)
// 			finished_map[finished_path_y[i]][finished_path_x[i]] = 1;
//   end
