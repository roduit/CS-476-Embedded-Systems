// ramDmaCi module
// Author: Filippo Quadri & Vincent Roduit

module ramDmaCi #(  parameter [7:0]     customId = 8'h00)
                (   input wire          start,
                                        clock,
                                        reset,
                    input wire [31:0]   valueA,
                                        valueB,
                    input wire [7:0]    ciN,
                    output wire         done,
                    output wire [31:0]  result, 
                    
                    // Bus interfaces
                    output wire         busOut_request,
                    input wire          busIn_grants,

                    // BusIn interface 
                    input wire [31:0]   busIn_address_data,
                    input wire          busIn_end_transaction,
                    input wire          busIn_data_valid,
                    input wire          busIn_busy,
                    input wire          busIn_error,

                    // BusOut interface
                    output wire [31:0]  busOut_address_data,
                    output wire [7:0]   busOut_burst_size,
                    output wire         busOut_read_n_write,
                    output wire         butOut_begin_transaction,
                    output wire         busOut_end_transaction,
                    output wire         busOut_data_valid,
                    output wire         busOut_busy,
                    output wire         busOut_error    
                );

    /// Enumerated states
    // parameter       RW_MEMORY = 3'b000;
    parameter       RW_BUS_START_ADD = 3'b001;
    parameter       RW_MEMORY_START_ADD = 3'b010;
    parameter       RW_BLOCK_SIZE = 3'b011;
    parameter       RW_BURST_SIZE = 3'b100;
    parameter       RW_STATUS_CTRL_REG = 3'b101;
    
    /// Global control signals
    wire            s_isMyCi = (ciN == customId) ? start : 1'b0;
    wire            state = valueA[12:10];
    wire            read = valueA[9];
    
    /// SRAM control signals
    wire            enWR = (valueA[31:10] == 0 && s_isMyCi); 
    wire            writeEnableA = valueA[9] && enWR;
    wire [31:0]     resultSRAM_CPU;
    wire [31:0]     resultSRAM_DMA;
    reg             read_done = 0;

    /// DMA control signals
    reg [31:0]      bus_start_address = 0;
    reg [8:0]       memory_start_address = 0;
    reg [9:0]       block_size = 0;
    reg [7:0]       burst_size = 0;
    reg             control_register = 0;
    reg [1:0]       status_register = 0;
    reg [8:0]       memory_address = 0;
    // reg             write_enable = 0;

    /// Done and result signal
    always @(posedge clock) begin
        read_done <= enWR;
    end

    assign done     = ((writeEnableA | ~enWR) ? 1'b1 : read_done) && s_isMyCi;


    //! result needs to be a reg, not a wire
    assign result   = done ? resultSRAM_CPU : 32'b0;

    /// State transition and output logic
    always @(*) begin
        case(state)
            // RW_MEMORY: begin
            //     if (read) begin
            //         // Read from memory location A[8:0]
            //         memory_start_address = valueA[8:0];
            //         write_enable = 0;
            //     end else begin
            //         // Write to memory location A[8:0]
            //         memory_start_address = valueA[8:0];
            //         write_enable = 1;
            //     end
            // end
            RW_BUS_START_ADD: begin
                if (valueA[9] == 0) begin
                    // Read the bus start address of the DMA transfer
                    result = bus_start_address;
                end else begin
                    // Write the bus start address of the DMA transfer B[31:0]
                    bus_start_address = valueB;
                end
            end
                    
        endcase
    end
    
    
    /// SRAM module
    dualPortSSRAM #(.bitwidth(32), 
                    .nrOfEntries(512), 
                    .readAfterWrite(0))
    SSRAM (
        .clockA(clock),
        .clockB(~clock),
        .writeEnableA(writeEnableA),
        .writeEnableB(1'b0),
        .addressA(valueA[8:0]),
        .addressB(9'b0),
        .dataInA(valueB),
        .dataInB(0),
        .dataOutA(resultSRAM_CPU),
        .dataOutB(resultSRAM_DMA)
    );

    
    /// DMA module
    // Here we will implement the DMA module that will handle the bus interface

endmodule