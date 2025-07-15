//-----------------------------------------------
//	module name: cCondfork5_32b
//	author: Tong Fu, Lingzhuang Zhang
//	version: 1st version (2022-11-02)
//-----------------------------------------------

`timescale 1ns / 1ps

module cCondFork2 (
    // in -->
    input       i_drive     ,
    output      o_free      ,
    // --> out0
    output      o_driveNext0,
    input       i_freeNext0 ,
    input       valid0      ,
    // --> out1
    output      o_driveNext1,
    input       i_freeNext1 ,
    input       valid1
);

// control logic
assign o_driveNext0 = i_drive & valid0;
assign o_driveNext1 = i_drive & valid1;
// simple free signal
// here can make some changes, if you need.
assign o_free       = i_freeNext0 | i_freeNext1;

endmodule

