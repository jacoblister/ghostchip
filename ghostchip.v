module ghostchip (
    input clk, 
    output keypad_out0,
    output keypad_out1,
    output keypad_out2,
    output keypad_out3,
    input keypad_in0,
    input keypad_in1,
    input keypad_in2,
    input keypad_in3,
    
    output video_rst,
    output video_cs,
    output video_dc,
    output video_sclk,
    output video_mosi,

    output flash_cs,
    output flash_clk,
    output flash_mosi,
    input flash_miso,
    
    
    input button,
    output speaker,
    output speaker_inv,
        
    output led0,
    output led1,
    output led2,
    output led3,
    output led4,
    output led5,
    output led6,
    output led7,
    output keypad_gnd,
    output video_gnd,
    output video_vcc);

    assign keypad_gnd = 0;
    assign video_gnd = 0;
    assign video_vcc = 1;
    
    reg [23:0] divider = 0;
    reg clk_60hz;
    always @ (posedge clk) 
    begin
      if (divider == 0)
        begin
        clk_60hz <= !clk_60hz;
        divider <= 100000;
        end
      else
        begin
          divider <= divider - 1'b1;
        end
    end
    wire divclk = clk;
    
    
    wire [15:0] keypad_matrix;

    keypad keypad(
        .clk(clk_60hz),
        .out0(keypad_out0),
        .out1(keypad_out1),
        .out2(keypad_out2),
        .out3(keypad_out3),
        .in0(keypad_in0),
        .in1(keypad_in1),
        .in2(keypad_in2),
        .in3(keypad_in3),
        .matrix(keypad_matrix),
        .led0(led0),
        .led1(led1),
        .led2(led2),
        .led3(led3),
        .led4(led4),
        .led5(led5),
        .led6(led6),
        .led7(led7)
    );
    
   reg [27:0] speaker_counter = 0;
   always @ (posedge clk) 
   begin
       speaker_counter <= speaker_counter + 1'b1;
   end
   wire beep;
   assign speaker = speaker_counter[15] && beep;
   assign speaker_inv = 0; //!speaker;    
//   assign speaker = !button && speaker_counter[15];
//   assign speaker_inv = !button && !speaker;    
    
  wire [15:0] rom_addr;
  wire [7:0] rom_dout;
  wire rom_dready;
  romflash rom(
    .clk(clk),
    .flash_cs(flash_cs),
    .flash_clk(flash_clk),
    .flash_mosi(flash_mosi),
    .flash_miso(flash_miso),
    .addr(rom_addr),
    .dout(rom_dout),
    .dready(rom_dready)
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
    .beep(beep),
    .hires(hires),
    .vsync(clk_60hz),
    .keypad_matrix(keypad_matrix),
    .rom_addr(rom_addr[13:0]),
    .rom_dout(rom_dout),
    .ram_addr(ram_addr[13:0]),
    .ram_din(ram_din),
    .ram_dout(ram_dout),
    .rom_dready(rom_dready),
    .ram_we(ram_we),
    .vram_hpos(vram_hpos),
    .vram_vpos(vram_vpos),
    .vram_pixeli(vram_pixeli),
    .vram_pixelo(vram_pixelo),
    .vram_we(vram_we)
  );
  
  wire [1:0] vdrive_pixel;
  vdrive vdrive(
    .clk(clk),
    .hires(hires),
    .vram_hpos(vram_vdrive_hpos),
    .vram_vpos(vram_vdrive_vpos),
    .vram_pixel(vram_vdrive_pixel),
    .rst(video_rst),
    .cs(video_cs),
    .dc(video_dc),
    .sclk(video_sclk),
    .mosi(video_mosi)    
  );
endmodule