//======================================================
// Project: SOLVA
// Module:  CL_grant
// Author:  zhuangzhuang Liao
// Reviser: jinyu Yang
// Mail：   lzhuangzhuang2023@lzu.edu.cn
// Date:    2025-05-28
// Description: priority generation in combinational circuits
// This module generates a priority grant signal based on the request input.
//======================================================
module CL_grant #(
    parameter DATA_WIDTH = 5
)(
    input wire [DATA_WIDTH-1:0] i_req,
    output wire [DATA_WIDTH-1:0] o_grant,
    output wire o_pmtFinish 
);

    assign o_grant = i_req & (~i_req + 1'b1);
    assign o_pmtFinish = | o_grant;
endmodule 
//CL_grant