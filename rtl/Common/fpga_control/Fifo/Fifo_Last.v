//======================================================
// Project:        RCA
// Module:         Fifo_Last
// Author:         YiHua Lu
// Date:           2025/06/22
// Description:    《这是我最后的Fifo了》
// 				   这里free是直接往前给的
//======================================================

`timescale 1ns / 1ps

module Fifo_Last(
    // last -->
    input           i_drive,
    output          o_free,

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

delay4U outdelay0 (.inR(i_drive  )   , .outR(i_freeNext), .rst(rst));
endmodule

