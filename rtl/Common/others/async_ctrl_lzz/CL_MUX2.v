//======================================================
// Project: SOLVA
// Module:  CL_MUX2
// Author:  zhuangzhuang Liao
// Mail：   lzhuangzhuang2023@lzu.edu.cn
// Date:    2025-05-28
// Description: mux2 data selector
//======================================================
module CL_MUX2#(
    parameter DATA_WIDTH = 5
) (
    input  wire [2-1:0] i_sel,
    input  wire [DATA_WIDTH-1:0] i_data0,
    input  wire [DATA_WIDTH-1:0] i_data1,
    output reg  [DATA_WIDTH-1:0] o_data
);
  always @(i_sel) begin
    case (i_sel)
        2'b01: o_data <= i_data0 ;
        2'b10: o_data <= i_data1 ;
        default : o_data <= {DATA_WIDTH{1'b0}};
    endcase
  end

endmodule //CL_MUX