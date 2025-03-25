module cpu(
  input clk,
  input [15:0] keypad_matrix,
  output [11:0] rom_addr,
  input [7:0] rom_dout,
  output [11:0] ram_addr,
  output [7:0] ram_din,
  input [7:0] ram_dout,
  output ram_we,
  output [6:0] vram_hpos,
  output [5:0] vram_vpos,
  output [1:0] vram_pixeli,
  input [1:0] vram_pixelo,
  output vram_we
  );
  
  parameter CPU_INIT   = 0;
  parameter CPU_MEMORY = 1;
  parameter CPU_FETCH  = 2;
  parameter CPU_EXEC   = 3;
  parameter CPU_CLEAR  = 4;
  parameter CPU_DRAW   = 5;
  parameter CPU_IDLE   = 6;
  
  reg [11:0] reg_pc;
  reg [11:0] reg_i;
  reg [7:0] reg_vr [15];
  reg [7:0] reg_ir [1:0];
  
  reg [3:0] state = CPU_INIT;
  reg [11:0] mem_from_index = 0;
  reg [11:0] mem_to_index = 0;
  reg [11:0] mem_count;
  reg mem_delay_cycle = 0;
  reg mem_is_fetch = 0;

  reg [1:0] draw_state = 0;
  reg [6:0] draw_x = 0;
  reg [5:0] draw_y = 0;
  reg [3:0] draw_rx = 0;
  reg [3:0] draw_ry = 0;
  reg [3:0] draw_n = 8;
  assign vram_hpos = draw_x;
  assign vram_vpos = draw_y;
//  reg [12:0] counter = 0;
  //assign vram_hpos = counter[12:6];
  //assign vram_vpos = counter[5:0];
  //wire [2:0] vram_pixel_index = 7 - {counter[1:0], 1'b0};
  //assign vram_pixeli = {ram_dout[vram_pixel_index], ram_dout[vram_pixel_index-1]};
  
  assign vram_we = state == CPU_CLEAR || state == CPU_DRAW;
  assign vram_pixeli = state == CPU_DRAW ? 1 : 0;
  assign rom_addr = mem_from_index;
//  assign ram_addr = state == CPU_DRAW ? {1'b00, counter[12:2]} : mem_to_index;
  assign ram_addr = state == CPU_DRAW ? mem_from_index : mem_to_index;
  assign ram_din = rom_dout;
  assign ram_we = state == CPU_MEMORY;
 
  always @(posedge clk)
  begin
    case (state)
      CPU_INIT: begin
//        mem_from <= MEM_ROM;
        mem_from_index <= 0;
//        mem_to <= MEM_RAM;
        mem_to_index <= 0; //12'h0200;
        mem_count <= 2048;
        mem_delay_cycle <= 1;
        mem_is_fetch <= 0;
        
        reg_vr[0] <= 20;
        reg_vr[1] <= 10;
        draw_rx <= 0;
        draw_ry <= 1;
        draw_n <= 4;
        
        state <= CPU_MEMORY;
      end
      CPU_MEMORY: begin
        if (mem_delay_cycle)
        begin
          mem_from_index <= mem_from_index + 1;
          mem_delay_cycle <= 0;
        end
        else
          if (mem_count > 0)
          begin
            mem_from_index <= mem_from_index + 1;
            mem_to_index <= mem_to_index + 1;
            mem_count <= mem_count - 1;
          end
          else
            state <= CPU_CLEAR;
      end
      CPU_CLEAR: begin
        draw_x <= draw_x + 1;
        if (draw_x == 127)
          begin
            draw_x <= 0;
            draw_y <= draw_y + 1;
          end
        if (draw_x == 127 && draw_y == 63)
          begin
            draw_x <= reg_vr[draw_rx][6:0];
            draw_y <= reg_vr[draw_ry][5:0];
            state <= CPU_DRAW;
          end
      end
      CPU_DRAW: begin
        draw_x <= draw_x + 1;
        if (draw_x >= reg_vr[draw_rx][6:0] + 7)
          begin
            draw_x <= reg_vr[draw_rx][6:0];
            if (draw_n != 1)
                draw_y <= draw_y + 1;
            draw_n <= draw_n - 1;
          end
        if (draw_n == 0)
          state <= CPU_IDLE;
      end
    endcase
  end  
endmodule