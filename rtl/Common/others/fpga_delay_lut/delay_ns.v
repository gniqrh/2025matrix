//-----------------------------------------------
//	module name: delay1U
//	author: Anping HE (heap@lzu.edu.cn)
//	version: 1st version (2021-11-13)
//	description: 
//		delay1U
//  tech: xilinx fpga
//----------------------------------------------
`timescale 1ns / 1ps

(* dont_touch="true" *)module delay_ns#(
    parameter integer DELAY_PS = 5000  // 需要延迟的总时间(ps)
)(
    input wire inR,
    input wire rst,
    output wire outR
);

    // 延迟基础值和步长
    localparam integer BASE_PS = 3637;   // 1个LUT1起步延迟
    localparam integer STEP_PS = 210;    // 每增加1个LUT1带来的增量延迟

    // 需要额外的LUT1数量
    localparam integer ADD_LUT1 = (DELAY_PS > BASE_PS) ? ((DELAY_PS - BASE_PS + STEP_PS - 1) / STEP_PS) : 0;
    localparam integer NUM_LUT1 = ADD_LUT1 + 1; // 总共使用的LUT1数量（至少1个）

    (* dont_touch = "true" *)wire [NUM_LUT1:0] chain;
    assign chain[0] = inR;

    genvar i;
    generate
        for (i = 0; i < NUM_LUT1; i = i + 1) begin : gen_lut1_chain
            (* dont_touch = "true" *)
            LUT1 #(.INIT(2'b10)) u_lut1 (
                .O(chain[i+1]),
                .I0(chain[i])
            );
        end
    endgenerate

    (* dont_touch = "true" *)
    LUT2 #(.INIT(4'b1000)) u_lut2 (
        .O(outR),
        .I0(rst),
        .I1(chain[NUM_LUT1])
    );

endmodule

