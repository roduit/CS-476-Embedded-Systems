// ramDmaCi module
// Author: Filippo Quadri & Vincent Roduit

// TODO: 
//       [ ] Implement the DMA module that will handle the bus interface
//       [ ] Implement the bus interface
//       [ ] Implement the test program in C

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
                                        busIn_data_valid,
                                        busIn_busy,
                                        busIn_error,

                    // BusOut interface
                    output wire [31:0]  busOut_address_data,
                    output wire [7:0]   busOut_burst_size,
                    output wire         busOut_read_n_write,
                                        butOut_begin_transaction,
                                        busOut_end_transaction,
                                        busOut_data_valid,
                                        busOut_busy,
                                        busOut_error    
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
    wire [2:0]      state = valueA[12:10];
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
    reg [1:0]       control_register = 0;
    reg [1:0]       status_register = 0;
    // reg [8:0]       memory_address = 0;
    // reg             write_enable = 0;

    //! REVIEW: this will probably introduce an extra cycle of latency, keep it or not?
    reg [31:0]      resTemp = 0;

    /// Done and result signal
    always @(posedge clock) begin
        read_done <= enWR;
    end

    //! To be modified to output the correct result
    assign done     = ((writeEnableA | ~enWR) ? 1'b1 : read_done) && s_isMyCi;
    assign result   = done ? resultSRAM_CPU : 32'b0;

    /// State transition and output logic
    always @(*) begin
        case(state)
            //! What to do when the state is RW_MEMORY? I would say anything because we have already the connection
            //! with the SRAM module
            // RW_MEMORY: begin
            //     if (read) begin
            //         //* Read from memory location A[8:0]
            //         memory_start_address = valueA[8:0];
            //         write_enable = 0;
            //     end else begin
            //         //* Write to memory location A[8:0]
            //         memory_start_address = valueA[8:0];
            //         write_enable = 1;
            //     end
            // end
            RW_BUS_START_ADD: begin
                if (valueA[9] == 0) begin
                    //* Read the bus start address of the DMA transfer
                    resTemp = bus_start_address;
                end else begin
                    //* Write the bus start address of the DMA transfer B[31:0]
                    bus_start_address = valueB;
                end
            end
            RW_MEMORY_START_ADD: begin
                if (valueA[9] == 0) begin
                    //* Read the memory start address of the DMA transfer
                    resTemp = {23'b0, memory_start_address};
                end else begin
                    //* Write the memory start address of the DMA transfer B[8:0]
                    memory_start_address = valueB[8:0];
                end
            end
            RW_BLOCK_SIZE: begin
                if (valueA[9] == 0) begin
                    //* Read block size (nb. of words) of the DMA transfer
                    resTemp = {22'b0, block_size};
                end else begin
                    //* Write block size (nb. of words) of the DMA transfer B[9:0]
                    block_size = valueB[9:0];
                end
            end
            RW_BURST_SIZE: begin
                if (valueA[9] == 0) begin
                    //* Read the burst size for the DMA transfer
                    resTemp = {24'b0, burst_size};
                end else begin
                    //* Write the burst size for the DMA transfer B[7:0]
                    burst_size = valueB[7:0];
                end
            end
            RW_STATUS_CTRL_REG: begin
                if (valueA[9] == 0) begin
                    //* Read the status register
                    resTemp = {30'b0, status_register};
                end else begin
                    //* Write the control register
                    control_register = valueB[1:0];
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

    
    /// DMA Controller module
    // Here we will implement the DMA module that will handle the bus interface

endmodule