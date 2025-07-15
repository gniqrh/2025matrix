//-----------------------------------------------
//	module name: cCopyFork3
//	author: Tong Fu, Lingzhuang Zhang
//	version: 1st version (2022-11-02)
//-----------------------------------------------

`timescale 1ns / 1ps

module cCopyFork3 (
    // in -->
    input       i_drive     ,
    output      o_free      ,
    // --> out0
    output      o_driveNext0,
    input       i_freeNext0 ,
    // --> out1
    output      o_driveNext1,
    input       i_freeNext1 ,
    // --> out2
    output      o_driveNext2,
    input       i_freeNext2 
);

// control logic
assign o_driveNext0 = i_drive;
assign o_driveNext1 = i_drive;
assign o_driveNext2 = i_drive;

// simple free signal
// here can make some changes, if you need.
assign o_free       = i_freeNext0 | i_freeNext1 | i_freeNext2;

endmodule

