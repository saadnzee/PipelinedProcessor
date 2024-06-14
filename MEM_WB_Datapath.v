module MEM_WB_Register(
 output reg [31:0] read_data_Out,
 output reg [4:0] rd_Out,
 output reg [31:0] ALUResult_Out,
 input clk,
 input rst,
 input [31:0] read_data_In,
 input [4:0] rd_In,
 input [31:0] ALUResult_In
);

always@(posedge clk) begin
if(rst==1) begin
 read_data_Out <= 0;
 rd_Out <= 0;
 ALUResult_Out <= 0;
end

else begin
 read_data_Out <= read_data_In;
 rd_Out <= rd_In;
 ALUResult_Out <= ALUResult_In;
end

end
endmodule

