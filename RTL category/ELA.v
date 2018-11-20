`timescale 1ns/10ps

module ELA(clk, rst, in_data, req, out_data, valid);
input clk, rst;
input [7:0] in_data;
output req;
output [7:0] out_data;
output valid;

//--------------------------------------
//  \^o^/   Write your code here~  \^o^/
//--------------------------------------


reg     req;
reg     valid;
reg[7:0]out_data;
reg[1:0]current_state,next_state;

parameter [1:0] INIT      = 2'b00,
                DIRECT    = 2'b01,
                CALCULATE = 2'b10,
                SCAN      = 2'b11;

reg[7:0]data_array[0:31];
integer i;
reg en;
reg[7:0] array_in;
wire[7:0] array_out;
reg[4:0]cnt;
reg w_req;
reg cnt_rst;
reg w_valid;

reg[7:0]cal_out;

always @(*) begin
    next_state = current_state;
	cnt_rst = 0;
    case(current_state)
        INIT: begin
            if(cnt==17)begin
				next_state = DIRECT;
				cnt_rst = 1;
			end
        end
		
        DIRECT: begin
			if(cnt==14)begin
				next_state = CALCULATE;
				cnt_rst = 1;
			end
		end
		
        CALCULATE:begin
			if(cnt==15)begin
				next_state = SCAN;
				cnt_rst = 1;
			end
		end
		
        SCAN: begin
			if(cnt==17)begin
				next_state = DIRECT;
				cnt_rst = 1;
			end
		end
		
    endcase
end


always @(*) begin
	w_req = req;
	w_valid = valid;
	en = 0;
	array_in = in_data;
    case(current_state)
        INIT: begin
			out_data = in_data;
			
			w_req = 0;
			w_valid = 1;
			en = 1;
			if(cnt==5'h10)		//16
				w_req = 1;
			if(cnt==5'h11)begin		//17
				en = 0;
				w_valid = 0;
			end			
        end
		
        DIRECT: begin
			w_valid = 0;
			en = 1;

			if(cnt == 14)begin
				w_req = 0;
				w_valid = 1;
			end
			
		end
		
        CALCULATE:begin
			out_data = cal_out;
			w_req = 0;
			w_valid = 1;
			en = 1;
			if(cnt>0)
				array_in = 8'h0;
			if(cnt==15)begin
				en = 0;
				w_valid = 0;
			end	
		end
		
        SCAN: begin
			en = 1;
			w_req = 0;
			w_valid = 1;
			
			if(cnt ==17)begin
				w_valid = 0;
				en = 0;
			end
			else if(cnt == 16) begin
				w_req = 1;
				
				en = 0;
		
				out_data = data_array[31];
			end
			else begin
				out_data = data_array[31];
			end	
			
		end
		
    endcase
end

reg[7:0]a_f;
reg[7:0]b_e;
reg[7:0]c_d;
reg[7:0]campare1;
reg[7:0]campare2;
reg[1:0]flag;
reg[8:0]cal_preout;

always@(*)begin
	
	if(
		(current_state == CALCULATE && cnt == 0)||
		(current_state == CALCULATE && cnt == 15)
	)begin
		cal_preout = ({1'b0, data_array[1]}+{1'b0, data_array[17]});
		cal_out = cal_preout[8:1] + cal_preout[0];
	end	
	
	else begin
		if((data_array[0]>=data_array[18]))begin	
		a_f = data_array[0]-data_array[18];
		end
		else begin
			a_f = data_array[18]-data_array[0];
		end
		
		
		if((data_array[1]>=data_array[17]))begin	
			b_e = data_array[1]-data_array[17];
		end
		else begin
			b_e = data_array[17]-data_array[1];
		end
			
		if((data_array[2]>=data_array[16]))begin	
			c_d = data_array[2]-data_array[16];
		end
		else begin
			c_d = data_array[16]-data_array[2];
		end

		
		if((b_e < a_f) || (b_e == a_f))begin
			campare1 = b_e;
		end
		else begin
			campare1 = a_f;
		end
		
		if((campare1<c_d)||(campare1==c_d))begin
			campare2 = campare1;
		end
		else begin
			campare2 = c_d;
		end
		
		if (campare2==b_e)begin
			flag = 2'b01;
		end
		else if(campare2==a_f)begin
			flag = 2'b00;
		end
		else begin
			flag = 2'b10;
		end
		
		
		case(flag)
			2'b00:begin
				cal_preout = ({1'b0, data_array[0]}+{1'b0, data_array[18]});
				cal_out = cal_preout[8:1] + cal_preout[0];
			end
			2'b01:begin
				cal_preout = ({1'b0, data_array[1]}+{1'b0, data_array[17]});
				cal_out = cal_preout[8:1] + cal_preout[0];
			end
			default:begin
				cal_preout = ({1'b0, data_array[2]}+{1'b0, data_array[16]});
				cal_out = cal_preout[8:1] + cal_preout[0];
				end
		endcase
	end
	
end

always @(posedge clk) begin
    if (rst | cnt_rst)
        cnt <= 0;
    else
        cnt <= cnt + 5'h1;
end

assign array_out = data_array[0];

always@(posedge clk)begin
	if(rst)begin
		for(i=0;i<32;i=i+1)begin
			data_array[i] <= 8'b0;
		end
	end
	
	else if(en)begin
	
		if(current_state==SCAN)begin
			data_array[31] <= data_array[2];
			for(i=1;i<32;i=i+1)begin
				data_array[i-1] <= data_array[i];
			end	
		end
		
		else begin
			data_array[31] <= array_in;
			for(i=1;i<32;i=i+1)begin
				data_array[i-1] <= data_array[i];
			end
		end
	end	
end

always @(posedge clk) begin
    if(rst) begin
		req <= 1;
		valid <= 0;
        current_state <= INIT;
    end
    else begin
		req <= w_req;
		valid <= w_valid;
        current_state <= next_state;
    end
end

endmodule

