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
    reg         reset;
    reg [31:0]  valueA = 0;
    reg [31:0]  valueB = 0;
    reg [7:0]   ciN;
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
    ramDmaCi #(.customId(8'h0B)) DUT (
        .start(start), 
        .clock(clock), 
        .reset(reset), 
        .valueA(valueA), 
        .valueB(valueB),
        .ciN(ciN),
        .done(done), 
        .result(result),
        .busIn_grants(busGrants),
        .busIn_address_data(busIn_address_data),
        .busIn_end_transaction(busIn_end_transaction),
        .busIn_data_valid(busIn_data_valid),
        .busIn_busy(busIn_busy),
        .busIn_error(busIn_error)
    );

        /// Testbench functions

    //* Set the bus start address
    task set_bus_start_address;
        input [31:0] new_address;
        begin
            valueA = {19'b0, 3'b001, 1'b1, 9'b0};
            valueB = new_address;
            start = 1'b1;
            `WAITCYCLE;
            start = 1'b0;
            $display("[BUS_START] Setting bus_start_address to %0d", new_address);
        end
    endtask

    //* Read the bus start address
    task read_bus_start_address;
        begin
            start = 1'b1;
            valueA = {19'b0, 3'b001, 1'b0, 9'b0};
            `WAIT2CYCLES;
            start = 1'b0;
            $display("[BUS_START] Reading bus_start_address via resTemp = %0d", DUT.result);
        end
    endtask

    //* Set the memory start address
    task set_memory_start_address;
        input [8:0] new_address;
        begin
            start = 1'b1;
            valueA = {19'b0, 3'b010, 1'b1, 9'b0};
            valueB = new_address;
            `WAITCYCLE
            start = 1'b0;
            $display("[MEMORY_START] Setting memory_start_address to %0d", new_address);
            memory_start_address = new_address;
        end
    endtask

    //* Read the memory start address
    task read_memory_start_address;
        begin
            start = 1'b1;
            valueA = {19'b0, 3'b010, 1'b0, 9'b0};
            `WAIT2CYCLES;
            start = 1'b0;
            $display("[MEMORY_START] Reading memory_start_address via resTemp = %0d", DUT.result);
        end
    endtask

    //* Set the block size
    task set_block_size;
        input [9:0] new_block_size;
        begin
            start = 1'b1;
            valueA = {19'b0, 3'b011, 1'b1, 9'b0};
            valueB = new_block_size;
            `WAITCYCLE
            start = 1'b0;
            $display("[BLOCK_SIZE] Setting block_size to %0d", new_block_size);
            block_size = new_block_size;
        end
    endtask

    //* Read the block size
    task read_block_size;
        begin
            start = 1'b1;
            valueA = {19'b0, 3'b011, 1'b0, 9'b0};
            `WAIT2CYCLES;
            start = 1'b0;
            $display("[BLOCK_SIZE] Reading block_size via resTemp = %0d", DUT.result);
        end
    endtask

    //* Set the burst size
    task set_burst_size;
        input [7:0] new_burst_size;
        begin
            start = 1'b1;
            valueA = {19'b0, 3'b100, 1'b1, 9'b0};
            valueB = new_burst_size;
            `WAITCYCLE
            start = 1'b0;
            $display("[BURST_SIZE] Setting burst_size to %0d", new_burst_size);
            burst_size = new_burst_size;
        end
    endtask

    //* Read the burst size
    task read_burst_size;
        begin
            start = 1'b1;
            valueA = {19'b0, 3'b100, 1'b0, 9'b0};
            `WAIT2CYCLES;
            start = 1'b0;
            $display("[BURST_SIZE] Reading burst_size via resTemp = %0d", DUT.result);
        end
    endtask

    //* Set the control register
    task set_control_register;
        input [1:0] new_control_register;
        begin
            start = 1'b1;   
            valueA = {19'b0, 3'b101, 1'b1, 9'b0};
            valueB = new_control_register;
            `WAITCYCLE
            start = 1'b0;
            $display("[CTRL_REG] Setting control_register to [%0b %0b]", new_control_register[1], new_control_register[0]);
        end
    endtask

    //* Read the control register
    task read_status_register;
        begin
            start = 1'b1;
            valueA = {19'b0, 3'b101, 1'b0, 9'b0};
            `WAIT2CYCLES;
            start = 1'b0;
            $display("[STAT_REG] Reading status_register via resTemp = [%0b %0b]", DUT.result[1], DUT.result[0]);
        end
    endtask

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
        $dumpvars(1, DUT.DMA);

        /// Set the initial values and reset the DUT
        $display("\n[LOG] Resetting the DUT");
        ciN = 8'h0B;
        start = 1'b0;
        reset = 1'b1;
        `WAIT2CYCLES;
        reset = 1'b0;
        `WAITCYCLE;
        $display("[LOG] DUT reset complete at %0tps", $time);

        /// Setup the DMA for the first transaction
        set_bus_start_address(32'd12);
        set_memory_start_address(9'd8);
        set_block_size(10'd20);
        set_burst_size(8'd9);

        `WAIT2CYCLES;
        `DISPLAY_DMA_REGISTERS;

        /// Start the DMA transaction
        set_control_register(2'b01);

        //* Return grant signal
        `WAIT2CYCLES
        busGrants = 1'b1;
        `WAIT2CYCLES;
        busGrants = 1'b0;
        `WAITHALFCYCLE;

        valueA = 0;

        //* Send the first burst with data_valid stopped
        busIn_data_valid = 1'b1;
        repeat(burst_size >> 1) begin
            busIn_address_data = busIn_address_data + 1;
            `WAITCYCLE;
        end

        busIn_data_valid = 1'b0;
        #20;
        busIn_data_valid = 1'b1;

        repeat(burst_size + 1 - (burst_size >> 1)) begin
            busIn_address_data = busIn_address_data + 1;
            `WAITCYCLE;
        end
        busIn_data_valid = 1'b0;
        busIn_end_transaction = 1'b1;
        `WAITCYCLE;
        busIn_end_transaction = 1'b0;

        burst_counter = burst_counter + 1;

        `WAITCYCLE

        //* Send the other bursts
        repeat(nb_transfers - 1) begin
            `WAIT2CYCLES;
            busGrants = 1'b1;
            `WAIT2CYCLES;
            busGrants = 1'b0;
            `WAITHALFCYCLE;
            
            $display("[LOG] Sending burst %0d", burst_counter);
            busIn_data_valid = 1'b1;
            repeat(block_size - burst_counter * (burst_size + 1) >= burst_size ? burst_size + 1 : block_size - burst_counter * (burst_size + 1)) begin
                busIn_address_data = busIn_address_data + 1;
                `WAITCYCLE;
            end
            busIn_data_valid = 1'b0;
            busIn_end_transaction = 1'b1;
            `WAITCYCLE;
            busIn_end_transaction = 1'b0;

            burst_counter = burst_counter + 1;

            `WAITCYCLE
        end
        
        // //* Send the last burst with error
        // $display("[LOG] Sending burst %0d", burst_counter);
        // busIn_data_valid = 1'b1;
        // repeat(burst_size >> 1) begin
        //     busIn_address_data = busIn_address_data + 1;
        //     `WAITCYCLE;
        // end
        // busIn_error = 1'b1;
        // busIn_data_valid = 1'b0;
        // `WAITCYCLE;
        // busIn_error = 1'b0;
        // #50;

        // //* Check if the burst transaction was successful
        valueA = memory_start_address;
        `WAITCYCLE;

        repeat(block_size) begin
            start = 1'b1; 
            `WAIT2CYCLES;
            start = 1'b0;             
            $display("[R_CPU] Read value %0d from address %0d", result, valueA[8:0]);
            valueA = valueA + 4;
        end

        //* Begin Write txn
        set_bus_start_address(32'd12);
        set_memory_start_address(9'd8);
        set_block_size(10'd20);
        set_burst_size(8'd7);

        `WAIT2CYCLES;

        set_control_register(2'b10);

        `WAIT2CYCLES;

        valueA = 0;
        repeat(nb_transfers) begin
            busGrants = 1'b1;
            `WAIT2CYCLES;
            busGrants = 1'b0;
            `WAITHALFCYCLE;
            #200;
        end



        $finish;

    
    end

endmodule