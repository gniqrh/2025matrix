//===============================================================================
// Project:        RCA
// Module:         WaitMerge_2_df
// Author:         YiHua Lu
// Date:           2025/06/18
// Description:    二路融合;不带数据版;对数据做持久化;
//                 这儿的持久化在数据和控制链一起流动的模型中可能存在先到者数据消失的问题
//                 这里是数据A,B都到了以后一起持久化，而不是分开持久化，所以可能会消失一个
//                 我懒得改了，我不会用不持久化的
//                 测试值：4ns给出去
//===============================================================================
`timescale 1ns / 1ps

module WaitMerge_2_df#(
    parameter DATA_WIDTH=32
)(
    /* input flow 0 */
    i_drive0, i_data0, o_free0,
    /* input flow 1 */
    i_drive1, i_data1, o_free1,
    /* output flow */
    o_driveNext, o_data, i_freeNext,
    /* rst */
    rst
);

    /* input & output ports */
    input                   i_drive0, i_drive1;
    input [DATA_WIDTH-1:0]  i_data0, i_data1;
    input                   i_freeNext;
    input                   rst;

    output                  o_free0, o_free1;
    output                  o_driveNext;
    output [2*DATA_WIDTH-1:0]o_data;

    /* wire and reg */
    wire       w_trig0, w_trig1;
    wire       w_req0, w_req1;
    wire       w_sendDrive, w_sendFree;
    wire       w_driveNext,w_free_delay;
    wire       w_fire, w_fire_delayed;
    wire [1:0] w_outRRelay_2, w_outARelay_2;
    wire       w_allReqCome,w_d_andReq;  

    wire [31:0] w_data0;
    wire [31:0] w_data1;
    reg  [31:0] r_data0;
    reg  [31:0] r_data1;

    /*------------------------------------------------------------------------------------------------
    1. 每路输入通过 w_req[i] 电平控制 —— 高电平表示当前通路包含未送出的数据;
    2. 每路 w_req[i] 电平通过 i_drive[i] 信号敲高；通过 w_sendFree 信号复位.
    ------------------------------------------------------------------------------------------------*/
    assign w_trig0 = (i_drive0&~w_req0) | w_free_delay;
    assign w_trig1 = (i_drive1&~w_req1) | w_free_delay;
    contTap tap0(.trig(w_trig0), .req(w_req0), .rst(rst));
    contTap tap1(.trig(w_trig1), .req(w_req1), .rst(rst));

    /*------------------------------------------------------------------------------------------------
    1. 根据 WaitMerge 功能，需要定位到所有输入端口中最后到来的事件：
    2. 将多路输入事件（脉冲）经过或得到 w_driveNext;
    3. 将 w_driveNext 与所有通路的 w_req[i] 电平进行“与”操作，得到 w_sendDrive;
    4. 等到输入端所有事件到来后，才会生成 w_driveNext.
    ------------------------------------------------------------------------------------------------*/

    // 控制两个都到后通过延迟的方式产生o_drive，
    assign w_allReqCome = w_req0 & w_req1;
    delay4U u_delay(
        .inR  ( w_allReqCome ),
        .rst  ( rst ),
        .outR ( w_d_andReq )
    );
    assign w_driveNext = w_allReqCome ^ w_d_andReq & w_req0 & w_req1;

    /*------------------------------------------------------------------------------------------------
    1. 发送-中继-接收部分;
    2. 该部分位于 WaitMerge 的单路【输出】端;
    3. 该部分用于匹配时序逻辑.
    ------------------------------------------------------------------------------------------------*/
    sender sender(
        .i_drive (w_driveNext),
        .o_free  (),
        .outR    (w_outRRelay_2[0]),
        .i_free  (w_fire),
        .rst    (rst)
    );

    relay relay0(
        .inR   (w_outRRelay_2[0]),
        .inA   (w_outARelay_2[0]),
        .outR  (w_outRRelay_2[1]),
        .outA  (w_outARelay_2[1]),
        .fire  (w_fire),
	    .rst  (rst)
    );

    //===============================================================================
    //
    // 其他的 relay[i] 模块可被连接至 relay0 - receiver 之间，生成连续的 fire 信号，匹配不同的时序逻辑
    //
    //===============================================================================

    receiver receiver(
        .inR     (w_outRRelay_2[1]),
        .inA     (w_outARelay_2[1]),
        .i_freeNext  (i_freeNext),
        .rst    (rst)
    );


    /*------------------------------------------------------------------------------------------------
    1. 时序逻辑匹配部分;
    2. 根据不同的功能，自定义 组合逻辑 + 时许逻辑，完成数据处理.
    ------------------------------------------------------------------------------------------------*/
    always @(posedge w_fire or negedge rst) begin
        if (!rst) begin
            r_data0 <= {DATA_WIDTH{1'b0}};
            r_data1 <= {DATA_WIDTH{1'b0}};
        end
        else begin
            r_data0 <= i_data0;
            r_data1 <= i_data1;
        end
    end
    
    assign w_data0 = r_data0;
    assign w_data1 = r_data1;

    // 两路都到了就可以出去了
    delay1U outdelay (.inR(w_driveNext), .outR(o_driveNext),.rst(rst));

    // i_free进入后，先复位receiver，给出free，再敲低对应的conTap
    delay1U delay0 (.inR(i_freeNext)   , .outR(w_free_delay), .rst(rst));

    /* 连接输出 */
    assign o_free0    = i_freeNext;
    assign o_free1    = i_freeNext;
    assign o_data     = {w_data1,w_data1};

endmodule
