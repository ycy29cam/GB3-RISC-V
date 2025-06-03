// -----------------------------------------------------------------------------
//  Hybrid Branch Predictor (minimal changes from baseline design)
//  * Keeps the same I/O ports and simulation counters
//  * Adds a simple hybrid predictor: local‑history (per‑branch) + gshare
//    with a 2‑bit meta‑chooser table.
//  * Branches are still assumed not to occur back‑to‑back (pipeline bubble),
//    simplifying bookkeeping (only one in‑flight branch at a time).
// -----------------------------------------------------------------------------

// module branch_predictor(
//         clk,
//         actual_branch_decision,
//         branch_decode_sig,
//         branch_mem_sig,
//         in_addr,
//         offset,
//         branch_addr,
//         prediction
//     );

//     //------------------------------------------------------------
//     // inputs
//     //------------------------------------------------------------
//     input           clk;
//     input           actual_branch_decision;
//     input           branch_decode_sig;   // asserted in Decode stage for a branch
//     input           branch_mem_sig;      // asserted in MEM stage for same branch
//     input [31:0]    in_addr;             // PC of the branch (Decode stage)
//     input [31:0]    offset;

//     //------------------------------------------------------------
//     // outputs
//     //------------------------------------------------------------
//     output [31:0]   branch_addr;         // target address (same as baseline)
//     output          prediction;          // 1 = predict taken, 0 = predict not‑taken

//     //------------------------------------------------------------
//     // INTERNAL STATE
//     //------------------------------------------------------------
//     //  NOTE: The old 2‑bit counter "s" is retained so the SIMULATION block
//     //  (which tracks accuracy) can stay almost unchanged.  We now load s[1]
//     //  with *our current prediction* each time a branch is decoded.
//     //------------------------------------------------------------
//     reg  [1:0]  s;

//     //------------------------------------------------------------
//     // Registers to pipeline "branch_mem_sig" (unchanged)
//     //------------------------------------------------------------
//     reg         branch_mem_sig_reg;
//     always @(negedge clk) begin
//         branch_mem_sig_reg <= branch_mem_sig;
//     end

//     //------------------------------------------------------------
//     // *** NEW: Hybrid‑predictor tables ***
//     //------------------------------------------------------------
//     localparam BHT_ENTRIES = 64;        // 8‑bit index (PC[9:2])

//     // Local (per‑branch) predictor – 2‑bit saturating counters
//     reg [1:0] local_bht   [0:BHT_ENTRIES-1];

//     // Gshare predictor – 2‑bit saturating counters indexed by PC ^ GHR
//     reg [1:0] gshare_pht  [0:BHT_ENTRIES-1];

//     // Meta chooser – 2‑bit counters; 0/1: prefer local, 2/3: prefer gshare
//     reg [1:0] chooser      [0:BHT_ENTRIES-1];

//     // Global History Register (8 bits)
//     reg [5:0] ghr;

//     //------------------------------------------------------------
//     // State captured at Decode so we can update tables later when
//     // the same branch reaches MEM stage (only 1 in‑flight branch).
//     //------------------------------------------------------------
//     reg [5:0] dec_local_idx;
//     reg [5:0] dec_gshare_idx;
//     reg       dec_local_pred;
//     reg       dec_gshare_pred;

//     //------------------------------------------------------------
//     // INITIALISATION (synth‑only tools will turn this into reset logic)
//     //------------------------------------------------------------
//     integer i;
//     initial begin
//         s  = 2'b00;
//         branch_mem_sig_reg = 1'b0;
//         ghr = 8'h00;
//         for (i = 0; i < BHT_ENTRIES; i = i + 1) begin
//             local_bht[i]  = 2'b01;   // weakly NOT‑taken
//             gshare_pht[i] = 2'b01;
//             chooser[i]    = 2'b01;   // weakly prefer local
//         end
//     end

//     //------------------------------------------------------------
//     // COMBINATIONAL PREDICTION (Decode stage)
//     //------------------------------------------------------------
//     wire [5:0] local_idx   = in_addr[9:2];
//     wire [5:0] gshare_idx  = in_addr[9:2] ^ ghr;

//     wire       local_pred  = local_bht[local_idx][1];
//     wire       gshare_pred = gshare_pht[gshare_idx][1];
//     wire       choose_gs   = chooser[local_idx][1];   // 0=local, 1=gshare

//     wire       final_pred  = choose_gs ? gshare_pred : local_pred;

//     //------------------------------------------------------------
//     // Drive outputs
//     //------------------------------------------------------------
//     assign branch_addr = in_addr + offset;
//     assign prediction  = branch_decode_sig ? final_pred : 1'b0;

//     //------------------------------------------------------------
//     // Capture Decode‑stage info *and* expose current prediction via s[1]
//     //------------------------------------------------------------
//     always @(posedge clk) begin
//         if (branch_decode_sig) begin
//             dec_local_idx   <= local_idx;
//             dec_gshare_idx  <= gshare_idx;
//             dec_local_pred  <= local_pred;
//             dec_gshare_pred <= gshare_pred;
//             // Export current prediction to SIMULATION counters
//             s[1] <= final_pred;
//             s[0] <= final_pred;   // not used, keeps width = 2 bits
//         end
//     end

//     //------------------------------------------------------------
//     // TABLE UPDATES (MEM stage)
//     //------------------------------------------------------------
//     always @(posedge clk) begin
//         if (branch_mem_sig_reg) begin
//             // --- Update Local BHT ---
//             if (actual_branch_decision)
//                 local_bht[dec_local_idx]  <= (local_bht[dec_local_idx]==2'b11) ? 2'b11 : local_bht[dec_local_idx] + 1;
//             else
//                 local_bht[dec_local_idx]  <= (local_bht[dec_local_idx]==2'b00) ? 2'b00 : local_bht[dec_local_idx] - 1;

//             // --- Update Gshare PHT ---
//             if (actual_branch_decision)
//                 gshare_pht[dec_gshare_idx] <= (gshare_pht[dec_gshare_idx]==2'b11) ? 2'b11 : gshare_pht[dec_gshare_idx] + 1;
//             else
//                 gshare_pht[dec_gshare_idx] <= (gshare_pht[dec_gshare_idx]==2'b00) ? 2'b00 : gshare_pht[dec_gshare_idx] - 1;

//             // --- Update Chooser if predictors disagree ---
//             if (dec_local_pred != dec_gshare_pred) begin
//                 if (dec_gshare_pred == actual_branch_decision) begin
//                     chooser[dec_local_idx] <= (chooser[dec_local_idx]==2'b11) ? 2'b11 : chooser[dec_local_idx] + 1;
//                 end else if (dec_local_pred == actual_branch_decision) begin
//                     chooser[dec_local_idx] <= (chooser[dec_local_idx]==2'b00) ? 2'b00 : chooser[dec_local_idx] - 1;
//                 end
//             end

//             // --- Update Global History Register ---
//             ghr <= {ghr[5:0], actual_branch_decision};
//         end
//     end

// // -----------------------------------------------------------------------------
// //                    S I M U L A T I O N   S U P P O R T
// // -----------------------------------------------------------------------------
// `ifdef SIMULATION
//     // Testbench still provides a normalised PC, so the offset logic above is OK.
//     reg [31:0] total_branches;
//     reg [31:0] correct_predictions;
//     initial begin
//         total_branches     = 32'd0;
//         correct_predictions = 32'd0;
//     end

//     // Accuracy counters – now compare against *prediction* output (not s[1])
//     always @(posedge clk) begin
//         if (branch_mem_sig_reg) begin
//             total_branches <= total_branches + 1;
//             if (s[1] == actual_branch_decision)
//                 correct_predictions <= correct_predictions + 1;
//         end
//     end
// `endif
// endmodule


// Improved branch predictor with 256‑entry 2‑bit BHT
// (minimal changes to ports; simulation sections kept intact)


// module branch_predictor(
//         clk,
//         actual_branch_decision,
//         branch_decode_sig,
//         branch_mem_sig,
//         in_addr,
//         offset,
//         branch_addr,
//         prediction
//     );

//     /*
//      *  inputs
//      */
//     input       clk;
//     input       actual_branch_decision;
//     input       branch_decode_sig;
//     input       branch_mem_sig;
//     input [31:0] in_addr;
//     input [31:0] offset;

//     /*
//      *  outputs
//      */
//     output [31:0]    branch_addr;
//     output          prediction;

//     /*
//      *  internal state
//      */
//     // 2‑bit saturating counter that holds the *current* prediction value
//     // for the branch in the DECODE stage – keeps the simulation code intact.

//     // One‑cycle delayed MEM‑stage branch signal (unchanged)
//     reg       branch_mem_sig_reg;

//     // 256‑entry Branch History Table – indexed by bits [9:2] of the PC
//     reg  [1:0] bht [0:255];
//     wire [7:0] index = in_addr[9:2];

//     // Remember the table entry belonging to the branch that is currently
//     // flowing down the pipeline so we can update it in MEM.
//     reg  [7:0] commit_index;

//     // Latch the prediction of the branch when it is in DECODE so the
//     // simulator can check it later in MEM.
//     reg        predicted_taken_reg;

// `ifdef SIMULATION
//     // Simple statistics counters – unchanged except for using the new
//     // registered prediction value.
//     reg [31:0] total_branches;
//     reg [31:0] correct_predictions;
//     initial begin
//         total_branches        = 32'd0;
//         correct_predictions   = 32'd0;
//     end
// `endif

//     /*------------------------------------------------------------
//      *  Reset / initialisation (kept – note about Yosys remains)
//      *----------------------------------------------------------*/
//     integer i;
//     initial begin
//         branch_mem_sig_reg = 1'b0;
//         // Initialise the whole BHT to 2'b00 (strong NOT‑TAKEN)
//         for (i = 0; i < 256; i = i + 1) begin
//             bht[i] = 2'b00;
//         end
//     end

//     /*------------------------------------------------------------
//      *  Pipeline bookkeeping
//      *----------------------------------------------------------*/
//     // MEM‑stage signal delay (unchanged)
//     always @(negedge clk) begin
//         branch_mem_sig_reg <= branch_mem_sig;
//     end

//     // Capture the index and the *current* prediction when the branch is in
//     // DECODE.  This is a single outstanding branch because the pipeline
//     // inserts a bubble after every branch.
//     always @(posedge clk) begin
//         if (branch_decode_sig) begin
//             commit_index        <= index;
//             predicted_taken_reg <= bht[index][1];
//         end
//     end

//     /*------------------------------------------------------------
//      *  Update rule for the 2‑bit saturating counter in MEM
//      *----------------------------------------------------------*/
//     always @(posedge clk) begin
//         if (branch_mem_sig_reg) begin
//             if (actual_branch_decision) begin  // branch **taken**
//                 if (bht[commit_index] != 2'b11)
//                     bht[commit_index] <= bht[commit_index] + 2'b01;
//             end else begin                     // branch **not taken**
//                 if (bht[commit_index] != 2'b00)
//                     bht[commit_index] <= bht[commit_index] - 2'b01;
//             end
//         end
//     end

// `ifdef SIMULATION
//     /*
//      *  Simple accuracy counters (unchanged apart from using the new
//      *  registered prediction value).
//      */
//     always @(posedge clk) begin
//         if (branch_mem_sig_reg) begin
//             total_branches <= total_branches + 1;
//             if (predicted_taken_reg == actual_branch_decision)
//                 correct_predictions <= correct_predictions + 1;
//         end
//     end
// `endif

//     /*------------------------------------------------------------
//      *  Outputs
//      *----------------------------------------------------------*/
//     assign branch_addr = in_addr + offset;
//     // Use the BHT entry for the *current* PC to form the decode‑stage
//     // prediction.  The extra AND keeps the original hand‑shake with the
//     // outside world unchanged.
//     assign prediction  = bht[index][1] & branch_decode_sig;

// endmodule

 /*
 *		Branch Predictor FSM (baseline design)
 */

module branch_predictor(
		clk,
		actual_branch_decision,
		branch_decode_sig,
		branch_mem_sig,
		in_addr,
		offset,
		branch_addr,
		prediction
	);

	/*
	 *	inputs
	 */
	input		clk;
	input		actual_branch_decision;
	input		branch_decode_sig;
	input		branch_mem_sig;
	input [31:0]	in_addr;
	input [31:0]	offset;

	/*
	 *	outputs
	 */
	output [31:0]	branch_addr;
	output		prediction;

	/*
	 *	internal state
	 */
	reg [1:0]	s;

	reg		branch_mem_sig_reg;
	// reg [1:0] bht[0:255];
	// wire [7:0] index;  // Use PC bits

	// initial begin
	// 	integer i;
	// 	for (i = 0; i < 256; i = i + 1) begin
	// 		bht[i] = 2'b00;
	// 	end
	// 	branch_mem_sig_reg = 1'b0;
	// end
	// assign index = in_addr[9:2];  


// (new)
`ifdef SIMULATION
	// In simulation: testbench provides normalized address, so no offset needed
	reg [31:0] total_branches;
	reg [31:0] correct_predictions;
	initial begin
		// s = 2'b00;
		// branch_mem_sig_reg = 1'b0;
		total_branches = 32'd0;
		correct_predictions = 32'd0;
	end
`endif
	/*
	 *	The `initial` statement below uses Yosys's support for nonzero
	 *	initial values:
	 *
	 *		https://github.com/YosysHQ/yosys/commit/0793f1b196df536975a044a4ce53025c81d00c7f
	 *
	 *	Rather than using this simulation construct (`initial`),
	 *	the design should instead use a reset signal going to
	 *	modules in the design and to thereby set the values.
	 */
	initial begin
		s = 2'b00;
		branch_mem_sig_reg = 1'b0;
	end

	always @(negedge clk) begin
		branch_mem_sig_reg <= branch_mem_sig;
	end



`ifdef SIMULATION
	always @(posedge clk) begin
		if (branch_mem_sig_reg) begin
			total_branches <= total_branches + 1;
			if (s[1] == actual_branch_decision)
				correct_predictions <= correct_predictions + 1;
		end
	end
`endif
	/*
	 *	Using this microarchitecture, branches can't occur consecutively
	 *	therefore can use branch_mem_sig as every branch is followed by
	 *	a bubble, so a 0 to 1 transition
	 */
	always @(posedge clk) begin
		if (branch_mem_sig_reg) begin
			s[1] <= (s[1]&s[0]) | (s[0]&actual_branch_decision) | (s[1]&actual_branch_decision);
			s[0] <= (s[1]&(!s[0])) | ((!s[0])&actual_branch_decision) | (s[1]&actual_branch_decision);
		end
		
	end


    // adder / dsp swap (new)
	assign branch_addr = in_addr + offset;// potentially improve this since offset bits are less than 32 bits
    // adder_dsp u1(
    //   .input1      (in_addr),
    //   .input2      (offset),
    //   .is_sub    (1'b0),
    //   .out (branch_addr)
    // );
	assign prediction = s[1] & branch_decode_sig;
endmodule
