//* DMAController module
//* Author: Filippo Quadri & Vincent Roduit

// TODO:
// [x] Update status register
// [x] Implement multiple burst
// [x] control register
// [x] implement reset
// [x] burst_size = burst_size_true - 1
// [x] new address
// [x] error
// [ ] check if idle

module DMAController (
    // reset
    input wire          reset,

    // State signal
    input wire [2:0]    state,
    input wire          write,
    input wire [31:0]   data_valueB,
    input wire          clock,

    // Memory control signals
    output reg          SRAM_write_enable,
    output reg [8:0]    SRAM_address,
    output reg [31:0]   SRAM_data,

    
    // Bus interfaces
    output wire         busOut_request,
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
    output wire         busOut_error,

    // Result
    output reg [31:0]  result
);

/// Local parameters
// localparam transfer_nb = (block_size + (burst_size + 1) - 1) / (burst_size + 1);

//* Enumerated states for the control signals
// parameter       RW_MEMORY = 3'b000;
localparam      RW_BUS_START_ADD = 3'b001;
localparam      RW_MEMORY_START_ADD = 3'b010;
localparam      RW_BLOCK_SIZE = 3'b011;
localparam      RW_BURST_SIZE = 3'b100;
localparam      RW_STATUS_CTRL_REG = 3'b101;

//* Enumerated states for the txn states
localparam      IDLE = 3'b000;
localparam      REQUEST_BUS = 3'b001;
localparam      INIT_BURST = 3'b010;
localparam      DO_BURST_READ = 3'b011;
localparam      END_TRANSACTION = 3'b100;
localparam      ERROR = 3'b101;

reg [2:0]       current_trans_state, next_trans_state = IDLE;

/// DMA control signals
reg [31:0]      bus_start_address = 0;
reg [8:0]       memory_start_address = 0;
reg [9:0]       block_size = 0;
reg [7:0]       burst_size = 0;
reg [1:0]       control_register = 0;
reg [1:0]       status_register = 0;

reg [9:0]       transfer_nb = 0;
reg [9:0]       burst_counter = 0;

// /// Sync flag
//! Check behavior if the signal is changed on the negedge
// reg sync_flag;
// reg prev_write = 0;
// reg [2:0] prev_state = 0;
// reg [31:0] prev_data_valueB = 0;

// always @(*) begin
//     sync_flag <= (state != prev_state) || (data_valueB != prev_data_valueB) || (write != prev_write);
// end

/// Set the registers
always @(*) begin
    // if (sync_flag) begin
    //     prev_state <= state;
    //     prev_data_valueB <= data_valueB;
    if (reset) begin
        bus_start_address <= 0;
        memory_start_address <= 0;
        block_size <= 0;
        burst_size <= 0;
        result <= 0;
    end 
    else begin
        case (state)
            RW_BUS_START_ADD: begin
                if (write) bus_start_address <= data_valueB;
                else result <= bus_start_address;
            end
            RW_MEMORY_START_ADD: begin
                if (write) memory_start_address <= {23'd0, data_valueB[8:0]};
                else result <= memory_start_address;
            end
            RW_BLOCK_SIZE: begin
                if (write) block_size <= {22'd0, data_valueB[9:0]};
                else result <= block_size;
            end
            RW_BURST_SIZE: begin
                if (write) begin
                    burst_size <= {24'd0, data_valueB[7:0]};
                    transfer_nb <= (block_size + (burst_size + 1) - 1) / (burst_size + 1);
                    burst_counter <= 0;
                end
                else result <= burst_size;
            end
            RW_STATUS_CTRL_REG: begin
                if (write) control_register <= data_valueB[1:0];
                else result <= status_register;
            end
            default: begin
                // $display("Default state: %0d", state);
            end
        endcase
    end
end


/// Burst transaction state machine
always @(*) begin
    if (busIn_error) next_trans_state = ERROR;
    else
    case (current_trans_state)
        IDLE            : next_trans_state <=   (control_register[0] == 1'b1 && burst_counter != transfer_nb) ? REQUEST_BUS : IDLE;
        REQUEST_BUS     : next_trans_state <=   (busIn_grants == 1'b1) ? INIT_BURST : REQUEST_BUS;
        INIT_BURST      : next_trans_state <=   DO_BURST_READ;
        DO_BURST_READ   : next_trans_state <=   (busIn_end_transaction == 1) ? END_TRANSACTION : DO_BURST_READ;
        END_TRANSACTION : next_trans_state <=   (burst_counter == transfer_nb) ?  IDLE : INIT_BURST;
        ERROR           : next_trans_state <=   IDLE;
        default         : next_trans_state <=   IDLE;
    endcase
end


always @(posedge clock) begin
    
    /// Update the state
    current_trans_state = reset ? IDLE : next_trans_state;
    
    if (current_trans_state == ERROR) begin
        control_register[0] <= 1'b0;
        status_register <= 2'b10;
        burst_counter <= 0;
        SRAM_write_enable <= 0;
    end else begin

        /// Update the status register and reset control register
        status_register[0]  <=  reset ? 1'b0 :  (current_trans_state == END_TRANSACTION && burst_counter == transfer_nb) ? 1'b0 : 
                                                (current_trans_state == REQUEST_BUS) ? 1: status_register[0];
        control_register[0] <=  reset ? 1'b0 :  (current_trans_state == END_TRANSACTION && burst_counter == transfer_nb) ? 1'b0 : control_register[0];

        burst_counter       <=  reset ? 0 :  (current_trans_state == INIT_BURST) ? burst_counter + 1 : (next_trans_state == IDLE) ? 0 : burst_counter;


        /// Update the SRAM control signals
        SRAM_data           <=  reset ? 0 :  busIn_address_data;
        SRAM_address        <=  reset ? 0 :  (burst_counter == 1 && butOut_begin_transaction) ? memory_start_address : 
                                             (current_trans_state == DO_BURST_READ && busIn_data_valid) ? SRAM_address + 1 : SRAM_address;
        SRAM_write_enable   <=  reset ? 0 :  (next_trans_state == DO_BURST_READ && busIn_data_valid == 1'b1) ? 1'b1 : 1'b0;

        /// Update the bus start address
        bus_start_address   <=  reset ? 0 :  (current_trans_state == DO_BURST_READ && busIn_data_valid == 1'b1) ? 
                                             bus_start_address + 1 : bus_start_address;
    end

end
    

/// Bus interface
assign busOut_request = (current_trans_state == REQUEST_BUS) ? 1'b1 : 1'b0;
assign busOut_address_data = (current_trans_state == INIT_BURST) ? bus_start_address : 32'd0;
assign busOut_burst_size = (current_trans_state == INIT_BURST) ? burst_size : 8'd0;
assign busOut_read_n_write = (current_trans_state == INIT_BURST) ? 1'b1 : 1'b0;
assign butOut_begin_transaction = (current_trans_state == INIT_BURST) ? 1'b1 : 1'b0;

assign busOut_data_valid = 0;
assign busOut_busy = 0;
assign busOut_end_transaction = (current_trans_state == ERROR) ? 1'b1 : 1'b0;
assign busOut_error = 0;

/// Output the control signals
assign bus_start_address_out = bus_start_address;
assign memory_start_address_out = memory_start_address;
assign block_size_out = block_size;
assign burst_size_out = burst_size;
assign control_register_out = control_register;
assign status_register_out = status_register;
    
endmodule