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

module delay5U(inR, outR, rst);
input inR, rst;
output outR;

wire outR0,outR1,outR2,outR3;
delay1U delay1 ( .inR(inR)  , .outR(outR0), .rst(rst));
delay1U delay2 ( .inR(outR0), .outR(outR1), .rst(rst));
delay1U delay3 ( .inR(outR1), .outR(outR2), .rst(rst));
delay1U delay4 ( .inR(outR2), .outR(outR3), .rst(rst));
delay1U delay5 ( .inR(outR3), .outR(outR) , .rst(rst));
endmodule
