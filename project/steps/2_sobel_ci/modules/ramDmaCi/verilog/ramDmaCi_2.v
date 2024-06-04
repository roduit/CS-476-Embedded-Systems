module ramDmaCi #( parameter [7:0] customId = 8'h00 )
                 ( input wire         start,
                                      clock,
                                      reset,
                   input wire [31:0]  valueA,
                                      valueB,
                   input wire [7:0]   ciN,
                   output wire        done ,
                   output wire [31:0] result,

                   // Here the required bus signals are defined
                   output wire        requestTransaction,
                   input wire         transactionGranted,
                   input wire         endTransactionIn,
                                      dataValidIn,
                                      busErrorIn,
                   input wire [31:0]  addressDataIn,
                   output reg         beginTransactionOut,
                   output reg         readNotWriteOut,
                   output reg [3:0]   byteEnablesOut,
                   output reg [7:0]   burstSizeOut,
                   output reg [31:0]  addressDataOut);

  wire [31:0] s_sramDataValue;
  /*
   *
   * Here we define the custom instruction control signals
   *
   */
  wire s_isMyCi = (ciN == customId) ? start : 1'b0;
  wire s_isSramWrite = (valueA[31:10] == 22'd0) ? s_isMyCi & valueA[9] : 1'b0;
  wire s_isSramRead  = s_isMyCi & ~valueA[9];
  reg s_isSramReadReg;
  
  assign done   = (s_isMyCi & valueA[9]) | s_isSramReadReg;
  
  always @(posedge clock) s_isSramReadReg = ~reset & s_isSramRead;

  /*
   *
   * Here we define the sdram control registers
   *
   */
  reg[31:0] s_busStartAddressReg;
  reg[8:0]  s_memoryStartAddressReg;
  reg[9:0]  s_blockSizeReg;
  reg[7:0]  s_usedBurstSizeReg;
  
  always @(posedge clock)
    begin
      s_busStartAddressReg    <= (reset == 1'b1) ? 32'd0 :
                                 (s_isMyCi == 1'b1 && valueA[12:9] == 4'b0011) ? valueB : s_busStartAddressReg;
      s_memoryStartAddressReg <= (reset == 1'b1) ? 9'd0 :
                                 (s_isMyCi == 1'b1 && valueA[12:9] == 4'b0101) ? valueB[8:0] : s_memoryStartAddressReg;
      s_blockSizeReg          <= (reset == 1'b1) ? 10'd0 :
                                 (s_isMyCi == 1'b1 && valueA[12:9] == 4'b0111) ? valueB[9:0] : s_blockSizeReg;
      s_usedBurstSizeReg      <= (reset == 1'b1) ? 8'd0 :
                                 (s_isMyCi == 1'b1 && valueA[12:9] == 4'b1001) ? valueB[7:0] : s_usedBurstSizeReg;
    end

  /*
   *
   * Here we define all bus-in registers
   *
   */
  reg s_endTransactionInReg, s_dataValidInReg;
  reg [31:0] s_addressDataInReg;
  
  always @(posedge clock)
    begin
      s_endTransactionInReg <= endTransactionIn;
      s_dataValidInReg      <= dataValidIn;
      s_addressDataInReg    <= addressDataIn;
    end

  /*
   *
   * Here we map the dual-ported memory
   *
   */
  
  reg [8:0] s_ramCiAddressReg;
  wire s_ramCiWriteEnable;
  
  dualPortSSRAM #( .bitwidth(32),
                   .nrOfEntries(512)) memory
                 ( .clockA(clock), 
                   .clockB(~clock),
                   .writeEnableA(s_isSramWrite), 
                   .writeEnableB(s_ramCiWriteEnable),
                   .addressA(valueA[8:0]), 
                   .addressB(s_ramCiAddressReg),
                   .dataInA(valueB), 
                   .dataInB(s_addressDataInReg),
                   .dataOutA(s_sramDataValue), 
                   .dataOutB());
  

  /*
   *
   * Here we define the dma-state-machine
   *
   */
  localparam [2:0] IDLE = 3'd0;
  localparam [2:0] INIT = 3'd1;
  localparam [2:0] REQUEST_BUS = 3'd2;
  localparam [2:0] SET_UP_TRANSACTION = 3'd3;
  localparam [2:0] DO_READ = 3'd4;
  localparam [2:0] WAIT_END = 3'd5;
  
  reg [2:0] s_dmaCurrentStateReg, s_dmaNextState;
  reg       s_busErrorReg;
  
  // a dma action is requested by the ci:
  wire s_requestDmaIn = (valueA[12:9] == 4'b1011) ? s_isMyCi & valueB[0] : 1'b0;
  wire s_dmaIsBusy = (s_dmaCurrentStateReg == IDLE) ? 1'b0 : 1'b1;
  wire s_dmaDone;
  
  // here we define the next state
  always @*
    case (s_dmaCurrentStateReg)
      IDLE               : s_dmaNextState <= (s_requestDmaIn == 1'b1) ? INIT : IDLE;
      INIT               : s_dmaNextState <= REQUEST_BUS;
      REQUEST_BUS        : s_dmaNextState <= (transactionGranted == 1'b1) ? SET_UP_TRANSACTION : REQUEST_BUS;
      SET_UP_TRANSACTION : s_dmaNextState <= DO_READ;
      DO_READ            : s_dmaNextState <= (busErrorIn == 1'b1) ? WAIT_END:
                                             (s_endTransactionInReg == 1'b1 && s_dmaDone == 1'b1) ? IDLE :
                                             (s_endTransactionInReg == 1'b1) ? REQUEST_BUS : DO_READ;
      WAIT_END           : s_dmaNextState <= (s_endTransactionInReg == 1'b1) ? IDLE : WAIT_END;
      default            : s_dmaNextState <= IDLE;
    endcase
  
  always @(posedge clock)
    begin
      s_dmaCurrentStateReg <= (reset == 1'b1) ? IDLE : s_dmaNextState;
      s_busErrorReg        <= (reset == 1'b1 || s_dmaCurrentStateReg == INIT) ? 1'b0 :
                              (s_dmaCurrentStateReg == WAIT_END) ? 1'b1 : s_busErrorReg;
    end

  /*
   *
   * Here we define the shadow registers used by the dma-controller
   *
   */
  reg[31:0] s_busStartAddressShadowReg;
  reg[9:0]  s_blockSizeShadowReg;
  
  /* the second condition is the special case where the end of transaction collides with the last data valid in */
  assign s_dmaDone = (s_blockSizeShadowReg == 10'd0 ||
                      (s_blockSizeShadowReg == 10'd1 && s_endTransactionInReg == 1'b1 && s_dataValidInReg == 1'b1)) ? 1'b1 : 1'b0;
  assign s_ramCiWriteEnable = (s_dmaCurrentStateReg == DO_READ) ? s_dataValidInReg : 1'b0;
  
  always @(posedge clock)
    begin
      s_busStartAddressShadowReg <= (s_dmaCurrentStateReg == INIT) ? s_busStartAddressReg :
                                    (s_ramCiWriteEnable == 1'b1) ? s_busStartAddressShadowReg + 32'd4 : s_busStartAddressShadowReg;
      s_blockSizeShadowReg       <= (s_dmaCurrentStateReg == INIT) ? s_blockSizeReg :
                                    (s_ramCiWriteEnable == 1'b1) ? s_blockSizeShadowReg - 10'd1 : s_blockSizeShadowReg;
      s_ramCiAddressReg          <= (s_dmaCurrentStateReg == INIT) ? s_memoryStartAddressReg :
                                    (s_ramCiWriteEnable == 1'b1) ? s_ramCiAddressReg + 9'd1 : s_ramCiAddressReg;
    end
  
  /*
   *
   * Here we define the bus-out signals
   *
   */
  wire [9:0] s_maxBurstSize = {2'd0,s_usedBurstSizeReg} + 10'd1;
  wire [9:0] s_restingBlockSize = s_blockSizeShadowReg - 10'd1;
  wire [7:0] s_usedBurstSize = (s_blockSizeShadowReg > s_maxBurstSize) ? s_usedBurstSizeReg : s_restingBlockSize[7:0];
  
  assign requestTransaction = (s_dmaCurrentStateReg == REQUEST_BUS) ? 1'd1 : 1'd0;
  
  always @(posedge clock)
    begin
      beginTransactionOut <= (s_dmaCurrentStateReg == SET_UP_TRANSACTION) ? 1'b1 : 1'b0;
      readNotWriteOut     <= (s_dmaCurrentStateReg == SET_UP_TRANSACTION) ? 1'b1 : 1'b0;
      byteEnablesOut      <= (s_dmaCurrentStateReg == SET_UP_TRANSACTION) ? 4'hF : 4'd0;
      burstSizeOut        <= (s_dmaCurrentStateReg == SET_UP_TRANSACTION) ? s_usedBurstSize : 8'd0;
      addressDataOut      <= (s_dmaCurrentStateReg == SET_UP_TRANSACTION) ? {s_busStartAddressShadowReg[31:2],2'd0} : 32'd0;
    end

  /*
   *
   * Here we define the result value
   *
   */
  reg[31:0] s_result;
  
  always @*
    case (valueA[12:10])
      3'b000    : s_result <= s_sramDataValue;
      3'b001    : s_result <= s_busStartAddressReg;
      3'b010    : s_result <= {23'd0,s_memoryStartAddressReg};
      3'b011    : s_result <= {22'd0,s_blockSizeReg};
      3'b100    : s_result <= {24'd0,s_usedBurstSizeReg};
      3'b101    : s_result <= {30'd0,s_busErrorReg,s_dmaIsBusy};
      default   : s_result <= 32'd0;
    endcase
  
  assign result = (s_isSramReadReg == 1'b1) ? s_result : 32'd0;

endmodule
