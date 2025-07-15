//===============================================================================
// Project:        RCA
// Module:         SelSplit_2_d
// Author:         YiHua Lu
// Date:           2025/06/18
// Description:    有条件分支;带数据版;把数据和控制位分开;
//                 对数据不做持久化处理;
//                 测试值：1ns即可传递
//===============================================================================
`timescale 1ns / 1ps

module SelSplit_2_d#(
    parameter DATA_WIDTH=32
) (
    input  wire i_drive,
    input  wire i_freeNext0,i_freeNext1,

    input  valid0,
    input  valid1,
    input  wire [DATA_WIDTH-1:0] i_data,

    output wire o_free,
    output wire o_driveNext0,o_driveNext1,

    output wire [DATA_WIDTH-1:0] o_data0,o_data1,

    input wire rst
);

(*dont_touch = "yes"*)wire w_sendFree;
(*dont_touch = "yes"*)wire w_d_sendFree;
(*dont_touch = "yes"*)wire w_firstReq;
(*dont_touch = "yes"*)wire w_secondReq;
(*dont_touch = "yes"*)wire w_dirveReq;
(*dont_touch = "yes"*)wire w_andReq;
wire w_d_andReq;

assign w_andReq = (w_firstReq|~valid0) & (w_secondReq|~valid1);
assign w_sendFree = w_dirveReq & w_andReq;

delay2U delay_dandreq (.inR(w_andReq), .outR(w_d_andReq), .rst(rst));
delay1U delay_sendFree (.inR(w_sendFree), .outR(w_d_sendFree), .rst(rst));
delay1U delayDSendfree (.inR(w_d_sendFree), .outR(o_free), .rst(rst));

assign o_data0 = i_data;
assign o_data1 = i_data;

contTap driveTap(
    .trig((i_drive&(~w_dirveReq)) | w_d_andReq),
    .req(w_dirveReq),
    .rst(rst)
); 

contTap firstTap(
    .trig((i_freeNext0&(~w_firstReq)) | w_d_sendFree),
    .req(w_firstReq),
    .rst(rst)
);

contTap secondTap(
    .trig((i_freeNext1&(~w_secondReq)) | w_d_sendFree),
    .req(w_secondReq),
    .rst(rst)
);

delay1U outdelay2 (.inR(w_free_1), .outR(o_free), .rst(rst));

assign o_driveNext0 = i_drive & valid0;
assign o_driveNext1 = i_drive & valid1;

endmodule
