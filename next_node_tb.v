
`timescale 1ns/1ps

module next_node_tb;
    reg        clk;
    reg        rst;
    reg        density;

    wire [1:0] N_sig;
    wire [1:0] S_sig;
    wire [1:0] E_sig;
    wire [1:0] W_sig;
    next_node DUT (
        .clk(clk),
        .rst(rst),
        .density(density),
        .N_sig(N_sig),
        .S_sig(S_sig),
        .E_sig(E_sig),
        .W_sig(W_sig)
    );
    initial clk = 0;
    always #5 clk = ~clk;
    initial begin
        $dumpfile("next_node_tb.vcd");
        $dumpvars(0, next_node_tb);
    end
    initial begin
        $monitor("Time=%0t | N=%b | S=%b | E=%b | W=%b | density=%b",
                  $time, N_sig, S_sig, E_sig, W_sig, density);
    end
    initial begin

        // --- Apply Reset ---
        rst     = 1;
        density = 0;
        $display("--- Reset Applied ---");
        repeat(3) @(posedge clk);

        // --- Release Reset ---
        rst = 0;
        $display("--- Reset Released | density = LOW ---");

        // --- Run with LOW density ---
        // Watch NS Green → NS Yellow → EW Green → EW Yellow → back
        repeat(30) @(posedge clk);

        // --- Switch to HIGH density ---
        density = 1;
        $display("--- Density = HIGH (green will extend) ---");
        repeat(20) @(posedge clk);

        // --- Back to LOW density ---
        density = 0;
        $display("--- Density = LOW ---");
        repeat(20) @(posedge clk);

        // --- Reset in middle ---
        rst = 1;
        $display("--- Reset mid-operation ---");
        repeat(3) @(posedge clk);
        rst = 0;

        // --- Run a few more cycles ---
        repeat(15) @(posedge clk);

        $display("--- Simulation Done ---");
        $finish;
    end

endmodule
