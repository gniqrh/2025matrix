//======================================================
// Project: SOLVA
// Module:  cMutexMerge4
// Author:  zhuangzhuang Liao
// Mail：   lzhuangzhuang2023@lzu.edu.cn
// Date:    2025-05-28
// Description: parameterized 4-input cMutexMerge
//======================================================

module cMutexMerge4#(
    parameter DATA_WIDTH = 32
)(
    input  wire i_drive0,i_drive1,i_drive2,i_drive3,
    input  wire [DATA_WIDTH-1:0] i_data0,i_data1,i_data2,i_data3,
    input  wire i_freeNext,

    output wire o_free0,o_free1,o_free2,o_free3,
    output wire o_driveNext,
    output wire [DATA_WIDTH-1:0] o_data,

    input wire rstn

);

wire w_firstTrig,w_secondTrig,w_thirdTrig,w_forthTrig;
wire w_firstReq,w_secondReq,w_thirdReq,w_forthReq;
wire [DATA_WIDTH-1:0] w_data;
wire [4-1:0] w_ofree_4;

(* dont_touch="true" *)delay1U outdelay0_donttouch (.inR(o_free0), .outR(w_ofree_4[0]), .rstn(rstn));
(* dont_touch="true" *)delay1U outdelay1_donttouch (.inR(o_free1), .outR(w_ofree_4[1]), .rstn(rstn));
(* dont_touch="true" *)delay1U outdelay2_donttouch (.inR(o_free2), .outR(w_ofree_4[2]), .rstn(rstn));
(* dont_touch="true" *)delay1U outdelay3_donttouch (.inR(o_free3), .outR(w_ofree_4[3]), .rstn(rstn));


assign w_firstTrig = i_drive0 &(~w_firstReq)| w_ofree_4[0]&w_firstReq;
assign w_secondTrig = i_drive1&(~w_secondReq)| w_ofree_4[1]&w_secondReq;
assign w_thirdTrig = i_drive2 &(~w_thirdReq)| w_ofree_4[2]&w_thirdReq;
assign w_forthTrig = i_drive3 &(~w_forthReq)| w_ofree_4[3]&w_forthReq;

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
contTap forthTap(
.trig(w_forthTrig),
.req(w_forthReq),
.rstn(rstn)
);

freeSetDelay #(
    .DELAY_UNIT_NUM(4)
) u_freeSetDelay (
    .i_signal(i_drive0 | i_drive1 | i_drive2 | i_drive3),
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
delay4U u_delay4U_free3_donttouch(
    .inR  ( i_freeNext & w_forthReq  ),
    .outR ( o_free3 ),
    .rstn  ( rstn  )
);

assign w_data = (w_firstReq == 1'b1) ? i_data0 :
		    	(w_secondReq == 1'b1) ? i_data1 :
                (w_thirdReq == 1'b1) ? i_data2 :
                (w_forthReq == 1'b1) ? i_data3 :
                {DATA_WIDTH{1'b0}};

assign o_data = w_data;

endmodule
