//======================================================
// Project: RCA
// Module:  cFifoN
// Author:  zhuangzhuang Liao
// Reviser: jinyu Yang
// Mail：   lzhuangzhuang2023@lzu.edu.cn
// Date:    2025-05-28
// Description:  N relays
//======================================================
`timescale 1ns / 1ps

module Fifo_N#(
    parameter RELAY_NUMS = 5
)(
i_drive,i_freeNext,
o_free,o_driveNext,
o_fire_n,rst
);

input i_drive, i_freeNext;
output o_free, o_driveNext;
output wire [RELAY_NUMS-1:0] o_fire_n;
input rst;

(* dont_touch="true" *)wire [RELAY_NUMS:0] w_outRRelay_n;
(* dont_touch="true" *)wire [RELAY_NUMS:0] w_outARelay_n;
(* dont_touch="true" *)wire w_driveNext;

//pipeline
// 微流水线，由发送中继接收组成的FIFO控制器，不过relay的个数是RELAY_NUMS(N)个
(* dont_touch="true" *)sender sender(
	.i_drive(i_drive),
	.o_free(o_free),
	.outR(w_outRRelay_n[0]),
	.i_free(w_driveNext),
	.rst(rst)
);

genvar relayNUms;
generate
    for (relayNUms = 0;relayNUms<RELAY_NUMS ;relayNUms=relayNUms+1 ) begin:gen_relay
        relay relay0(
            .inR(w_outRRelay_n[relayNUms]),
            .inA(w_outARelay_n[relayNUms]),
            .outR(w_outRRelay_n[relayNUms+1]),
            .outA(w_outARelay_n[relayNUms+1]),
            .fire(o_fire_n[relayNUms]),
            .rst(rst)
        );
    end
endgenerate


(* dont_touch="true" *)receiver receiver(
	.inR(w_outRRelay_n[RELAY_NUMS]),
	.inA(w_outARelay_n[RELAY_NUMS]),
	.i_freeNext(i_freeNext),
	.rst(rst)
);

(* dont_touch="true" *)delay2U outdelay0_donttouch (.inR(o_fire_n[RELAY_NUMS-1]), .outR(w_driveNext), .rst(rst));
(* dont_touch="true" *)delay2U outdelay1_donttouch (.inR(w_driveNext), .outR(o_driveNext), .rst(rst));
endmodule
