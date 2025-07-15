//======================================================
// Project: SOLVA
// Module:  cWaitMerge9
// Author:  zhuangzhuang Liao
// Mail：   lzhuangzhuang2023@lzu.edu.cn
// Date:    2025-05-28
// Description: parameterized 9-input cWaitMerge
//======================================================

 module cWaitMerge9#(
    parameter DATA_WIDTH_I0 = 1,
    parameter DATA_WIDTH_I1 = 3,
    parameter DATA_WIDTH_I2 = 3,
    parameter DATA_WIDTH_I3 = 3,
    parameter DATA_WIDTH_I4 = 1,
    parameter DATA_WIDTH_I5 = 3,
    parameter DATA_WIDTH_I6 = 3,
    parameter DATA_WIDTH_I7 = 3,
    parameter DATA_WIDTH_I8 = 3
)(
    input wire i_drive0,i_drive1,i_drive2,i_drive3,
    input wire i_drive4,i_drive5,i_drive6,i_drive7,i_drive8,
    input wire [DATA_WIDTH_I0-1:0] i_data0,
    input wire [DATA_WIDTH_I1-1:0] i_data1,
    input wire [DATA_WIDTH_I2-1:0] i_data2,
    input wire [DATA_WIDTH_I3-1:0] i_data3,
    input wire [DATA_WIDTH_I0-1:0] i_data4,
    input wire [DATA_WIDTH_I1-1:0] i_data5,
    input wire [DATA_WIDTH_I2-1:0] i_data6,
    input wire [DATA_WIDTH_I3-1:0] i_data7,
    input wire [DATA_WIDTH_I3-1:0] i_data8,
    input wire i_freeNext,

    output wire o_free0,o_free1,o_free2,o_free3,
    output wire o_free4,o_free5,o_free6,o_free7,o_free8,
    output wire o_driveNext,
    output wire [DATA_WIDTH_I0+DATA_WIDTH_I1+DATA_WIDTH_I2+DATA_WIDTH_I3+DATA_WIDTH_I4+DATA_WIDTH_I5+DATA_WIDTH_I6+DATA_WIDTH_I7+DATA_WIDTH_I8-1:0] o_data,

    input wire rstn

);

//wire & reg
wire [9-1:0] w_driveNext_9;
wire [9-1:0] w_trig;
wire [9-1:0] w_req;
wire w_driveNext;
wire w_sendDrive,w_sendFree;
wire w_andReq;
wire w_d_andReq;

assign w_trig[0] = i_drive0&(~w_req[0]) | w_sendFree;
contTap Tap0(
.trig(w_trig[0]),
.req(w_req[0]),
.rstn(rstn)
);

assign w_trig[1] = i_drive1&(~w_req[1]) | w_sendFree;
contTap Tap1(
.trig(w_trig[1]),
.req(w_req[1]),
.rstn(rstn)
);

assign w_trig[2] = i_drive2&(~w_req[2]) | w_sendFree;
contTap Tap2(
.trig(w_trig[2]),
.req(w_req[2]),
.rstn(rstn)
);

assign w_trig[3] = i_drive3&(~w_req[3]) | w_sendFree;
contTap Tap3(
.trig(w_trig[3]),
.req(w_req[3]),
.rstn(rstn)
);

assign w_trig[4] = i_drive4&(~w_req[4]) | w_sendFree;
contTap Tap4(
.trig(w_trig[4]),
.req(w_req[4]),
.rstn(rstn)
);

assign w_trig[5] = i_drive5&(~w_req[5]) | w_sendFree;
contTap Tap5(
.trig(w_trig[5]),
.req(w_req[5]),
.rstn(rstn)
);

assign w_trig[6] = i_drive6&(~w_req[6]) | w_sendFree;
contTap Tap6(
.trig(w_trig[6]),
.req(w_req[6]),
.rstn(rstn)
);

assign w_trig[7] = i_drive7&(~w_req[7]) | w_sendFree;
contTap Tap7(
.trig(w_trig[7]),
.req(w_req[7]),
.rstn(rstn)
);

assign w_trig[8] = i_drive8&(~w_req[8]) | w_sendFree;
contTap Tap8(
.trig(w_trig[8]),
.req(w_req[8]),
.rstn(rstn)
);

assign w_andReq = & w_req;
delay4U u_delay2U_donttouch(
    .inR  ( w_andReq ),
    .rstn ( rstn ),
    .outR ( w_d_andReq )
);

assign w_driveNext = w_andReq ^ w_d_andReq;
assign w_sendDrive = w_driveNext & (&w_req);
assign w_sendFree = i_freeNext;
assign o_free0 = i_freeNext;
assign o_free1 = i_freeNext;
assign o_free2 = i_freeNext;
assign o_free3 = i_freeNext;
assign o_free4 = i_freeNext;
assign o_free5 = i_freeNext;
assign o_free6 = i_freeNext;
assign o_free7 = i_freeNext;
assign o_free8 = i_freeNext;
assign o_data = {i_data8,i_data7, i_data6,i_data5,i_data4,i_data3, i_data2,i_data1,i_data0};
assign o_driveNext = w_sendDrive;

endmodule
