//-----------------------------------------------
//	module name: clickfifo1
//	author: Tong Fu, Lingzhuang Zhang
//	version: 1st version (2022-11-15)
//-----------------------------------------------

`timescale 1ns / 1ps

module cFifo1(
    // last -->
    input           i_drive,
    output          o_free,
    // --> next
    output          o_driveNext,
    input           i_freeNext,
    output          o_fire_1,
    // reset signal
    input           rst
);

wire [1:0] w_outRRelay_2,w_outARelay_2;
wire w_driveNext;

// pipeline
sender sender(
	.i_drive    ( i_drive           ),
	.o_free     ( o_free            ),
	.outR       ( w_outRRelay_2[0]  ),
	.i_free     ( w_driveNext       ),
	.rst        ( rst               )
);

relay relay0(
	.inR        ( w_outRRelay_2[0]  ),
	.inA        ( w_outARelay_2[0]  ),
	.outR       ( w_outRRelay_2[1]  ),
	.outA       ( w_outARelay_2[1]  ),
	.fire       ( o_fire_1          ),
	.rst        ( rst               )
);

receiver receiver(
	.inR        ( w_outRRelay_2[1]  ),
	.inA        ( w_outARelay_2[1]  ),
	.i_freeNext ( i_freeNext        ),
	.rst        ( rst               )
);

// make sure regs assignment is before o_driveNext.
delay1U outdelay0 (.inR(o_fire_1)   , .outR(w_driveNext), .rst(rst));
delay1U outdelay1 (.inR(w_driveNext), .outR(o_driveNext), .rst(rst));
endmodule

