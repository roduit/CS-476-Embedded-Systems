//* DMAController module
//* Author: Filippo Quadri & Vincent Roduit

module DMAController (
    // State signal
    input wire [2:0]    state,
    input wire [31:0]   data_valueB,
    input wire          clock,
    
    // Bus interfaces
    output reg          busOut_request,
    input wire          busIn_grants,

    // DMA control signals
    output wire [31:0]  bus_start_address_out,
    output wire [8:0]   memory_start_address_out,
    output wire [9:0]   block_size_out,
    output wire [7:0]   burst_size_out,
    output wire [1:0]   control_register_out,
    output wire [1:0]   status_register_out,

    // Bus In
    input wire [31:0]   busIn_address_data,
    input wire          busIn_end_transaction,
    input wire          busIn_data_valid,
    input wire          busIn_busy,
    input wire          busIn_error,
    
    // Bus Out
    output wire [31:0]  busOut_address_data,
    output wire [7:0]   busOut_burst_size,
    output wire         busOut_read_n_write,
    output wire         butOut_begin_transaction,
    output wire         busOut_end_transaction,
    output wire         busOut_data_valid,
    output wire         busOut_busy,
    output wire         busOut_error
);

/// Local parameters
// localparam transfer_nb = (block_size + (burst_size + 1) - 1) / (burst_size + 1);

/// Enumerated states
// parameter       RW_MEMORY = 3'b000;
parameter       RW_BUS_START_ADD = 3'b001;
parameter       RW_MEMORY_START_ADD = 3'b010;
parameter       RW_BLOCK_SIZE = 3'b011;
parameter       RW_BURST_SIZE = 3'b100;
parameter       RW_STATUS_CTRL_REG = 3'b101;

/// DMA control signals
reg [31:0]      bus_start_address = 0;
reg [8:0]       memory_start_address = 0;
reg [9:0]       block_size = 0;
reg [7:0]       burst_size = 0;
reg [1:0]       control_register = 0;
reg [1:0]       status_register = 0;

reg sync_flag;
reg [2:0] prev_state = 0;
reg [31:0] prev_data_valueB = 0;

always @(*) begin
    sync_flag <= (state != prev_state) || (data_valueB != prev_data_valueB);
end

/// Set the registers
always @(*) begin
    if (sync_flag) begin
        prev_state <= state;
        prev_data_valueB <= data_valueB;
        case (state)
            RW_BUS_START_ADD: begin
                bus_start_address <= data_valueB;
            end
            RW_MEMORY_START_ADD: begin
                $display("RW_MEMORY_START_ADD state: %0d", state);
                memory_start_address <= {23'd0, data_valueB[8:0]};
            end
            RW_BLOCK_SIZE: begin
                block_size <= {22'd0, data_valueB[9:0]};
            end
            RW_BURST_SIZE: begin
                burst_size <= {24'd0, data_valueB[7:0]};
            end
            RW_STATUS_CTRL_REG: begin
                control_register <= data_valueB[1:0];
            end
            default: begin
                $display("Default state: %0d", state);
            end
        endcase
    end
end

/// Output the control signals
assign bus_start_address_out = bus_start_address;
assign memory_start_address_out = memory_start_address;
assign block_size_out = block_size;
assign burst_size_out = burst_size;
assign control_register_out = control_register;
assign status_register_out = status_register;
    
endmodule