//======================================================
// Module:         Fifo1
// Author:         YiHua Lu
// Date:           2025/06/18
// Description:    普通Fifo，加了一个delay1U通过
//                 这里的free也是和其他控制链一样，后面来了再往前给
//======================================================

`timescale 1ns / 1ps

module Fifo_1(
    // last -->
    input           i_drive,
    output          o_free,
    // --> next
    output          o_driveNext,
    input           i_freeNext,

    output          o_fire,
    // reset signal
    input           rst
);

wire [1:0] w_outRRelay_2,w_outARelay_2;

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
	.fire       ( o_fire            ),
	.rst        ( rst               )
);

receiver receiver(
	.inR        ( w_outRRelay_2[1]  ),
	.inA        ( w_outARelay_2[1]  ),
	.i_freeNext ( i_freeNext        ),
	.rst        ( rst               )
);

// make sure regs assignment is before o_driveNext.
delay1U outdelay0 (.inR(i_drive  )   , .outR(o_driveNext), .rst(rst));
delay1U outdelay1 (.inR(i_freeNext  )   , .outR(o_free), .rst(rst));

endmodule

