/*Modify by yourself*/
`define CYCLE 45.1
`define TEST_DATA "test1.data"
`define GOLDEN_DATA "golden1.data"
/********************/

`timescale 1ns/10ps
module test();
reg clk, rst;
reg [7:0] in_data;
wire [7:0] out_data;
wire valid, req;

reg [7:0] test_data[79:0];
reg [7:0] golden_data[143:0];
reg [6:0] tcounter;
reg [7:0] gcounter;
reg [7:0] err;
wire [7:0] match = golden_data[gcounter];

integer i;

ELA inst_ELA(.clk(clk),.rst(rst),.in_data(in_data),.req(req),.out_data(out_data),.valid(valid));

always #(`CYCLE/2) clk = ~clk;

initial begin
	clk = 0;
	rst = 1;
	tcounter = 0;
	gcounter = 0;
	err = 0;
	$readmemh(`TEST_DATA, test_data);
	$readmemh(`GOLDEN_DATA, golden_data);
	#(`CYCLE+2) rst = 0;
end

always@(negedge clk)
begin
	if (req) begin
		for (i=tcounter;i<tcounter+16;i=i+1) begin
			@(negedge clk)
				in_data = test_data[i];	
		end
		tcounter = tcounter + 16;
	end 
end

always@(posedge clk)
begin
	if (!req) begin
		if (valid) begin 
			if (match!==out_data) begin
				$display("NUM %d: output %h != expected %h", gcounter, out_data, golden_data[gcounter]);
				err = err + 1; 
			end
			gcounter = gcounter + 1;
			if (gcounter == 144) begin
				$display("------------------------------------------------------------");
				if (err==0) begin
					$display("\\^0^/ All data have been generated successfully! \\^0^/ ");
				end
				else begin
					$display("(/`n`)/ ~# There are %d errors! (/`n`)/ ~#", err);
				end
				$display("------------------------------------------------------------");
				#5 $stop;
			end
		end
	end
end
endmodule
