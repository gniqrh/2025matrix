//-----------------------------------------------
//	module name: cMutexMerge2_32b
//	author: Tong Fu, Lingzhuang Zhang
//  for high speed fpga.
//	version: 1st version (2022-11-17)
//-----------------------------------------------

module cWaitMerge2(
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

wire        w_firstTrig, w_secondTrig;
wire        w_firstReq , w_secondReq;
wire        w_free0    , w_free1;
wire        w_drive0   , w_drive1;

wire        w_allReqCome, w_outARelay, w_outRRelay, w_driveNext;

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

assign w_allReqCome = w_firstReq & w_secondReq;

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

endmodule
