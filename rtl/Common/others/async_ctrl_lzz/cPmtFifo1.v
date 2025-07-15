//======================================================
// Project: SOLVA
// Module:  cPmtFifo1
// Author:  Tong Fu, Lingzhuang Zhang ,zhuangzhuang Liao
// Mail：   zhanglzh22@lzu.edu.cn
// Date:    2025-05-28
// Description: cPmtFifo1
//======================================================

`timescale 1ns / 1ps

module cPmtFifo1(
i_drive,i_freeNext, rstn,
pmt,o_free,o_driveNext,o_fire_1
);

input i_drive, i_freeNext, rstn;
input pmt;
output o_free, o_driveNext;
output o_fire_1;

wire [3-1:0] w_outRRelay_3,w_outARelay_3;
wire w_driveNext;

//pipeline
(* dont_touch="true" *)sender sender(
	.i_drive(i_drive),
	.o_free(o_free),
	.outR(w_outRRelay_3[0]),
	.i_free(w_driveNext),
	.rstn(rstn)
);

(* dont_touch="true" *)pmtRelay pmtRelay0(
	.inR(w_outRRelay_3[0]),
	.inA(w_outARelay_3[0]),
	.outR(w_outRRelay_3[1]),
	.outA(w_outARelay_3[1]),
	.fire(),
	.pmt(pmt),
	.rstn(rstn)
);
(* dont_touch="true" *)relay u_relay(
    .inR   (w_outRRelay_3[1]),
    .inA   (w_outARelay_3[1]),
    .outR  (w_outRRelay_3[2]),
    .outA  (w_outARelay_3[2]),
    .fire  (o_fire_1),
    .rstn   (rstn)
);

(* dont_touch="true" *)receiver receiver(
	.inR(w_outRRelay_3[2]),
	.inA(w_outARelay_3[2]),
	.i_freeNext(i_freeNext),
	.rstn(rstn)
);

// delay1U outdelay0 (.inR(o_fire_1), .outR(w_driveNext), .rstn(rstn));
delay1U outdelay0_donttouch (.inR(o_fire_1), .outR(w_driveNext),.rstn(rstn));
delay1U outdelay1_donttouch (.inR(w_driveNext),.outR(o_driveNext),.rstn(rstn));


endmodule