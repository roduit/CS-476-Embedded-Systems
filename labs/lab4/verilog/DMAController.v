module DMAController #( parameter [7:0] customId = 8'h00)
                      ( input   reg [31:0]  valueA,
                                            valueB,
                        input   reg         data_valid,
                        input   reg         busy_in,
                        input   reg         bus_error,
                        input   reg         bus_grant,
                        input   reg         ctrl_register_in,
                        output  wire        bus_request,
                        output  reg [31:0]  result
                      );

    // Enumerated states
    parameter   IDLE = 3'b111;
    parameter   RW_MEMORY = 3'b000;
    parameter   RW_BUS_START_ADD = 3'b001;
    parameter   RW_MEMORY_START_ADD = 3'b010;
    parameter   RW_BLOCK_SIZE = 3'b011;
    parameter   RW_BURST_SIZE = 3'b100;
    parameter   RW_STATUS_CTRL_REG = 3'b101;


    // State register
    reg [2:0] state;

    // Control register
    reg         ctrl_register;      // 1 in bit 0 means start a DMA-transfer in case the DMA-controller is idle.
    reg [1:0]   status_register;    // Bit 0: DMA transfer in progress (1); DMA is idle(0)
                                    // Bit 1: Indicate an error during the DMA transfer (1); No error (0)

    // Internal registers
    reg [31:0]  bus_start_address;      // Where the DMA-Controller starts transferring the data
    reg [8:0]   memory_start_address;   // Where the DMA-Controller starts writing the data
    reg [9:0]   block_size;             // Number of 32-bit words to transfer
    reg [7:0]   burst_size;             // Number of 32-bit words to transfer in one burst

    // State transition and output logic
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= IDLE; // Initial state
        end else begin
            state <= valueA[12:10];
        end
    end

    always @(*) begin
        case(state)
            RW_MEMORY: begin
                if (valueA[9] == 0) begin
                    // Read from memory location A[8:0]
                    memory_address = valueA[8:0];
                    write_enable = 0;
                end else begin
                    // Write to memory location A[8:0]
                    memory_address = valueA[8:0];
                    write_enable = 1;
                end
            end

            RW_BUS_START_ADD: begin
                if (valueA[9] == 0) begin
                    // Read the bus start address of the DMA transfer
                    result = bus_start_address;
                end else begin
                    // Write the bus start address of the DMA transfer B[31:0]
                    bus_start_address = valueB;
                end
            end

            RW_MEMORY_START_ADD: begin
                if (valueA[9] == 0) begin
                    // Read the memory start address of the DMA transfer
                    result = memory_start_address;
                end else begin
                    // Write the memory start address of the DMA transfer B[8:0]
                    memory_start_address = valueB[8:0];
                end
            end

            RW_BLOCK_SIZE: begin
                if (valueA[9] == 0) begin
                    // Read block size (nb. of words) of the DMA transfer
                    result = block_size;
                end else begin
                    // Write block size (nb. of words) of the DMA transfer B[9:0]
                    block_size = valueB[9:0];
                end
            end

            RW_BURST_SIZE: begin
                if (valueA[9] == 0) begin
                    // Read the burst size for the DMA transfer
                    result = burst_size;
                end else begin
                    // Write the burst size for the DMA transfer B[7:0]
                    burst_size = valueB[7:0];
                end
            end

            RW_STATUS_CTRL_REG: begin
                if (valueA[9] == 0) begin
                    // Read the status register
                    result = status_register;
                end else begin
                    // Write control register
                    ctrl_register = ctrl_register_in;
                end
            end

        endcase
    end

    


endmodule

    // reg         dma_control = valueA[12:10];
    // reg         dma_RW = valueA[9];
    // reg [31:0]  bus_start_address = 0;
    // reg [8:0]   memory_start_address = 0;
    // reg [9:0]   block_size = 0;
    // reg [7:0]   burst_size = 0;
    // reg         control_register = 0;
    // reg         write_enable = 0;
    // reg [1:0]   status_register = 0;
    // reg [8:0]   memory_address = 0;

    // /*
    //  *
    //  *  Here we extract the information from the DMA control
    //  *
    // */

    // // Request the bus and wait until it is granted
    // assign bus_request = 1;

    // // detect a change in the bus granted signal
    // always @(*) begin
        
    //     if (bus_error == 1) begin
    //         //* Error detected: Signal the error and return to idle state
    //         // TODO: Remove error after a cycle
    //         status_register = 2'b10;


    //     end

    //     if (bus_grant == 1) begin    
    //         //* Set the bus request to 0 and busy to 1
    //         bus_request = 0;
    //         status_register[0] = 1;
    //     end

    //     if (status_register[0] == 1 && data_valid == 0) begin
    //         //* Begin the transaction
    //         // TODO: create the transaction

    //     end

    // end