//-----------------------------------------------
//	module name: cMutexMerge4
//	author:  zhanglzh
//	version: 2024.06.24
//-----------------------------------------------

module cMutexMerge4(
    // in0 -->
    input       i_drive0    ,
    output      o_free0     , 
    // in1 -->
    input       i_drive1    ,
    output      o_free1     ,
    // in2 -->
    input       i_drive2    ,
    output      o_free2     ,
    // in3 -->
    input       i_drive3    ,
    output      o_free3     ,
    // --> out
    output      o_driveNext ,
    input       i_freeNext  ,
    input       rst
);

wire        w_firstTrig, w_secondTrig, w_thirdTrig, w_fourthTrig;
wire        w_firstReq , w_secondReq , w_thirdReq , w_fourthReq ;
wire        w_free0    , w_free1     , w_free2    , w_free3     ;

wire        w_free0_delayed, w_free1_delayed, w_free2_delayed, w_free3_delayed;

assign w_firstTrig = i_drive0 | w_free0_delayed;
contTap firstTap(
    .trig       ( w_firstTrig   ),
    .req        ( w_firstReq    ),
    .rst        ( rst           )
);

assign w_secondTrig = i_drive1 | w_free1_delayed;
contTap secondTap(
    .trig       ( w_secondTrig  ),
    .req        ( w_secondReq   ),
    .rst        ( rst           )
);

assign w_thirdTrig = i_drive2 | w_free2_delayed;
contTap thirdTap(
    .trig       ( w_thirdTrig   ),
    .req        ( w_thirdReq    ),
    .rst        ( rst           )
);

assign w_fourthTrig = i_drive3 | w_free3_delayed;
contTap fourthTap(
    .trig       ( w_fourthTrig  ),
    .req        ( w_fourthReq   ),
    .rst        ( rst           )
);

// the timing of w_firstReq/w_secondReq should be stable before o_driveNext;
assign o_driveNext = i_drive0 | i_drive1 | i_drive2 | i_drive3;

// make free signals won't shrink.
delay1U delay1U_free0 (.inR ( w_free0  ), .outR ( w_free0_delayed  ), .rst ( rst       ));
delay1U delay1U_free1 (.inR ( w_free1  ), .outR ( w_free1_delayed  ), .rst ( rst       ));
delay1U delay1U_free2 (.inR ( w_free2  ), .outR ( w_free2_delayed  ), .rst ( rst       ));
delay1U delay1U_free3 (.inR ( w_free3  ), .outR ( w_free3_delayed  ), .rst ( rst       ));

assign w_free0 = i_freeNext & w_firstReq ;
assign w_free1 = i_freeNext & w_secondReq;
assign w_free2 = i_freeNext & w_thirdReq ;
assign w_free3 = i_freeNext & w_fourthReq;

assign o_free0 = w_free0;
assign o_free1 = w_free1;
assign o_free2 = w_free2;
assign o_free3 = w_free3;

endmodule
