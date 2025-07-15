//======================================================
// Project: SOLVA
// Module:  cArbMerge2
// Author:  zhuangzhuang Liao
// Reviser: jinyu Yang
// Mail：   lzhuangzhuang2023@lzu.edu.cn
// Date:    2025-05-28
// Description: parameterized two-input cArbMerge
// Tips:   This module is used to merge two input data streams, encode=utf-8.
//======================================================

module cArbMerge2
#(
	parameter DATA_WIDTH=105
)(
    input [2-1:0] i_drive_2,
    input [DATA_WIDTH-1:0] i_data0,
    input [DATA_WIDTH-1:0] i_data1,
    input i_freeNext,
    input rstn,

    output [2-1:0] o_free_2,
    output o_driveNext,
    output [DATA_WIDTH-1:0] o_data
);

  localparam DELAY_CL = 7;
  // 为了匹配仲裁器组合电路的时间+MUX时间
  // to match the delay of the arbiter and MUX
  (* dont_touch="true" *)wire [2-1:0] w_fire_2;
  (* dont_touch="true" *)wire [2-1:0] w_driveNext_2;
  (* dont_touch="true" *)wire [2-1:0] w_d_fire_2;

  (* dont_touch="true" *)wire [2-1:0] w_sendFire_2;

  (* dont_touch="true" *)wire [2-1:0] w_reset_2;

  (* dont_touch="true" *)wire [2-1:0] w_trig_2;

  (* dont_touch="true" *)wire [2-1:0] w_req_2;

  (* dont_touch="true" *)wire [DATA_WIDTH-1:0] w_data0, w_data1;
  (* dont_touch="true" *)wire [DATA_WIDTH-1:0] w_wdata;

  (* dont_touch="true" *)reg [DATA_WIDTH-1:0]r_data0,r_data1, r_data;

  (* dont_touch="true" *)wire w_sendFinish;
  (* dont_touch="true" *)wire pmt;
  (* dont_touch="true" *)wire pmtFinish;
  (* dont_touch="true" *)wire w_sendDrive;
  (* dont_touch="true" *)wire w_sendDrive0;
  (* dont_touch="true" *)wire w_sendDrive1;
  (* dont_touch="true" *)wire w_sendFree;
  (* dont_touch="true" *)wire [2-1:0] w_grant_2;
  (* dont_touch="true" *)wire [2-1:0] w_pmtIfreeNext_2;
  wire w_freeNext;
  wire [2-1:0] w_ifreeReq_2;

  // save inputs
  // 保存输入数据
  genvar i;
  generate
    for (i = 0; i < 2; i = i + 1) begin : pmt_fifo
      assign w_pmtIfreeNext_2[i]=w_sendFire_2[1] & w_grant_2[i];
      cPmtFifo1 PmtFifo (
          .i_drive(i_drive_2[i]),
          .i_freeNext(w_pmtIfreeNext_2[i]),
          .o_free(o_free_2[i]),
          .o_driveNext(w_driveNext_2[i]),
          .o_fire_1(w_fire_2[i]),
          .pmt(pmt),
          .rstn(rstn)
      );
      assign w_trig_2[i]  = w_fire_2[i] | w_reset_2[i];
      assign w_reset_2[i] = w_grant_2[i] & w_freeNext;
      contTap tap (
          .trig(w_trig_2[i]),
          .req (w_req_2[i]),
          .rstn (rstn)
      );
      (* dont_touch="true" *)freeSetDelay #(
        .DELAY_UNIT_NUM( DELAY_CL )
      ) delayDriveNext (
          .i_signal(w_fire_2[i]),
          .o_signal(w_d_fire_2[i]),
          .rstn     (rstn)
      );
    end
  endgenerate


  always @(posedge w_fire_2[0] or negedge rstn) begin
    if (!rstn) begin
      r_data0 <= {DATA_WIDTH{1'b0}};
    end else begin
      r_data0 <= i_data0;
    end
  end
  assign w_data0 = r_data0;

  always @(posedge w_fire_2[1] or negedge rstn) begin
    if (!rstn) begin
      r_data1 <= {DATA_WIDTH{1'b0}};
    end else begin
      r_data1 <= i_data1;
    end
  end
  assign w_data1 = r_data1;


  //lock
  //锁存请求信号
  assign pmt = ~(|w_req_2);

  // grant
  // 仲裁器
  CL_grant#(
      .DATA_WIDTH ( 2 )
  )u_CL_grant(
      .i_req (w_req_2),
      .o_grant  (w_grant_2),
      .o_pmtFinish(pmtFinish)
  );

  // Shorten pulse width
  // 缩短脉冲宽度
  contTap d_ifreeNext (
    .trig(i_freeNext),
    .req (w_ifreeReq_2[0]),
    .rstn (rstn)
  );
  delay2U delayifreeReq_donttouch(.inR(w_ifreeReq_2[0]),.rstn(rstn), .outR(w_ifreeReq_2[1]));
  assign w_freeNext = w_ifreeReq_2[0]^w_ifreeReq_2[1];

  //sendFifo
  //发送FIFO
  assign w_sendDrive0 = (|(w_d_fire_2 & w_grant_2));

  // assign pmtFinish = (w_req_2==w_grant_2)?1'b0:1'b1;
  // assign pmtFinish = |w_grant_2;
  wire w_d_freeNext;
  delay3U delayd_freeNext_donttouch(.inR(w_freeNext),.rstn(rstn), .outR(w_d_freeNext));
  (* dont_touch="true" *)freeSetDelay #(
    .DELAY_UNIT_NUM(DELAY_CL)
  ) delayW_sendFire (
      .i_signal(w_d_freeNext & pmtFinish),
      .o_signal(w_sendDrive1),
      .rstn     (rstn)
  );
  assign w_sendDrive = w_sendDrive0 | w_sendDrive1;

  wire w_driveNext;
  cFifoN #(
    .RELAY_NUMS  ( 2 )
  )sendFifo (
      .i_drive(w_sendDrive),
      .i_freeNext(i_freeNext),
      .o_free(w_sendFree),
      .o_driveNext(w_driveNext),
      .o_fire_n(w_sendFire_2),
      .rstn(rstn)
  );

  delay3U delay_odrive_donttouch(.inR(w_driveNext),.rstn(rstn), .outR(o_driveNext));

  always @(posedge w_sendFire_2[1] or negedge rstn) begin
    if (!rstn) begin
      r_data <= {DATA_WIDTH{1'b0}};
    end else begin
      r_data <= w_wdata;
    end
  end
  assign o_data = r_data;

  //Mux
  // always @(w_grant_2) begin
  //   case (w_grant_2)
  //       2'b01: w_wdata <= w_data0 ;
  //       2'b10: w_wdata <= w_data1 ;
  //       default : w_wdata <= {DATA_WIDTH{1'b0}};
  //   endcase
  // end
  CL_MUX2#(
      .DATA_WIDTH ( DATA_WIDTH )
  )u_CL_MUX2(
      .i_sel   (w_grant_2),
      .i_data0 (w_data0),
      .i_data1 (w_data1),
      .o_data  (w_wdata)
  );

endmodule  //cArbMerge2
