`include "cpu.sv"

module test;

  logic clk;
  logic rst;

  cpu i_cpu (
    .clk (clk),
    .rst (rst)
  );

  initial begin
    clk = 1;
    rst = 1;

    #5 clk = 0;
    #5 clk = 1;
    #5 clk = 0;
    #5 clk = 1;
    #5 clk = 0;
    #5 clk = 1;
    #5 clk = 0;
    #5 clk = 1;
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
