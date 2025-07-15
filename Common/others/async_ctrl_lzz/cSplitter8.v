//======================================================
// Project: SOLVA
// Module:  cSplitter8
// Author:  zhuangzhuang Liao
// Mail：   lzhuangzhuang2023@lzu.edu.cn
// Date:    2025-05-28
// Description: parameterized 8-input cSplitter
//======================================================
 module cSplitter8#(
    parameter DATA_WIDTHI=32,
    parameter COPY=0,//!表示完全copy
    parameter SPLITTER=1,//!表示分流
    parameter DATA_WIDTHOUT0=5,//!第一路位宽
    parameter DATA_WIDTHOUT1=10,
    parameter DATA_WIDTHOUT2=3,
    parameter DATA_WIDTHOUT3=2,
    parameter DATA_WIDTHOUT4=5,
    parameter DATA_WIDTHOUT5=5,
    parameter DATA_WIDTHOUT6=1,
    parameter DATA_WIDTHOUT7=1
 )(
    input  wire i_drive,
    input  wire [8-1:0] i_freeNext_8,
    input  wire [DATA_WIDTHI-1:0] i_data,

    output wire o_free,
    output wire [8-1:0] o_driveNext_8,
    output wire [COPY*DATA_WIDTHI+SPLITTER*DATA_WIDTHOUT0-1:0] o_data0,
    output wire [COPY*DATA_WIDTHI+SPLITTER*DATA_WIDTHOUT1-1:0] o_data1,
    output wire [COPY*DATA_WIDTHI+SPLITTER*DATA_WIDTHOUT2-1:0] o_data2,
    output wire [COPY*DATA_WIDTHI+SPLITTER*DATA_WIDTHOUT3-1:0] o_data3,
    output wire [COPY*DATA_WIDTHI+SPLITTER*DATA_WIDTHOUT4-1:0] o_data4,
    output wire [COPY*DATA_WIDTHI+SPLITTER*DATA_WIDTHOUT5-1:0] o_data5,
    output wire [COPY*DATA_WIDTHI+SPLITTER*DATA_WIDTHOUT6-1:0] o_data6,
    output wire [COPY*DATA_WIDTHI+SPLITTER*DATA_WIDTHOUT7-1:0] o_data7,

    input wire rstn
);
 
 (*dont_touch = "yes"*)wire w_sendFree;
 (*dont_touch = "yes"*)wire w_d_sendFree;
 (*dont_touch = "yes"*)wire [8-1:0] w_Trig_8;
 (*dont_touch = "yes"*)wire [8-1:0] w_Req_8;
 (*dont_touch = "yes"*)wire w_dirveReq;
 (*dont_touch = "yes"*)wire w_andReq;

 
 assign o_data0=i_data[DATA_WIDTHI-1:DATA_WIDTHI-SPLITTER*DATA_WIDTHOUT0-COPY*DATA_WIDTHI];
 assign o_data1=i_data[DATA_WIDTHI-1-SPLITTER*DATA_WIDTHOUT0:DATA_WIDTHI-SPLITTER*(DATA_WIDTHOUT0+DATA_WIDTHOUT1)-COPY*DATA_WIDTHI];
 assign o_data2=i_data[DATA_WIDTHI-1-SPLITTER*(DATA_WIDTHOUT0+DATA_WIDTHOUT1):DATA_WIDTHI-SPLITTER*(DATA_WIDTHOUT0+DATA_WIDTHOUT1+DATA_WIDTHOUT2)-COPY*DATA_WIDTHI];
 assign o_data3=i_data[DATA_WIDTHI-1-SPLITTER*(DATA_WIDTHOUT0+DATA_WIDTHOUT1+DATA_WIDTHOUT2):DATA_WIDTHI-SPLITTER*(DATA_WIDTHOUT0+DATA_WIDTHOUT1+DATA_WIDTHOUT2+DATA_WIDTHOUT3)-COPY*DATA_WIDTHI];
 assign o_data4=i_data[DATA_WIDTHI-1-SPLITTER*(DATA_WIDTHOUT0+DATA_WIDTHOUT1+DATA_WIDTHOUT2+DATA_WIDTHOUT3):DATA_WIDTHI-SPLITTER*(DATA_WIDTHOUT0+DATA_WIDTHOUT1+DATA_WIDTHOUT2+DATA_WIDTHOUT3+DATA_WIDTHOUT4)-COPY*DATA_WIDTHI];
 assign o_data5=i_data[DATA_WIDTHI-1-SPLITTER*(DATA_WIDTHOUT0+DATA_WIDTHOUT1+DATA_WIDTHOUT2+DATA_WIDTHOUT3+DATA_WIDTHOUT4):DATA_WIDTHI-SPLITTER*(DATA_WIDTHOUT0+DATA_WIDTHOUT1+DATA_WIDTHOUT2+DATA_WIDTHOUT3+DATA_WIDTHOUT4+DATA_WIDTHOUT5)-COPY*DATA_WIDTHI];
 assign o_data6=i_data[DATA_WIDTHI-1-SPLITTER*(DATA_WIDTHOUT0+DATA_WIDTHOUT1+DATA_WIDTHOUT2+DATA_WIDTHOUT3+DATA_WIDTHOUT4+DATA_WIDTHOUT5):DATA_WIDTHI-SPLITTER*(DATA_WIDTHOUT0+DATA_WIDTHOUT1+DATA_WIDTHOUT2+DATA_WIDTHOUT3+DATA_WIDTHOUT4+DATA_WIDTHOUT5+DATA_WIDTHOUT6)-COPY*DATA_WIDTHI];
 assign o_data7=i_data[DATA_WIDTHI-1-SPLITTER*(DATA_WIDTHOUT0+DATA_WIDTHOUT1+DATA_WIDTHOUT2+DATA_WIDTHOUT3+DATA_WIDTHOUT4+DATA_WIDTHOUT5+DATA_WIDTHOUT6):DATA_WIDTHI-SPLITTER*(DATA_WIDTHOUT0+DATA_WIDTHOUT1+DATA_WIDTHOUT2+DATA_WIDTHOUT3+DATA_WIDTHOUT4+DATA_WIDTHOUT5+DATA_WIDTHOUT6+DATA_WIDTHOUT7)-COPY*DATA_WIDTHI];
 
 assign w_andReq = & w_Req_8;
 assign w_sendFree = w_dirveReq & w_andReq;
 wire w_d_andReq;
 delay2U delay_dandreq (.inR(w_andReq), .outR(w_d_andReq), .rstn(rstn));

 (* dont_touch="true" *)freeSetDelay#(
   .DELAY_UNIT_NUM ( 4 )
 )delay_sendFree(
    .i_signal ( w_sendFree ),
    .o_signal ( w_d_sendFree ),
    .rstn      ( rstn )
 );

 delay2U delayDSendfree_donttouch (.inR(w_d_sendFree), .outR(o_free), .rstn(rstn));

 contTap driveTap(
   .trig((i_drive&(~w_dirveReq)) | w_d_andReq),
   .req(w_dirveReq),
   .rstn(rstn)
 ); 

 genvar tap_i;
 generate
   for (tap_i =0 ;tap_i<8 ;tap_i=tap_i+1 ) begin:gen_contap
      assign w_Trig_8[tap_i] = i_freeNext_8[tap_i]&(~w_Req_8[tap_i]) | w_d_sendFree;
      contTap tapifree(
         .trig(w_Trig_8[tap_i]),
         .req(w_Req_8[tap_i]),
         .rstn(rstn)
         );
      assign o_driveNext_8[tap_i] = i_drive;
   end
 endgenerate

 
 endmodule
 
 