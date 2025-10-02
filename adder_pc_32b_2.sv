module adder_pc_32b_2 (
  input  logic [31:0] a_i,
  input  logic [31:0] b_i,
  output logic [31:0] result_o 
);

  assign result_o = (a_i + b_i) % 4096; 

endmodule
