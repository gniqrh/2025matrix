//======================================================
// Project:        RCA
// Module:         NatSplit_4
// Author:         YiHua Lu
// Date:           2025/06/22
// Description:    无条件分支;无数据版; 四路输出
//======================================================
`timescale 1ns / 1ps

module NatSplit_4(
    input  wire i_drive,
    input  wire i_freeNext0, i_freeNext1, i_freeNext2, i_freeNext3,

    output wire o_free,
    output wire o_driveNext0, o_driveNext1, o_driveNext2, o_driveNext3,

    input wire rst
);

(*dont_touch = "yes"*)wire w_sendFree;
(*dont_touch = "yes"*)wire w_d_sendFree;
(*dont_touch = "yes"*)wire w_driveReq;
(*dont_touch = "yes"*)wire w_req0, w_req1, w_req2, w_req3;
(*dont_touch = "yes"*)wire w_andReq;

assign w_andReq = w_req0 & w_req1 & w_req2 & w_req3;
assign w_sendFree = w_driveReq & w_andReq;

wire w_d_andReq;
delay2U delay_dandreq (.inR(w_andReq), .outR(w_d_andReq), .rst(rst));
delay1U delay_sendFree (.inR(w_sendFree), .outR(w_d_sendFree), .rst(rst));
delay1U delayDSendfree (.inR(w_d_sendFree), .outR(o_free), .rst(rst));

contTap driveTap(
    .trig((i_drive & (~w_driveReq)) | w_d_andReq),
    .req(w_driveReq),
    .rst(rst)
);

contTap tap0(
    .trig((i_freeNext0 & (~w_req0)) | w_d_sendFree),
    .req(w_req0),
    .rst(rst)
);
contTap tap1(
    .trig((i_freeNext1 & (~w_req1)) | w_d_sendFree),
    .req(w_req1),
    .rst(rst)
);
contTap tap2(
    .trig((i_freeNext2 & (~w_req2)) | w_d_sendFree),
    .req(w_req2),
    .rst(rst)
);
contTap tap3(
    .trig((i_freeNext3 & (~w_req3)) | w_d_sendFree),
    .req(w_req3),
    .rst(rst)
);

assign o_driveNext0 = i_drive;
assign o_driveNext1 = i_drive;
assign o_driveNext2 = i_drive;
assign o_driveNext3 = i_drive;

endmodule
