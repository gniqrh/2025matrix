`timescale 1ns / 1ps
//======================================================
// Project: 
// Module:  ArbMerge_2
// Author:  Yang Yuyuan
// Date:    2025/06/23
// Description: 
// 1.Instantiation: ArbMerge_2 #(2, 22) u_ArbMerge_2(...);
//          ArbMerge_2 #(.NUM_PORTS(2),.DATA_WIDTH(22)) u_ArbMerge_2(...);
//
// 2.Modification: Modify the modelname (ArbMerge_2, NUM_PORTS, DATA_WIDTH)
//         Modify the interface (i_drive0, i_data0, o_free0)
//         Modify the signal (w_pf1id, w_pf1of, w_idata, o_data)
//======================================================

module ArbMerge_2 #(
    parameter NUM_PORTS  = 2,
    parameter DATA_WIDTH = 22
) (
    input rstn,

    input                   i_drive0,
    input  [DATA_WIDTH-1:0] i_data0,
    output                  o_free0,

    input                   i_drive1,
    input  [DATA_WIDTH-1:0] i_data1,
    output                  o_free1,

    output                  o_driveNext,
    output [DATA_WIDTH-1:0] o_data,
    input                   i_freeNext
);

    wire [DATA_WIDTH-1:0] w_idata   [NUM_PORTS-1:0];
    reg  [DATA_WIDTH-1:0] r_data    [NUM_PORTS-1:0];

    wire [ NUM_PORTS-1:0] w_pf1id;
    wire [ NUM_PORTS-1:0] w_pf1if;
    wire [ NUM_PORTS-1:0] w_pf1of;
    wire [ NUM_PORTS-1:0] w_pf1od;
    wire [ NUM_PORTS-1:0] w_pf1fire;
    wire [ NUM_PORTS-1:0] w_pf1pmt;

    wire [ NUM_PORTS-1:0] w_pf2id;
    wire [ NUM_PORTS-1:0] w_pf2if;
    wire [ NUM_PORTS-1:0] w_pf2of;
    wire [ NUM_PORTS-1:0] w_pf2od;
    wire [ NUM_PORTS-1:0] w_pf2fire;

    wire [ NUM_PORTS-1:0] w_trig;
    wire [ NUM_PORTS-1:0] w_req;
    wire [ NUM_PORTS-1:0] w_grant;
    wire [ NUM_PORTS-1:0] w_reset;

    assign w_pf1id = {i_drive1, i_drive0};
    assign {o_free1, o_free0} = w_pf1of;
    assign w_idata[1] = i_data1;
    assign w_idata[0] = i_data0;
    assign o_data = ({DATA_WIDTH{w_grant[0]}} & r_data[0]) | 
    ({DATA_WIDTH{w_grant[1]}} & r_data[1]);

    assign o_driveNext = |w_pf2od;
    assign w_pf1pmt = {NUM_PORTS{~(|w_req)}};
    assign w_grant = w_req & (~w_req + 1'b1);

    genvar i;
    generate
        for (i = 0; i < NUM_PORTS; i = i + 1) begin : arbUnit
            assign w_pf1if[i] = w_pf2of[i];
            assign w_pf2if[i] = i_freeNext & w_grant[i];

            (* dont_touch="true" *) cPmtFifo1 PmtFifo1 (
                .i_drive    (w_pf1id[i]),
                .i_freeNext (w_pf1if[i]),
                .o_free     (w_pf1of[i]),
                .o_driveNext(w_pf1od[i]),
                .o_fire_1   (w_pf1fire[i]),
                .pmt        (w_pf1pmt[i]),
                .rstn       (rstn)
            );

            always @(posedge w_pf1fire[i] or negedge rstn) begin
                if (!rstn) begin
                    r_data[i] <= {DATA_WIDTH{1'b0}};
                end else begin
                    r_data[i] <= w_idata[i];
                end
            end

            assign w_trig[i] = w_pf1fire[i] | w_reset[i];
            (* dont_touch="true" *) contTap tap (
                .trig(w_trig[i]),
                .req (w_req[i]),
                .rstn(rstn)
            );

            (* dont_touch="true" *) delayNU #(8) delay1 (
                .inR (w_pf1od[i]),
                .outR(w_pf2id[i]),
                .rstn(rstn)
            );

            (* dont_touch="true" *) cPmtFifo1 PmtFifo2 (
                .i_drive    (w_pf2id[i]),
                .i_freeNext (w_pf2if[i]),
                .o_free     (w_pf2of[i]),
                .o_driveNext(w_pf2od[i]),
                .o_fire_1   (w_pf2fire[i]),
                .pmt        (w_grant[i]),
                .rstn       (rstn)
            );

            (* dont_touch="true" *) delayNU #(1) delay2 (
                .inR (w_grant[i] & i_freeNext),
                .outR(w_reset[i]),
                .rstn(rstn)
            );
        end
    endgenerate

endmodule
