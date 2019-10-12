`timescale 1ns /1ps

module axi_pw_bit_tb();
    localparam AXI_ID_WIDTH   = 1;
    localparam AXI_DATA_WIDTH = 32;
    localparam AXI_ADDR_WIDTH = 8;
    
    localparam NUM_OUTPUTS    = 4;
    
    localparam [31:0][AXI_DATA_WIDTH-1:0] regs_values = {
        32'd1  ,
        32'd40 ,
        32'd80 ,
        32'd125,
        32'd0  ,
        32'd0  ,
        32'h00000007,
        32'd0  ,
        32'd1  ,
        32'd40 ,
        32'd80 ,
        32'd125,
        32'd0  ,
        32'd0  ,
        32'h00000007,
        32'd0  ,
        32'd1  ,
        32'd40 ,
        32'd80 ,
        32'd125,
        32'd0  ,
        32'd0  ,
        32'h00000007,
        32'd0  ,
        32'd1  ,
        32'd40 ,
        32'd80 ,
        32'd125,
        32'd0  ,
        32'd0  ,
        32'h00000007,
        32'd0  
    };
    
    reg [31:0][AXI_DATA_WIDTH-1:0] regs;

    integer write_cntdwn;

    integer reg_number;
    
    wire [NUM_OUTPUTS-1:0]      txd          ;
    
    reg  [AXI_ID_WIDTH-1:0]     s_axi_awid   ;
    reg  [AXI_ADDR_WIDTH-1:0]   s_axi_awaddr ;
    reg  [2:0]                  s_axi_awprot ;
    reg                         s_axi_awvalid;
    wire                        s_axi_awready;
    
    reg  [AXI_DATA_WIDTH-1:0]   s_axi_wdata  ;
    reg  [AXI_DATA_WIDTH/8-1:0] s_axi_wstrb  ;
    reg                         s_axi_wvalid ;
    wire                        s_axi_wready ;
    
    wire [AXI_ID_WIDTH-1:0]     s_axi_bid    ;
    wire [1:0]                  s_axi_bresp  ;
    wire                        s_axi_bvalid ;
    reg                         s_axi_bready ;
    
    reg  [AXI_ID_WIDTH-1:0]     s_axi_arid   ;
    reg  [AXI_ADDR_WIDTH-1:0]   s_axi_araddr ;
    reg  [2:0]                  s_axi_arprot ;
    reg                         s_axi_arvalid;
    wire                        s_axi_arready;
    
    wire [AXI_ID_WIDTH-1:0]     s_axi_rid    ;
    wire [AXI_DATA_WIDTH-1:0]   s_axi_rdata  ;
    wire [1:0]                  s_axi_rresp  ;
    wire                        s_axi_rvalid ;
    reg                         s_axi_rready ;
    
    reg                         aclk         ;
    reg                         aresetn      ;
    
    axi_pw_bit #(
        .AXI_ID_WIDTH  (AXI_ID_WIDTH  ), // : integer := 1;
        .AXI_DATA_WIDTH(AXI_DATA_WIDTH), // : integer := 32;
        .AXI_ADDR_WIDTH(AXI_ADDR_WIDTH), // : integer := 8;
                        
        .NUM_OUTPUTS   (NUM_OUTPUTS   )  // : integer := 4
    ) dut (
        .txd          (txd          ), // : out std_logic_vector(NUM_OUTPUTS-1 downto 0);
                       
        .s_axi_awid   (s_axi_awid   ), // : in  std_logic_vector(AXI_ID_WIDTH-1 downto 0);
        .s_axi_awaddr (s_axi_awaddr ), // : in  std_logic_vector(AXI_ADDR_WIDTH-1 downto 0);
        .s_axi_awprot (s_axi_awprot ), // : in  std_logic_vector(2 downto 0);
        .s_axi_awvalid(s_axi_awvalid), // : in  std_logic;
        .s_axi_awready(s_axi_awready), // : out std_logic;
                       
        .s_axi_wdata  (s_axi_wdata  ), // : in  std_logic_vector(AXI_DATA_WIDTH-1 downto 0);
        .s_axi_wstrb  (s_axi_wstrb  ), // : in  std_logic_vector(AXI_DATA_WIDTH/8-1 downto 0);
        .s_axi_wvalid (s_axi_wvalid ), // : in  std_logic;
        .s_axi_wready (s_axi_wready ), // : out std_logic;
                       
        .s_axi_bid    (s_axi_bid    ), // : out std_logic_vector(AXI_ID_WIDTH-1 downto 0);
        .s_axi_bresp  (s_axi_bresp  ), // : out std_logic_vector(1 downto 0);
        .s_axi_bvalid (s_axi_bvalid ), // : out std_logic;
        .s_axi_bready (s_axi_bready ), // : in  std_logic;
                       
        .s_axi_arid   (s_axi_arid   ), // : in  std_logic_vector(AXI_ID_WIDTH-1 downto 0);
        .s_axi_araddr (s_axi_araddr ), // : in  std_logic_vector(AXI_ADDR_WIDTH-1 downto 0);
        .s_axi_arprot (s_axi_arprot ), // : in  std_logic_vector(2 downto 0);
        .s_axi_arvalid(s_axi_arvalid), // : in  std_logic;
        .s_axi_arready(s_axi_arready), // : out std_logic;
                       
        .s_axi_rid    (s_axi_rid    ), // : out std_logic_vector(AXI_ID_WIDTH-1 downto 0);
        .s_axi_rdata  (s_axi_rdata  ), // : out std_logic_vector(AXI_DATA_WIDTH-1 downto 0);
        .s_axi_rresp  (s_axi_rresp  ), // : out std_logic_vector(1 downto 0);
        .s_axi_rvalid (s_axi_rvalid ), // : out std_logic;
        .s_axi_rready (s_axi_rready ), // : in  std_logic;
                       
        .aclk         (aclk         ), // : in std_logic;
        .aresetn      (aresetn      )  // : in std_logic
    );
    
    initial begin
        regs <= regs_values;

        write_cntdwn <= 300;

        s_axi_awid    <= 0;
        s_axi_awaddr  <= 0;
        s_axi_awprot  <= 0;
        s_axi_awvalid <= 0;
        
        s_axi_wdata   <= 0;
        s_axi_wstrb   <= -1;
        s_axi_wvalid  <= 0;
        
        s_axi_bready  <= 1;
        
        s_axi_arid    <= 0;
        s_axi_araddr  <= 0;
        s_axi_arprot  <= 0;
        s_axi_arvalid <= 0;
        
        s_axi_rready  <= 0;
        
        reg_number    <= -1;
        
        aclk          <= 1;
        aresetn       <= 0;
        
        #200;
        
        aresetn       <= 1;
    end
    
    always #5 aclk <= !aclk;
    
    always @(posedge(aclk)) begin
        if (aresetn == 1) begin
            if (write_cntdwn == 0) begin
                write_cntdwn <= 2000;
                reg_number   <= 31;
                regs[0]      <= regs[0] + 1;
                regs[8]      <= regs[8] + 1;
                regs[16]     <= regs[16] + 1;
                regs[24]     <= regs[24] + 1;
            end else begin
                write_cntdwn <= write_cntdwn - 1;
            end

            if (reg_number >= 0 && s_axi_awvalid == 0) begin
                reg_number    <= reg_number - 1;
                s_axi_awvalid <= 1;
                s_axi_awaddr  <= 4*reg_number;
                s_axi_wdata   <= regs[reg_number];
            end

            if (s_axi_awvalid == 1 && s_axi_awready == 1) begin
                s_axi_awvalid <= 0;
                s_axi_wvalid  <= 1;
            end

            if (s_axi_wvalid == 1 && s_axi_wready == 1) begin
                s_axi_wvalid <= 0;
            end
        end
    end
endmodule
