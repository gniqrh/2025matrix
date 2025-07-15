//-----------------------------------------------
//	module name: cMutexMerge2_32b
//	author: Tong Fu, Lingzhuang Zhang
//	version: 1st version (2022-11-17)
//-----------------------------------------------

module cMutexMerge2(
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

delay2U delay0 (.inR(w_free0)   , .outR(w_free0_delay), .rst(rst));
assign w_firstTrig = i_drive0 | w_free0_delay;
contTap firstTap(
    .trig       ( w_firstTrig   ),
    .req        ( w_firstReq    ),
    .rst        ( rst           )
);

delay2U delay1 (.inR(w_free1)   , .outR(w_free1_delay), .rst(rst));
assign w_secondTrig = i_drive1 | w_free1_delay;
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
