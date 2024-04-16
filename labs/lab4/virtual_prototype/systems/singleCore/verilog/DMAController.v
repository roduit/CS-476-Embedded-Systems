module DMAController #( parameter [7:0] customId = 8'h00)
                      ( input wire [31:0]   valueA,
                                            valueB,
                        input wire          ctrl_register_in,
                        output reg [31:0]   read_ctrl_result
                      );
        
    reg         dma_control = valueA[12:10];
    reg         dma_RW = valueA[9];
    reg [31:0]  bus_start_address = 0;
    reg [8:0]   memory_start_address = 0;
    reg [9:0]   block_size = 0;
    reg [7:0]   burst_size = 0;
    reg         control_register = 0;
    reg         write_enable = 0;
    reg [1:0]   status_register = 0;
    reg [8:0]   memory_address = 0;

    /*
     *
     *  Here we extract the information from the DMA control
     *
    */
    
    always @(*) begin
        case(dma_control)
            
            3'b000: if (dma_RW == 0) begin
                        // Read from memory location A[8:0]
                        memory_address = valueA[8:0];
                        write_enable = 0;
                    end
                    else begin
                        // Write to memory location A[8:0]
                        memory_address = valueA[8:0];
                        write_enable = 1;
                    end
            
            3'b001: if (dma_RW == 0) begin
                        // Read the bus start address of the DMA transfer
                        read_ctrl_result = bus_start_address;
                    end
                    else begin
                        // Write the bus start address of the DMA transfer B[31:0]
                        bus_start_address = valueB;
                    end
            
            3'b010: if (dma_RW == 0) begin
                        // Read the memory start address of the DMA transfer
                        read_ctrl_result = memory_start_address; /// !!!!!!! SIZE
                    end
                    else begin
                        // Write the memory start address of the DMA transfer B[8:0]
                        memory_start_address = valueB[8:0];
                    end
            
            3'b011: if (dma_RW == 0) begin
                        // Read block size (nb. of words) of the DMA transfer
                        read_ctrl_result = block_size;
                    end
                    else begin
                        // Write block size (nb. of words) of the DMA transfer B[9:0]
                        block_size = valueB[9:0];
                    end
            
            3'b100: if (dma_RW == 0) begin
                        // Read the burst size for the DMA transfer
                        read_ctrl_result = burst_size;
                    end
                    else begin
                        // Write the burst size for the DMA transfer B[7:0]
                        burst_size = valueB[7:0];
                    end
            
            3'b101: if (dma_RW == 0) begin
                        // Read the status register
                        read_ctrl_result = status_register;
                    end
                    else begin
                        // Write control register
                        control_register = ctrl_register_in;
                    end
        
        endcase
    end


endmodule