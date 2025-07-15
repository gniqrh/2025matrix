//======================================================
// Project: SOLVA
// Module:  cFifo3
// Author:  zhuangzhuang Liao
// Reviser: jinyu Yang
// Mail：   lzhuangzhuang2023@lzu.edu.cn
// Date:    2025-05-28
// Description: cFifo3
//======================================================

`timescale 1ns / 1ps

module cFifo3(
    // rstn
    input           rstn,
    // From Last
    input           i_drive, 
    output          o_free, 
    // To Next
    output          o_driveNext,
    input           i_freeNext,
    // fire signal
    output  [2:0]   o_fire_3
);

wire [3:0]  w_outRRelay_4,  w_outARelay_4;
wire        w_driveNext;

//pipeline
//微流水线，由发送中继接收组成的FIFO控制器，不过relay的个数是三个
sender sender(
	.i_drive(i_drive),
	.o_free(o_free),
	.outR(w_outRRelay_4[0]),
	.i_free(w_driveNext),
	.rstn(rstn)
);

relay relay0(
	.inR(w_outRRelay_4[0]),
	.inA(w_outARelay_4[0]),
	.outR(w_outRRelay_4[1]),
	.outA(w_outARelay_4[1]),
	.fire(o_fire_3[0]),
	.rstn(rstn)
);

relay relay1(
	.inR(w_outRRelay_4[1]),
	.inA(w_outARelay_4[1]),
	.outR(w_outRRelay_4[2]),
	.outA(w_outARelay_4[2]),
	.fire(o_fire_3[1]),
	.rstn(rstn)
);

relay relay2(
	.inR(w_outRRelay_4[2]),
	.inA(w_outARelay_4[2]),
	.outR(w_outRRelay_4[3]),
	.outA(w_outARelay_4[3]),
	.fire(o_fire_3[2]),
	.rstn(rstn)
);

receiver receiver(
	.inR(w_outRRelay_4[3]),
	.inA(w_outARelay_4[3]),
	.i_freeNext(i_freeNext),
	.rstn(rstn)
);

delay1U outdelay0_donttouch (.inR(o_fire_3[2]), .outR(w_driveNext),.rstn(rstn));
delay1U outdelay1_donttouch (.inR(w_driveNext), .outR(o_driveNext),.rstn(rstn));
endmodule
