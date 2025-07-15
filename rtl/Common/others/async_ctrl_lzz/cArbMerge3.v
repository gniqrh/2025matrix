//======================================================
// Project: SOLVA
// Module:  cArbMerge3
// Author:  zhuangzhuang Liao
// Reviser: jinyu Yang
// Mail：   lzhuangzhuang2023@lzu.edu.cn
// Date:    2025-05-28
// Description: parameterized 3-input cArbMerge
// Tips:   This module is used to merge three input data streams, encode=utf-8.
//======================================================
module cArbMerge3
#(
	parameter DATA_WIDTH=32
)(
    input [3-1:0] i_drive_3,
    input [DATA_WIDTH-1:0] i_data0,
    input [DATA_WIDTH-1:0] i_data1,
    input [DATA_WIDTH-1:0] i_data2,
    input i_freeNext,
    input rstn,

    output [3-1:0] o_free_3,
    output o_driveNext,
    output [DATA_WIDTH-1:0] o_data
);

  localparam DELAY_CL = 15;//为了匹配仲裁器组合电路的时间+MUX时间

  (* dont_touch="true" *)wire [3-1:0] w_fire_3;
  (* dont_touch="true" *)wire [3-1:0] w_driveNext_3;
  (* dont_touch="true" *)wire [3-1:0] w_d_fire_3;

  (* dont_touch="true" *)wire w_sendFire_1;

  (* dont_touch="true" *)wire [3-1:0] w_reset_3;

  (* dont_touch="true" *)wire [3-1:0] w_trig_3;

  (* dont_touch="true" *)wire [3-1:0] w_req_3;

  (* dont_touch="true" *)wire [DATA_WIDTH-1:0] w_data0, w_data1, w_data2;
  (* dont_touch="true" *)reg [DATA_WIDTH-1:0] r_wdata;

  (* dont_touch="true" *)reg [DATA_WIDTH-1:0]r_data0,r_data1,r_data2, r_data;

  (* dont_touch="true" *)wire w_sendFinish;
  (* dont_touch="true" *)wire pmt;
  (* dont_touch="true" *)wire pmtFinish;
  (* dont_touch="true" *)wire w_sendDrive;
  (* dont_touch="true" *)wire w_sendDrive0;
  (* dont_touch="true" *)wire w_sendDrive1;
  (* dont_touch="true" *)wire w_sendFree;
  (* dont_touch="true" *)wire [3-1:0] w_grant_3;
  (* dont_touch="true" *)wire [3-1:0] w_pmtIfreeNext_3;
  wire w_freeNext;
  wire [1:0] w_ifreeReq;

  // save inputs
  genvar i;
  generate
    for (i = 0; i < 3; i = i + 1) begin : pmt_fifo
      assign w_pmtIfreeNext_3[i]=w_sendFire_1 & w_grant_3[i];
      cPmtFifo1 PmtFifo (
          .i_drive(i_drive_3[i]),
          .i_freeNext(w_pmtIfreeNext_3[i]),
          .o_free(o_free_3[i]),
          .o_driveNext(w_driveNext_3[i]),
          .o_fire_1(w_fire_3[i]),
          .pmt(pmt),
          .rstn(rstn)
      );
      assign w_trig_3[i]  = w_fire_3[i] | w_reset_3[i];
      assign w_reset_3[i] = w_grant_3[i] & w_freeNext;
      contTap tap (
          .trig(w_trig_3[i]),
          .req (w_req_3[i]),
          .rstn (rstn)
      );
      (* dont_touch="true" *)freeSetDelay #(
        .DELAY_UNIT_NUM( DELAY_CL )
      ) delayDriveNext (
          .i_signal(w_fire_3[i]),
          .o_signal(w_d_fire_3[i]),
          .rstn     (rstn)
      );
    end
  endgenerate


  always @(posedge w_fire_3[0] or negedge rstn) begin
    if (!rstn) begin
      r_data0 <= {DATA_WIDTH{1'b0}};
    end else begin
      r_data0 <= i_data0;
    end
  end
  assign w_data0 = r_data0;

  always @(posedge w_fire_3[1] or negedge rstn) begin
    if (!rstn) begin
      r_data1 <= {DATA_WIDTH{1'b0}};
    end else begin
      r_data1 <= i_data1;
    end
  end
  assign w_data1 = r_data1;

  always @(posedge w_fire_3[2] or negedge rstn) begin
    if (!rstn) begin
      r_data2 <= {DATA_WIDTH{1'b0}};
    end else begin
      r_data2 <= i_data2;
    end
  end
  assign w_data2 = r_data2;


  //lock
  assign pmt = ~(|w_req_3);

  // grant
  assign w_grant_3 = w_req_3 & (~w_req_3 + 1'b1);

  // Shorten pulse width
  contTap d_ifreeNext (
    .trig(i_freeNext),
    .req (w_ifreeReq[0]),
    .rstn (rstn)
  );
  delay2U delayifreeReq_donttouch(.inR(w_ifreeReq[0]),.rstn(rstn), .outR(w_ifreeReq[1]));
  assign w_freeNext = w_ifreeReq[0]^w_ifreeReq[1];

  //sendFifo
  assign w_sendDrive0 = (|(w_d_fire_3 & w_grant_3));

  assign pmtFinish = (w_req_3==w_grant_3)?1'b0:1'b1;
  (* dont_touch="true" *)freeSetDelay #(
    .DELAY_UNIT_NUM(DELAY_CL)
  ) delayW_sendFire (
      .i_signal( (|w_reset_3) & pmtFinish),
      .o_signal(w_sendDrive1),
      .rstn     (rstn)
  );
  assign w_sendDrive = w_sendDrive0 | w_sendDrive1;

  cFifo1 sendFifo (
      .i_drive(w_sendDrive),
      .i_freeNext(i_freeNext),
      .o_free(w_sendFree),
      .o_driveNext(o_driveNext),
      .o_fire_1(w_sendFire_1),
      .rstn(rstn)
  );

  always @(posedge w_sendFire_1 or negedge rstn) begin
    if (!rstn) begin
      r_data <= {DATA_WIDTH{1'b0}};
    end else begin
      r_data <= r_wdata;
    end
  end
  assign o_data = r_data;

  //Mux
  always @(w_grant_3) begin
    case (w_grant_3)
        3'b001: r_wdata <= w_data0 ;
        3'b010: r_wdata <= w_data1 ;
        3'b100: r_wdata <= w_data2 ;
        default : r_wdata <= {DATA_WIDTH{1'b0}};
    endcase
  end

endmodule  //cArbMerge3