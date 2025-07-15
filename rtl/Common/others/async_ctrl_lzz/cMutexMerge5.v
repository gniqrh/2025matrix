//======================================================
// Project: SOLVA
// Module:  cMutexMerge5
// Author:  zhuangzhuang Liao
// Mail：   lzhuangzhuang2023@lzu.edu.cn
// Date:    2025-05-28
// Description: parameterized two-input cMutexMerge
//======================================================
module cMutexMerge5#(
    parameter DATA_WIDTH = 32
)(
    input  wire i_drive0,i_drive1,i_drive2,i_drive3,
    input wire i_drive4,
    input  wire [DATA_WIDTH-1:0] i_data0,i_data1,i_data2,i_data3,
    input  wire [DATA_WIDTH-1:0] i_data4,
    input  wire i_freeNext,

    output wire o_free0,o_free1,o_free2,o_free3,
    output wire o_free4,
    output wire o_driveNext,
    output wire [DATA_WIDTH-1:0] o_data,

    input wire rstn

);

wire [5-1:0] w_Trig;
wire [5-1:0] w_Req;
wire [DATA_WIDTH-1:0] w_data;
wire [5-1:0] w_ofree_5;

(* dont_touch="true" *)delay1U outdelay0_donttouch (.inR(o_free0), .outR(w_ofree_5[0]), .rstn(rstn));
(* dont_touch="true" *)delay1U outdelay1_donttouch (.inR(o_free1), .outR(w_ofree_5[1]), .rstn(rstn));
(* dont_touch="true" *)delay1U outdelay2_donttouch (.inR(o_free2), .outR(w_ofree_5[2]), .rstn(rstn));
(* dont_touch="true" *)delay1U outdelay3_donttouch (.inR(o_free3), .outR(w_ofree_5[3]), .rstn(rstn));
(* dont_touch="true" *)delay1U outdelay4_donttouch (.inR(o_free4), .outR(w_ofree_5[4]), .rstn(rstn));


assign w_Trig[0] = i_drive0&(~w_Req[0]) | w_ofree_5[0]&w_Req[0];
assign w_Trig[1] = i_drive1&(~w_Req[1]) | w_ofree_5[1]&w_Req[1];
assign w_Trig[2] = i_drive2&(~w_Req[2]) | w_ofree_5[2]&w_Req[2];
assign w_Trig[3] = i_drive3&(~w_Req[3]) | w_ofree_5[3]&w_Req[3];
assign w_Trig[4] = i_drive4&(~w_Req[4]) | w_ofree_5[4]&w_Req[4];

contTap t0(
.trig(w_Trig[0]),
.req(w_Req[0]),
.rstn(rstn)
);
contTap t1(
.trig(w_Trig[1]),
.req(w_Req[1]),
.rstn(rstn)
);
contTap t2(
.trig(w_Trig[2]),
.req(w_Req[2]),
.rstn(rstn)
);
contTap t3(
.trig(w_Trig[3]),
.req(w_Req[3]),
.rstn(rstn)
);
contTap t4(
.trig(w_Trig[4]),
.req(w_Req[4]),
.rstn(rstn)
);

freeSetDelay #(
    .DELAY_UNIT_NUM(4)
) u_freeSetDelay (
    .i_signal(i_drive0 | i_drive1 | i_drive2 | i_drive3|i_drive4),
    .o_signal(o_driveNext),
    .rstn    (rstn)
);
delay4U u_delay4U_free0_donttouch(
    .inR  ( i_freeNext & w_Req[0]  ),
    .outR ( o_free0 ),
    .rstn  ( rstn  )
);
delay4U u_delay4U_free1_donttouch(
    .inR  ( i_freeNext & w_Req[1]  ),
    .outR ( o_free1 ),
    .rstn  ( rstn  )
);
delay4U u_delay4U_free2_donttouch(
    .inR  ( i_freeNext & w_Req[2]  ),
    .outR ( o_free2 ),
    .rstn  ( rstn  )
);
delay4U u_delay4U_free3_donttouch(
    .inR  ( i_freeNext & w_Req[3]  ),
    .outR ( o_free3 ),
    .rstn  ( rstn  )
);
delay4U u_delay4U_free4_donttouch(
    .inR  ( i_freeNext & w_Req[4]  ),
    .outR ( o_free4 ),
    .rstn  ( rstn  )
);


assign w_data = (w_Req[0] == 1'b1) ? i_data0 :
		    	(w_Req[1] == 1'b1) ? i_data1 :
                (w_Req[2] == 1'b1) ? i_data2 :
                (w_Req[3] == 1'b1) ? i_data3 :
                (w_Req[4] == 1'b1) ? i_data4 :
                {DATA_WIDTH{1'b0}};

assign o_data = w_data;

endmodule
