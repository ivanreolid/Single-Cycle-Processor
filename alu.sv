module alu #(
  parameter OPCODE_WIDTH = 4,
  parameter DATA_WIDTH = 32
)(
  input  logic [OPCODE_WIDTH-1:0] op_i,
  input  logic [DATA_WIDTH-1:0] a_i,
  input  logic [DATA_WIDTH-1:0] b_i,
  output logic [DATA_WIDTH-1:0] result_o
);

  always_comb begin : operation
    case (op_i)
      4'b0000, 4'b0001, 4'b0010: result_o = a_i + b_i;
      4'b0011: result_o = a_i - b_i;
      4'b0110: result_o = a_i & b_i;
      4'b0100: result_o = a_i * b_i;
      4'b0101: result_o = a_i / b_i;
      4'b0111: result_o = a_i | b_i;
      4'b1000: result_o = a_i ^ b_i;
      default: result_o = 0;
    endcase
  end
  
endmodule
