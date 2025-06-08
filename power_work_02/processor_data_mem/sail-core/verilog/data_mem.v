// data_mem.v
// Drop-in data memory module that preloads “data.hex” into two 16K×16 SPRAMs,
// forming a 1K×32 data RAM.  While preloading, clk_stall=1 holds the CPU pipeline.
// After preload, normal read/write FSM kicks in.  Port list matches the original:
//
//    clk, addr, write_data, memwrite, memread, sign_mask, read_data, led, clk_stall
//
// No modifications to cpu.v or toplevel.v are required.

`timescale 1ns / 1ps

module data_mem (
    input           clk,            // system clock (from HFOSC)
    input  [31:0]   addr,           // byte address
    input  [31:0]   write_data,     // data to write
    input           memwrite,       // write enable
    input           memread,        // read enable
    input  [3:0]    sign_mask,      // byte/halfword/word mask
    output reg [31:0] read_data,    // loaded data out
    output [7:0]    led,            // user LED register (mapped at 0x2000)
    output reg      clk_stall       // high while SPRAM preloads or FSM stalls
);

    //========================================================================
    // 1) Parameters and FSM States (we need at least 3 bits to represent 0..5)
    //========================================================================
    localparam IDLE        = 3'b000;
    localparam READ_BUFFER = 3'b001;
    localparam READ        = 3'b010;
    localparam WRITE       = 3'b011;
    localparam PRELOAD0    = 3'b100;  // Present one init word to SPRAM
    localparam PRELOAD1    = 3'b101;  // Increment preload counter, then loop

    reg [2:0] state = PRELOAD0;

    //========================================================================
    // 2) init_rom: small “ROM” to hold preload data from data.hex
    //    ($readmemh only works on a Verilog array, not the SPRAM primitive)
    //========================================================================
    reg [31:0] init_rom [0:1023];
    initial begin
        $readmemh("data.hex", init_rom);
    end

    //========================================================================
    // 3) Preload address counter (0..1023).  Each cycle we write init_rom[i] into SPRAM
    //========================================================================
    reg [9:0] preload_addr = 10'b0000000000;

    //========================================================================
    // 4) LED register (unchanged)
    //========================================================================
    reg [31:0] led_reg = 32'b0;
    assign led = led_reg[7:0];

    //========================================================================
    // 5) Internal buffers & signals mirroring original data_mem logic
    //========================================================================
    reg [31:0] word_buf;            // holds a 32-bit word read from SPRAM
    reg        memread_buf;
    reg        memwrite_buf;
    reg [31:0] write_data_buffer;
    reg [31:0] addr_buf;
    reg [3:0]  sign_mask_buf;

    // Byte-address → block_index = addr_buf[11:2], byte_offset = addr_buf[1:0]
    wire [9:0] addr_buf_block_addr = addr_buf[11:2];
    wire [1:0] addr_buf_byte_offset = addr_buf[1:0];

    //========================================================================
    //  6) Byte-select decode (unchanged)
    //========================================================================
    wire bdec_sig0 = (~addr_buf_byte_offset[1]) & (~addr_buf_byte_offset[0]);
    wire bdec_sig1 = (~addr_buf_byte_offset[1]) & ( addr_buf_byte_offset[0]);
    wire bdec_sig2 = ( addr_buf_byte_offset[1]) & (~addr_buf_byte_offset[0]);
    wire bdec_sig3 = ( addr_buf_byte_offset[1]) & ( addr_buf_byte_offset[0]);

    //========================================================================
    //  7) Byte replacement (unchanged)
    //========================================================================
    wire [7:0] buf0 = word_buf[ 7: 0];
    wire [7:0] buf1 = word_buf[15: 8];
    wire [7:0] buf2 = word_buf[23:16];
    wire [7:0] buf3 = word_buf[31:24];

    wire [7:0] byte_r0 = (bdec_sig0) ? write_data_buffer[7:0] : buf0;
    wire [7:0] byte_r1 = (bdec_sig1) ? write_data_buffer[7:0] : buf1;
    wire [7:0] byte_r2 = (bdec_sig2) ? write_data_buffer[7:0] : buf2;
    wire [7:0] byte_r3 = (bdec_sig3) ? write_data_buffer[7:0] : buf3;

    //========================================================================
    //  8) Halfword replacement (unchanged)
    //========================================================================
    wire [15:0] halfword_r0 = (addr_buf_byte_offset[1])
                             ? { buf1, buf0 }
                             : write_data_buffer[15:0];
    wire [15:0] halfword_r1 = (addr_buf_byte_offset[1])
                             ? write_data_buffer[15:0]
                             : { buf3, buf2 };

    //========================================================================
    //  9) Write-select logic (unchanged)
    //     sign_mask_buf[2]=full-word, [1]=halfword, [0]=byte
    //========================================================================
    wire write_select0 = (~sign_mask_buf[2]) &  sign_mask_buf[1]; // halfword
    wire write_select1 =  sign_mask_buf[2];                       // full-word

    wire [31:0] write_out1 = (write_select0)
                             ? { halfword_r1, halfword_r0 }
                             : { byte_r3, byte_r2, byte_r1, byte_r0 };
    wire [31:0] write_out2 = (write_select0) ? 32'b0 : write_data_buffer;

    wire [31:0] replacement_word = (write_select1)
                                   ? write_out2
                                   : write_out1;

    //========================================================================
    // 10) Read-assemble logic (unchanged)
    //     select0, select1, select2 determine sign/zero‐extend
    //========================================================================
    wire select0 = ( (~sign_mask_buf[2] & ~sign_mask_buf[1] & ~addr_buf_byte_offset[1] &  addr_buf_byte_offset[0])
                   | (~sign_mask_buf[2] &  addr_buf_byte_offset[1] &  addr_buf_byte_offset[0])
                   | (~sign_mask_buf[2] &  sign_mask_buf[1] &  addr_buf_byte_offset[1]) );
    wire select1 = ( (~sign_mask_buf[2] & ~sign_mask_buf[1] &  addr_buf_byte_offset[1])
                   | ( sign_mask_buf[2] &  sign_mask_buf[1]) );
    wire select2 = sign_mask_buf[1];

    wire [31:0] out1 = (select0)
                       ? ((sign_mask_buf[3])
                          ? {{24{buf1[7]}}, buf1}
                          : {24'b0, buf1})
                       : ((sign_mask_buf[3])
                          ? {{24{buf0[7]}}, buf0}
                          : {24'b0, buf0});
    wire [31:0] out2 = (select0)
                       ? ((sign_mask_buf[3])
                          ? {{24{buf3[7]}}, buf3}
                          : {24'b0, buf3})
                       : ((sign_mask_buf[3])
                          ? {{24{buf2[7]}}, buf2}
                          : {24'b0, buf2});
    wire [31:0] out3 = (select0)
                       ? ((sign_mask_buf[3])
                          ? {{16{buf3[7]}}, buf3, buf2}
                          : {16'b0, buf3, buf2})
                       : ((sign_mask_buf[3])
                          ? {{16{buf1[7]}}, buf1, buf0}
                          : {16'b0, buf1, buf0});
    wire [31:0] out4 = (select0) ? 32'b0 : { buf3, buf2, buf1, buf0 };

    wire [31:0] out5 = (select1) ? out2 : out1;
    wire [31:0] out6 = (select1) ? out4 : out3;

    wire [31:0] read_buf = (select2) ? out6 : out5;

    //========================================================================
    // 11) SPRAM Instantiations (SB_SPRAM256KA):
    //     – Two 16K×16 blocks → 1K×32 memory.  Index = addr[11:2]
    //========================================================================
    wire spram_we   = (state == WRITE);
    wire spram_cs   = 1'b1;     
    wire spram_clk  = clk;
    wire [15:0] spram_write_lower = replacement_word[15:0];
    wire [15:0] spram_write_upper = replacement_word[31:16];

    // Lower 16 bits
    wire [15:0] spram_read_lower;
    SB_SPRAM256KA spram_lo (
        .ADDRESS       ( addr_buf_block_addr ),  // 10-bit address
        .DATAIN        ( spram_write_lower ),    
        .WREN          ( spram_we ),
        .MASKWREN      ( 4'b0000 ),
        .CHIPSELECT    ( spram_cs ),
        .CLOCK         ( spram_clk ),
        .DATAOUT       ( spram_read_lower ),
        .STANDBY       ( 1'b0 ),
        .SLEEP         ( 1'b0 ),
        .POWEROFF      ( 1'b1 )
    );

    // Upper 16 bits
    wire [15:0] spram_read_upper;
    SB_SPRAM256KA spram_hi (
        .ADDRESS       ( addr_buf_block_addr ),
        .DATAIN        ( spram_write_upper ),
        .WREN          ( spram_we ),
        .MASKWREN      ( 4'b0000 ),
        .CHIPSELECT    ( spram_cs ),
        .CLOCK         ( spram_clk ),
        .DATAOUT       ( spram_read_upper ),
        .STANDBY       ( 1'b0 ),
        .SLEEP         ( 1'b0 ),
        .POWEROFF      ( 1'b1 )
    );

    // Combine into 32 bits
    wire [31:0] spram_combined_out = { spram_read_upper, spram_read_lower };

    //========================================================================
    // 12) Main FSM: PRELOAD0→PRELOAD1→IDLE→READ_BUFFER→(READ or WRITE)
    //========================================================================
    always @(posedge clk) begin
        case (state)
            PRELOAD0: begin
                clk_stall        <= 1'b1;
                addr_buf         <= { preload_addr, 2'b00 };     // byte‐address ← word<<2
                write_data_buffer<= init_rom[preload_addr];      // 32‐bit init data
                memwrite_buf     <= 1'b1;
                memread_buf      <= 1'b0;
                sign_mask_buf    <= 4'b1000;                     // full‐word write
                state            <= PRELOAD1;
            end

            PRELOAD1: begin
                preload_addr <= preload_addr + 10'b0000000001;
                if (preload_addr == 10'b1111111111) begin
                    state     <= IDLE;
                    clk_stall <= 1'b0;
                end else begin
                    state <= PRELOAD0;
                end
            end

            IDLE: begin
                clk_stall        <= 1'b0;
                memread_buf      <= memread;
                memwrite_buf     <= memwrite;
                write_data_buffer<= write_data;
                addr_buf         <= addr;
                sign_mask_buf    <= sign_mask;
                if (memread || memwrite) begin
                    state     <= READ_BUFFER;
                    clk_stall <= 1'b1;
                end else begin
                    state <= IDLE;
                end
            end

            READ_BUFFER: begin
                word_buf <= spram_combined_out;
                if (memread_buf) begin
                    state <= READ;
                end else begin
                    state <= WRITE;
                end
            end

            READ: begin
                clk_stall <= 1'b0;
                read_data <= read_buf;
                state     <= IDLE;
            end

            WRITE: begin
                clk_stall <= 1'b0;
                // SPRAM writes happen automatically via spram_we=1 
                state <= IDLE;
            end

            default: begin
                state     <= IDLE;
                clk_stall <= 1'b0;
            end
        endcase
    end

endmodule
