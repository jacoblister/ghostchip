`ifdef __8BITWORKSHOP__

`include "hvsync.v"
`include "rom.v"
`include "ram.v"
`include "vram.v"
`include "cpu.v"
`include "vdrive_workshop.v"
`include "matrix_workshop.v"

module ghostchip_workshop(clk, reset, hsync, vsync, 
                    switches_p1, switches_p2,
                    rgb, spkr);

  input clk, reset;
  input [7:0] switches_p1;
  input [7:0] switches_p2;
  output hsync, vsync;
  output [2:0] rgb;
  wire display_on;
  wire [8:0] hpos;
  wire [8:0] vpos;
  wire hvsync_vsync;
  output spkr;
  
  wire beep;
  assign spkr = 0;//hvsync_vsync && beep;
  
  hvsync_generator hvsync_gen(
    .clk(clk),
    .reset(reset),
    .hsync(hsync),
    .vsync(hvsync_vsync),
    .display_on(display_on),
    .hpos(hpos),
    .vpos(vpos)
  );
  assign vsync = hvsync_vsync;
  
  wire [15:0] keypad_matrix;
  matrix_workshop matrix_workshop(
    .clk(clk),
    .switches_p1(switches_p1),
    .switches_p2(switches_p2),
    .matrix(keypad_matrix)
  );
  
  wire [15:0] rom_addr;
  wire [7:0] rom_dout;

  reg [7:0] mem [0:4095];
  initial begin
  $readmemh("chip8logo.hex", mem);
  $readmemh("flags.hex", mem);
  $readmemh("keypad.hex", mem);
  $readmemh("random.hex", mem);
  $readmemh("snake.hex", mem);
  $readmemh("blinky.hex", mem);
  $readmemh("down8.hex", mem);
  $readmemh("rockto.hex", mem);
  $readmemh("chipcross.hex", mem);
  $readmemh("squad.hex", mem);
  $readmemh("octopaint.hex", mem);
  $readmemh("sound.hex", mem);
  end
  
  rom rom(
    .clk(clk),
    .addr(rom_addr[13:0]),
    .dout(rom_dout)
  );
  
  wire [15:0] ram_addr;
  wire [7:0] ram_din;
  wire [7:0] ram_dout;
  wire ram_we;
  ram ram(
    .clk(clk),
    .we(ram_we),
    .addr(ram_addr[13:0]),
    .din(ram_din),
    .dout(ram_dout)
  );
  
  wire [6:0] vram_hpos;
  wire [5:0] vram_vpos;
  wire [1:0] vram_pixeli;
  wire [1:0] vram_pixelo;
  wire vram_we;
  wire [6:0] vram_vdrive_hpos;
  wire [5:0] vram_vdrive_vpos;
  wire [1:0] vram_vdrive_pixel;
  vram vram(
    .clk(clk),
    .hpos(vram_hpos),
    .vpos(vram_vpos),
    .pixeli(vram_pixeli),
    .pixelo(vram_pixelo),
    .we(vram_we),
    .vdrive_hpos(vram_vdrive_hpos),
    .vdrive_vpos(vram_vdrive_vpos),
    .vdrive_pixel(vram_vdrive_pixel)
  );
  
  wire hires;
  
  cpu cpu(
    .clk(clk),
    .vsync(hvsync_vsync),
    .beep(beep),
    .hires(hires),
    .keypad_matrix(keypad_matrix),
    .rom_addr(rom_addr),
    .rom_dout(rom_dout),
    .ram_addr(ram_addr),
    .ram_din(ram_din),
    .ram_dout(ram_dout),
    .ram_we(ram_we),
    .vram_hpos(vram_hpos),
    .vram_vpos(vram_vpos),
    .vram_pixeli(vram_pixeli),
    .vram_pixelo(vram_pixelo),
    .vram_we(vram_we)
  );
  
  wire [1:0] vdrive_pixel;
  vdrive_workshop vdrive(
    .hires(hires),
    .vram_hpos(vram_vdrive_hpos),
    .vram_vpos(vram_vdrive_vpos),
    .vram_pixel(vram_vdrive_pixel),
    .hvsync_hpos(hpos),
    .hvsync_vpos(vpos),
    .hvsync_pixel(vdrive_pixel)
  );

  assign rgb = {1'b0, 
                display_on && vdrive_pixel[1],
                display_on && vdrive_pixel[0]};
endmodule

`endif