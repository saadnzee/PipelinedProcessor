module Control_PP(
input [5:0] opcode,
output reg [1:0] ALUOp,
output reg RegDst,
output reg Branch,
output reg MemRead,
output reg MemtoReg,
output reg MemWrite,
output reg ALUSrc,
output reg RegWrite,
output reg jump
);

always@(opcode) begin
// R-Type
if (opcode == 6'd0) begin
ALUOp <= 2'b10;
RegDst <= 1'b1;
RegWrite <= 1'b1;
ALUSrc <= 1'b0;
MemtoReg <= 1'b1;
MemWrite <= 1'b0;
MemRead <= 1'b0;
Branch <= 1'b0;
jump <= 1'b0;
end

// I-Type (addi)
else if (opcode == 6'd10) begin
ALUOp <= 2'b00;
RegDst <= 1'b0;
RegWrite <= 1'b1;
ALUSrc <= 1'b1;
MemtoReg <= 1'b0;
MemWrite <= 1'b0;
MemRead <= 1'b0;
Branch <= 1'b0;
jump <= 1'b0;
end

// Load Word
else if (opcode == 6'd35) begin
ALUOp <= 2'b00;
RegDst <= 1'b0;
RegWrite <= 1'b1;
ALUSrc <= 1'b1;
MemtoReg <= 1'b0;
MemWrite <= 1'b0;
MemRead <= 1'b1;
Branch <= 1'b0;
jump <= 1'b0;
end

// Store Word
else if (opcode == 6'd43) begin
ALUOp <= 2'b00;
RegDst <= 1'b1;
RegWrite <= 1'b0;
ALUSrc <= 1'b1;
MemtoReg <= 1'b0;
MemWrite <= 1'b1;
MemRead <= 1'b0;
Branch <= 1'b0;
jump <= 1'b0;
end

// BEQ
else if (opcode == 6'd4) begin
ALUOp <= 2'b01;
RegDst <= 1'b1;
RegWrite <= 1'b0;
ALUSrc <= 1'b0;
MemtoReg <= 1'b0;
MemWrite <= 1'b0;
MemRead <= 1'b0;
Branch <= 1'b1;
jump <= 1'b0;
end

// Jump
else if (opcode == 6'd2) begin
ALUOp <= 2'b00;
RegDst <= 1'b0;
RegWrite <= 1'b0;
ALUSrc <= 1'b0;
MemtoReg <= 1'b0;
MemWrite <= 1'b0;
MemRead <= 1'b0;
Branch <= 1'b0;
jump <= 1'b1;
end

end
endmodule


