module vdrive (
    input clk, 
    input hires,
 
    output [6:0] vram_hpos,
    output [5:0] vram_vpos,
    input [1:0] vram_pixel,

    output reg rst = 0,
    output reg cs = 1,
    output reg dc = 0,
    output sclk,
    output mosi);

    reg [23:0] divider = 0;
    
    always @ (posedge clk) 
    begin
        divider <= divider + 1'b1;
    end
    wire divclk = clk;

    parameter CMD_INIT = 0;
    parameter CMD_DISPLAYON = 1;
    parameter CMD_FREQ = 2;
    parameter CMD_MODE = 3;
    parameter CMD_COLN = 4;
    parameter CMD_PAGE = 5;
    parameter CMD_DATA = 6;
    parameter CMD_WAIT = 7;
    parameter CMD_IDLE = 8;
    reg [3:0] cmd_state = CMD_INIT;

    reg [23:0] data = 0;
    reg [31:0] counter = 0;
    reg [31:0] counter_max = 0;
    
    parameter DRV_INIT   = 0;
    parameter DRV_RESET  = 1;
    parameter DRV_SELECT = 2;
    parameter DRV_CMD    = 3;
    parameter DRV_DATA   = 4;
    parameter DRV_IDLE   = 5;
    reg [2:0] drv_state = DRV_INIT;

    reg [1:0] frame = 0;

    wire [31:0] counter_n = (8191 - counter) + 1;
//    assign vram_hpos = counter_n[9:3] / 2;
//    assign vram_vpos = {counter_n[12:10], 3'h7 - counter_n[2:0]} / 2;
    assign vram_hpos = counter_n[9:3] / (hires ? 1 : 2);
    assign vram_vpos = {counter_n[12:10], 3'h7 - counter_n[2:0]} / (hires ? 1 : 2);

    wire pixel_0 = 0;
//    wire pixel_1 = {counter[3], counter[0]} == frame;
//    wire pixel_2 = counter[0] ^ counter[3] ^ frame[0];
    wire pixel_1 = frame == 0;
    wire pixel_2 = frame == 0 || frame == 1;
//    wire pixel_1 = counter % 3 == frame;
//    wire pixel_2 = counter % 3 == frame || (counter + 1) % 3 == frame;
    wire pixel_3 = 1;

//    wire pixelValue = counter < 4096 ? 
//        (counter < 2048 ? pixel_0 : pixel_1) :
//        (counter < 6144 ? pixel_2 : pixel_3);
    wire pixelValue = 
        (vram_pixel == 1 && frame == 0) ||
        (vram_pixel == 2 && (frame == 0 || frame == 1)) ||
        (vram_pixel == 3);
    
    assign mosi = drv_state == DRV_CMD ? data[counter] : pixelValue;
    assign sclk = (drv_state == DRV_CMD) || (drv_state == DRV_DATA) ? divclk : 0;
    
    always @ (negedge divclk) 
    begin
        if (drv_state == DRV_IDLE)
            case (cmd_state)
                CMD_INIT: begin
                    cmd_state <= CMD_DISPLAYON;
                    cs <= 0;
                    drv_state <= DRV_CMD;
                    counter <= 7;
                    data <= 8'hAF;
                end
                CMD_DISPLAYON: begin
                    cmd_state <= CMD_FREQ;
                    cs <= 0;
                    drv_state <= DRV_CMD;
                    counter <= 15;
                    data <= 16'hD5F0;
                end
                CMD_FREQ: begin
                    cmd_state <= CMD_MODE;
                    cs <= 0;
                    drv_state <= DRV_CMD;
                    counter <= 15;
                    data <= 16'h2000;
                end
                CMD_MODE: begin
                    cmd_state <= CMD_COLN;
                    cs <= 0;
                    drv_state <= DRV_CMD;
                    counter <= 23;
                    data <= 24'h21007F;
                end
                CMD_COLN: begin
                    cmd_state <= CMD_PAGE;
                    cs <= 0;
                    drv_state <= DRV_CMD;
                    counter <= 23;
                    data <= 24'h22003F;
                end
                CMD_PAGE: begin
                    cmd_state <= CMD_DATA;
                    cs <= 0;
                    dc <= 1;
                    drv_state <= DRV_DATA;
                    counter <= 8191;
                end
                CMD_DATA: begin
                    frame = frame < 2 ? frame + 1 : 0;
                    cmd_state <= CMD_WAIT;
                    cs <= 1;
                    dc <= 0;
                    counter <= 71800;
                end
                CMD_WAIT: begin
                    cmd_state <= CMD_FREQ;
                    counter <= 0;
                end
             endcase

        if (counter == 0)
            case (drv_state)
                DRV_INIT: begin
                    rst <= 0;
                    cs <= 1;
                    drv_state <= DRV_RESET;
                    counter <= 3;
                end
                DRV_RESET: begin
                    rst <= 1;
                    drv_state <= DRV_IDLE;
                    counter <= 0;
                end
                DRV_CMD, DRV_DATA: begin
                    drv_state <= DRV_IDLE;
                    cs <= 1;
                    dc <= 0;
                    data <= 0;
                end
                DRV_IDLE: begin
                end
            endcase
        else
            counter <= counter - 1;
    end
    
endmodule