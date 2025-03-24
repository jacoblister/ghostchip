`ifdef __8BITWORKSHOP__

`include "hvsync.v"
`include "rom.v"
`include "ram.v"
`include "vram.v"
`include "cpu.v"
`include "vdrive_workshop.v"

module ghostchip_workshop(clk, reset, hsync, vsync, 
                    switches_p1, switches_p2,
                    rgb);

  input clk, reset;
  input [7:0] switches_p1;
  input [7:0] switches_p2;
  output hsync, vsync;
  output [2:0] rgb;
  wire display_on;

  wire [8:0] hpos;
  wire [8:0] vpos;
  
  hvsync_generator hvsync_gen(
    .clk(clk),
    .reset(reset),
    .hsync(hsync),
    .vsync(vsync),
    .display_on(display_on),
    .hpos(hpos),
    .vpos(vpos)
  );
  
  wire [15:0] keypad_matrix;
  assign keypad_matrix[15:0] = 0;
//  wire p1gfx = switches_p1[vpos[7:5]]; 
//  wire p2gfx = switches_p2[vpos[7:5]];
  
  wire [11:0] rom_addr;
  wire [7:0] rom_dout;
//  rom rom(
//    .clk(clk),
//    .addr(rom_addr),
//    .dout(rom_dout)
//  );
  
  reg [7:0] rom [0:2047];
  wire [10:0] rom_short = rom_addr[10:0];
  initial begin
    integer x;
    for (x=0; x < 2048; x=x+1)
      rom[x] = 8'h00;

    rom[0] = 8'hC8;
    rom[1] = 8'h84;
    rom[64] = 8'h80;
    rom[128] = 8'h80;
    rom[192] = 8'h40;
    rom[1855] = 8'h04;
    rom[1919] = 8'h08;
    rom[1983] = 8'h08;
    rom[2046] = 8'h48;
    rom[2047] = 8'h8C;
    
    $readmemh("cubes.hex", rom);
  end
  always @(posedge clk) begin
    rom_dout <= rom[rom_short];
  end
  
  wire [11:0] ram_addr;
  wire [7:0] ram_din;
  wire [7:0] ram_dout;
  wire ram_we;
  ram ram(
    .clk(clk),
    .we(ram_we),
    .addr(ram_addr),
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
  
  cpu cpu(
    .clk(clk),
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