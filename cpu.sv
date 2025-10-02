`include "adder_pc_32b_2.sv"

module cpu (
  input logic clk,
  input logic rst
);

  logic [31:0] pc_d, pc_q;

  adder_pc_32b_2 pc_adder (
    .a_i      (pc_q ),
    .b_i      (1    ),
    .result_o (pc_d )
  );

  always_ff @(posedge clk or negedge rst) begin : flops
    if (!rst) begin
      pc_q <= 0;
    end else begin
      pc_q <= pc_d;
    end
  end

  initial begin
    pc_d = 0;
  end
  
endmodule
