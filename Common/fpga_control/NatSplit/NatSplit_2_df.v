//======================================================
// Project:        RCA
// Module:         NatSplit_2_df
// Author:         YiHua Lu
// Date:           2025/06/18
// Description:    无条件分支;带数据版;对数据做持久化处理
//                 测试值：32bit，6ns左右
//======================================================

`timescale 1ns / 1ps

module NatSplit_2_df#(
    parameter DATA_WIDTH = 32
)(
    input  wire i_drive,
    input  wire i_freeNext0,i_freeNext1,
    input  wire [DATA_WIDTH-1:0] i_data,

    output wire o_free,
    output wire o_driveNext0,o_driveNext1,
    output wire [DATA_WIDTH-1:0] o_data0,
    output wire [DATA_WIDTH-1:0] o_data1,

    input wire rst
);

wire [1:0] w_outRRelay_2,w_outARelay_2;
wire w_fire;
wire w_freeNext;
wire w_driveNext0;
wire [2-1:0] w_valid_2;
reg [DATA_WIDTH-1:0] r_data;
reg [2-1:0] r_valid_2;

sender sender(
    .i_drive(i_drive),
    .o_free(),
    .outR(w_outRRelay_2[0]),
    .i_free(w_fire),
    .rst(rst)
);

relay relay0(
    .inR(w_outRRelay_2[0]),
    .inA(w_outARelay_2[0]),
    .outR(w_outRRelay_2[1]),
    .outA(w_outARelay_2[1]),
    .fire(w_fire),
    .rst(rst)
);

receiver receiver(
    .inR(w_outRRelay_2[1]),
    .inA(w_outARelay_2[1]),
    .i_freeNext(w_freeNext),
    .rst(rst)
);

always @(posedge w_fire or negedge rst) begin
    if (!rst) begin
        r_data <= {DATA_WIDTH{1'b0}};
    end
    else begin
        r_data <= i_data;
    end
end

delay1U outdelay2 (.inR(w_freeNext), .outR(o_free), .rst(rst));
delay2U outdelay0 (.inR(i_drive), .outR(w_driveNext0),.rst(rst));
assign o_driveNext0 = w_driveNext0;
assign o_driveNext1 = w_driveNext0;
assign o_data0 = r_data;
assign o_data1 = r_data;
assign w_freeNext = i_freeNext0 | i_freeNext1;

endmodule

