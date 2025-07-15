//===============================================================================
// Project:        RCA
// Module:         ConfMerge_4
// Author:         YiHua Lu
// Date:           2025/06/22
// Description:    四路互斥融合; 不带数据版;
//===============================================================================
`timescale 1ns / 1ps

module ConfMerge_4(
    input        i_drive0,
    output       o_free0,
    input        i_drive1,
    output       o_free1,
    input        i_drive2,
    output       o_free2,
    input        i_drive3,
    output       o_free3,

    output       o_driveNext,
    input        i_freeNext,
    input        rst
);

// 中间握手信号
wire w_req[3:0];
wire w_free[3:0];
wire w_free_delay[3:0];
wire w_trig[3:0];

// delay + contTap 组合
genvar i;
generate
    for (i = 0; i < 4; i = i + 1) begin: handshake
        delay1U u_delay (
            .inR(w_free[i]),
            .outR(w_free_delay[i]),
            .rst(rst)
        );
        assign w_trig[i] = ( (i == 0 ? i_drive0 : 
                              i == 1 ? i_drive1 : 
                              i == 2 ? i_drive2 : i_drive3) & ~w_req[i] ) | 
                           (w_free_delay[i] & w_req[i]);

        contTap u_tap (
            .trig(w_trig[i]),
            .req (w_req[i]),
            .rst (rst)
        );
    end
endgenerate

// free 输出逻辑
assign w_free[0] = i_freeNext & w_req[0];
assign w_free[1] = i_freeNext & w_req[1];
assign w_free[2] = i_freeNext & w_req[2];
assign w_free[3] = i_freeNext & w_req[3];

assign o_free0 = w_free[0];
assign o_free1 = w_free[1];
assign o_free2 = w_free[2];
assign o_free3 = w_free[3];

// driveNext 输出
assign o_driveNext = i_drive0 | i_drive1 | i_drive2 | i_drive3;

endmodule
