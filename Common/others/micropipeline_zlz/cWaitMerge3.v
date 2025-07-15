//-----------------------------------------------
//	module name: cWaitMerge3
//	author: Tong Fu, Lingzhuang Zhang
//	version: 1st version (2022-11-17)
//-----------------------------------------------

module cWaitMerge3(
    // in0 -->
    input       i_drive0    ,
    output      o_free0     , 
    // in1 -->
    input       i_drive1    ,
    output      o_free1     ,
    // in2 -->
    input       i_drive2    ,
    output      o_free2     ,
    // --> out
    output      o_driveNext ,
    input       i_freeNext  ,
    input       rst
);

wire        w_firstTrig, w_secondTrig, w_thirdTrig  ;
wire        w_firstReq , w_secondReq , w_thirdReq   ;
wire        w_free0    , w_free1     , w_free2      ;
wire        w_drive0   , w_drive1    , w_drive2     ;

wire        w_allReqCome, w_outRRelay, w_outARelay, w_driveNext;

assign w_firstTrig = i_drive0 | i_freeNext;
contTap firstTap(
    .trig       ( w_firstTrig   ),
    .req        ( w_firstReq    ),
    .rst        ( rst           )
);

assign w_secondTrig = i_drive1 | i_freeNext;
contTap secondTap(
    .trig       ( w_secondTrig  ),
    .req        ( w_secondReq   ),
    .rst        ( rst           )
);

assign w_thirdTrig = i_drive2 | i_freeNext;
contTap thirdTap(
    .trig       ( w_thirdTrig   ),
    .req        ( w_thirdReq    ),
    .rst        ( rst           )
);


assign w_allReqCome = w_firstReq & w_secondReq & w_thirdReq;

relay relay0(
	.inR        ( w_allReqCome      ),
	.inA        (                   ),
	.outR       ( w_outRRelay       ),
	.outA       ( w_outARelay       ),
	.fire       ( w_driveNext       ),
	.rst        ( rst               )
);

delay1U deloutR(
    .inR        ( w_outRRelay       ), 
    .outR       ( w_outARelay       ), 
    .rst        ( rst               )
);

assign o_driveNext = w_driveNext & w_allReqCome;

assign o_free0 = i_freeNext;
assign o_free1 = i_freeNext;
assign o_free2 = i_freeNext;

endmodule
