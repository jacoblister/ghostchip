`timescale 1 ns/1 ps

module vdrive_tb;

    reg clk = 0;
    wire rst;
    wire cs;
    wire dc;
    wire sclk;
    wire mosi;
    
    vdrive UUT (.clk(clk), .rst(rst), .cs(cs), .dc(dc), .sclk(sclk), .mosi(mosi) );
    
    initial
        begin
            forever
                #41.666 clk = !clk;
        end
endmodule