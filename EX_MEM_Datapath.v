module EX_MEM_Register(
 output reg [31:0] Rt_Out,
 output reg [4:0] rd_Out,
 output reg [31:0] ALUResult_Out,
 input clk,
 input rst,
 input [31:0] Rt_In,
 input [4:0] rd_In,
 input [31:0] ALUResult_In
);

always@(posedge clk) begin
if(rst==1) begin
 Rt_Out <= 0;
 rd_Out <= 0;
 ALUResult_Out <= 0;
end

else begin
 Rt_Out <= Rt_In;
 rd_Out <= rd_In;
 ALUResult_Out <= ALUResult_In;
end

end
endmodule

