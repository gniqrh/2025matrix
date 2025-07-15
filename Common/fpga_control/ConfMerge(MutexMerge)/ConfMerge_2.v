//===============================================================================
// Project:        RCA
// Module:         ConfMerge_2
// Author:         YiHua Lu
// Date:           2025/06/18
// Description:    互斥融合;不带数据版;
//                 测试值：1ns左右输出
//===============================================================================
`timescale 1ns / 1ps

module ConfMerge_2(
    // in0 -->
    input       i_drive0    ,
    output      o_free0     , 
    // in1 -->
    input       i_drive1    ,
    output      o_free1     ,
    // --> out
    output      o_driveNext ,
    input       i_freeNext  ,
    input       rst
);

wire        w_firstTrig     , w_secondTrig;
wire        w_firstReq      , w_secondReq;
wire        w_free0         , w_free1;
wire        w_free0_delay   , w_free1_delay;

delay1U delay0 (.inR(w_free0)   , .outR(w_free0_delay), .rst(rst));
assign w_firstTrig =  i_drive0&(~w_firstReq) | w_free0_delay&(w_firstReq);
contTap firstTap(
    .trig       ( w_firstTrig   ),
    .req        ( w_firstReq    ),
    .rst        ( rst           )
);

delay1U delay1 (.inR(w_free1)   , .outR(w_free1_delay), .rst(rst));
assign w_secondTrig = i_drive1&(~w_secondReq) | w_free1_delay&(w_secondReq);
contTap secondTap(
    .trig       ( w_secondTrig  ),
    .req        ( w_secondReq   ),
    .rst        ( rst           )
);

// the timing of w_firstReq/w_secondReq should be stable before o_driveNext;
assign o_driveNext = i_drive0 | i_drive1;

assign w_free0 = i_freeNext & w_firstReq;
assign w_free1 = i_freeNext & w_secondReq;

assign o_free0 = w_free0;
assign o_free1 = w_free1;

endmodule
