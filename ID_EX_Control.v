module ID_EX_Control(
 output reg [1:0] ALUOp_Out,
 output reg RegDst_Out,
 output reg Branch_Out,
 output reg MemRead_Out,
 output reg MemtoReg_Out,
 output reg MemWrite_Out,
 output reg ALUSrc_Out,
 output reg RegWrite_Out,
 output reg jump_Out,
 input clk,
 input rst,
 input [1:0] ALUOp_In,
 input RegDst_In,
 input Branch_In,
 input MemRead_In,
 input MemtoReg_In,
 input MemWrite_In,
 input ALUSrc_In,
 input RegWrite_In,
 input jump_In
);

always@(posedge clk) begin
if(rst==1) begin
 ALUOp_Out <= 0;
 RegDst_Out <= 0;
 Branch_Out <= 0;
 MemRead_Out <= 0;
 MemtoReg_Out <= 0;
 MemWrite_Out <= 0;
 ALUSrc_Out <= 0;
 RegWrite_Out <= 0;
 jump_Out <= 0;
end

else begin
 ALUOp_Out <= ALUOp_In;
 RegDst_Out <= RegDst_In;
 Branch_Out <= Branch_In;
 MemRead_Out <= MemRead_In;
 MemtoReg_Out <= MemtoReg_In;
 MemWrite_Out <= MemWrite_In;
 ALUSrc_Out <= ALUSrc_In;
 RegWrite_Out <= RegWrite_In;
 jump_Out <= jump_In;
end

end

endmodule


