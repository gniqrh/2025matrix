//======================================================
// Project: SOLVA
// Module:  cWaitMerge2
// Author:  longtao zhang , zhuangzhuang Liao
// Mail：   lzhuangzhuang2023@lzu.edu.cn
// Date:    2025-05-28
// Description: parameterized two-input cWaitMerge
//======================================================
module cWaitMerge2#(
    parameter DATA_WIDTH_I0 = 18,
    parameter DATA_WIDTH_I1 = 32
)(
    input wire i_drive0,i_drive1,
    input wire [DATA_WIDTH_I0-1:0] i_data0,
    input wire [DATA_WIDTH_I1-1:0] i_data1,
    input wire i_freeNext,

    output wire o_free0,o_free1,
    output wire o_driveNext,
    output wire [DATA_WIDTH_I0+DATA_WIDTH_I1-1:0] o_data,

    input wire rstn

);

//wire & reg
wire w_firstTrig,w_secondTrig;
wire w_firstReq,w_secondReq;
wire w_driveNext;
wire w_andReq;
wire w_d_andReq;
wire w_sendDrive,w_sendFree;
wire [DATA_WIDTH_I0-1:0] w_data0_32;
wire [DATA_WIDTH_I1-1:0] w_data1_32;


assign w_data0_32 = i_data0;
assign w_firstTrig = i_drive0&(~w_firstReq) | w_sendFree;
contTap firstTap(
.trig(w_firstTrig),
.req(w_firstReq),
.rstn(rstn)
);

assign w_data1_32 = i_data1;
assign w_secondTrig = i_drive1&(~w_secondReq) | w_sendFree;
contTap secondTap(
.trig(w_secondTrig),
.req(w_secondReq),
.rstn(rstn)
);

assign w_andReq = w_firstReq & w_secondReq;
delay2U u_delay2U_donttouch(
    .inR  ( w_andReq ),
    .rstn ( rstn ),
    .outR ( w_d_andReq )
);

assign w_driveNext = w_andReq ^ w_d_andReq;
assign w_sendDrive = w_driveNext & w_secondReq & w_firstReq;
assign w_sendFree = i_freeNext;
assign o_free0 = i_freeNext;
assign o_free1 = i_freeNext;
assign o_data = {w_data1_32, w_data0_32};
assign o_driveNext = w_sendDrive;

endmodule
