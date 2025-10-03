`include "cpu.sv"

module test;
  localparam MEM_SIZE = 4096;

  logic clk;
  logic rst;

  cpu #(
    .MEM_SIZE (MEM_SIZE)
  ) i_cpu (
    .clk_i (clk),
    .rst_i (rst)
  );

  initial begin
    clk = 1;
    rst = 1;

    #5 clk = 0;
    #5 clk = 1;
    #5 clk = 0;
    #5 clk = 1;
    #5 clk = 0; rst = 0;
    #5 clk = 1;
    #5 clk = 0;
    #5 clk = 1; rst = 1;
    #5 clk = 0;
    #5 clk = 1;
    #5 clk = 0;
    #5 clk = 1;
    #5 clk = 0;
    #5 clk = 1;
    #5 clk = 0;
    #5 clk = 1;
  end
  
endmodule
