//======================================================
// Project: SOLVA
// Module:  cSplitter2
// Author:  longtao zhang , zhuangzhuang Liao
// Mail：   lzhuangzhuang2023@lzu.edu.cn
// Date:    2025-05-28
// Description: parameterized two-input cSplitter
//======================================================
 `timescale 1ns / 1ps

 module cSplitter2#(
    parameter DATA_WIDTHI=32,
    parameter DATA_WIDTHOUT0=12,//!第一路位宽
    parameter DATA_WIDTHOUT1=DATA_WIDTHOUT0==DATA_WIDTHI?DATA_WIDTHI:DATA_WIDTHI-DATA_WIDTHOUT0//!第二路位宽
 )(
    input  wire i_drive,
    input  wire i_freeNext0,i_freeNext1,
    input  wire [DATA_WIDTHI-1:0] i_data,

    output wire o_free,
    output wire o_driveNext0,o_driveNext1,
    output wire [DATA_WIDTHOUT0-1:0] o_data0,
    output wire [DATA_WIDTHOUT1-1:0] o_data1,

    input wire rstn
);
 
(*dont_touch = "yes"*)wire w_sendFree;
(*dont_touch = "yes"*)wire w_d_sendFree;
(*dont_touch = "yes"*)wire w_firstReq;
(*dont_touch = "yes"*)wire w_secondReq;
(*dont_touch = "yes"*)wire w_dirveReq;
(*dont_touch = "yes"*)wire w_andReq;

 
 assign o_data0 = i_data[DATA_WIDTHOUT0-1:0];//取低位
 assign o_data1 = i_data[DATA_WIDTHI-1:DATA_WIDTHI-DATA_WIDTHOUT1];//取高位
 
 assign w_andReq = w_firstReq & w_secondReq;
 assign w_sendFree = w_dirveReq & w_andReq;

//  delay time must > width of w_sendFree;
//  width of w_sendFree is about time of contTap trig to req
//  (* dont_touch="true" *)freeSetDelay#(
//      .DELAY_UNIT_NUM ( 1 )
//  )delay_sendFree(
//      .i_signal ( w_sendFree ),
//      .o_signal ( w_d_sendFree ),
//      .rstn      ( rstn )
//  );
 wire w_d_andReq;
 delay2U delay_dandreq (.inR(w_andReq), .outR(w_d_andReq), .rstn(rstn));
 delay1U delay_sendFree (.inR(w_sendFree), .outR(w_d_sendFree), .rstn(rstn));

//  wait w_firstReq and w_secondReq 1->0 and then send o_free
 (* dont_touch="true" *)delay1U delayDSendfree_donttouch (.inR(w_d_sendFree), .outR(o_free), .rstn(rstn));

//  符号| 左边的写法能够避免原本因为drive脉宽过宽导致的屏蔽 符号| 右边的变量的上升沿
 contTap driveTap(
   .trig((i_drive&(~w_dirveReq)) | w_d_andReq),
   .req(w_dirveReq),
   .rstn(rstn)
 ); 
 
 contTap firstTap(
 .trig((i_freeNext0&(~w_firstReq)) | w_d_sendFree),
 .req(w_firstReq),
 .rstn(rstn)
 );
 
 contTap secondTap(
 .trig((i_freeNext1&(~w_secondReq)) | w_d_sendFree),
 .req(w_secondReq),
 .rstn(rstn)
 );

 assign o_driveNext0 = i_drive;
 assign o_driveNext1 = i_drive;
 
 endmodule
 
 