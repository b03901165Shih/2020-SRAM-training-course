module sram_wrapper
(
	input 			CLK,
	input 			RST,
	input [511:0]	sram_in,
	input 			valid_in,
	output [511:0]	sram_out,
	output			valid_out
);

parameter RECI  = 2'b01;
parameter TRANS = 2'b10;
parameter SEND  = 2'b11;

reg [1:0] state, state_nxt;

reg [5:0] idx, idx_nxt;

reg 		sram_WEN, sram_REN;
reg [5:0]	sram_waddr, sram_raddr;

assign valid_out = (state==SEND);

genvar gen_idx;

// Do not chang
//Divide receiving data, process, and sending data
always @(*) begin
	sram_WEN = 0;
	sram_REN = 0;
	sram_waddr = 0;
	sram_raddr = 0;
	idx_nxt = idx;
	state_nxt = state;
	case(state)
		RECI: begin
			if(valid_in) begin
				sram_WEN = 1;
				sram_waddr = idx;
				idx_nxt = idx+1;
				if(idx==63) begin
					idx_nxt = idx;
					state_nxt = TRANS;
				end
			end
		end
		TRANS: begin
			sram_REN = 1;
			sram_raddr = idx;
			idx_nxt = 62;
			state_nxt = SEND;
		end
		SEND: begin
			sram_REN = 1;
			sram_raddr = idx;
			idx_nxt = idx-1;
			if(idx==63) begin
				state_nxt = RECI;
			end
		end
	endcase
end

always @(posedge CLK or posedge RST) begin
	if (RST) begin
		idx 	<= 0;
		state 	<= RECI;
	end
	else begin
		idx 	<= idx_nxt;
		state 	<= state_nxt;
	end
end


generate
  for(gen_idx=0;gen_idx<4;gen_idx=gen_idx+1)begin: genBlock1
	sram_dp_64x128 sbj_memory ( 
		.CLKA(CLK),
		.CLKB(CLK),
		.CENA( !sram_WEN ),
		.CENB( !sram_REN  ),    
		.WENA(1'b0),    // port A is always used to store
		.WENB(1'b1),    // port B provide the sequence data to register array/
		.AA(sram_waddr),   
		.AB(sram_raddr),   
		.DA(sram_in[(128*(gen_idx+1)-1)-:128]),
		.DB(128'b0),
		// output
		//.QA(),
		.QB(sram_out[(128*(gen_idx+1)-1)-:128]),	
		.EMAA(3'b0), 
		.EMAB(3'b0), 
		.EMASA(1'b0), 
		.EMASB(1'b0), 
		.EMAWA(2'b0), 
		.EMAWB(2'b0), 
		.BENA(1'b1), 
		.BENB(1'b1), 
		.STOVA(1'b0), 
		.STOVB(1'b0), 
		.TENA(1'b1),
		.TENB(1'b1),
		.RET1N(1'b1) 
	);
  end
endgenerate



endmodule
