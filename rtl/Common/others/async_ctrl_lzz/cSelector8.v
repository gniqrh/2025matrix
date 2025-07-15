//======================================================
// Project: SOLVA
// Module:  cSelector8
// Author:  zhuangzhuang Liao
// Mail：   lzhuangzhuang2023@lzu.edu.cn
// Date:    2025-05-28
// Description: parameterized 8-input cSelector
//======================================================
 module cSelector8 #(
    parameter DATA_WIDTH=32
) (
    input  wire i_drive,
    input  wire i_freeNext0,i_freeNext1,i_freeNext2,i_freeNext3,
    input  wire i_freeNext4,i_freeNext5,i_freeNext6,i_freeNext7,
    input  wire [DATA_WIDTH+8-1:0] i_data,//!高8位为valid位

    output wire o_free,
    output wire o_driveNext0,o_driveNext1,o_driveNext2,o_driveNext3,
    output wire o_driveNext4,o_driveNext5,o_driveNext6,o_driveNext7,
    output wire [DATA_WIDTH-1:0] o_data0,o_data1,o_data2,o_data3,
    output wire [DATA_WIDTH-1:0] o_data4,o_data5,o_data6,o_data7,

    input wire rstn
);

wire [1:0] w_outRRelay_2,w_outARelay_2;
wire w_fire;
wire w_free_1;
wire w_freeNext;
wire w_driveNext0;

wire [8-1:0] w_valid_8;
reg [DATA_WIDTH-1:0] r_data;
reg [8-1:0] r_valid_8;

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

assign w_valid_8 = i_data[DATA_WIDTH+8-1:DATA_WIDTH];

always @(posedge w_fire or negedge rstn) begin
	if (!rstn) begin
		r_data <= {DATA_WIDTH{1'b0}}; 
		r_valid_8 <= 8'b0;
	end else begin
		r_data <= i_data[DATA_WIDTH-1:0];
		r_valid_8 <= w_valid_8;
	end
end

assign o_data0 = r_data & {DATA_WIDTH{r_valid_8[0]}};
assign o_data1 = r_data & {DATA_WIDTH{r_valid_8[1]}};
assign o_data2 = r_data & {DATA_WIDTH{r_valid_8[2]}};
assign o_data3 = r_data & {DATA_WIDTH{r_valid_8[3]}};
assign o_data4 = r_data & {DATA_WIDTH{r_valid_8[4]}};
assign o_data5 = r_data & {DATA_WIDTH{r_valid_8[5]}};
assign o_data6 = r_data & {DATA_WIDTH{r_valid_8[6]}};
assign o_data7 = r_data & {DATA_WIDTH{r_valid_8[7]}};

//control signal
(* dont_touch="true" *)delay1U outdelay2_donttouch (.inR(w_free_1), .outR(o_free), .rstn(rstn));
delay8U outdelay0_donttouch(.inR(w_fire), .outR(w_driveNext0),.rstn(rstn));
assign o_driveNext0 = w_driveNext0 & r_valid_8[0];
assign o_driveNext1 = w_driveNext0 & r_valid_8[1];
assign o_driveNext2 = w_driveNext0 & r_valid_8[2];
assign o_driveNext3 = w_driveNext0 & r_valid_8[3];
assign o_driveNext4 = w_driveNext0 & r_valid_8[4];
assign o_driveNext5 = w_driveNext0 & r_valid_8[5];
assign o_driveNext6 = w_driveNext0 & r_valid_8[6];
assign o_driveNext7 = w_driveNext0 & r_valid_8[7];
assign w_freeNext = i_freeNext0 | i_freeNext1 | i_freeNext2 | i_freeNext3 |i_freeNext4|i_freeNext5|i_freeNext6|i_freeNext7;

 endmodule