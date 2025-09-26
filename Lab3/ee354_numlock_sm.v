`timescale 1ns / 1ps

module ee354_numlock_sm(clk, reset, U, Z, 
                            q_I, q_G1get, q_G1, q_G10get, q_G10, 
                            q_G101get, q_G101, q_G1011get, q_G1011, 
                            q_Opening, q_Bad, Unlock);

    // inputs:
    input clk, reset;
    input U, Z;

    // output:
    output Unlock;
    output q_Bad, q_Opening, q_G1011, q_G1011get, q_G101, q_G101get, q_G10, q_G10get, q_G1, q_G1get, q_I;

    reg[10:0] state;
    assign {q_Bad, q_Opening, q_G1011, q_G1011get, q_G101, q_G101get, q_G10, q_G10get, q_G1, q_G1get, q_I} = state;

    // assigning states using onehot coding
    localparam 
        qI =        11'b00000000001,
        qG1GET =    11'b00000000010,
        qG1 =       11'b00000000100,
        qG10GET =   11'b00000001000,
        qG10 =      11'b00000010000,
        qG101GET =  11'b00000100000,
        qG101 =     11'b00001000000,
        qG1011GET = 11'b00010000000,
        qG1011 =    11'b00100000000,
        qOPENING =  11'b01000000000,
        qBAD =      11'b10000000000;

    //Timerout
    reg[3:0] Timer_count;
    wire Timerout;
    assign Timerout = (Timer_count[3]) & (Timer_count[2]) & (Timer_count[1]) & (Timer_count[0]);

    always @ (posedge clk, posedge reset)
    begin : TIMER_COUNT 
        if(reset)
            Timer_count = 0;
        else   
            if(state == qOPENING)
                Timer_count <= Timer_count + 1;
            else
                Timer_count <= 0;
    end


    // NSL
    always @ (posedge clk, posedge reset)
    begin
        if(reset)
            state <= qI;
        else
        begin
            case(state)
                qI:
                    if(U==1 && Z == 0)
                        state <= qG1GET;
                qG1GET:
                    if(U == 0)
                        state <= qG1;
                qG1:
                    if(U == 0 && Z == 1)
                        state <= qG10GET;
                    else if(U == 1)
                        state <= qBAD;
                qG10GET:
                    if(Z == 0)
                        state <= qG10;
                qG10:
                    if(U == 1 && Z == 0)
                        state <= qG101GET;
                    else if(Z == 1)
                        state <= qBAD;
                qG101GET:
                    if(U == 0)
                        state <= qG101;
                qG101:
                    if(U == 1 && Z == 0)
                        state <= qG1011GET;
                    else if(Z == 1)
                        state <= qBAD;
                qG1011GET:
                    if(U == 0)
                        state <= qG1011;
                qG1011:
                    state <= qOPENING;
                qOPENING:
                    if(Timerout == 1)
                        state <= qI;
                qBAD:
                    if(U == 0 && Z == 0)
                        state <= qI;
            endcase
        end
    end


    // OFL
    assign Unlock = q_Opening;

endmodule