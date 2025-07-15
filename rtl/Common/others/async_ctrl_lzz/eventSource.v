//======================================================
// Project: SOLVA
// Module:  eventSource
// Author:  zhuangzhuang Liao
// Mail：   lzhuangzhuang2023@lzu.edu.cn
// Date:    2025-05-28
// Description: event source
//======================================================
module eventSource (
    input  wire switch,//negedge generate fire
    input  wire rstn,
    output wire fire
);
  wire w_req;
  wire w_nd_req;
  wire w_fire;
  contTap u_contTap (
      .trig(~switch),
      .req (w_req),
      .rstn(rstn)
  );
  delay2U u_delay2U_donttouch (
      .inR (~w_req),
      .outR(w_nd_req),
      .rstn(rstn)
  );

  assign w_fire = w_nd_req & (~switch);
  assign fire   = w_fire;
endmodule
