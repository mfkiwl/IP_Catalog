/*

Copyright (c) 2019 Alex Forencich

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

*/

// Language: Verilog 2001

`resetall
`timescale 1ns / 1ps
`default_nettype none

/*
 * AXI4-Stream broadcaster
 */
module axis_broadcast #
(
    parameter IP_TYPE 		= "ASBR",
	parameter IP_VERSION 	= 32'h1, 
	parameter IP_ID 		= 32'h2691033,
    
    // Number of AXI stream outputs
    parameter M_COUNT = 4,
    // Width of AXI stream interfaces in bits
    parameter DATA_WIDTH = 8,
    // Propagate tkeep signal
    parameter KEEP_ENABLE = (DATA_WIDTH>8),
    // tkeep signal width (words per cycle)
    parameter KEEP_WIDTH = ((DATA_WIDTH+7)/8),
    // Propagate tlast signal
    parameter LAST_ENABLE = 1,
    // Propagate tid signal
    parameter ID_ENABLE = 0,
    // tid signal width
    parameter ID_WIDTH = 8,
    // Propagate tdest signal
    parameter DEST_ENABLE = 0,
    // tdest signal width
    parameter DEST_WIDTH = 8,
    // Propagate tuser signal
    parameter USER_ENABLE = 1,
    // tuser signal width
    parameter USER_WIDTH = 1
)
(
    input  wire                          clk,
    input  wire                          rst,

    /*
     * AXI input
     */
    input  wire [DATA_WIDTH-1:0]         s_axis_tdata,
    input  wire [KEEP_WIDTH-1:0]         s_axis_tkeep,
    input  wire                          s_axis_tvalid,
    output wire                          s_axis_tready,
    input  wire                          s_axis_tlast,
    input  wire [ID_WIDTH-1:0]           s_axis_tid,
    input  wire [DEST_WIDTH-1:0]         s_axis_tdest,
    input  wire [USER_WIDTH-1:0]         s_axis_tuser,

    /*
     * AXI outputs
     */
    output wire [M_COUNT*DATA_WIDTH-1:0] m_axis_tdata,
    output wire [M_COUNT*KEEP_WIDTH-1:0] m_axis_tkeep,
    output wire [M_COUNT-1:0]            m_axis_tvalid,
    input  wire [M_COUNT-1:0]            m_axis_tready,
    output wire [M_COUNT-1:0]            m_axis_tlast,
    output wire [M_COUNT*ID_WIDTH-1:0]   m_axis_tid,
    output wire [M_COUNT*DEST_WIDTH-1:0] m_axis_tdest,
    output wire [M_COUNT*USER_WIDTH-1:0] m_axis_tuser
);

parameter CL_M_COUNT = $clog2(M_COUNT);

// datapath registers
reg s_axis_tready_reg = 1'b0, s_axis_tready_next;

reg [DATA_WIDTH-1:0] m_axis_tdata_reg  = {DATA_WIDTH{1'b0}};
reg [KEEP_WIDTH-1:0] m_axis_tkeep_reg  = {KEEP_WIDTH{1'b0}};
reg [M_COUNT-1:0]    m_axis_tvalid_reg = {M_COUNT{1'b0}}, m_axis_tvalid_next;
reg                  m_axis_tlast_reg  = 1'b0;
reg [ID_WIDTH-1:0]   m_axis_tid_reg    = {ID_WIDTH{1'b0}};
reg [DEST_WIDTH-1:0] m_axis_tdest_reg  = {DEST_WIDTH{1'b0}};
reg [USER_WIDTH-1:0] m_axis_tuser_reg  = {USER_WIDTH{1'b0}};

reg [DATA_WIDTH-1:0] temp_m_axis_tdata_reg  = {DATA_WIDTH{1'b0}};
reg [KEEP_WIDTH-1:0] temp_m_axis_tkeep_reg  = {KEEP_WIDTH{1'b0}};
reg                  temp_m_axis_tvalid_reg = 1'b0, temp_m_axis_tvalid_next;
reg                  temp_m_axis_tlast_reg  = 1'b0;
reg [ID_WIDTH-1:0]   temp_m_axis_tid_reg    = {ID_WIDTH{1'b0}};
reg [DEST_WIDTH-1:0] temp_m_axis_tdest_reg  = {DEST_WIDTH{1'b0}};
reg [USER_WIDTH-1:0] temp_m_axis_tuser_reg  = {USER_WIDTH{1'b0}};

// // datapath control
reg store_axis_input_to_output;
reg store_axis_input_to_temp;
reg store_axis_temp_to_output;

assign s_axis_tready = s_axis_tready_reg;

assign m_axis_tdata  = {M_COUNT{m_axis_tdata_reg}};
assign m_axis_tkeep  = KEEP_ENABLE ? {M_COUNT{m_axis_tkeep_reg}} : {M_COUNT*KEEP_WIDTH{1'b1}};
assign m_axis_tvalid = m_axis_tvalid_reg;
assign m_axis_tlast  = LAST_ENABLE ? {M_COUNT{m_axis_tlast_reg}} : {M_COUNT{1'b1}};
assign m_axis_tid    = ID_ENABLE   ? {M_COUNT{m_axis_tid_reg}}   : {M_COUNT*ID_WIDTH{1'b0}};
assign m_axis_tdest  = DEST_ENABLE ? {M_COUNT{m_axis_tdest_reg}} : {M_COUNT*DEST_WIDTH{1'b0}};
assign m_axis_tuser  = USER_ENABLE ? {M_COUNT{m_axis_tuser_reg}} : {M_COUNT*USER_WIDTH{1'b0}};

// enable ready input next cycle if output is ready or if both output registers are empty
wire s_axis_tready_early = ((m_axis_tready & m_axis_tvalid) == m_axis_tvalid) || (!temp_m_axis_tvalid_reg && !m_axis_tvalid_reg);

always @* begin
    // transfer sink ready state to source
    m_axis_tvalid_next = m_axis_tvalid_reg & ~m_axis_tready;
    temp_m_axis_tvalid_next = temp_m_axis_tvalid_reg;

    store_axis_input_to_output = 1'b0;
    store_axis_input_to_temp = 1'b0;
    store_axis_temp_to_output = 1'b0;

    if (s_axis_tready_reg) begin
        // input is ready
        if (((m_axis_tready & m_axis_tvalid) == m_axis_tvalid) || !m_axis_tvalid) begin
            // output is ready or currently not valid, transfer data to output
            m_axis_tvalid_next = {M_COUNT{s_axis_tvalid}};
            store_axis_input_to_output = 1'b1;
        end else begin
            // output is not ready, store input in temp
            temp_m_axis_tvalid_next = s_axis_tvalid;
            store_axis_input_to_temp = 1'b1;
        end
    end else if ((m_axis_tready & m_axis_tvalid) == m_axis_tvalid) begin
        // input is not ready, but output is ready
        m_axis_tvalid_next = {M_COUNT{temp_m_axis_tvalid_reg}};
        temp_m_axis_tvalid_next = 1'b0;
        store_axis_temp_to_output = 1'b1;
    end
end

always @(posedge clk) begin
    s_axis_tready_reg <= s_axis_tready_early;
    m_axis_tvalid_reg <= m_axis_tvalid_next;
    temp_m_axis_tvalid_reg <= temp_m_axis_tvalid_next;

    // datapath
    if (store_axis_input_to_output) begin
        m_axis_tdata_reg <= s_axis_tdata;
        m_axis_tkeep_reg <= s_axis_tkeep;
        m_axis_tlast_reg <= s_axis_tlast;
        m_axis_tid_reg   <= s_axis_tid;
        m_axis_tdest_reg <= s_axis_tdest;
        m_axis_tuser_reg <= s_axis_tuser;
    end else if (store_axis_temp_to_output) begin
        m_axis_tdata_reg <= temp_m_axis_tdata_reg;
        m_axis_tkeep_reg <= temp_m_axis_tkeep_reg;
        m_axis_tlast_reg <= temp_m_axis_tlast_reg;
        m_axis_tid_reg   <= temp_m_axis_tid_reg;
        m_axis_tdest_reg <= temp_m_axis_tdest_reg;
        m_axis_tuser_reg <= temp_m_axis_tuser_reg;
    end

    if (store_axis_input_to_temp) begin
        temp_m_axis_tdata_reg <= s_axis_tdata;
        temp_m_axis_tkeep_reg <= s_axis_tkeep;
        temp_m_axis_tlast_reg <= s_axis_tlast;
        temp_m_axis_tid_reg   <= s_axis_tid;
        temp_m_axis_tdest_reg <= s_axis_tdest;
        temp_m_axis_tuser_reg <= s_axis_tuser;
    end

    if (rst) begin
        s_axis_tready_reg <= 1'b0;
        m_axis_tvalid_reg <= {M_COUNT{1'b0}};
        temp_m_axis_tvalid_reg <= {M_COUNT{1'b0}};
    end
end

endmodule

`resetall
