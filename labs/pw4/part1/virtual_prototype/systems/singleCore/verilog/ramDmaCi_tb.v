`timescale 1ps/1ps // set the time-units for simulation

`define WAITHALFCYCLE #5;
`define WAITCYCLE #10;
`define WAIT2CYCLES repeat(2) @(posedge clock);

`define DISPLAY_DMA_REGISTERS \
    $display("[DMA_SETUP] bus_start_address: \t%0d", DUT.DMA.bus_start_address_out);\
    $display("            mem_start_address: \t%0d", DUT.memory_start_address);\
    $display("            block_size: \t%0d", DUT.block_size);\
    $display("            burst_size: \t%0d", DUT.burst_size);\
    $display("            control_register: \t%0b   %0b", DUT.control_register[1], DUT.control_register[0]);\
    $display("            status_register: \t%0b   %0b", DUT.status_register[1], DUT.status_register[0]);

module DMATestBench;

    /// Testbench signals
    reg         start;
    reg         clock;
    reg         reset = 0;
    reg [31:0]  valueA = 0;
    reg [31:0]  valueB = 0;
    reg [7:0]   ciN = 0;
    wire        done;
    wire [31:0] result;

    reg         busGrants = 0;
    reg [31:0]  busIn_address_data = 0;
    reg         busIn_end_transaction = 0;
    reg         busIn_data_valid = 0;
    reg         busIn_busy = 0;
    reg         busIn_error = 0;

    reg [8:0]   memory_start_address = 0;
    reg [7:0]   burst_size = 0;
    reg [9:0]   block_size = 0;

    wire [9:0]  nb_transfers = (block_size + (burst_size + 1) - 1) / (burst_size + 1);
    reg [9:0]   burst_counter = 0;

    /// Instantiate the DUT
    ramDmaCi #(.customId(8'h00)) DUT (
        .start(start), 
        .clock(clock), 
        .reset(reset), 
        .valueA(valueA), 
        .valueB(valueB),
        .ciN(ciN),
        .done(done), 
        .result(result)
    );

    /// Testbench logic

    //* Generate the clock signal
    initial begin
        clock = 1'b1;
        forever #5 clock = ~clock; 
    end

    //* Generate the stimuli
    initial begin
        $dumpfile("dma_tb.vcd");
        $dumpvars(1, DUT);
        $dumpvars(1, DUT.SSRAM);

       //* Perform some write operation from the CPU to the SSRAM
        // Eneble write operation
        valueA[9] = 1;

        repeat(5) begin
            start = 1'b1; 
            valueA = valueA + 1;
            valueB[7:0] = $random;
            `WAITCYCLE;
            start = 1'b0; 
            `WAITCYCLE;
            $display("\n[W_CPU] Write value %0d to address %0d", valueB, valueA[8:0]);
        end

        //* Wait 2 clock cycles
        `WAIT2CYCLES;
        $display("\n");

        //* Perform some read operation from the CPU to the SSRAM
        // Disable write operation
        valueA = 0;

        repeat(5) begin
            start = 1'b1; 
            valueA = valueA + 1;
            #20;
            start = 1'b0;             
            $display("[R_CPU] Read value %0d from address %0d", result, valueA[8:0]);
            `WAITCYCLE;
        end


        $finish;

    
    end

endmodule