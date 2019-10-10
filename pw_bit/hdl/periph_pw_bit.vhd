library ieee;
use ieee.std_logic_1164.all;

entity periph_pw_bit is
    generic (
        AXI_ID_WIDTH   : integer := 1;
        AXI_DATA_WIDTH : integer := 32;
        AXI_ADDR_WIDTH : integer := 8;

        NUM_OUTPUTS : integer := 4
    );
    port (
        txd : out std_logic_vector(NUM_OUTPUTS-1 downto 0);

        s_axi_awid    : in  std_logic_vector(AXI_ID_WIDTH-1 downto 0);
        s_axi_awaddr  : in  std_logic_vector(AXI_ADDR_WIDTH-1 downto 0);
        s_axi_awprot  : in  std_logic_vector(2 downto 0);
        s_axi_awvalid : in  std_logic;
        s_axi_awready : out std_logic;

        s_axi_wdata   : in  std_logic_vector(AXI_DATA_WIDTH-1 downto 0);
        s_axi_wstrb   : in  std_logic_vector(AXI_DATA_WIDTH/8-1 downto 0);
        s_axi_wvalid  : in  std_logic;
        s_axi_wready  : out std_logic;

        s_axi_bid     : out std_logic_vector(AXI_ID_WIDTH-1 downto 0);
        s_axi_bresp   : out std_logic_vector(1 downto 0);
        s_axi_bvalid  : out std_logic;
        s_axi_bready  : in  std_logic;

        s_axi_arid    : in  std_logic_vector(AXI_ID_WIDTH-1 downto 0);
        s_axi_araddr  : in  std_logic_vector(AXI_ADDR_WIDTH-1 downto 0);
        s_axi_arprot  : in  std_logic_vector(2 downto 0);
        s_axi_arvalid : in  std_logic;
        s_axi_arready : out std_logic;

        s_axi_rid     : out std_logic_vector(AXI_ID_WIDTH-1 downto 0);
        s_axi_rdata   : out std_logic_vector(AXI_DATA_WIDTH-1 downto 0);
        s_axi_rresp   : out std_logic_vector(1 downto 0);
        s_axi_rvalid  : out std_logic;
        s_axi_rready  : in  std_logic;

        aclk    : in std_logic;
        aresetn : in std_logic
    );
end periph_pw_bit;

architecture arch of periph_pw_bit is
    component axi_pw_bit is
        generic (
            AXI_ID_WIDTH   : integer := 1;
            AXI_DATA_WIDTH : integer := 32;
            AXI_ADDR_WIDTH : integer := 8;

            NUM_OUTPUTS : integer := 4
        );
        port (
            txd : out std_logic_vector(NUM_OUTPUTS-1 downto 0);

            s_axi_awid    : in  std_logic_vector(AXI_ID_WIDTH-1 downto 0);
            s_axi_awaddr  : in  std_logic_vector(AXI_ADDR_WIDTH-1 downto 0);
            s_axi_awprot  : in  std_logic_vector(2 downto 0);
            s_axi_awvalid : in  std_logic;
            s_axi_awready : out std_logic;

            s_axi_wdata   : in  std_logic_vector(AXI_DATA_WIDTH-1 downto 0);
            s_axi_wstrb   : in  std_logic_vector(AXI_DATA_WIDTH/8-1 downto 0);
            s_axi_wvalid  : in  std_logic;
            s_axi_wready  : out std_logic;

            s_axi_bid     : out std_logic_vector(AXI_ID_WIDTH-1 downto 0);
            s_axi_bresp   : out std_logic_vector(1 downto 0);
            s_axi_bvalid  : out std_logic;
            s_axi_bready  : in  std_logic;

            s_axi_arid    : in  std_logic_vector(AXI_ID_WIDTH-1 downto 0);
            s_axi_araddr  : in  std_logic_vector(AXI_ADDR_WIDTH-1 downto 0);
            s_axi_arprot  : in  std_logic_vector(2 downto 0);
            s_axi_arvalid : in  std_logic;
            s_axi_arready : out std_logic;

            s_axi_rid     : out std_logic_vector(AXI_ID_WIDTH-1 downto 0);
            s_axi_rdata   : out std_logic_vector(AXI_DATA_WIDTH-1 downto 0);
            s_axi_rresp   : out std_logic_vector(1 downto 0);
            s_axi_rvalid  : out std_logic;
            s_axi_rready  : in  std_logic;

            aclk    : in std_logic;
            aresetn : in std_logic
        );
    end component;
begin
    axi_pwm_inst : axi_pw_bit
    generic map (
        AXI_ID_WIDTH   => AXI_ID_WIDTH  ,
        AXI_DATA_WIDTH => AXI_DATA_WIDTH,
        AXI_ADDR_WIDTH => AXI_ADDR_WIDTH,

        NUM_OUTPUTS => NUM_OUTPUTS
    ) port map (
        txd => txd,

        s_axi_awid    => s_axi_awid   ,
        s_axi_awaddr  => s_axi_awaddr ,
        s_axi_awprot  => s_axi_awprot ,
        s_axi_awvalid => s_axi_awvalid,
        s_axi_awready => s_axi_awready,

        s_axi_wdata   => s_axi_wdata  ,
        s_axi_wstrb   => s_axi_wstrb  ,
        s_axi_wvalid  => s_axi_wvalid ,
        s_axi_wready  => s_axi_wready ,

        s_axi_bid     => s_axi_bid    ,
        s_axi_bresp   => s_axi_bresp  ,
        s_axi_bvalid  => s_axi_bvalid ,
        s_axi_bready  => s_axi_bready ,

        s_axi_arid    => s_axi_arid   ,
        s_axi_araddr  => s_axi_araddr ,
        s_axi_arprot  => s_axi_arprot ,
        s_axi_arvalid => s_axi_arvalid,
        s_axi_arready => s_axi_arready,

        s_axi_rid     => s_axi_rid    ,
        s_axi_rdata   => s_axi_rdata  ,
        s_axi_rresp   => s_axi_rresp  ,
        s_axi_rvalid  => s_axi_rvalid ,
        s_axi_rready  => s_axi_rready ,

        aclk    => aclk   ,
        aresetn => aresetn
    );
end arch;
