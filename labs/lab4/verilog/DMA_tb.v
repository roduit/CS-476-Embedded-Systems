`timescale 1ps/1ps // set the time-units for simulation

`define DISPLAY_DMA_REGISTERS \
    $display("[DMA_SETUP] bus_start_address: \t%0d", DUT.bus_start_address);\
    $display("            mem_start_address: \t%0d", DUT.memory_start_address);\
    $display("            block_size: \t%0d", DUT.block_size);\
    $display("            burst_size: \t%0d", DUT.burst_size);\
    $display("            control_register: \t%0d", DUT.control_register);\
    $display("            status_register: \t%0d", DUT.status_register);\
    $display("            memory_address: \t%0d", DUT.memory_address);

module DMATestBench;

    /// Testbench signals
    reg start;
    reg clock;
    reg reset;
    reg [31:0] valueA = 0;
    reg [31:0] valueB = 0;
    reg [7:0] ciN;
    wire done;
    wire [31:0] result;

    /// Instantiate the DUT
    ramDmaCi #(.customId(8'h0B)) DUT (
        .start(start), 
        .clock(clock), 
        .reset(reset), 
        .valueA(valueA), 
        .valueB(valueB),
        .ciN(ciN),
        .done(done), 
        .result(result)
    );

    /// TestBench behavior

    //? Generate the clock signal
    initial begin
        clock = 1'b1;
        forever #5 clock = ~clock; 
    end

    initial begin
        $dumpfile("dma_tb.vcd");
        $dumpvars(1, DUT);
        $dumpvars(1, DUT.SSRAM);

        //* Set the initial values and reset the DUT
        $display("\n");
        $display("[LOG] Resetting the DUT");
        ciN = 8'h0B;
        start = 1'b0;
        reset = 1'b1;
        #10;
        reset = 1'b0;
        #10;
        $display("[LOG] DUT reset complete at %0tps", $time);

        //* Wait 2 clock cycles
        repeat(2) @(posedge clock);
        $display("\n");

        //* Perform some write operation from the CPU to the SSRAM
        // Eneble write operation
        valueA[9] = 1;

        repeat(5) begin
            start = 1'b1; 
            valueA = valueA + 1;
            valueB[7:0] = $random;
            #10;
            start = 1'b0; 
            #10;
            $display("[W_CPU] Write value %0d to address %0d", valueB, valueA[8:0]);
        end

        //* Wait 2 clock cycles
        repeat(2) @(posedge clock);
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
            #10;
        end

        //* Wait 2 clock cycles
        repeat(2) @(posedge clock);
        $display("\n");

        //* Test the DMA setup
        $display("[DMA_SETUP] Setting up the DMA controller");
        
        `DISPLAY_DMA_REGISTERS;
        
        //* End the simulation
        $display("\n");
        $finish;
    end

endmodule
