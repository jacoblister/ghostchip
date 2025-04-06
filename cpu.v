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
  
  parameter MEM_ROM = 0;
  parameter MEM_RAM = 1;
  parameter MEM_REG = 2;
  parameter MEM_IR  = 3;
  
  reg [11:0] reg_pc;
  reg [11:0] reg_i;
  reg [7:0] reg_vr [16];
  reg [15:0] reg_ir;
  
  reg [3:0] state = CPU_INIT;
  reg [2:0] mem_from;
  reg [11:0] mem_from_index = 0;
  reg [2:0] mem_to;
  reg [11:0] mem_to_index = 0;
  reg [11:0] mem_count;
  reg mem_delay_cycle = 0;
  reg mem_is_fetch = 0;

  reg [6:0] draw_x = 0;
  reg [5:0] draw_y = 0;
  reg [3:0] draw_rx = 0;
  reg [3:0] draw_ry = 0;
  reg [3:0] draw_n = 8;
  assign vram_hpos = draw_x;
  assign vram_vpos = draw_y;
  
  assign vram_we = state == CPU_CLEAR || state == CPU_DRAW;
  wire[7:0] vram_ram_index = 7 - (draw_x - reg_vr[draw_rx]);
  assign vram_pixeli = state == CPU_DRAW ? ram_dout[vram_ram_index[2:0]] ? 3 : 0 : 0;

  wire [7:0] data = 
    mem_from == MEM_RAM ? ram_dout : 
    mem_from == MEM_ROM ? rom_dout : 
    mem_from == MEM_REG ? reg_vr[mem_from_index[3:0]] :
    mem_from == MEM_IR && mem_from_index == 0 ? reg_ir[15:8] :
    mem_from == MEM_IR && mem_from_index == 1 ? reg_ir[7:0] :
    0;
  assign ram_addr =  
    mem_from == MEM_RAM ? mem_from_index : 
    mem_to == MEM_RAM ? mem_to_index :
    0;
  assign rom_addr =  
    mem_from == MEM_ROM ? mem_from_index : 
    mem_to == MEM_ROM ? mem_to_index :
    0;
  assign ram_din = data;
  assign ram_we = mem_to == MEM_RAM;
  always @(posedge clk)
  begin
    if (mem_to == MEM_IR && mem_to_index == 0) 
      reg_ir[15:8] <= data;
    if (mem_to == MEM_IR && mem_to_index == 1) 
      reg_ir[7:0] <= data;
    if (mem_to == MEM_REG)
      reg_vr[mem_to_index[3:0]] <= data;
  end
  
  always @(posedge clk)
  begin
    case (state)
      CPU_INIT: begin
        mem_from <= MEM_ROM;
        mem_from_index <= 0;
        mem_to <= MEM_RAM;
        mem_to_index <= 12'h0200;
        mem_count <= 2048;
        mem_delay_cycle <= 1;
        mem_is_fetch <= 0;
        
        reg_vr[4'hf] <= 0;
        reg_pc <= 12'h0200;
       
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
            state <= 
              mem_is_fetch ? CPU_EXEC : 
              mem_from == MEM_ROM ? CPU_CLEAR :
              CPU_FETCH;
      end
      CPU_FETCH: begin
        mem_from <= MEM_RAM;
        mem_from_index <= reg_pc;
        mem_to <= MEM_IR;
        mem_to_index <= 0;
        mem_count <= 2;
        mem_is_fetch <= 1;
        mem_delay_cycle <= 1;

        reg_pc <= reg_pc + 2;
        state <= CPU_MEMORY;
      end
      CPU_EXEC: begin
        if (reg_ir == 16'h00e0)
          state <= CPU_CLEAR;
        else if (reg_ir[15:12] == 4'h1)
          begin
          reg_pc <= reg_ir[11:0];
          state <= CPU_FETCH;
          end
        else if (reg_ir[15:12] == 4'h3)
          begin
          if (reg_vr[reg_ir[11:8]] == reg_ir[7:0])
            reg_pc <= reg_pc + 2;
          state <= CPU_FETCH;
          end
        else if (reg_ir[15:12] == 4'h4)
          begin
          if (reg_vr[reg_ir[11:8]] != reg_ir[7:0])
            reg_pc <= reg_pc + 2;
          state <= CPU_FETCH;
          end
        else if (reg_ir[15:12] == 4'h5)
          begin
          if (reg_vr[reg_ir[11:8]] == reg_vr[reg_ir[7:4]])
            reg_pc <= reg_pc + 2;
          state <= CPU_FETCH;
          end
        else if (reg_ir[15:12] == 4'h6)
          begin
          reg_vr[reg_ir[11:8]] <= reg_ir[7:0];
          state <= CPU_FETCH;
          end
        else if (reg_ir[15:12] == 4'h7)
          begin
          reg_vr[reg_ir[11:8]] <= reg_vr[reg_ir[11:8]] + reg_ir[7:0];
          state <= CPU_FETCH;
          end
        else if (reg_ir[15:12] == 4'h8 && reg_ir[3:0] == 4'h1)
          begin
          reg_vr[reg_ir[11:8]] <= reg_vr[reg_ir[11:8]] | reg_vr[reg_ir[7:4]];
          state <= CPU_FETCH;
          end
        else if (reg_ir[15:12] == 4'h8 && reg_ir[3:0] == 4'h2)
          begin
          reg_vr[reg_ir[11:8]] <= reg_vr[reg_ir[11:8]] & reg_vr[reg_ir[7:4]];
          state <= CPU_FETCH;
          end
        else if (reg_ir[15:12] == 4'h8 && reg_ir[3:0] == 4'h3)
          begin
          reg_vr[reg_ir[11:8]] <= reg_vr[reg_ir[11:8]] ^ reg_vr[reg_ir[7:4]];
          state <= CPU_FETCH;
          end
        else if (reg_ir[15:12] == 4'h8 && reg_ir[3:0] == 4'h5)
          begin
          reg_vr[4'hf] <= reg_vr[reg_ir[11:8]] < reg_vr[reg_ir[7:4]] ? 8'h00 : 8'h01;
          reg_vr[reg_ir[11:8]] <= reg_vr[reg_ir[11:8]] - reg_vr[reg_ir[7:4]];
          state <= CPU_FETCH;
          end
        else if (reg_ir[15:12] == 4'h8 && reg_ir[3:0] == 4'h6)
          begin
          reg_vr[4'hf] <= reg_vr[reg_ir[11:8]][0] ? 8'h01 : 8'h00;
          reg_vr[reg_ir[11:8]] <= reg_vr[reg_ir[11:8]] >> 1;
          state <= CPU_FETCH;
          end
        else if (reg_ir[15:12] == 4'h8 && reg_ir[3:0] == 4'h7)
          begin
          reg_vr[4'hf] <= reg_vr[reg_ir[11:8]] > reg_vr[reg_ir[7:4]] ? 8'h00 : 8'h01;
          reg_vr[reg_ir[11:8]] <= reg_vr[reg_ir[7:4]] - reg_vr[reg_ir[11:8]];
          state <= CPU_FETCH;
          end
        else if (reg_ir[15:12] == 4'h8 && reg_ir[3:0] == 4'hE)
          begin
          reg_vr[4'hf] <= reg_vr[reg_ir[11:8]][7] ? 8'h01 : 8'h00;
          reg_vr[reg_ir[11:8]] <= reg_vr[reg_ir[11:8]] << 1;
          state <= CPU_FETCH;
          end
        else if (reg_ir[15:12] == 4'hA)
          begin
          reg_i <= reg_ir[11:0];
          state <= CPU_FETCH;
          end
        else if (reg_ir[15:12] == 4'hD)
          begin
          draw_rx <= reg_ir[11:8];
          draw_ry <= reg_ir[7:4];
          draw_x <= reg_vr[reg_ir[11:8]][6:0];
          draw_y <= reg_vr[reg_ir[7:4]][5:0];
          draw_n <= reg_ir[3:0];
          mem_from <= MEM_RAM;
          mem_from_index <= reg_i;
          mem_delay_cycle <= 1;
          state <= CPU_DRAW;
          end
//        else if (reg_ir[15:12] == 4'hF && reg_ir[7:0] == 8'h1E)
//          begin
//          state <= CPU_FETCH;
//          end
        else if (reg_ir[15:12] == 4'hF && reg_ir[7:0] == 8'h29)
          begin
          // set hex
          state <= CPU_FETCH;
          end
        else if (reg_ir[15:12] == 4'hF && reg_ir[7:0] == 8'h33)
          begin
          // BCD Decode
          state <= CPU_FETCH;
          end
        else if (reg_ir[15:12] == 4'hF && reg_ir[7:0] == 8'h55)
          begin
          mem_count <= {8'h00, reg_ir[11:8]};
          mem_from <= MEM_REG;
          mem_to <= MEM_RAM;
          mem_delay_cycle <= 1;
          mem_is_fetch <= 0;
          state <= CPU_MEMORY;
          end
        else if (reg_ir[15:12] == 4'hF && reg_ir[7:0] == 8'h65)
          begin
          mem_count <= {8'h00, reg_ir[11:8]};
          mem_from <= MEM_RAM;
          mem_to <= MEM_REG;
          mem_delay_cycle <= 1;
          mem_is_fetch <= 0;
          state <= CPU_MEMORY;
          end
        else 
          state <= CPU_IDLE;
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
            state <= CPU_FETCH;
          end
      end
      CPU_DRAW: begin
        if (mem_delay_cycle)
        begin
          mem_delay_cycle <= 0;
        end
        else
          draw_x <= draw_x + 1;
          if (draw_x >= reg_vr[draw_rx][6:0] + 7)
            begin
              draw_x <= reg_vr[draw_rx][6:0];
              if (draw_n != 1)
                draw_y <= draw_y + 1;
              draw_n <= draw_n - 1;

              mem_from_index <= mem_from_index + 1;
              mem_delay_cycle <= 1;
            end
          if (draw_n == 0)
            state <= CPU_FETCH;
        end
      CPU_IDLE: begin
        draw_x <= ram_dout[6:0];
      end
    endcase
  end  
endmodule