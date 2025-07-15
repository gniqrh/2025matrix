//-----------------------------------------------
//	module name: cMutexMerge9
//	author:  zhanglzh
//	version: 2024.12.24
//-----------------------------------------------

module cMutexMerge9(
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
    // in4 -->
    input       i_drive4    ,
    output      o_free4     , 
    // in5 -->
    input       i_drive5    ,
    output      o_free5     ,
    // in6 -->
    input       i_drive6    ,
    output      o_free6     ,
    // in7 -->
    input       i_drive7    ,
    output      o_free7     ,
    // in8 -->
    input       i_drive8    ,
    output      o_free8     ,
    // --> out
    output      o_driveNext ,
    input       i_freeNext  ,
    input       rst
);

wire        w_firstTrig, w_secondTrig, w_thirdTrig, w_fourthTrig;
wire        w_firstReq , w_secondReq , w_thirdReq , w_fourthReq ;


wire        w_fifthTrig, w_sixthTrig , w_seventhTrig, w_eighthTrig, w_ninthTrig ;
wire        w_fifthReq , w_sixthReq  , w_seventhReq , w_eighthReq , w_ninthReq  ;

wire        w_free0    , w_free1     , w_free2    , w_free3     ;
wire        w_free4    , w_free5     , w_free6    , w_free7     , w_free8;

wire        w_free0_delayed, w_free1_delayed, w_free2_delayed, w_free3_delayed;
wire        w_free4_delayed, w_free5_delayed, w_free6_delayed, w_free7_delayed, w_free8_delayed;

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

assign w_fifthTrig = i_drive4 | w_free4_delayed;
contTap fifthTap(
    .trig       ( w_fifthTrig   ),
    .req        ( w_fifthReq    ),
    .rst        ( rst           )
);

assign w_sixthTrig = i_drive5 | w_free5_delayed;
contTap sixthTap(
    .trig       ( w_sixthTrig   ),
    .req        ( w_sixthReq    ),
    .rst        ( rst           )
);

assign w_seventhTrig = i_drive6 | w_free6_delayed;
contTap seventhTap(
    .trig       ( w_seventhTrig ),
    .req        ( w_seventhReq  ),
    .rst        ( rst           )
);

assign w_eighthTrig = i_drive7 | w_free7_delayed;
contTap eighthTap(
    .trig       ( w_eighthTrig  ),
    .req        ( w_eighthReq   ),
    .rst        ( rst           )
);

assign w_ninthTrig = i_drive8 | w_free8_delayed;
contTap ninthTap(
    .trig       ( w_ninthTrig   ),
    .req        ( w_ninthReq    ),
    .rst        ( rst           )
);

// the timing of w_firstReq/w_secondReq should be stable before o_driveNext;
assign o_driveNext = i_drive0 | i_drive1 | i_drive2 | i_drive3
                   | i_drive4 | i_drive5 | i_drive6 | i_drive7 | i_drive8;

// make free signals won't shrink.
delay1U delay1U_free0 (.inR ( w_free0  ), .outR ( w_free0_delayed  ), .rst ( rst       ));
delay1U delay1U_free1 (.inR ( w_free1  ), .outR ( w_free1_delayed  ), .rst ( rst       ));
delay1U delay1U_free2 (.inR ( w_free2  ), .outR ( w_free2_delayed  ), .rst ( rst       ));
delay1U delay1U_free3 (.inR ( w_free3  ), .outR ( w_free3_delayed  ), .rst ( rst       ));
delay1U delay1U_free4 (.inR ( w_free4  ), .outR ( w_free4_delayed  ), .rst ( rst       ));
delay1U delay1U_free5 (.inR ( w_free5  ), .outR ( w_free5_delayed  ), .rst ( rst       ));
delay1U delay1U_free6 (.inR ( w_free6  ), .outR ( w_free6_delayed  ), .rst ( rst       ));
delay1U delay1U_free7 (.inR ( w_free7  ), .outR ( w_free7_delayed  ), .rst ( rst       ));
delay1U delay1U_free8 (.inR ( w_free8  ), .outR ( w_free8_delayed  ), .rst ( rst       ));

assign w_free0 = i_freeNext & w_firstReq  ;
assign w_free1 = i_freeNext & w_secondReq ;
assign w_free2 = i_freeNext & w_thirdReq  ;
assign w_free3 = i_freeNext & w_fourthReq ;
assign w_free4 = i_freeNext & w_fifthReq  ;
assign w_free5 = i_freeNext & w_sixthReq  ;
assign w_free6 = i_freeNext & w_seventhReq;
assign w_free7 = i_freeNext & w_eighthReq ;
assign w_free8 = i_freeNext & w_ninthReq  ;

assign o_free0 = w_free0;
assign o_free1 = w_free1;
assign o_free2 = w_free2;
assign o_free3 = w_free3;
assign o_free4 = w_free4;
assign o_free5 = w_free5;
assign o_free6 = w_free6;
assign o_free7 = w_free7;
assign o_free8 = w_free8;

endmodule
