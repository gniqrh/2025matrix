`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Create Date: 2023/06/26 10:00:04
// Design Name: dalay4Unit    ->    delay4U
// Module Name: delay4U
// Project Name: RCA
// Target Devices: FPGA
// Description: 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


(*dont_touch = "true"*)module delay4U(
    inR, outR,rst
    );
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)input inR;
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)input rst;
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)output outR;
    
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)wire outR0;
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)delay2U delay0(.inR(inR), .outR(outR0),.rst(rst));
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)delay2U delay1(.inR(outR0), .outR(outR),.rst(rst));
    
endmodule
