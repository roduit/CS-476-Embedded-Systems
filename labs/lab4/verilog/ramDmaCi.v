//* ramDmaCi module
//* Author: Filippo Quadri & Vincent Roduit

// TODO: 
//       [x] Implement the DMA control registers
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
                    //! Need to be flopped
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
    
    /// Global control signals
    wire            s_isMyCi = (ciN == customId) ? start : 1'b0;
    wire [2:0]      state = valueA[12:10];
    wire            read_b = valueA[9];
    
    /// SRAM control signals
    wire            enWR_CPU = (valueA[31:10] == 0 && s_isMyCi); 
    wire            writeEnableA = valueA[9] && enWR_CPU;
    wire [31:0]     resultSRAM_CPU;
    wire [31:0]     resultSRAM_DMA;
    reg             read_done = 0;

    /// DMA control signals
    wire [31:0]      bus_start_address;
    wire [8:0]       memory_start_address;
    wire [9:0]       block_size;
    wire [7:0]       burst_size;
    wire [1:0]       control_register;
    wire [1:0]       status_register;

    //! REVIEW: this will probably introduce an extra cycle of latency, keep it or not?
    reg [31:0]      resTemp = 0;

    /// Done and result signal
    always @(posedge clock) begin
        read_done <= enWR_CPU;
    end

    //! To be modified to output the correct result
    assign done     = ((writeEnableA | ~enWR_CPU) ? 1'b1 : read_done) && s_isMyCi;
    assign result   = done ? resultSRAM_CPU : 32'b0;
    
    
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
    DMAController #()
    DMA (
        .state(read_b ? state : 3'b111),
        .data_valueB(valueB),
        .clock(clock),
        .busOut_request(busOut_request),
        .busIn_grants(busIn_grants),
        .bus_start_address_out(bus_start_address),
        .memory_start_address_out(memory_start_address),
        .block_size_out(block_size),
        .burst_size_out(burst_size),
        .control_register_out(control_register),
        .status_register_out(status_register),
        .busIn_address_data(busIn_address_data),
        .busIn_end_transaction(busIn_end_transaction),
        .busIn_data_valid(busIn_data_valid),
        .busIn_busy(busIn_busy),
        .busIn_error(busIn_error),
        .busOut_address_data(busOut_address_data),
        .busOut_burst_size(busOut_burst_size),
        .busOut_read_n_write(busOut_read_n_write),
        .butOut_begin_transaction(butOut_begin_transaction),
        .busOut_end_transaction(busOut_end_transaction),
        .busOut_data_valid(busOut_data_valid),
        .busOut_busy(busOut_busy),
        .busOut_error(busOut_error)
    );

endmodule