`timescale 1ns / 1ps
//======================================================
// Project: mmu_asic
// Module:  cSelector3_mmu
// Author:  Yang Yuyuan
// Date:    2024/11/7
// Description: 
// 1.Instantiation: cSelector2_mmu #(2) u_cSelector2_mmu(...);
//		    cSelector2_mmu #(.NUM_PORTS(2)) u_cSelector2_mmu(...);
//
// 2.Modification: Modify the modelname (cSelectorX_mmu, NUM_PORTS)
//		   Modify the interface (o_driveNext0, i_freeNext0)
//		   Modify the signal (w_freeNext, o_driveNext)
//======================================================

module cSelector2_nodata #(
    parameter NUM_PORTS = 2
) (
    input                 rstn,
    input [NUM_PORTS-1:0] i_select,

    input  i_drive,
    output o_free,

    output o_driveNext0,
    input  i_freeNext0,

    output o_driveNext1,
    input  i_freeNext1

);

    wire [1:0] w_outRRelay_2, w_outARelay_2;
    wire w_freeNext, w_driveNext, w_fire;

    assign w_freeNext   = i_freeNext0 | i_freeNext1;
    assign o_driveNext0 = w_fire & i_select[0];
    assign o_driveNext1 = w_fire & i_select[1];

    sender sender (
        .i_drive(i_drive),
        .o_free (o_free),
        .outR   (w_outRRelay_2[0]),
        .i_free (w_freeNext),
        .rstn   (rstn)
    );

    relay relay (
        .inR (w_outRRelay_2[0]),
        .inA (w_outARelay_2[0]),
        .outR(w_outRRelay_2[1]),
        .outA(w_outARelay_2[1]),
        .fire(w_fire),
        .rstn(rstn)
    );

    receiver receiver (
        .inR       (w_outRRelay_2[1]),
        .inA       (w_outARelay_2[1]),
        .i_freeNext(w_freeNext),
        .rstn      (rstn)
    );

endmodule