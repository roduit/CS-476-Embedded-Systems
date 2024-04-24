`timescale 1ps/1ps // set the time-units for simulation

module DMATestBench;

    reg start,clock,reset;
    reg [31:0] dataA = 32'h0000_0000;
    reg [31:0] dataB = 32'h0000_0000;
    reg [7:0] ciN;
    wire done;
    wire [31:0] result;

    reg dmaAckBusIn;
    reg dmaBusErrorIn;
    reg dmaBusyIn;
    reg dmaEndTransactionIn;
    reg dmaDataValidIn;
    reg [31:0] dmaAddressDataIn;

    wire dmaRequestBusOut;
    wire dmaBeginTransactionOut;
    wire dmaEndTransactionOut;
    wire dmaReadNotWriteOut;
    wire dmaDataValidOut;
    wire [7:0] dmaBurstSize;
    wire [3:0] dmaByteEnables;
    wire [31:0] dmaAddressDataOut;

    initial begin
        clock = 1'b0; // set the initial value
        repeat (4) #5 clock = ~clock; // generate 2 clock periods
        forever #5 clock = ~clock; // generate a clock with a period of 10 time-units
    end

    // instantiate the unit under test (UUT) 

    ramDmaCi #(.customId(8'd13)) UUT
            (.start(start),
            .clock(clock),
            .reset(reset),
            .valueA(dataA),
            .valueB(dataB),
            .ciN(ciN),
            .done(done),
            .result(result),

            .busIn_grants(dmaAckBusIn),
            .busIn_error(dmaBusErrorIn),
            .busIn_busy(dmaBusyIn),
            .busIn_end_transaction(dmaEndTransactionIn),
            .busIn_data_valid(dmaDataValidIn),
            .busIn_address_data(dmaAddressDataIn),

            .busOut_request(dmaRequestBusOut),
            .butOut_begin_transaction(dmaBeginTransactionOut),
            .busOut_end_transaction(dmaEndTransactionOut),
            .busOut_read_n_write(dmaReadNotWriteOut),
            .busOut_data_valid(dmaDataValidOut),
            .busOut_burst_size(dmaBurstSize),
            //.dmaByteEnablesOut(dmaByteEnables),
            .busOut_address_data(dmaAddressDataOut)
        );

integer addr;

    initial begin
        // Reset the device
        reset = 1'b1;
        start = 1'b0;
        dataA = 32'h0000_0000;
        dataB = 32'h0000_0000;
        ciN = 8'd0;
        repeat(2) @(negedge clock);
        reset = 1'b0;
        repeat(2) @(negedge clock);


        // =========================================
        // =========== TEST FOR PART 2.2 ===========
        // =========================================

        // $display("\n===== TESTS FOR PART 2.2 =====");

        // $display("\n== Writing and reading to/from SRAM through CI interface ==");
        // // Write value to certain address
        // dataB = 32'h1234_5678;
        // dataA = 32'h0000_034A;
        // ciN = 8'd13;
        // start = 1'b1;
        // @(negedge clock);
        // start = 1'b0;
        // repeat(2) @(negedge clock);
        // $display("Written first value = %h",dataB);

        // // Write value to another address
        // dataB = 32'h8765_4321;
        // dataA = 32'h0000_03B7;
        // ciN = 8'd13;
        // start = 1'b1;
        // @(negedge clock);
        // start = 1'b0;
        // repeat(2) @(negedge clock);
        // $display("Written second value = %h",dataB);

        // // change custom instruction number
        // @(negedge clock)
        // ciN = 8'd1;
        // repeat(2) @(negedge clock);

        // // Read value written second back
        // ciN = 8'd13;
        // dataA = 32'h0000_01B7;
        // start = 1'b1;
        // @(posedge done);
        // @(negedge clock);
        // $display("Read first value = %h",result);
        // start = 1'b0;
        // repeat(2) @(negedge clock);

        // // Read value written first back
        // dataA = 32'h0000_014A;
        // start = 1'b1;
        // @(posedge done);
        // @(negedge clock);
        // $display("Read second value = %h",result);
        // start = 1'b0;
        // repeat(2) @(negedge clock);

        // repeat(5) @(negedge clock);



        // =========================================
        // =========== TEST FOR PART 2.3 ===========
        // =========================================

        $display("\n\n===== TESTS FOR PART 2.3 =====");
        ciN = 8'd13;


        // ===== Writing and reading the DMA configuration =====

        $display("\n== Writing and reading DMA configuration ==");
        // Write bus start address and read it back
        dataB = 32'h1111_1100;
        dataA = (32'h0003) << 9;
        start = 1'b1;
        @(negedge clock);
        start = 1'b0;
        repeat(2) @(negedge clock);
        $display("Written bus start address = %0d",dataB);

        dataA = (32'h0002) << 9;
        start = 1'b1;
        @(posedge done);
        @(negedge clock);
        $display("Read bus start address = %0d\n",result);
        start = 1'b0;
        repeat(2) @(negedge clock);

        // Write memory start address and read it back
        dataB = 32'h10;
        dataA = (32'b101) << 9;
        start = 1'b1;
        @(negedge clock);
        start = 1'b0;
        repeat(2) @(negedge clock);
        $display("Written memory start address = %0d",dataB);

        dataA = (32'b0100) << 9;
        start = 1'b1;
        @(posedge done);
        @(negedge clock);
        $display("Read memory start address = %0d\n",result);
        start = 1'b0;
        repeat(2) @(negedge clock);

        // Write block size and read it back
        dataB = 32'h5;
        dataA = (32'b111) << 9;
        start = 1'b1;
        @(negedge clock);
        start = 1'b0;
        repeat(2) @(negedge clock);
        $display("Written block size = %0d",dataB);

        dataA = (32'b0110) << 9;
        start = 1'b1;
        @(posedge done);
        @(negedge clock);
        $display("Read block size = %0d\n",result);
        start = 1'b0;
        repeat(2) @(negedge clock);

        // // Write burst size and read it back
        dataB = 32'h4;
        dataA = (32'b1001) << 9;
        start = 1'b1;
        @(negedge clock);
        start = 1'b0;
        repeat(2) @(negedge clock);
        $display("Written burst size = %0d",dataB);

        dataA = (32'b1000) << 9;
        start = 1'b1;
        @(posedge done);
        @(negedge clock);
        $display("Read burst size = %0d",result);
        start = 1'b0;
        repeat(2) @(negedge clock);


        // // ===== Start a bus->memory transaction : burst size 4(+1), block size 5, 0x10 memory address =====

        $display("\n== Bus->memory transaction (Burst & Block of size 5) starting at memory address 16 ==");
        dmaAckBusIn = 1'b0;
        dmaBusErrorIn = 1'b0;
        dmaBusyIn = 1'b0;
        dmaEndTransactionIn = 1'b0;
        dmaDataValidIn = 1'b0;
        dmaAddressDataIn = 32'h0000_0000;

        // write 0x1 to control: read from bus
        dataB = 32'h1;
        dataA = (32'b1011) << 9;
        start = 1'b1;
        @(negedge clock);
        start = 1'b0;
        $display("Wrote control = %d",dataB);

        // read status, should be 1
        repeat(2) @(negedge clock);
        dataA = (32'b1010) << 9;
        start = 1'b1;
        @(posedge done);
        @(negedge clock);
        $display("Status = %0d (expected 1)",result);
        start = 1'b0;

        // wait for request, give grant@(posedge clock)
        $display("Waiting for request, then giving grant...");
        while (dmaRequestBusOut == 0) @(negedge clock);
        dmaAckBusIn = 1'b1;

        // readout info signals
        @(negedge clock);
        dmaAckBusIn = 1'b0;
        #10;

        $display("dmaBeginTransactionOut = %d (expected 1)",dmaBeginTransactionOut);
        $display("dmaReadNotWriteOut = %d (expected 1)",dmaReadNotWriteOut);
        $display("dmaBurstSizeOut = %d (expected 4)",dmaBurstSize);
        $display("dmaByteEnablesOut = %d (expected 15)",dmaByteEnables);
        $display("dmaAddressDataOut = %d (expected %d)",dmaAddressDataOut,32'h1111_1100);

        #30;

        // // have slave send some data, 5 blocks, with one transfer during data valid low
        dmaDataValidIn = 1'b1;

        dmaAddressDataIn = 32'h12;
        $display("Sending 1st data: %d",dmaAddressDataIn);
        #5;
        @(negedge clock);
        dmaAddressDataIn = 32'h34;
        $display("Sending 2nd data: %d",dmaAddressDataIn);
        @(negedge clock);
        dmaAddressDataIn = 32'h56;
        $display("Sending 3rd data: %d",dmaAddressDataIn);
        @(negedge clock);
        dmaDataValidIn = 1'b0;
        dmaAddressDataIn = 32'hEE;
        $display("Sending invalid data: %d",dmaAddressDataIn);
        @(negedge clock);
        dmaDataValidIn = 1'b1;
        dmaAddressDataIn = 32'h78;
        $display("Sending 4th data: %d",dmaAddressDataIn);
        @(negedge clock);
        dmaAddressDataIn = 32'h90;
        $display("Sending 5th and last data: %d",dmaAddressDataIn);
        @(negedge clock);

        dmaAddressDataIn = 32'h00;
        dmaEndTransactionIn = 1'b1;
        dmaDataValidIn = 1'b0;
        $display("End transaction: dmaEndTransactionIn = %d",dmaEndTransactionIn);
        @(negedge clock);
        dmaEndTransactionIn = 1'b0;

        // // check if status is back to idle and no error (value 0), then read memory
        @(negedge clock);
        dataA = (32'b1010) << 9;
        start = 1'b1;
        @(posedge done);
        @(negedge clock);
        $display("Status = %d (expected 0)",result);
        start = 1'b0;

        repeat(2) @(negedge clock);
        for (addr = 16; addr <= 21; addr = addr + 1) begin // there should be no value at addr = 21
            dataA = addr;
            start = 1'b1;
            @(posedge done);
            @(negedge clock);
            $display("Read memory at %d = %d", addr, result);
            start = 1'b0;
            @(negedge clock);
        end

        repeat(5) @(negedge clock);


        // // ===== Start a bus->memory transaction with block size < burst size  =====

        $display("\n== Bus->memory transaction (Block size = 3 < burst size = 5) starting at memory address 32 ==");
        dmaAckBusIn = 1'b0;
        dmaBusErrorIn = 1'b0;
        dmaBusyIn = 1'b0;
        dmaEndTransactionIn = 1'b0;
        dmaDataValidIn = 1'b0;
        dmaAddressDataIn = 32'h0000_0000;

        // Set memory start address to 32
        dataB = 32'h20;
        dataA = (32'b101) << 9;
        start = 1'b1;
        @(negedge clock);
        start = 1'b0;
        repeat(2) @(negedge clock);
        $display("Written memory start address = %d",dataB);

        // Set block size to 3
        dataB = 32'h3;
        dataA = (32'b111) << 9;
        start = 1'b1;
        @(negedge clock);
        start = 1'b0;
        repeat(2) @(negedge clock);
        $display("Written block size = %d",dataB);

        // write 0x1 to control: read from bus
        dataB = 32'h1;
        dataA = (32'b1011) << 9;
        start = 1'b1;
        @(negedge clock);
        start = 1'b0;
        $display("Wrote control = %d",dataB);

        // read status, should be 1
        repeat(2) @(negedge clock);
        dataA = (32'b1010) << 9;
        start = 1'b1;
        @(posedge done);
        @(negedge clock);
        $display("Status = %d (expected 1)",result);
        start = 1'b0;

        // wait for request, give grant
        $display("Waiting for request, then giving grant...");
        while (dmaRequestBusOut == 0) @(negedge clock);
        dmaAckBusIn = 1'b1;

        // readout info signals
        @(negedge clock);
        dmaAckBusIn = 1'b0;
        #10;
        $display("dmaBeginTransactionOut = %d (expected 1)",dmaBeginTransactionOut);
        $display("dmaReadNotWriteOut = %d (expected 1)",dmaReadNotWriteOut);
        $display("dmaBurstSizeOut = %d (expected 2)",dmaBurstSize);
        $display("dmaByteEnablesOut = %d (expected 15)",dmaByteEnables);
        $display("dmaAddressDataOut = %d (expected %d)",dmaAddressDataOut,32'h1111_1100);

        // have slave send some data
        dmaDataValidIn = 1'b1;

        dmaAddressDataIn = 32'h65;
        $display("Sending 1st data: %d",dmaAddressDataIn);
        #5;
        @(negedge clock);
        dmaAddressDataIn = 32'h43;
        $display("Sending 2nd data: %d",dmaAddressDataIn);
        @(negedge clock);
        dmaAddressDataIn = 32'h21;
        $display("Sending 3rd data: %d",dmaAddressDataIn);
        @(negedge clock);

        dmaAddressDataIn = 32'h00;
        dmaEndTransactionIn = 1'b1;
        dmaDataValidIn = 1'b0;
        $display("End transaction: dmaEndTransactionIn = %d",dmaEndTransactionIn);
        @(negedge clock);
        dmaEndTransactionIn = 1'b0;

        // check if status is back to idle and no error (value 0), then read memory
        @(negedge clock);
        dataA = (32'b1010) << 9;
        start = 1'b1;
        @(posedge done);
        @(negedge clock);
        $display("Status = %d (expected 0)",result);
        start = 1'b0;

        repeat(2) @(negedge clock);
        for (addr = 32; addr <= 35; addr = addr + 1) begin // there should be no value at addr = 35
            dataA = addr;
            start = 1'b1;
            @(posedge done);
            @(negedge clock);
            $display("Read memory at 0x%h = %d", addr, result);
            start = 1'b0;
            @(negedge clock);
        end

        repeat(5) @(negedge clock);


        // // ===== Start a bus->memory transaction with block size > burst size (and no integer multiple) =====

        $display("\n== Bus->memory transaction (Block size = 7 < burst size = 5) starting at memory address 48 ==");
        dmaAckBusIn = 1'b0;
        dmaBusErrorIn = 1'b0;
        dmaBusyIn = 1'b0;
        dmaEndTransactionIn = 1'b0;
        dmaDataValidIn = 1'b0;
        dmaAddressDataIn = 32'h0000_0000;

        // Set memory start address to 48
        dataB = 32'h30;
        dataA = (32'b101) << 9;
        start = 1'b1;
        @(negedge clock);
        start = 1'b0;
        repeat(2) @(negedge clock);
        $display("Written memory start address = %d",dataB);

        // Set block size to 7
        dataB = 32'h7;
        dataA = (32'b111) << 9;
        start = 1'b1;
        @(negedge clock);
        start = 1'b0;
        repeat(2) @(negedge clock);
        $display("Written block size = %d",dataB);

        // write 0x1 to control: read from bus
        dataB = 32'h1;
        dataA = (32'b1011) << 9;
        start = 1'b1;
        @(negedge clock);
        start = 1'b0;
        $display("Wrote control = %d",dataB);

        // read status, should be 1
        repeat(2) @(negedge clock);
        dataA = (32'b1010) << 9;
        start = 1'b1;
        @(posedge done);
        @(negedge clock);
        $display("Status = %d (expected 1)",result);
        start = 1'b0;

        // wait for request, give grant
        $display("Waiting for request, then giving grant...");
        while (dmaRequestBusOut == 0) @(negedge clock);
        dmaAckBusIn = 1'b1;

        // readout info signals
        @(negedge clock);
        dmaAckBusIn = 1'b0;
        #10;
        $display("dmaBeginTransactionOut = %d (expected 1)",dmaBeginTransactionOut);
        $display("dmaReadNotWriteOut = %d (expected 1)",dmaReadNotWriteOut);
        $display("dmaBurstSizeOut = %d (expected 4)",dmaBurstSize);
        $display("dmaByteEnablesOut = %d (expected 15)",dmaByteEnables);
        $display("dmaAddressDataOut = %d (expected %d)",dmaAddressDataOut,32'h1111_1100);

        // have slave send some data, 5 blocks
        dmaDataValidIn = 1'b1;

        dmaAddressDataIn = 32'h11;
        $display("Sending 1st data: %d",dmaAddressDataIn);
        #5;
        @(negedge clock);
        dmaAddressDataIn = 32'h22;
        $display("Sending 2nd data: %d",dmaAddressDataIn);
        @(negedge clock);
        dmaAddressDataIn = 32'h33;
        $display("Sending 3rd data: %d",dmaAddressDataIn);
        @(negedge clock);
        dmaAddressDataIn = 32'h44;
        $display("Sending 4th data: %d",dmaAddressDataIn);
        @(negedge clock);
        dmaAddressDataIn = 32'h55;
        $display("Sending 5th data: %d",dmaAddressDataIn);
        @(negedge clock);

        dmaAddressDataIn = 32'h00;
        dmaDataValidIn = 1'b0;
        dmaEndTransactionIn = 1'b1;
        $display("End transaction: dmaEndTransactionIn = %d",dmaEndTransactionIn);
        @(negedge clock);
        dmaEndTransactionIn = 1'b0;

        // check if status is still active and no error (value 1)
        @(negedge clock);
        dataA = (32'b1010) << 9;
        start = 1'b1;
        @(posedge done);
        @(negedge clock);
        $display("Status = %d (expected 1)",result);
        start = 1'b0;

        // give dma grant for new transfer
        $display("Waiting for request, then giving grant...");
        while (dmaRequestBusOut == 0) @(negedge clock);
        dmaAckBusIn = 1'b1;

        // readout info signals
        @(negedge clock);
        dmaAckBusIn = 1'b0;
        #10;
        $display("dmaBeginTransactionOut = %d (expected 1)",dmaBeginTransactionOut);
        $display("dmaReadNotWriteOut = %d (expected 1)",dmaReadNotWriteOut);
        $display("dmaBurstSizeOut = %d (expected 1)",dmaBurstSize);
        $display("dmaByteEnablesOut = %d (expected 15)",dmaByteEnables);
        $display("dmaAddressDataOut = %d (expected %d)",dmaAddressDataOut,32'h1111_1100 + 4*32'h0000_0004 + 4);

        // send data
        dmaDataValidIn = 1'b1;

        dmaAddressDataIn = 32'h66;
        $display("Sending 1st data: %d",dmaAddressDataIn);
        #5;
        @(negedge clock);
        dmaAddressDataIn = 32'h77;
        $display("Sending 2nd data: %d",dmaAddressDataIn);
        @(negedge clock);

        dmaAddressDataIn = 32'h00;
        dmaDataValidIn = 1'b0;
        dmaEndTransactionIn = 1'b1;
        $display("End transaction: dmaEndTransactionIn = %d",dmaEndTransactionIn);
        @(negedge clock);
        dmaEndTransactionIn = 1'b0;


        // check if status is back to idle and no error (value 0), then read memory
        @(negedge clock);
        dataA = (32'b1010) << 9;
        start = 1'b1;
        @(posedge done);
        @(negedge clock);
        $display("Status = %d (expected 0)",result);
        start = 1'b0;

        repeat(2) @(negedge clock);
        for (addr = 48; addr <= 55; addr = addr + 1) begin // there should be no value at addr = 55
            dataA = addr;
            start = 1'b1;
            @(posedge done);
            @(negedge clock);
            $display("Read memory at %d = %d", addr, result);
            start = 1'b0;
            @(negedge clock);
        end

        repeat(5) @(negedge clock);


        // // ===== Start a bus->memory transaction with an error =====

        $display("\n== Bus->memory transaction with error starting at memory address 48 ==");
        dmaAckBusIn = 1'b0;
        dmaBusErrorIn = 1'b0;
        dmaBusyIn = 1'b0;
        dmaEndTransactionIn = 1'b0;
        dmaDataValidIn = 1'b0;
        dmaAddressDataIn = 32'h0000_0000;

        // write 0x1 to control: read from bus
        dataB = 32'h1;
        dataA = (32'b1011) << 9;
        start = 1'b1;
        @(negedge clock);
        start = 1'b0;
        $display("Wrote control = %d",dataB);

        // read status, should be 1
        repeat(2) @(negedge clock);
        dataA = (32'b1010) << 9;
        start = 1'b1;
        @(posedge done);
        @(negedge clock);
        $display("Status = %d (expected 1)",result);
        start = 1'b0;

        // give dma grant for new transfer
        $display("Waiting for request, then giving grant...");
        while (dmaRequestBusOut == 0) @(negedge clock);
        dmaAckBusIn = 1'b1;

        // readout info signals
        @(negedge clock);
        dmaAckBusIn = 1'b0;
        #10;
        $display("dmaBeginTransactionOut = %d (expected 1)",dmaBeginTransactionOut);
        $display("dmaReadNotWriteOut = %d (expected 1)",dmaReadNotWriteOut);
        $display("dmaBurstSizeOut = %d (expected 4)",dmaBurstSize);
        $display("dmaByteEnablesOut = %d (expected 15)",dmaByteEnables);
        $display("dmaAddressDataOut = %d (expected %d)",dmaAddressDataOut,32'h1111_1100);

        // have slave send some data but also put bus error received on 3rd data
        dmaDataValidIn = 1'b1;

        dmaAddressDataIn = 32'h12;
        $display("Sending 1st data: %d",dmaAddressDataIn);
        #10;
        @(negedge clock);
        dmaAddressDataIn = 32'hCD;
        dmaBusErrorIn = 1'b1;
        $display("Sending 2nd data (= %d) with dmaBusErrorIn set to 1",dmaAddressDataIn);
        @(negedge clock);
        dmaBusErrorIn = 1'b0;
        dmaAddressDataIn = 32'hCD;
        dmaEndTransactionIn = 1'b1;
        $display("Sending 3rd data (= %d) with dmaBusErrorIn set back to 0",dmaAddressDataIn);

        @(negedge clock);
        dmaAddressDataIn = 32'h00;
        dmaDataValidIn = 1'b0;
        dmaEndTransactionIn = 1'b0;

        // check if status is at error (value 2) and that the memory has not changed compared to before transaction
        @(negedge clock);
        dataA = (32'b1010) << 9;
        start = 1'b1;
        @(posedge done);
        @(negedge clock);
        $display("Status = %d (expected 2)",result);
        start = 1'b0;

        repeat(2) @(negedge clock);
        for (addr = 48; addr <= 55; addr = addr + 1) begin // there should be no value at addr = 55
            dataA = addr;
            start = 1'b1;
            @(posedge done);
            @(negedge clock);
            $display("Read memory at %d = %d", addr, result);
            start = 1'b0;
            @(negedge clock);
        end

        repeat(5) @(negedge clock);


        // =========================================
        // =========== TEST FOR PART 2.4 ===========
        // =========================================

        $display("\n\n===== TESTS FOR PART 2.4 =====");
        ciN = 8'd13;

        // ===== Start a memory->bus transaction : burst size 4(+1), block size 5, 0x10 memory address =====
        $display("\n== Memory->bus transaction (Burst & Block of size 5) starting at memory address 16 ==");
        dmaAckBusIn = 1'b0;
        dmaBusErrorIn = 1'b0;
        dmaBusyIn = 1'b0;
        dmaEndTransactionIn = 1'b0;
        dmaDataValidIn = 1'b0;
        dmaAddressDataIn = 32'h0000_0000;

        // Set memory start address to 16
        dataB = 32'h10;
        dataA = (32'b101) << 9;
        start = 1'b1;
        @(negedge clock);
        start = 1'b0;
        repeat(2) @(negedge clock);
        $display("Written memory start address = %d",dataB);

        // Set block size to 5
        dataB = 32'h5;
        dataA = (32'b111) << 9;
        start = 1'b1;
        @(negedge clock);
        start = 1'b0;
        repeat(2) @(negedge clock);
        $display("Written block size = %d",dataB);

        // write 0x2 to control: write to bus
        dataB = 32'h2;
        dataA = (32'b1011) << 9;
        start = 1'b1;
        @(negedge clock);
        start = 1'b0;
        $display("Wrote control = %d",dataB);

        // read status, should be 1
        repeat(2) @(negedge clock);
        dataA = (32'b1010) << 9;
        start = 1'b1;
        @(posedge done);
        @(negedge clock);
        $display("Status = %d (expected 1)",result);
        start = 1'b0;

        // wait for request, give grant
        $display("Waiting for request, then giving grant...");
        while (dmaRequestBusOut == 0) @(negedge clock);
        dmaAckBusIn = 1'b1;

        // readout info signals
        @(negedge clock);
        dmaAckBusIn = 1'b0;
        #10;
        $display("dmaBeginTransactionOut = %d (expected 1)",dmaBeginTransactionOut);
        $display("dmaReadNotWriteOut = %d (expected 0)",dmaReadNotWriteOut);
        $display("dmaBurstSizeOut = %d (expected 4)",dmaBurstSize);
        $display("dmaByteEnablesOut = %d (expected 15)",dmaByteEnables);
        $display("dmaAddressDataOut = %d (expected %d)",dmaAddressDataOut,32'h1111_1100);
        $display("dmaDataValidOut = %d (expected 0)",dmaDataValidOut);

        // have the slave receive some data, with the busy signal set to one at some point
        #5;
        @(negedge clock);
        dmaBusyIn = 1'b0;
        $display("Received 1st data: %d (expected %d)",dmaAddressDataOut,32'h12);
        $display("dmaDataValidOut = %d (expected 1)\n",dmaDataValidOut);
        @(negedge clock);
        $display("Received 2nd data: %d (expected %d)",dmaAddressDataOut,32'h34);
        $display("dmaDataValidOut = %d (expected 1)\n",dmaDataValidOut);
        @(negedge clock);
        $display("Received 3rd data: %d (expected %d)",dmaAddressDataOut,32'h56);
        $display("dmaDataValidOut = %d (expected 1)\n",dmaDataValidOut);
        @(negedge clock);
        dmaBusyIn = 1'b1;
        $display("Received 4th data but with dmaBusyIn set to 1: %d (expected %d)",dmaAddressDataOut,32'h78);
        $display("dmaDataValidOut = %d (expected 1)\n",dmaDataValidOut);
        @(negedge clock);
        dmaBusyIn = 1'b0;
        $display("Received 4th data: %d (expected %d)",dmaAddressDataOut,32'h78);
        $display("dmaDataValidOut = %d (expected 1)\n",dmaDataValidOut);
        @(negedge clock);
        $display("Received 5th and last data: %d (expected %d)",dmaAddressDataOut,32'h90);
        $display("dmaDataValidOut = %d (expected 1)\n",dmaDataValidOut);
        @(negedge clock);
        $display("dmaEndTransactionOut = %d (expected 1)",dmaEndTransactionOut);
        $display("dmaDataValidOut = %d (expected 0)",dmaDataValidOut);
        $display("dmaAddressDataOut = %d (expected 0)\n",dmaAddressDataOut);

        // transaction finished, checking if all is set back to 0 again and status is back to idle with no error (value 0)
        @(negedge clock);
        $display("dmaEndTransactionOut = %d (expected 0)",dmaEndTransactionOut);
        @(negedge clock);
        dataA = (32'b1010) << 9;
        start = 1'b1;
        @(posedge done);
        @(negedge clock);
        $display("Status = %d (expected 0)",result);
        start = 1'b0;


        // // ===== Start a memory->bus transaction with block size < burst size =====

        $display("\n== Memory->bus transaction (Block size = 3 < burst size = 5) starting at memory address 32 ==");
        dmaAckBusIn = 1'b0;
        dmaBusErrorIn = 1'b0;
        dmaBusyIn = 1'b0;
        dmaEndTransactionIn = 1'b0;
        dmaDataValidIn = 1'b0;
        dmaAddressDataIn = 32'h0000_0000;

        // Set memory start address to 32
        dataB = 32'h20;
        dataA = (32'b101) << 9;
        start = 1'b1;
        @(negedge clock);
        start = 1'b0;
        repeat(2) @(negedge clock);
        $display("Written memory start address = %d",dataB);

        // Set block size to 3
        dataB = 32'h3;
        dataA = (32'b111) << 9;
        start = 1'b1;
        @(negedge clock);
        start = 1'b0;
        repeat(2) @(negedge clock);
        $display("Written block size = %d",dataB);

        // write 0x2 to control: write to bus
        dataB = 32'h2;
        dataA = (32'b1011) << 9;
        start = 1'b1;
        @(negedge clock);
        start = 1'b0;
        $display("Wrote control = %d",dataB);

        // read status, should be 1
        repeat(2) @(negedge clock);
        dataA = (32'b1010) << 9;
        start = 1'b1;
        @(posedge done);
        @(negedge clock);
        $display("Status = %d (expected 1)",result);
        start = 1'b0;

        // wait for request, give grant
        $display("Waiting for request, then giving grant...");
        while (dmaRequestBusOut == 0) @(negedge clock);
        dmaAckBusIn = 1'b1;

        // readout info signals
        @(negedge clock);
        dmaAckBusIn = 1'b0;
        #10;
        $display("dmaBeginTransactionOut = %d (expected 1)",dmaBeginTransactionOut);
        $display("dmaReadNotWriteOut = %d (expected 0)",dmaReadNotWriteOut);
        $display("dmaBurstSizeOut = %d (expected 2)",dmaBurstSize);
        $display("dmaByteEnablesOut = %d (expected 15)",dmaByteEnables);
        $display("dmaAddressDataOut = %d (expected %d)",dmaAddressDataOut,32'h1111_1100);
        $display("dmaDataValidOut = %d (expected 0)",dmaDataValidOut);

        // have the slave receive some data, with the busy signal set to one at some point
        #5;
        @(negedge clock);
        dmaBusyIn = 1'b0;
        $display("Received 1st data: %d (expected %d)",dmaAddressDataOut,32'h65);
        $display("dmaDataValidOut = %d (expected 1)",dmaDataValidOut);
        @(negedge clock);
        $display("Received 2nd data: %d (expected %d)",dmaAddressDataOut,32'h43);
        $display("dmaDataValidOut = %d (expected 1)",dmaDataValidOut);
        @(negedge clock);
        $display("Received 3rd data: %d (expected %d)",dmaAddressDataOut,32'h21);
        $display("dmaDataValidOut = %d (expected 1)",dmaDataValidOut);
        @(negedge clock);
        $display("dmaEndTransactionOut = %d (expected 1)",dmaEndTransactionOut);
        $display("dmaDataValidOut = %d (expected 0)",dmaDataValidOut);
        $display("dmaAddressDataOut = %d (expected 0)",dmaAddressDataOut);

        // transaction finished, checking if all is set back to 0 again and status is back to idle with no error (value 0)
        @(negedge clock);
        $display("dmaEndTransactionOut = %d (expected 0)",dmaEndTransactionOut);
        @(negedge clock);
        dataA = (32'b1010) << 9;
        start = 1'b1;
        @(posedge done);
        @(negedge clock);
        $display("Status = %d (expected 0)",result);
        start = 1'b0;


        // // ===== Start a memory->bus transaction with block size > burst size (and no integer multiple) =====

        $display("\n== Bus->memory transaction (Block size = 7 < burst size = 5) starting at memory address 48 ==");
        dmaAckBusIn = 1'b0;
        dmaBusErrorIn = 1'b0;
        dmaBusyIn = 1'b0;
        dmaEndTransactionIn = 1'b0;
        dmaDataValidIn = 1'b0;
        dmaAddressDataIn = 32'h0000_0000;

        // Set memory start address to 48
        dataB = 32'h30;
        dataA = (32'b101) << 9;
        start = 1'b1;
        @(negedge clock);
        start = 1'b0;
        repeat(2) @(negedge clock);
        $display("Written memory start address = %d",dataB);

        // Set block size to 7
        dataB = 32'h7;
        dataA = (32'b111) << 9;
        start = 1'b1;
        @(negedge clock);
        start = 1'b0;
        repeat(2) @(negedge clock);
        $display("Written block size = %d",dataB);

        // write 0x2 to control: write to bus
        dataB = 32'h2;
        dataA = (32'b1011) << 9;
        start = 1'b1;
        @(negedge clock);
        start = 1'b0;
        $display("Wrote control = %d",dataB);

        // read status, should be 1
        repeat(2) @(negedge clock);
        dataA = (32'b1010) << 9;
        start = 1'b1;
        @(posedge done);
        @(negedge clock);
        $display("Status = %d (expected 1)",result);
        start = 1'b0;

        // wait for request, give grant
        $display("Waiting for request, then giving grant...");
        while (dmaRequestBusOut == 0) @(negedge clock);
        dmaAckBusIn = 1'b1;

        // readout info signals
        @(negedge clock);
        dmaAckBusIn = 1'b0;
        #10;
        $display("dmaBeginTransactionOut = %d (expected 1)",dmaBeginTransactionOut);
        $display("dmaReadNotWriteOut = %d (expected 0)",dmaReadNotWriteOut);
        $display("dmaBurstSizeOut = %d (expected 4)",dmaBurstSize);
        $display("dmaByteEnablesOut = %d (expected 15)",dmaByteEnables);
        $display("dmaAddressDataOut = %d (expected %d)",dmaAddressDataOut,32'h1111_1100);
        $display("dmaDataValidOut = %d (expected 0)",dmaDataValidOut);

        // have the slave receive some data, with the busy signal set to one at some point
        #5;
        @(negedge clock);
        dmaBusyIn = 1'b0;
        $display("Received 1st data: %d (expected %d)",dmaAddressDataOut,32'h12);
        $display("dmaDataValidOut = %d (expected 1)",dmaDataValidOut);
        @(negedge clock);
        $display("Received 2nd data: %d (expected %d)",dmaAddressDataOut,32'h22);
        $display("dmaDataValidOut = %d (expected 1)",dmaDataValidOut);
        @(negedge clock);
        $display("Received 3rd data: %d (expected %d)",dmaAddressDataOut,32'h33);
        $display("dmaDataValidOut = %d (expected 1)",dmaDataValidOut);
        @(negedge clock);
        $display("Received 4th data: %d (expected %d)",dmaAddressDataOut,32'h44);
        $display("dmaDataValidOut = %d (expected 1)",dmaDataValidOut);
        @(negedge clock);
        $display("Received 5th data: %d (expected %d)",dmaAddressDataOut,32'h55);
        $display("dmaDataValidOut = %d (expected 1)",dmaDataValidOut);
        @(negedge clock);
        $display("dmaEndTransactionOut = %d (expected 1)",dmaEndTransactionOut);
        $display("dmaDataValidOut = %d (expected 0)",dmaDataValidOut);
        $display("dmaAddressDataOut = %d (expected 0)",dmaAddressDataOut);

        // transaction finished, checking if all is set back to 0 again and status is back to active with no error (value 1)
        @(negedge clock);
        $display("dmaEndTransactionOut = %d (expected 0)",dmaEndTransactionOut);
        @(negedge clock);
        dataA = (32'b1010) << 9;
        start = 1'b1;
        @(posedge done);
        @(negedge clock);
        $display("Status = %d (expected 1)",result);
        start = 1'b0;

        // wait for request, give grant
        $display("Waiting for request, then giving grant...");
        while (dmaRequestBusOut == 0) @(negedge clock);
        dmaAckBusIn = 1'b1;

        // readout info signals
        @(negedge clock);
        dmaAckBusIn = 1'b0;
        #10;
        $display("dmaBeginTransactionOut = %d (expected 1)",dmaBeginTransactionOut);
        $display("dmaReadNotWriteOut = %d (expected 0)",dmaReadNotWriteOut);
        $display("dmaBurstSizeOut = %d (expected 1)",dmaBurstSize);
        $display("dmaByteEnablesOut = %d (expected 15)",dmaByteEnables);
        $display("dmaAddressDataOut = %d (expected %d)",dmaAddressDataOut,32'h1111_1100 + 4*32'h0000_0004 + 4);
        $display("dmaDataValidOut = %d (expected 0)",dmaDataValidOut);

        // have the slave receive some data, with the busy signal set to one at some point
        #5;
        @(negedge clock);
        dmaBusyIn = 1'b0;
        $display("Received 1st data: %d (expected %d)",dmaAddressDataOut,32'h66);
        $display("dmaDataValidOut = %d (expected 1)",dmaDataValidOut);
        @(negedge clock);
        $display("Received 2nd data: %d (expected %d)",dmaAddressDataOut,32'h77);
        $display("dmaDataValidOut = %d (expected 1)",dmaDataValidOut);
        @(negedge clock);
        $display("dmaEndTransactionOut = %d (expected 1)",dmaEndTransactionOut);
        $display("dmaDataValidOut = %d (expected 0)",dmaDataValidOut);
        $display("dmaAddressDataOut = %d (expected 0)",dmaAddressDataOut);

        // transaction finished, checking if all is set back to 0 again and status is back to idle with no error (value 0)
        @(negedge clock);
        $display("dmaEndTransactionOut = %d (expected 0)",dmaEndTransactionOut);
        @(negedge clock);
        dataA = (32'b1010) << 9;
        start = 1'b1;
        @(posedge done);
        @(negedge clock);
        $display("Status = %d (expected 0)",result);
        start = 1'b0;


        // // ===== Start a memory->bus transaction with an error =====

        $display("\n== Memory->bus transaction with error starting at memory address 48 ==");
        dmaAckBusIn = 1'b0;
        dmaBusErrorIn = 1'b0;
        dmaBusyIn = 1'b0;
        dmaEndTransactionIn = 1'b0;
        dmaDataValidIn = 1'b0;
        dmaAddressDataIn = 32'h0000_0000;

        // Set block size to 5
        dataB = 32'h5;
        dataA = (32'b111) << 9;
        start = 1'b1;
        @(negedge clock);
        start = 1'b0;
        repeat(2) @(negedge clock);
        $display("Written block size = %d",dataB);

        // write 0x2 to control: write to bus
        dataB = 32'h2;
        dataA = (32'b1011) << 9;
        start = 1'b1;
        @(negedge clock);
        start = 1'b0;
        $display("Wrote control = %d",dataB);

        // read status, should be 1
        repeat(2) @(negedge clock);
        dataA = (32'b1010) << 9;
        start = 1'b1;
        @(posedge done);
        @(negedge clock);
        $display("Status = %d (expected 1)",result);
        start = 1'b0;

        // wait for request, give grant
        $display("Waiting for request, then giving grant...");
        while (dmaRequestBusOut == 0) @(negedge clock);
        dmaAckBusIn = 1'b1;

        // readout info signals
        @(negedge clock);
        dmaAckBusIn = 1'b0;
        #10;
        $display("dmaBeginTransactionOut = %d (expected 1)",dmaBeginTransactionOut);
        $display("dmaReadNotWriteOut = %d (expected 0)",dmaReadNotWriteOut);
        $display("dmaBurstSizeOut = %d (expected 4)",dmaBurstSize);
        $display("dmaByteEnablesOut = %d (expected 15)",dmaByteEnables);
        $display("dmaAddressDataOut = %d (expected %d)",dmaAddressDataOut,32'h1111_1100);
        $display("dmaDataValidOut = %d (expected 0)",dmaDataValidOut);

        // have the slave receive some data, with the busy signal set to one at some point
        #5;
        @(negedge clock);
        dmaBusyIn = 1'b0;
        $display("Received 1st data: %d (expected %d)",dmaAddressDataOut,32'h12);
        $display("dmaDataValidOut = %d (expected 1)",dmaDataValidOut);
        @(negedge clock);
        dmaBusErrorIn = 1'b1;
        $display("Received 2nd data while busError is set to 1: %d (expected %d)",dmaAddressDataOut,32'h22);
        $display("dmaDataValidOut = %d (expected 1)",dmaDataValidOut);
        @(negedge clock);
        $display("Data on dmaAddressDataOut: %d (expected %d)",dmaAddressDataOut,32'h0);
        $display("dmaDataValidOut = %d (expected 0)",dmaDataValidOut);
        $display("dmaEndTransactionOut = %d (expected 1)",dmaEndTransactionOut);

        // check if status is at error (value 2)
        @(negedge clock);
        dataA = (32'b1010) << 9;
        start = 1'b1;
        @(posedge done);
        @(negedge clock);
        $display("Status = %d (expected 2)",result);
        start = 1'b0;


        $finish;
    end

    initial begin
        // define the name of the .vcd file that can be viewed by GTKWAVE
        //$dumpfile("ramDmaCi.vcd");
        $dumpfile("dma_tb.vcd");

        // dump all signals inside the DUT-component in the .vcd file
        $dumpvars(0, UUT);
    end


endmodule
