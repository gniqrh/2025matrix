//======================================================
// Project: SOLVA
// Module:  cFifo2
// Author:  zhuangzhuang Liao
// Reviser: jinyu Yang
// Mail：   lzhuangzhuang2023@lzu.edu.cn
// Date:    2025-05-28
// Description: cFifo2
//======================================================

`timescale 1ns / 1ps

module cFifo2(
    // rstn
    input           rstn,
    // From Last
    input           i_drive, 
    output          o_free, 
    // To Next
    output          o_driveNext,
    input           i_freeNext,
    // fire signal
    output  [1:0]   o_fire_2
);

wire [2:0]  w_outRRelay_3,  w_outARelay_3;
wire        w_driveNext;

//pipeline
// 微流水线，由发送中继接收组成的FIFO控制器，不过relay的个数是两个
sender sender(
	.i_drive(i_drive),
	.o_free(o_free),
	.outR(w_outRRelay_3[0]),
	.i_free(w_driveNext),
	.rstn(rstn)
);

relay relay0(
	.inR(w_outRRelay_3[0]),
	.inA(w_outARelay_3[0]),
	.outR(w_outRRelay_3[1]),
	.outA(w_outARelay_3[1]),
	.fire(o_fire_2[0]),
	.rstn(rstn)
);

relay relay1(
	.inR(w_outRRelay_3[1]),
	.inA(w_outARelay_3[1]),
	.outR(w_outRRelay_3[2]),
	.outA(w_outARelay_3[2]),
	.fire(o_fire_2[1]),
	.rstn(rstn)
);

receiver receiver(
	.inR(w_outRRelay_3[2]),
	.inA(w_outARelay_3[2]),
	.i_freeNext(i_freeNext),
	.rstn(rstn)
);

delay1U outdelay0_donttouch (.inR(o_fire_2[1]), .outR(w_driveNext),.rstn(rstn));
delay1U outdelay1_donttouch (.inR(w_driveNext), .outR(o_driveNext),.rstn(rstn));
endmodule
