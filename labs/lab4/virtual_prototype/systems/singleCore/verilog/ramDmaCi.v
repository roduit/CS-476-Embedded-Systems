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
    wire [2:0]      state = s_isMyCi ? valueA[12:10] : 3'b111;
    wire            write = s_isMyCi ? valueA[9] : 0;
    
    /// SRAM control signals
    wire            correctState = ((valueA[12] == 0 && valueA[10] == 1) || (valueA[12] == 0 && valueA[11] == 1) || (valueA[12] == 1 && valueA[11] == 0)) ? 1'b1 : 1'b0;
    wire            enWR_DMA = (correctState && s_isMyCi && valueA[31:13] == 0) ? 1'b1 : 1'b0;
    wire            enWR_CPU = valueA[31:10] == 0 && s_isMyCi;
    wire            writeEnableA = valueA[9] && enWR_CPU;
    wire [31:0]     resultSRAM_CPU;
    wire [31:0]     resultSRAM_DMA;
    wire [31:0]     resultController;
    reg             read_done = 0;

    /// DMA control signals
    wire [31:0]      bus_start_address;
    wire [8:0]       memory_start_address;
    wire [9:0]       block_size;
    wire [7:0]       burst_size;
    wire [1:0]       control_register;
    wire [1:0]       status_register;

    /// DMA memory signals
    wire [31:0]     DMA_memory_data;
    wire [8:0]      DMA_memory_address;
    wire            DMA_memory_write_enable;
    reg [8:0]       DMA_memory_address_reg = 0;

    /// Bus Registers
    reg             busIn_grants_reg = 0;
    reg [31:0]      busIn_address_data_reg = 0;
    reg             busIn_end_transaction_reg = 0;
    reg             busIn_data_valid_reg = 0;
                    //busIn_busy_reg,
    reg             busIn_error_reg = 0;



    /// Done and result signal
    always @(posedge clock) begin
        read_done <= reset ? 0: enWR_CPU || enWR_DMA;
        busIn_grants_reg <= reset ? 0: busIn_grants;
        busIn_address_data_reg <= reset ? 0: busIn_address_data;
        busIn_end_transaction_reg <= reset ? 0 : busIn_end_transaction;
        busIn_data_valid_reg <= reset ? 0 : busIn_data_valid;
        //busIn_busy_reg <= reset ? 0 : busIn_busy;
        busIn_error_reg <= reset ? 0 : busIn_error;
        //DMA_memory_address_reg <= reset ? 0 : DMA_memory_address; 
    end

    assign done     = reset ? 0 : (write ? 1'b1 : read_done) && s_isMyCi;
    assign result   = reset ? 0 : done ? (enWR_CPU ? resultSRAM_CPU : (enWR_DMA ? resultController : 32'b0)) : 32'b0;
    
    
    /// SRAM module
    dualPortSSRAM #(.bitwidth(32), 
                    .nrOfEntries(512))
    SSRAM (
        .clockA(clock),
        .clockB(~clock),
        .writeEnableA(writeEnableA),
        .writeEnableB(DMA_memory_write_enable),
        .addressA(valueA[8:0]),
        .addressB(DMA_memory_address),
        .dataInA(valueB),
        .dataInB(DMA_memory_data),
        .dataOutA(resultSRAM_CPU),
        .dataOutB(resultSRAM_DMA)
    );

    /// DMA Controller module
    DMAController DMA (
        .reset(reset),
        .state(state),
        .write(write),
        .data_valueB(valueB),
        .clock(clock),
        .SRAM_write_enable(DMA_memory_write_enable),
        .SRAM_address(DMA_memory_address),
        .SRAM_data(DMA_memory_data),
        .SRAM_result(resultSRAM_DMA),
        .busOut_request(busOut_request),
        .busIn_grants(busIn_grants_reg),
        .bus_start_address_out(bus_start_address),
        .memory_start_address_out(memory_start_address),
        .block_size_out(block_size),
        .burst_size_out(burst_size),
        .control_register_out(control_register),
        .status_register_out(status_register),
        .busIn_address_data(busIn_address_data_reg),
        .busIn_end_transaction(busIn_end_transaction_reg),
        .busIn_data_valid(busIn_data_valid_reg),
        .busIn_busy(busIn_busy),
        .busIn_error(busIn_error),
        .busOut_address_data(busOut_address_data),
        .busOut_burst_size(busOut_burst_size),
        .busOut_read_n_write(busOut_read_n_write),
        .busOut_begin_transaction(butOut_begin_transaction),
        .busOut_end_transaction(busOut_end_transaction),
        .busOut_data_valid(busOut_data_valid),
        .busOut_busy(busOut_busy),
        .busOut_error(busOut_error),
        .result(resultController)
    );

endmodule


// Busy and error not registers!!!!!
// Check end transaction