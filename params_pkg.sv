package params_pkg;

  typedef enum logic[3:0] {
    ADD = 4'b0000,
    LW  = 4'b0001,
    SW  = 4'b0010,
    SUB = 4'b0011,
    MUL = 4'b0100,
    DIV = 4'b0101,
    AND = 4'b0110,
    OR  = 4'b0111,
    XOR = 4'b1000,
    BEQ = 4'b1001,
    BNE = 4'b1010,
    BLT = 4'b1011,
    BGE = 4'b1100,
    JMP = 4'b1101
  } opcode;

endpackage
