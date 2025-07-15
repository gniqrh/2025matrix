//======================================================
// Project: SOLVA
// Module:  cSelector2
// Author:  longtao zhang , zhuangzhuang Liao
// Mail：   lzhuangzhuang2023@lzu.edu.cn
// Date:    2025-05-28
// Description: parameterized two-input cSelector
//======================================================

`timescale 1ns / 1ps

module cSelector2 #(
    parameter DATA_WIDTH=32,
	parameter DELAY_NUMS = 7,//wider data_width, bigger nums
	parameter DELAY_OFREE = 1//wider data_width, bigger nums
) (
    input  wire i_drive,
    input  wire i_freeNext0,i_freeNext1,
    input  wire [DATA_WIDTH+2-1:0] i_data,//!高4位为valid位

    output wire o_free,
    output wire o_driveNext0,o_driveNext1,
    output wire [DATA_WIDTH-1:0] o_data0,o_data1,
    input wire rstn
);

wire [1:0] w_outRRelay_2,w_outARelay_2;
wire w_fire;
wire w_free_1;
wire w_freeNext;
wire w_driveNext0;

wire [2-1:0] w_valid_2;
reg [DATA_WIDTH-1:0] r_data;
reg [2-1:0] r_valid_2;

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

assign w_valid_2 = i_data[DATA_WIDTH+2-1:DATA_WIDTH];

always @(posedge w_fire or negedge rstn) begin
	if (!rstn) begin
		r_data <= {DATA_WIDTH{1'b0}}; 
		r_valid_2 <= 2'b0;
	end else begin
		r_data <= i_data[DATA_WIDTH-1:0];
		r_valid_2 <= w_valid_2;
	end
end

assign o_data0 = r_data & {DATA_WIDTH{r_valid_2[0]}};
assign o_data1 = r_data & {DATA_WIDTH{r_valid_2[1]}};

//control signal
freeSetDelay#(
    .DELAY_UNIT_NUM ( DELAY_OFREE )
)delay_ofree(
    .i_signal ( w_free_1 ),
    .o_signal ( o_free ),
    .rstn     ( rstn )
);
freeSetDelay#(
    .DELAY_UNIT_NUM ( DELAY_NUMS )
)u_freeSetDelay(
    .i_signal ( w_fire ),
    .o_signal ( w_driveNext0 ),
    .rstn     ( rstn )
);
assign o_driveNext0 = w_driveNext0 & r_valid_2[0];
assign o_driveNext1 = w_driveNext0 & r_valid_2[1];

assign w_freeNext = i_freeNext0 | i_freeNext1;
endmodule

