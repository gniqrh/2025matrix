//======================================================
// Project: SOLVA
// Module:  cMutexMerge2
// Author:  longtao zhang,zhuangzhuang Liao
// Mail：   lzhuangzhuang2023@lzu.edu.cn
// Date:    2025-05-28
// Description: parameterized two-input cMutexMerge
//======================================================
`timescale 1ns / 1ps
module cMutexMerge2#(
    parameter DATA_WIDTH = 32
)(
    input  wire i_drive0,i_drive1,
    input  wire [DATA_WIDTH-1:0] i_data0,i_data1,
    input  wire i_freeNext,

    output wire o_free0,o_free1,
    output wire o_driveNext,
    output wire [DATA_WIDTH-1:0] o_data,

    input wire rstn

);

wire w_firstTrig,w_secondTrig;
wire w_firstReq,w_secondReq;
wire [DATA_WIDTH-1:0] w_data;
wire [2-1:0] w_ofree_2;

(* dont_touch="true" *)delay2U outdelay0_donttouch (.inR(w_ofree_2[0]), .outR(o_free0), .rstn(rstn));
(* dont_touch="true" *)delay2U outdelay1_donttouch (.inR(w_ofree_2[1]), .outR(o_free1), .rstn(rstn));

assign w_firstTrig =  i_drive0&(~w_firstReq)  | (w_ofree_2[0]&w_firstReq);
assign w_secondTrig = i_drive1&(~w_secondReq) | (w_ofree_2[1]&w_secondReq);

contTap firstTap(
.trig(w_firstTrig),
.req(w_firstReq),
.rstn(rstn)
);
contTap secondTap(
.trig(w_secondTrig),
.req(w_secondReq),
.rstn(rstn)
);

freeSetDelay #(
    .DELAY_UNIT_NUM(4)
) u_freeSetDelay (
    .i_signal(i_drive0 | i_drive1),
    .o_signal(o_driveNext),
    .rstn    (rstn)
);

wire w_freeNext;
wire w_linkbuf;
BUFM48HM buf0_donttouch ( .A(i_freeNext), .Z(w_linkbuf) );
BUFM48HM buf1_donttouch ( .A(w_linkbuf), .Z(w_freeNext) );

delay2U u_delay4U_free0_donttouch(
    .inR  ( w_freeNext & w_firstReq  ),
    .outR ( w_ofree_2[0] ),
    .rstn  ( rstn  )
);
delay2U u_delay4U_free1_donttouch(
    .inR  ( w_freeNext & w_secondReq  ),
    .outR ( w_ofree_2[1] ),
    .rstn  ( rstn  )
);

assign w_data = (w_firstReq == 1'b1) ? i_data0 :
		    	((w_secondReq == 1'b1) ? i_data1 : {DATA_WIDTH{1'b0}});

assign o_data = w_data;

endmodule
