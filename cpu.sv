`include "adder_pc_32b_2.sv"
`include "imem.sv"

module cpu (
  input logic clk_i,
  input logic rst_i
);

  logic [31:0] pc_d, pc_q;
  logic [31:0] instruction;

  adder_pc_32b_2 pc_adder (
    .a_i      (pc_q ),
    .b_i      (1    ),
    .result_o (pc_d )
  );

  imem imem (
    .address_i     (pc_q       ),
    .instruction_o (instruction)
  );

  always_ff @(posedge clk_i or negedge rst_i) begin : flops
    if (!rst_i) begin
      pc_q <= 0;
    end else begin
      pc_q <= pc_d;
    end
  end

  initial begin
    pc_d = 0;
  end
  
endmodule
