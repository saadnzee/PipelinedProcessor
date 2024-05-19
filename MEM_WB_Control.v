module MEM_WB_Control(
 output reg MemtoReg_Out,
 output reg RegWrite_Out,
 input clk,
 input rst,
 input MemtoReg_In,
 input RegWrite_In
);

always@(posedge clk) begin
if(rst==1) begin
 MemtoReg_Out <= 0;
 RegWrite_Out <= 0;
end

else begin
 MemtoReg_Out <= MemtoReg_In;
 RegWrite_Out <= RegWrite_In;
end

end

endmodule


