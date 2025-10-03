`include "adder_pc_32b_2.sv"
`include "imem.sv"

module cpu (
  input logic clk_i,
  input logic rst_i
);

  logic [31:0] pc_d, pc_q;
  logic [31:0] instruction;

  logic [31:0] reg_a_data, reg_b_data;

  adder_pc_32b_2 pc_adder (
    .a_i      (pc_q ),
    .b_i      (1    ),
    .result_o (pc_d )
  );

  imem imem (
    .address_i     (pc_q       ),
    .instruction_o (instruction)
  );

  // TODO: populate correctly with the proper wires
  rbank rbank (
    .clk_i       (clk_i),
    .rst_i       (rst_i),
    .wr_en_i     (1'b0),
    .rd_reg_a_i  (2),
    .rd_reg_b_i  (3),
    .wr_reg_i    (0),
    .wr_data_i   (0),
    .reg_a_data_o (reg_a_data),
    .reg_b_data_o (reg_b_data)
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
