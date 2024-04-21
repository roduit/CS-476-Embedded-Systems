`timescale 1ps/1ps // set the time-units for simulation

`define WAIT2CYCLES repeat(1) @(posedge clock);

`define DISPLAY_DMA_REGISTERS \
    $display("[DMA_SETUP] bus_start_address: \t%0d", DUT.DMA.bus_start_address_out);\
    $display("            mem_start_address: \t%0d", DUT.memory_start_address);\
    $display("            block_size: \t%0d", DUT.block_size);\
    $display("            burst_size: \t%0d", DUT.burst_size);\
    $display("            control_register: \t%0b   %0b", DUT.control_register[1], DUT.control_register[0]);\
    $display("            status_register: \t%0b   %0b", DUT.status_register[1], DUT.status_register[0]);

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

    /// Testbench functions

    //* Set the bus start address
    task set_bus_start_address;
        input [31:0] new_address;
        begin
            valueA = {19'b0, 3'b001, 1'b1, 9'b0};
            valueB = new_address;
            $display("[BUS_START] Setting bus_start_address to %0d", new_address);
        end
    endtask

    //* Read the bus start address
    task read_bus_start_address;
        begin
            valueA = {19'b0, 3'b001, 1'b0, 9'b0};
            @(posedge clock);
            $display("[BUS_START] Reading bus_start_address via resTemp = %0d", DUT.resTemp);
        end
    endtask

    //* Set the memory start address
    task set_memory_start_address;
        input [8:0] new_address;
        begin
            valueA = {19'b0, 3'b010, 1'b1, 9'b0};
            valueB = new_address;
            $display("[MEMORY_START] Setting memory_start_address to %0d", new_address);
        end
    endtask

    //* Read the memory start address
    task read_memory_start_address;
        begin
            valueA = {19'b0, 3'b010, 1'b0, 9'b0};
            @(posedge clock);
            $display("[MEMORY_START] Reading memory_start_address via resTemp = %0d", DUT.resTemp);
        end
    endtask

    //* Set the block size
    task set_block_size;
        input [9:0] new_block_size;
        begin
            valueA = {19'b0, 3'b011, 1'b1, 9'b0};
            valueB = new_block_size;
            $display("[BLOCK_SIZE] Setting block_size to %0d", new_block_size);
        end
    endtask

    //* Read the block size
    task read_block_size;
        begin
            valueA = {19'b0, 3'b011, 1'b0, 9'b0};
            @(posedge clock);
            $display("[BLOCK_SIZE] Reading block_size via resTemp = %0d", DUT.resTemp);
        end
    endtask

    //* Set the burst size
    task set_burst_size;
        input [7:0] new_burst_size;
        begin
            valueA = {19'b0, 3'b100, 1'b1, 9'b0};
            valueB = new_burst_size;
            $display("[BURST_SIZE] Setting burst_size to %0d", new_burst_size);
        end
    endtask

    //* Read the burst size
    task read_burst_size;
        begin
            valueA = {19'b0, 3'b100, 1'b0, 9'b0};
            @(posedge clock);
            $display("[BURST_SIZE] Reading burst_size via resTemp = %0d", DUT.resTemp);
        end
    endtask

    //* Set the control register
    task set_control_register;
        input [1:0] new_control_register;
        begin
            valueA = {19'b0, 3'b101, 1'b1, 9'b0};
            valueB = new_control_register;
            $display("[CTRL_REG] Setting control_register to [%0b %0b]", new_control_register[1], new_control_register[0]);
        end
    endtask

    //* Read the control register
    task read_status_register;
        begin
            valueA = {19'b0, 3'b101, 1'b0, 9'b0};
            @(posedge clock);
            $display("[STAT_REG] Reading status_register via resTemp = [%0b %0b]", DUT.resTemp[1], DUT.resTemp[0]);
        end
    endtask


    
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
        $dumpvars(1, DUT.DMA);

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
        `WAIT2CYCLES;
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
            #10;
        end

        //* Wait 2 clock cycles
        `WAIT2CYCLES;
        $display("\n");

        //* Test the DMA setup
        $display("[DMA_SETUP] Setting up the DMA controller\n");
        
        set_bus_start_address(32'd5);
        `WAIT2CYCLES;
        read_bus_start_address();
        `WAIT2CYCLES;

        $display("\n");
        
        set_bus_start_address(32'd6);
        `WAIT2CYCLES;
        read_bus_start_address();
        `WAIT2CYCLES;

        $display("\n");

        set_memory_start_address(9'd220);
        `WAIT2CYCLES;
        read_memory_start_address();
        `WAIT2CYCLES;   

        $display("\n");

        set_block_size(10'd100);
        `WAIT2CYCLES;
        read_block_size();
        `WAIT2CYCLES;

        $display("\n");

        set_burst_size(8'd10);
        `WAIT2CYCLES;
        read_burst_size();
        `WAIT2CYCLES;

        $display("\n");

        set_control_register(2'b11);
        `WAIT2CYCLES;
        read_status_register();
        `WAIT2CYCLES;

        $display("\n");

        `DISPLAY_DMA_REGISTERS;

        $display("\n");

        $display("[DMA_ERROR] Test an error case. Normally the DMA controller should not respond to this operation");
        $display("            Setting valueA[12:10] = 3'b111 and valueA[9] = 1'b1 and valueB = 32'd17n");
        valueA = 0;
        valueA[12:10] = 3'b111;
        valueA[9] = 1;
        valueB = 32'd17;
        
        `WAIT2CYCLES;
        $display("\n");
        
        `DISPLAY_DMA_REGISTERS;
        
        //* End the simulation
        $display("\n");
        $finish;
    end

endmodule
