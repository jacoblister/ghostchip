module romflash(
  input  clk,
  
  output reg flash_cs = 1,
  output flash_clk,
  output reg flash_mosi = 0,
  input flash_miso,
  
  input  [15:0] addr,    
  output reg [7:0] dout,
  output reg dready = 0
  );
  
  parameter DRV_IDLE = 0;
  parameter DRV_SELECT = 1;
  parameter DRV_CMD = 2;
  parameter DRV_ADDR = 3;
  parameter DRV_DATA = 4;

  reg [8:0] count;
  reg [23:0] addr_loaded = 24'hfff;
  reg [2:0] drv_state = DRV_IDLE;
  reg [7:0] read_cmd = 8'h03;
  
  reg clk_enable = 0;
  
  assign flash_clk = !clk_enable || clk;
  
  always @(negedge clk) begin
    if (count > 0)
      count <= count - 1;
  
    case (drv_state)
      DRV_IDLE: begin
        flash_cs <= 1;
        clk_enable <= 0;
        flash_mosi <= 0;
      
        if (addr != addr_loaded)
          begin
          addr_loaded <= addr;
          count <= 0;
          dready <= 0;
          drv_state <= DRV_SELECT;
          end
      end
      DRV_SELECT: begin
        flash_cs <= 0;
        if (count == 0)
          begin
          count <= 7;
          drv_state <= DRV_CMD;
          end
        end
      DRV_CMD: begin
        flash_mosi <= read_cmd[count];
        clk_enable <= 1;
        if (count == 0)
          begin
          count <= 23;
          drv_state <= DRV_ADDR;
          end
      end
      DRV_ADDR: begin
        flash_mosi <= addr_loaded[count];
        if (count == 0)
          begin
          count <= 8;
          drv_state <= DRV_DATA;
          end
      end
      DRV_DATA: begin
        flash_mosi <= 0;
        if (count != 8)
          dout[count] <= flash_miso;
        if (count == 0)
          begin
          dready <= 1;
          drv_state <= DRV_IDLE;
          end
      end
    endcase
  end
endmodule