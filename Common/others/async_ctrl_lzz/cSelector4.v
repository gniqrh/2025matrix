//======================================================
// Project: SOLVA
// Module:  cSelector4
// Author:  zhuangzhuang Liao
// Mail：   lzhuangzhuang2023@lzu.edu.cn
// Date:    2025-05-28
// Description: parameterized 4-input cSelector
//======================================================
`timescale 1ns / 1ps

module cSelector4 #(
    parameter DATA_WIDTH=32
) (
    input  wire i_drive,
    input  wire i_freeNext0,i_freeNext1,i_freeNext2,i_freeNext3,
    input  wire [DATA_WIDTH+4-1:0] i_data,//!高4位为valid位

    output wire o_free,
    output wire o_driveNext0,o_driveNext1,o_driveNext2,o_driveNext3,
    output wire [DATA_WIDTH-1:0] o_data0,o_data1,o_data2,o_data3,

    input wire rstn
);

wire [1:0] w_outRRelay_2,w_outARelay_2;
wire w_fire;
wire w_free_1;
wire w_freeNext;
wire w_driveNext0;

wire [4-1:0] w_valid_4;
reg [DATA_WIDTH-1:0] r_data;
reg [4-1:0] r_valid_4;

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

assign w_valid_4 = i_data[DATA_WIDTH+4-1:DATA_WIDTH];

always @(posedge w_fire or negedge rstn) begin
	if (!rstn) begin
		r_data <= {DATA_WIDTH{1'b0}}; 
		r_valid_4 <= 4'b0;
	end else begin
		r_data <= i_data[DATA_WIDTH-1:0];
		r_valid_4 <= w_valid_4;
	end
end

assign o_data0 = r_data & {DATA_WIDTH{r_valid_4[0]}};
assign o_data1 = r_data & {DATA_WIDTH{r_valid_4[1]}};
assign o_data2 = r_data & {DATA_WIDTH{r_valid_4[2]}};
assign o_data3 = r_data & {DATA_WIDTH{r_valid_4[3]}};

//control signal
(* dont_touch="true" *)delay1U outdelay2_donttouch (.inR(w_free_1), .outR(o_free), .rstn(rstn));
delay8U outdelay0_donttouch(.inR(w_fire), .outR(w_driveNext0),.rstn(rstn));
assign o_driveNext0 = w_driveNext0 & r_valid_4[0];
assign o_driveNext1 = w_driveNext0 & r_valid_4[1];
assign o_driveNext2 = w_driveNext0 & r_valid_4[2];
assign o_driveNext3 = w_driveNext0 & r_valid_4[3];
assign w_freeNext = i_freeNext0 | i_freeNext1 | i_freeNext2 | i_freeNext3;

endmodule

