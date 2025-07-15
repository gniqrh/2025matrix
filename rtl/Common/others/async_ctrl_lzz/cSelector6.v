//======================================================
// Project: SOLVA
// Module:  cSelector6
// Author:  zhuangzhuang Liao
// Mail：   lzhuangzhuang2023@lzu.edu.cn
// Date:    2025-05-28
// Description: parameterized 6-input cSelector
//======================================================
`timescale 1ns / 1ps

 module cSelector6 #(
     parameter DATA_WIDTH=32,
     parameter DELAY_NUMS = 1
 ) (
     input  wire i_drive,
     input  wire i_freeNext0,i_freeNext1,i_freeNext2,i_freeNext3,i_freeNext4,i_freeNext5,
     input  wire [DATA_WIDTH+6-1:0] i_data,//!高6位为valid位
 
     output wire o_free,
     output wire o_driveNext0,o_driveNext1,o_driveNext2,o_driveNext3,o_driveNext4,o_driveNext5,
     output wire [DATA_WIDTH-1:0] o_data0,o_data1,o_data2,o_data3,o_data4,o_data5,
 
     input wire rstn
 );
 
 wire [1:0] w_outRRelay_2,w_outARelay_2;
 wire w_fire;
 wire w_free_1;
 wire w_freeNext;
 wire w_driveNext0;
 
 wire [6-1:0] w_valid_6;
 reg [DATA_WIDTH-1:0] r_data;
 reg [6-1:0] r_valid_6;
 
 //pipeline
 sender sender(
     .i_drive(i_drive),
     .o_free(w_free_1),
     .outR(w_outRRelay_2[0]),
     .i_free(w_fire),
     .rstn(rstn)
 );
 
 relay relay0(
     .inR(w_outRRelay_2[0]),
     .inA(w_outARelay_2[0]),
     .outR(w_outRRelay_2[1]),
     .outA(w_outARelay_2[1]),
     .fire(w_fire),
     .rstn(rstn)
 );
 
 receiver receiver(
     .inR(w_outRRelay_2[1]),
     .inA(w_outARelay_2[1]),
     .i_freeNext(w_freeNext),
     .rstn(rstn)
 );
 
 assign w_valid_6 = i_data[DATA_WIDTH+6-1:DATA_WIDTH];
 
 always @(posedge w_fire or negedge rstn) begin
     if (!rstn) begin
         r_data <= {DATA_WIDTH{1'b0}}; 
         r_valid_6 <= 5'b0;
     end else begin
         r_data <= i_data[DATA_WIDTH-1:0];
         r_valid_6 <= w_valid_6;
     end
 end
 
 assign o_data0 = r_data & {DATA_WIDTH{r_valid_6[0]}};
 assign o_data1 = r_data & {DATA_WIDTH{r_valid_6[1]}};
 assign o_data2 = r_data & {DATA_WIDTH{r_valid_6[2]}};
 assign o_data3 = r_data & {DATA_WIDTH{r_valid_6[3]}};
 assign o_data4 = r_data & {DATA_WIDTH{r_valid_6[4]}};
 assign o_data5 = r_data & {DATA_WIDTH{r_valid_6[5]}};
 
 //control signal
 (* dont_touch="true" *)delay1U outdelay2_donttouch (.inR(w_free_1), .outR(o_free), .rstn(rstn));
 freeSetDelay#(
    .DELAY_UNIT_NUM ( DELAY_NUMS )
)u_freeSetDelay(
    .i_signal ( w_fire ),
    .o_signal ( w_driveNext0 ),
    .rstn     ( rstn )
);
 assign o_driveNext0 = w_driveNext0 & r_valid_6[0];
 assign o_driveNext1 = w_driveNext0 & r_valid_6[1];
 assign o_driveNext2 = w_driveNext0 & r_valid_6[2];
 assign o_driveNext3 = w_driveNext0 & r_valid_6[3];
 assign o_driveNext4 = w_driveNext0 & r_valid_6[4];
 assign o_driveNext5 = w_driveNext0 & r_valid_6[5];
 assign w_freeNext = i_freeNext0 | i_freeNext1 | i_freeNext2 | i_freeNext3 | i_freeNext4 | i_freeNext5;
 
 endmodule