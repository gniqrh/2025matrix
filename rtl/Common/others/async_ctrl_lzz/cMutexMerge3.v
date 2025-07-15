//======================================================
// Project: SOLVA
// Module:  cMutexMerge3
// Author:  zhuangzhuang Liao
// Mail：   lzhuangzhuang2023@lzu.edu.cn
// Date:    2025-05-28
// Description: parameterized 3-input cMutexMerge
//======================================================
`timescale 1ns / 1ps

 module cMutexMerge3#(
    parameter DATA_WIDTH = 32
)(
    input  wire i_drive0,i_drive1,i_drive2,
    input  wire [DATA_WIDTH-1:0] i_data0,i_data1,i_data2,
    input  wire i_freeNext,

    output wire o_free0,o_free1,o_free2,
    output wire o_driveNext,
    output wire [DATA_WIDTH-1:0] o_data,

    input wire rstn

);

wire w_firstTrig,w_secondTrig,w_thirdTrig;
wire w_firstReq,w_secondReq,w_thirdReq;
wire [DATA_WIDTH-1:0] w_data;
wire [3-1:0] w_ofree_3;

(* dont_touch="true" *)delay1U outdelay0_donttouch (.inR(o_free0), .outR(w_ofree_3[0]), .rstn(rstn));
(* dont_touch="true" *)delay1U outdelay1_donttouch (.inR(o_free1), .outR(w_ofree_3[1]), .rstn(rstn));
(* dont_touch="true" *)delay1U outdelay2_donttouch (.inR(o_free2), .outR(w_ofree_3[2]), .rstn(rstn));


assign w_firstTrig =  i_drive0&(~w_firstReq)  | w_ofree_3[0]&w_firstReq;
assign w_secondTrig = i_drive1&(~w_secondReq) | w_ofree_3[1]&w_secondReq;
assign w_thirdTrig =  i_drive2&(~w_thirdReq)  | w_ofree_3[2]&w_thirdReq;

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
contTap thirdTap(
.trig(w_thirdTrig),
.req(w_thirdReq),
.rstn(rstn)
);

freeSetDelay #(
    .DELAY_UNIT_NUM(4)
) u_freeSetDelay (
    .i_signal(i_drive0 | i_drive1 | i_drive2),
    .o_signal(o_driveNext),
    .rstn    (rstn)
);

delay4U u_delay4U_free0_donttouch(
    .inR  ( i_freeNext & w_firstReq  ),
    .outR ( o_free0 ),
    .rstn  ( rstn  )
);
delay4U u_delay4U_free1_donttouch(
    .inR  ( i_freeNext & w_secondReq  ),
    .outR ( o_free1 ),
    .rstn  ( rstn  )
);
delay4U u_delay4U_free2_donttouch(
    .inR  ( i_freeNext & w_thirdReq  ),
    .outR ( o_free2 ),
    .rstn  ( rstn  )
);

assign w_data = (w_firstReq == 1'b1) ? i_data0 :
		    	(w_secondReq == 1'b1) ? i_data1 :
                (w_thirdReq == 1'b1) ? i_data2 :
                {DATA_WIDTH{1'b0}};

assign o_data = w_data;

endmodule
