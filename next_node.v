
`timescale 1ns/1ps
module next_node (
input    clk,         
input   rst,         
input  density,    

    // Traffic light outputs
output reg  [1:0]  N_sig,       // North signal
output reg  [1:0]  S_sig,       
output reg  [1:0]  E_sig,       
output reg  [1:0]  W_sig       
);

localparam GREEN  = 2'b10;
localparam YELLOW = 2'b01;
localparam RED    = 2'b00;
localparam S0 = 2'b00;  // NS Green,  EW Red
localparam S1 = 2'b01;  // NS Yellow, EW Red
localparam S2 = 2'b10;  // EW Green,  NS Red
localparam S3 = 2'b11;  // EW Yellow, NS Red

parameter GREEN_LOW  = 4'd5;   
parameter GREEN_HIGH = 4'd9;   
parameter YELLOW_DUR = 4'd3;  

reg [1:0] current_state;
reg [1:0] next_state;
reg [3:0] timer;          // Down counter
reg timer_done;     // Goes HIGH when timer hits 0
reg [3:0] load_val;       // Value to load into timer
    
always @(posedge clk) begin
        if (rst) begin
            current_state <= S0;
            timer<= GREEN_LOW;
        end
        else begin
            if (timer_done) begin
                // Move to next state and reload timer
                current_state <= next_state;
                timer         <= load_val;
            end
            else begin
                // Count down
                current_state <= current_state;
                timer         <= timer - 4'd1;
            end
        end
    end
    always @(*) begin
        next_state = S0;
        load_val   = GREEN_LOW;
        timer_done = (timer == 4'd0) ? 1'b1 : 1'b0;

        case (current_state)

            S0 : begin  // NS Green
                if (timer_done) begin
                    if (density) begin
                        // HIGH density — stay green, reload HIGH timer
                        next_state = S0;
                        load_val   = GREEN_HIGH;
                    end
                    else begin
                        // LOW density — move to Yellow
                        next_state = S1;
                        load_val   = YELLOW_DUR;
                    end
                end
                else begin
                    next_state = S0;
                    load_val   = GREEN_LOW;
                end
            end

            S1 : begin  // NS Yellow — always fixed, no adaptive
                if (timer_done) begin
                    next_state = S2;
                    load_val   = GREEN_LOW;  // EW starts at LOW
                end
                else begin
                    next_state = S1;
                    load_val   = YELLOW_DUR;
                end
            end

            S2 : begin  // EW Green
                if (timer_done) begin
                    if (density) begin
                        // HIGH density — extend EW green
                        next_state = S2;
                        load_val   = GREEN_HIGH;
                    end
                    else begin
                        // LOW density — move to Yellow
                        next_state = S3;
                        load_val   = YELLOW_DUR;
                    end
                end
                else begin
                    next_state = S2;
                    load_val   = GREEN_LOW;
                end
            end

            S3 : begin  // EW Yellow — always fixed
                if (timer_done) begin
                    next_state = S0;
                    load_val   = GREEN_LOW;
                end
                else begin
                    next_state = S3;
                    load_val   = YELLOW_DUR;
                end
            end

            default : begin  // Safety net — go to IDLE
                next_state = S0;
                load_val   = GREEN_LOW;
            end

        endcase
    end
    always @(*) begin
        // Safe defaults — all RED (fail-safe)
        N_sig = RED;
        S_sig = RED;
        E_sig = RED;
        W_sig = RED;

        case (current_state)

            S0 : begin  // NS Green, EW Red
                N_sig = GREEN;
                S_sig = GREEN;
                E_sig = RED;
                W_sig = RED;
            end

            S1 : begin  // NS Yellow, EW Red
                N_sig = YELLOW;
                S_sig = YELLOW;
                E_sig = RED;
                W_sig = RED;
            end

            S2 : begin  // EW Green, NS Red
                N_sig = RED;
                S_sig = RED;
                E_sig = GREEN;
                W_sig = GREEN;
            end

            S3 : begin  // EW Yellow, NS Red
                N_sig = RED;
                S_sig = RED;
                E_sig = YELLOW;
                W_sig = YELLOW;
            end

            default : begin  // All RED — safe state
                N_sig = RED;
                S_sig = RED;
                E_sig = RED;
                W_sig = RED;
            end

        endcase
    end

endmodule





























