//===============================================================================
// Project:        RCA
// Module:         ConfMerge_2_d
// Author:         YiHua Lu
// Date:           2025/06/18
// Description:    互斥融合;带数据版;对数据不做持久化保存；
//                 在控制链加入数据的模型中，mutex的实现逻辑是导致数据非持久化的原因
//                 测试值：1ns左右可出去
//===============================================================================
`timescale 1ns / 1ps

module ConfMerge_2_d#(
    parameter DATA_WIDTH = 128
)(
    // in0 -->
    input       i_drive0    ,
    output      o_free0     , 
    input  wire [DATA_WIDTH-1:0] i_data0,
    // in1 -->
    input       i_drive1    ,
    output      o_free1     ,
    input  wire [DATA_WIDTH-1:0] i_data1,
    // --> out
    output      o_driveNext ,
    input       i_freeNext  ,
    output wire [DATA_WIDTH-1:0] o_data,

    input       rst
);

wire        w_firstTrig     , w_secondTrig;
wire        w_firstReq      , w_secondReq;
wire        w_free0         , w_free1;
wire        w_free0_delay   , w_free1_delay;

wire[DATA_WIDTH-1:0] w_data;

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

// 数据需要一定的时间被赋值，这里让o_drive出去前数据已经准备好
wire w_driveNext = i_drive0 | i_drive1;
delay1U delay_out (.inR(w_driveNext)   , .outR(o_driveNext), .rst(rst));

assign w_free0 = i_freeNext & w_firstReq;
assign w_free1 = i_freeNext & w_secondReq;

assign o_free0 = w_free0;
assign o_free1 = w_free1;

assign w_data = (w_firstReq == 1'b1) ? i_data0 :
		    	((w_secondReq == 1'b1) ? i_data1 : {DATA_WIDTH{1'b0}});

assign o_data = w_data;

endmodule
