//-----------------------------------------------
//	module name: cArbMerge2
//	author: Lingzhuang Zhang
//      if the number of input reqs is greater than eight, 
//      using cArbMerge2 to construct the binary tree
//      is better solution. 
//      
//      1. if only one req come, then ArbMerge2 acts like 
//         mutexMerge2
//
//	version: 3rd version (2025-01-07)
//-----------------------------------------------

module cArbMerge3(
    // in0 -->
    input           i_drive0        ,
    output          o_free0         , 
    // in1 -->
    input           i_drive1        ,
    output          o_free1         ,
    // in1 -->
    input           i_drive2        ,
    output          o_free2         ,
    // --> out
    output          o_driveNext     ,
    input           i_freeNext      ,
    output  [2:0]   o_validation_3  ,
    // reset signal
    input           rst             ,
    input           i_stopStartFlag
);

/*  change it*/
// if r_req_3 can't avoid metastability, then we store it twice!!! 2025/01/03
wire            w_firstTrig , w_secondTrig  , w_thirdTrig ;
wire            w_firstReq  , w_secondReq   , w_thirdReq  ;
wire            w_firstReset, w_secondReset , w_thirdReset;
wire            w_rstStartflag, w_fireStartFlag;
wire    [2:0]   w_validation_3;
reg     [2:0]   r_priority_3, r_req_3       ;
reg             r_startFlag;


/* dont touch */
wire    [1:0]   w_updateTrig                ;
wire            w_existReq  , w_isValid     ;
wire            w_fire      , w_roundDrive  ;
wire            w_driveUpdateFifo;
wire            w_outR, w_outA;
wire            w_sendPreDrive, w_sendPreFree, w_freeNextDelayed;


assign w_firstTrig = i_drive0 | w_firstReset;
contTap firstTap(
    .trig   ( w_firstTrig   ),
    .req    ( w_firstReq    ),
    .rst    ( rst           )
);


assign w_secondTrig = i_drive1 | w_secondReset;
contTap secondTap(
    .trig   ( w_secondTrig  ),
    .req    ( w_secondReq   ),
    .rst    ( rst           )
);

assign w_thirdTrig = i_drive2 | w_thirdReset;
contTap thirdTap(
    .trig   ( w_thirdTrig   ),
    .req    ( w_thirdReset  ),
    .rst    ( rst           )
);

// in the begining, there is no req.
// there is a req, then the arbMerge can work sucessfully.
assign w_existReq = w_firstReq | w_secondReq | w_thirdReset;

relay  fireDrive (
    // resetTrig
    .rst            ( rst           ),
    .inR            ( w_existReq    ),
    .inA            (               ),  // leave it alone.
    .outR           ( w_outR        ),
    .outA           ( w_outA        ),
    .fire           ( w_fire        )
);
delay2U delayOutR(.inR(w_outR), .outR(w_outA), .rst(rst));

//delay2U delayFire(.inR(w_fire), .outR(w_fireStartFlag), .rst(rst));
assign w_fireStartFlag = r_startFlag & w_fire;
assign w_rstStartflag = rst & i_stopStartFlag;
always@(posedge w_fireStartFlag or negedge w_rstStartflag) begin
    if(!w_rstStartflag)
        r_startFlag <= 1'b1;
    else
        r_startFlag <= 1'b0;
end

// 1st: r_startFlag & w_fire;  other: w_roundDrive;
assign w_driveUpdateFifo = (r_startFlag & w_fire) | w_roundDrive;
cArbMerge3_cFifo2 u_UpdateFifo(
    .i_drive        ( w_driveUpdateFifo ),
    .o_free         (                   ),
    .o_driveNext    ( w_sendPreDrive    ),
    .i_freeNext     ( w_sendPreFree     ),
    .o_fire_2       ( w_updateTrig      ),
    .rst            ( rst               )
);

// req recorder
// record reqs for send drive. but we can't  
always@(posedge w_updateTrig[0] or negedge rst)
begin
	if(!rst)
		r_req_3 <= 3'b000;
	else begin
        r_req_3 <= {w_thirdReq, w_secondReq, w_firstReq};
    end
end

// priority
always@(posedge w_updateTrig[1] or negedge rst)
begin
	if(!rst)
		r_priority_3 <= 3'b000;
	else begin
        case(r_req_3)
            3'b001, 3'b011, 3'b111: r_priority_3 <= 3'b001;// if there is two req then we make first req first out!
            3'b010, 3'b110        : r_priority_3 <= 3'b010;
            3'b100                : r_priority_3 <= 3'b100;
            3'b000                : r_priority_3 <= 3'b000;
        endcase
    end
end 

//dir validation
assign w_validation_3 = r_priority_3;

assign w_isValid = |w_validation_3;

// about o_driveNext:
// 1. if current priority is valid, then o_driveNext is generated.
assign o_driveNext   = w_sendPreDrive & w_isValid;
// about w_roundDrive:
//  1. if current priority is invalid, then w_roundDrive is generated.
//  2. if all priority is invalid, then w_roundDrive need disapear.
//  3. when i_freeNext comes and req resets, if there exists req, we need generate w_roundDrive!!!
delay3U freedelay0 (.inR(i_freeNext)   , .outR(w_freeNextDelayed), .rst(rst));
assign w_roundDrive = (w_freeNextDelayed | (w_sendPreDrive & !w_isValid)) & (!r_startFlag);

//assign w_roundDrive = w_freeNextDelayed & (!(r_req_3[0]^r_req_3[1]));
//assign w_roundDrive = (w_sendPreDrive & (~w_isValid) & w_existReq)
//                    | (w_freeNextDelayed & w_existReq);


// resetTrig
assign w_firstReset  = w_validation_3[0] & i_freeNext; 
assign w_secondReset = w_validation_3[1] & i_freeNext;
assign w_thirdReset  = w_validation_3[2] & i_freeNext;


assign o_free0 = w_firstReset ;
assign o_free1 = w_secondReset;
assign o_free2 = w_thirdReset ;

assign o_validation_3 = w_validation_3;

endmodule
