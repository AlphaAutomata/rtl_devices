`timescale 1ns / 1ps

module axi_pwm_tb();
	localparam AXI_ID_WIDTH   = 1;
	localparam AXI_DATA_WIDTH = 32;
	localparam AXI_ADDR_WIDTH = 8;
	
	localparam NUM_OUTPUTS    = 4;
	
	localparam [11:0][AXI_DATA_WIDTH-1:0] regs_values = {
		32'd0  ,
		32'd150,
		32'd0  ,
		32'd250,
		32'd0  ,
		32'd350,
		32'd0  ,
		32'd450,
		32'd0  ,
		32'd0  ,
		32'd500,
		32'd0  
	};
	
	integer reg_number;
	
	wire [NUM_OUTPUTS-1:0]      pwm          ;
	
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
	
	axi_pwm #(
		.AXI_ID_WIDTH  (AXI_ID_WIDTH  ), // : integer := 1;
		.AXI_DATA_WIDTH(AXI_DATA_WIDTH), // : integer := 32;
		.AXI_ADDR_WIDTH(AXI_ADDR_WIDTH), // : integer := 8;
		                
		.NUM_OUTPUTS   (NUM_OUTPUTS   )  // : integer := 4
	) dut (
		.pwm          (pwm          ), // : out std_logic_vector(NUM_OUTPUTS-1 downto 0);
		               
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
		s_axi_awid    <= 0;
		s_axi_awaddr  <= 0;
		s_axi_awprot  <= 0;
		s_axi_awvalid <= 1;
		
		s_axi_wdata   <= 0;
		s_axi_wstrb   <= -1;
		s_axi_wvalid  <= 1;
		
		s_axi_bready  <= 1;
		
		s_axi_arid    <= 0;
		s_axi_araddr  <= 0;
		s_axi_arprot  <= 0;
		s_axi_arvalid <= 1;
		
		s_axi_rready  <= 1;
		
		reg_number    <= 0;
		
		aclk          <= 1;
		aresetn       <= 0;
		
		#20;
		
		aresetn       <= 1;
	end
	
	always #5 aclk <= !aclk;
	
	always @(posedge(aclk)) begin
		if (s_axi_awready == 1 && s_axi_awvalid == 1 && aresetn == 1) begin
			if (reg_number >= 11) begin
				reg_number <= 0;
			end else begin
				reg_number <= reg_number + 1;
			end
		end
		
		s_axi_awaddr  <= 4*reg_number;
		
		s_axi_wdata   <= regs_values[reg_number];
		
		s_axi_araddr  <= 4*reg_number;
	end
endmodule
