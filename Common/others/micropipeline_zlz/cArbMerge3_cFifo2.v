//-----------------------------------------------
//	module name: cArbMerge2_cFifo2
//	author: Lingzhuang Zhang, FuTong
//	version: 2nd version (2025-01-13)
//-----------------------------------------------

`timescale 1ns / 1ps

module cArbMerge3_cFifo2(
    // last -->
    input               i_drive,
    output              o_free,
    // --> next
    output              o_driveNext,
    input               i_freeNext,
    output  [1:0]       o_fire_2,
    // reset signal
    input               rst
);

wire    [3:0]   w_outRRelay, w_outARelay;
wire            w_driveNext                 ;

// pipeline
sender sender(
	.i_drive    ( i_drive           ),
	.o_free     ( o_free            ),
	.outR       ( w_outRRelay[0]    ),
	.i_free     ( i_freeNext        ),
	.rst        ( rst               )
);

relay relay0(
	.inR        ( w_outRRelay[0]    ),
	.inA        ( w_outARelay[0]    ),
	.outR       ( w_outRRelay[1]    ),
	.outA       ( w_outARelay[1]    ),
	.fire       ( o_fire_2[0]       ),
	.rst        ( rst               )
);

relay relay1(
	.inR        ( w_outRRelay[1]    ),
	.inA        ( w_outARelay[1]    ),
	.outR       ( w_outRRelay[2]    ),
	.outA       ( w_outARelay[2]    ),
	.fire       ( o_fire_2[1]       ),
	.rst        ( rst               )
);

relay relay2(
	.inR        ( w_outRRelay[2]    ),
	.inA        ( w_outARelay[2]    ),
	.outR       ( w_outRRelay[3]    ),
	.outA       ( w_outARelay[3]    ),
	.fire       ( w_driveNext       ),
	.rst        ( rst               )
);

delay1U deloutR(
    .inR        ( w_outRRelay[3]    ), 
    .outR       ( w_outARelay[3]    ), 
    .rst        ( rst               )
);

assign o_driveNext = w_driveNext;

endmodule

