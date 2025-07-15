//-----------------------------------------------
//	module name: cCondfork5
//	author: Tong Fu, Lingzhuang Zhang
//	version: 1st version (2022-11-02)
//-----------------------------------------------

`timescale 1ns / 1ps

module cCondFork5 (
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
    input       valid1      ,
    // --> out2
    output      o_driveNext2,
    input       i_freeNext2 ,
    input       valid2      ,
    // --> out3
    output      o_driveNext3,
    input       i_freeNext3 ,
    input       valid3      ,
    // --> out4
    output      o_driveNext4,
    input       i_freeNext4 ,
    input       valid4
);

// control logic
assign o_driveNext0 = i_drive & valid0;
assign o_driveNext1 = i_drive & valid1;
assign o_driveNext2 = i_drive & valid2;
assign o_driveNext3 = i_drive & valid3;
assign o_driveNext4 = i_drive & valid4;

// simple free signal
// here can make some changes, if you need.
assign o_free       = i_freeNext0 | i_freeNext1 | i_freeNext2 | i_freeNext3 | i_freeNext4;

endmodule

