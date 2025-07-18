//-----------------------------------------------
//	module name: delay1U
//	author: Fu Tong , Baoxia Wan , Mingshu Chen
//  modifier: 
//  	modifyer: Anping HE (heap@lzu.edu.cn)
//  		adopting FDPE explicitly
//	version: 2nd version (2021-11-17)
//	description: 
//		one unit delay
//      output ==> input (==>:one uint delay)
//-----------------------------------------------
`timescale 1ns / 1ps

module delay2U(inR, outR);
input inR;
output outR;

wire outR0,outR1,outR2;
(*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)LUT1 #(.INIT(2'b10)) delay0
(
    .O(outR0),
    .I0(inR)
);
(*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)LUT1 #(.INIT(2'b10)) delay1
(
    .O(outR1),
    .I0(outR0)
);
(*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)LUT1 #(.INIT(2'b10)) delay2
(
    .O(outR2),
    .I0(outR1)
);
(*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)LUT1 #(.INIT(2'b10)) delay3
(
    .O(outR),
    .I0(outR2)
);

endmodule