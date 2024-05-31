module EX_MEM_Control(
 output reg MemRead_Out,
 output reg MemtoReg_Out,
 output reg MemWrite_Out,
 output reg RegWrite_Out,
 input clk,
 input rst,
 input MemRead_In,
 input MemtoReg_In,
 input MemWrite_In,
 input RegWrite_In
);

always@(posedge clk) begin
if(rst==1) begin
 MemRead_Out <= 0;
 MemtoReg_Out <= 0;
 MemWrite_Out <= 0;
 RegWrite_Out <= 0;
end

else begin
 MemRead_Out <= MemRead_In;
 MemtoReg_Out <= MemtoReg_In;
 MemWrite_Out <= MemWrite_In;
 RegWrite_Out <= RegWrite_In;
end

end

endmodule


