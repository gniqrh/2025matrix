//======================================================
// Project: SOLVA
// Module:  cArbMerge8
// Author:  zhuangzhuang Liao
// Reviser: jinyu Yang
// Mail：   lzhuangzhuang2023@lzu.edu.cn
// Date:    2025-05-28
// Description: parameterized 8-input cArbMerge
//======================================================
module cArbMerge8 #(
    parameter DATA_WIDTH = 12
) (
    input [8-1:0] i_drive_8,
    input [DATA_WIDTH-1:0] i_data0,
    input [DATA_WIDTH-1:0] i_data1,
    input [DATA_WIDTH-1:0] i_data2,
    input [DATA_WIDTH-1:0] i_data3,
    input [DATA_WIDTH-1:0] i_data4,
    input [DATA_WIDTH-1:0] i_data5,
    input [DATA_WIDTH-1:0] i_data6,
    input [DATA_WIDTH-1:0] i_data7,
    input i_freeNext,
    input rstn,

    output [8-1:0] o_free_8,
    output o_driveNext,
    output [DATA_WIDTH-1:0] o_data
);

  localparam DELAY_CL = 15;//为了匹配仲裁器组合电路的时间+MUX时间

  (* dont_touch="true" *)wire [8-1:0] w_fire_8;
  (* dont_touch="true" *)wire [8-1:0] w_driveNext_8;
  (* dont_touch="true" *)wire [8-1:0] w_d_fire_8;

  (* dont_touch="true" *)wire w_sendFire_1;

  (* dont_touch="true" *)wire [8-1:0] w_reset_8;

  (* dont_touch="true" *)wire [8-1:0] w_trig_8;

  (* dont_touch="true" *)wire [8-1:0] w_req_8;

  (* dont_touch="true" *)wire [DATA_WIDTH-1:0] w_data0, w_data1, w_data2, w_data3, w_data4, w_data5, w_data6, w_data7;
  (* dont_touch="true" *)reg [DATA_WIDTH-1:0] r_wdata;

  (* dont_touch="true" *)reg [DATA_WIDTH-1:0]r_data0, r_data1, r_data2, r_data3, r_data4, r_data5, r_data6, r_data7, r_data;

  (* dont_touch="true" *)wire w_sendFinish;
  (* dont_touch="true" *)wire pmt;
  (* dont_touch="true" *)wire pmtFinish;
  (* dont_touch="true" *)wire w_sendDrive;
  (* dont_touch="true" *)wire w_sendDrive0;
  (* dont_touch="true" *)wire w_sendDrive1;
  (* dont_touch="true" *)wire w_sendFree;
  (* dont_touch="true" *)wire [8-1:0] w_grant_8;
  (* dont_touch="true" *)wire [8-1:0] w_pmtIfreeNext_8;
  wire w_freeNext;
  wire [2-1:0] w_ifreeReq_2;
  
  // save inputs
  genvar i;
  generate
    for (i = 0; i < 8; i = i + 1) begin : pmt_fifo
      assign w_pmtIfreeNext_8[i]=w_sendFire_1 & w_grant_8[i];
      cPmtFifo1 PmtFifo (
          .i_drive(i_drive_8[i]),
          .i_freeNext(w_pmtIfreeNext_8[i]),
          .o_free(o_free_8[i]),
          .o_driveNext(w_driveNext_8[i]),
          .o_fire_1(w_fire_8[i]),
          .pmt(pmt),
          .rstn(rstn)
      );
      assign w_trig_8[i]  = w_fire_8[i] | w_reset_8[i];
      assign w_reset_8[i] = w_grant_8[i] & w_freeNext;
      contTap tap (
          .trig(w_trig_8[i]),
          .req (w_req_8[i]),
          .rstn (rstn)
      );
      (* dont_touch="true" *)freeSetDelay #(
        .DELAY_UNIT_NUM( DELAY_CL )
      ) delayDriveNext (
          .i_signal(w_fire_8[i]),
          .o_signal(w_d_fire_8[i]),
          .rstn     (rstn)
      );
    end
  endgenerate


  always @(posedge w_fire_8[0] or negedge rstn) begin
    if (!rstn) begin
      r_data0 <= {DATA_WIDTH{1'b0}};
    end else begin
      r_data0 <= i_data0;
    end
  end
  assign w_data0 = r_data0;

  always @(posedge w_fire_8[1] or negedge rstn) begin
    if (!rstn) begin
      r_data1 <= {DATA_WIDTH{1'b0}};
    end else begin
      r_data1 <= i_data1;
    end
  end
  assign w_data1 = r_data1;

  always @(posedge w_fire_8[2] or negedge rstn) begin
    if (!rstn) begin
      r_data2 <= {DATA_WIDTH{1'b0}};
    end else begin
      r_data2 <= i_data2;
    end
  end
  assign w_data2 = r_data2;

  always @(posedge w_fire_8[3] or negedge rstn) begin
    if (!rstn) begin
      r_data3 <= {DATA_WIDTH{1'b0}};
    end else begin
      r_data3 <= i_data3;
    end
  end
  assign w_data3 = r_data3;

  always @(posedge w_fire_8[4] or negedge rstn) begin
    if (!rstn) begin
      r_data4 <= {DATA_WIDTH{1'b0}};
    end else begin
      r_data4 <= i_data4;
    end
  end
  assign w_data4 = r_data4;

  always @(posedge w_fire_8[5] or negedge rstn) begin
    if (!rstn) begin
      r_data5 <= {DATA_WIDTH{1'b0}};
    end else begin
      r_data5 <= i_data5;
    end
  end
  assign w_data5 = r_data5;

  always @(posedge w_fire_8[6] or negedge rstn) begin
    if (!rstn) begin
      r_data6 <= {DATA_WIDTH{1'b0}};
    end else begin
      r_data6 <= i_data6;
    end
  end
  assign w_data6 = r_data6;

  always @(posedge w_fire_8[7] or negedge rstn) begin
    if (!rstn) begin
      r_data7 <= {DATA_WIDTH{1'b0}};
    end else begin
      r_data7 <= i_data7;
    end
  end
  assign w_data7 = r_data7;

  //lock
  assign pmt = ~(|w_req_8);

  // grant
  assign w_grant_8 = w_req_8 & (~w_req_8 + 1'b1);

  // Shorten pulse width
  contTap d_ifreeNext (
    .trig(i_freeNext),
    .req (w_ifreeReq_2[0]),
    .rstn (rstn)
  );
  delay2U delayifreeReq_donttouch(.inR(w_ifreeReq_2[0]),.rstn(rstn), .outR(w_ifreeReq_2[1]));
  assign w_freeNext = w_ifreeReq_2[0]^w_ifreeReq_2[1];

  //sendFifo
  assign w_sendDrive0 = (|(w_d_fire_8 & w_grant_8));

  assign pmtFinish = (w_req_8==w_grant_8)?1'b0:1'b1;
  (* dont_touch="true" *)freeSetDelay #(
    .DELAY_UNIT_NUM(DELAY_CL)
  ) delayW_sendFire (
      .i_signal( (|w_reset_8) & pmtFinish),
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
  always @(w_grant_8) begin
    case (w_grant_8)
        8'b00000001: r_wdata <= w_data0 ;
        8'b00000010: r_wdata <= w_data1 ;
        8'b00000100: r_wdata <= w_data2 ;
        8'b00001000: r_wdata <= w_data3 ;
        8'b00010000: r_wdata <= w_data4 ;
        8'b00100000: r_wdata <= w_data5 ;
        8'b01000000: r_wdata <= w_data6 ;
        8'b10000000: r_wdata <= w_data7 ;
        default : r_wdata <= {DATA_WIDTH{1'b0}};
    endcase
  end

endmodule  //cArbMerge8
