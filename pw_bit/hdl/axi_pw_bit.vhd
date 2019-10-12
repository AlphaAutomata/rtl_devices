library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

library unisim;
use unisim.vcomponents.all;
library unimacro;
use unimacro.vcomponents.all;

entity axi_pw_bit is
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
end axi_pw_bit;

architecture arch of axi_pw_bit is
    ---------------------
    -- Input Registers --
    ---------------------
    
    signal s_axi_awid_reg    : std_logic_vector(AXI_ID_WIDTH-1 downto 0);
    signal s_axi_awaddr_reg  : std_logic_vector(AXI_ADDR_WIDTH-1 downto 0);
    signal s_axi_awprot_reg  : std_logic_vector(2 downto 0);
    signal s_axi_awvalid_reg : std_logic;
    
    signal s_axi_awid_reg_next    : std_logic_vector(AXI_ID_WIDTH-1 downto 0);
    signal s_axi_awaddr_reg_next  : std_logic_vector(AXI_ADDR_WIDTH-1 downto 0);
    signal s_axi_awprot_reg_next  : std_logic_vector(2 downto 0);
    signal s_axi_awvalid_reg_next : std_logic;
    
    ----------------------
    -- Output Registers --
    ----------------------
    
    signal s_axi_awready_next : std_logic;
    
    signal s_axi_wready_next  : std_logic;
    
    signal s_axi_bid_next     : std_logic_vector(AXI_ID_WIDTH-1 downto 0);
    signal s_axi_bresp_next   : std_logic_vector(1 downto 0);
    signal s_axi_bvalid_next  : std_logic;
    
    signal s_axi_arready_next : std_logic;
    
    signal s_axi_rid_next     : std_logic_vector(AXI_ID_WIDTH-1 downto 0);
    signal s_axi_rdata_next   : std_logic_vector(AXI_DATA_WIDTH-1 downto 0);
    signal s_axi_rresp_next   : std_logic_vector(1 downto 0);
    signal s_axi_rvalid_next  : std_logic;
    
    ---------------------
    -- AXI-4 constants --
    ---------------------
    
    constant AXI4_BURST_SZ001 : std_logic_vector(2 downto 0) := "000";
    constant AXI4_BURST_SZ002 : std_logic_vector(2 downto 0) := "001";
    constant AXI4_BURST_SZ004 : std_logic_vector(2 downto 0) := "010";
    constant AXI4_BURST_SZ008 : std_logic_vector(2 downto 0) := "011";
    constant AXI4_BURST_SZ016 : std_logic_vector(2 downto 0) := "100";
    constant AXI4_BURST_SZ032 : std_logic_vector(2 downto 0) := "101";
    constant AXI4_BURST_SZ064 : std_logic_vector(2 downto 0) := "110";
    constant AXI4_BURST_SZ128 : std_logic_vector(2 downto 0) := "111";
    
    constant AXI4_BURST_FIXED : std_logic_vector(1 downto 0) := "00";
    constant AXI4_BURST_INCRE : std_logic_vector(1 downto 0) := "01";
    constant AXI4_BURST_WRAPA : std_logic_vector(1 downto 0) := "10";
    
    constant AXI4_LOCK_NORMAL : std_logic_vector(0 downto 0) := "0";
    constant AXI4_LOCK_EXCLUS : std_logic_vector(0 downto 0) := "1";
    
    constant AXI4_CACH_ALLOCW : std_logic_vector(3 downto 0) := "1000";
    constant AXI4_CACH_OTHRAR : std_logic_vector(3 downto 0) := "1000";
    constant AXI4_CACH_ALLOCR : std_logic_vector(3 downto 0) := "0100";
    constant AXI4_CACH_OTHRAW : std_logic_vector(3 downto 0) := "0100";
    constant AXI4_CACH_MODFBL : std_logic_vector(3 downto 0) := "0010";
    constant AXI4_CACH_BFFRBL : std_logic_vector(3 downto 0) := "0001";
    
    constant AXI4_PROT_PRVLGE : std_logic_vector(2 downto 0) := "001";
    constant AXI4_PROT_SECURE : std_logic_vector(2 downto 0) := "010";
    constant AXI4_PROT_INSTRU : std_logic_vector(2 downto 0) := "100";
    
    constant AXI4_RESP_NMOKAY : std_logic_vector(1 downto 0) := "00";
    constant AXI4_RESP_EXOKAY : std_logic_vector(1 downto 0) := "01";
    constant AXI4_RESP_SLVERR : std_logic_vector(1 downto 0) := "10";
    constant AXI4_RESP_DECERR : std_logic_vector(1 downto 0) := "11";
    
    -----------------------
    -- AXI State Keeping --
    -----------------------
    
    type axi_wr_state is (idle, writing, responding);
    
    signal wr_state      : axi_wr_state;
    signal wr_state_next : axi_wr_state;
    
    type axi_rd_state is (idle, reading);
    
    signal rd_state      : axi_rd_state;
    signal rd_state_next : axi_rd_state;
    
    ---------------------
    -- Register Access --
    ---------------------

    constant NUM_REGS : integer := 8*NUM_OUTPUTS;

    type reg_bank is array (
        NUM_REGS-1 downto 0
    ) of std_logic_vector(
        AXI_DATA_WIDTH-1 downto 0
    );
    
    signal regs      : reg_bank;
    signal regs_next : reg_bank;
    
    constant AXADDR_REG_JUSTFY_BITS : integer := integer(ceil(log2(real(AXI_DATA_WIDTH/8))));
    
    signal reg_index_from_araddr     : integer;
    signal reg_index_from_awaddr_reg : integer;
begin
    --------------------------
    -- AXI-4 Lite Registers --
    --------------------------
    
    reg_index_from_araddr <=
        to_integer(
            unsigned(s_axi_araddr(AXI_ADDR_WIDTH-1 downto AXADDR_REG_JUSTFY_BITS))
        );
    reg_index_from_awaddr_reg <=
        to_integer(
            unsigned(s_axi_awaddr_reg(AXI_ADDR_WIDTH-1 downto AXADDR_REG_JUSTFY_BITS))
        );
    
    process (
        s_axi_awid   ,
        s_axi_awaddr ,
        s_axi_awprot ,
        s_axi_awvalid,
        s_axi_wdata ,
        s_axi_wstrb ,
        s_axi_wvalid,
        s_axi_bready,
        s_axi_arvalid,
        s_axi_arid   ,
        s_axi_arprot ,
        s_axi_awid_reg   ,
        s_axi_awaddr_reg ,
        s_axi_awprot_reg ,
        s_axi_awvalid_reg,
        s_axi_awready    ,
        s_axi_wready     ,
        s_axi_bid        ,
        s_axi_bresp      ,
        s_axi_bvalid     ,
        s_axi_arready    ,
        s_axi_rid        ,
        s_axi_rdata      ,
        s_axi_rresp      ,
        s_axi_rvalid     ,
        s_axi_rready     ,
        wr_state         ,
        rd_state         ,
        regs             ,
        reg_index_from_awaddr_reg,
        reg_index_from_araddr
    ) begin
        s_axi_awid_reg_next    <= s_axi_awid_reg   ;
        s_axi_awaddr_reg_next  <= s_axi_awaddr_reg ;
        s_axi_awprot_reg_next  <= s_axi_awprot_reg ;
        s_axi_awvalid_reg_next <= s_axi_awvalid_reg;
        s_axi_awready_next     <= s_axi_awready    ;
        s_axi_wready_next      <= s_axi_wready     ;
        s_axi_bid_next         <= s_axi_bid        ;
        s_axi_bresp_next       <= s_axi_bresp      ;
        s_axi_bvalid_next      <= s_axi_bvalid     ;
        s_axi_arready_next     <= s_axi_arready    ;
        s_axi_rid_next         <= s_axi_rid        ;
        s_axi_rdata_next       <= s_axi_rdata      ;
        s_axi_rresp_next       <= s_axi_rresp      ;
        s_axi_rvalid_next      <= s_axi_rvalid     ;
        wr_state_next          <= wr_state         ;
        rd_state_next          <= rd_state         ;
        regs_next              <= regs             ;
        
        case (wr_state) is
            when idle =>
                if (s_axi_awvalid = '1') then
                    wr_state_next <= writing;
                    
                    s_axi_awid_reg_next    <= s_axi_awid   ;
                    s_axi_awaddr_reg_next  <= s_axi_awaddr ;
                    s_axi_awprot_reg_next  <= s_axi_awprot ;
                    s_axi_awvalid_reg_next <= s_axi_awvalid;
                    
                    s_axi_awready_next     <= '0';
                    
                    s_axi_wready_next      <= '1';
                end if;
                
            when writing =>
                if (s_axi_wvalid = '1') then
                    wr_state_next <= responding;
                    
                    for i in 0 to AXI_DATA_WIDTH/8-1 loop
                        if (s_axi_wstrb(i) = '1') then
                            regs_next
                                (reg_index_from_awaddr_reg)
                                (8*(i+1)-1 downto 8*i) <= s_axi_wdata(8*(i+1)-1 downto 8*i);
                        end if;
                    end loop;
                    
                    s_axi_wready_next <= '0';
                    
                    s_axi_bid_next    <= s_axi_awid_reg;
                    if (reg_index_from_awaddr_reg < NUM_REGS) then
                        s_axi_rresp_next <= AXI4_RESP_NMOKAY;
                    else
                        s_axi_rresp_next <= AXI4_RESP_SLVERR;
                    end if;
                    s_axi_bvalid_next <= '1';
                end if;
                
            when responding =>
                if (s_axi_bready = '1') then
                    wr_state_next <= idle;
                    
                    s_axi_awready_next <= '1';
                    s_axi_bvalid_next  <= '0';
                end if;
                
        end case;
        
        case (rd_state) is
            when idle =>
                if (s_axi_arvalid = '1') then
                    rd_state_next <= reading;
                    
                    s_axi_arready_next <= '0';
                    
                    s_axi_rid_next     <= s_axi_arid;
                    s_axi_rdata_next   <= regs(reg_index_from_araddr);
                    if (reg_index_from_araddr < NUM_REGS) then
                        s_axi_rresp_next <= AXI4_RESP_NMOKAY;
                    else
                        s_axi_rresp_next <= AXI4_RESP_SLVERR;
                    end if;
                    s_axi_rvalid_next  <= '1';
                end if;
                
            when reading =>
                if (s_axi_rready = '1') then
                    rd_state_next <= idle;
                    
                    s_axi_arready_next <= '1';
                    s_axi_rvalid_next  <= '0';
                end if;
                
        end case;
    end process;
    
    process (aclk) begin
        if (rising_edge(aclk)) then
            if (aresetn = '0') then
                s_axi_awid_reg    <= (others => '0');
                s_axi_awaddr_reg  <= (others => '0');
                s_axi_awprot_reg  <= (others => '0');
                s_axi_awvalid_reg <= '0';
                s_axi_awready     <= '1';
                s_axi_wready      <= '0';
                s_axi_bid         <= (others => '0');
                s_axi_bresp       <= (others => '0');
                s_axi_bvalid      <= '0';
                s_axi_arready     <= '1';
                s_axi_rid         <= (others => '0');
                s_axi_rdata       <= (others => '0');
                s_axi_rresp       <= (others => '0');
                s_axi_rvalid      <= '0';
                wr_state          <= idle;
                rd_state          <= idle;
                regs              <= (others => (others => '0'));
            else
                s_axi_awid_reg    <= s_axi_awid_reg_next   ;
                s_axi_awaddr_reg  <= s_axi_awaddr_reg_next ;
                s_axi_awprot_reg  <= s_axi_awprot_reg_next ;
                s_axi_awvalid_reg <= s_axi_awvalid_reg_next;
                s_axi_awready     <= s_axi_awready_next    ;
                s_axi_wready      <= s_axi_wready_next     ;
                s_axi_bid         <= s_axi_bid_next        ;
                s_axi_bresp       <= s_axi_bresp_next      ;
                s_axi_bvalid      <= s_axi_bvalid_next     ;
                s_axi_arready     <= s_axi_arready_next    ;
                s_axi_rid         <= s_axi_rid_next        ;
                s_axi_rdata       <= s_axi_rdata_next      ;
                s_axi_rresp       <= s_axi_rresp_next      ;
                s_axi_rvalid      <= s_axi_rvalid_next     ;
                wr_state          <= wr_state_next         ;
                rd_state          <= rd_state_next         ;
                regs              <= regs_next             ;
            end if;
        end if;
    end process;

    ------------------------
    -- PWM Cell Instances --
    ------------------------
    
    GEN_CELLS : for i in 0 to NUM_OUTPUTS-1 generate
        constant data_reg_addr       : integer := 8*i;
        constant data_bmask_reg_addr : integer := 8*i+1;
        constant period_reg_addr     : integer := 8*i+4;
        constant duty_hi_reg_addr    : integer := 8*i+5;
        constant duty_lo_reg_addr    : integer := 8*i+6;
        constant cfg_reg_addr        : integer := 8*i+7;

        constant BMASK_NUM_BITS : integer := AXI_DATA_WIDTH/8;

        constant FIFO_DATA_WIDTH : integer := AXI_DATA_WIDTH + BMASK_NUM_BITS;

        signal cell_aresetn : std_logic;

        component pw_bit_cell is
            generic (
                COUNTER_WIDTH   : integer := 32;
                AXIS_DATA_WIDTH : integer := 8
            );
            port (
                txd : out std_logic;

                s_axis_tdata  : in  std_logic_vector(AXIS_DATA_WIDTH-1 downto 0);
                s_axis_tstrb  : in  std_logic_vector(AXIS_DATA_WIDTH/8-1 downto 0);
                s_axis_tlast  : in  std_logic;
                s_axis_tvalid : in  std_logic;
                s_axis_tready : out std_logic;

                period  : in std_logic_vector(COUNTER_WIDTH-1 downto 0);
                duty_hi : in std_logic_vector(COUNTER_WIDTH-1 downto 0);
                duty_lo : in std_logic_vector(COUNTER_WIDTH-1 downto 0);

                aclk    : in std_logic;
                aresetn : in std_logic
            );
        end component;

        signal fifo_wren : std_logic;
        signal fifo_di   : std_logic_vector(FIFO_DATA_WIDTH-1 downto 0);

        signal cell_s_axis_tdata  : std_logic_vector(AXI_DATA_WIDTH-1 downto 0);
        signal cell_s_axis_tstrb  : std_logic_vector(AXI_DATA_WIDTH/8-1 downto 0);
        signal cell_s_axis_tlast  : std_logic;
        signal cell_s_axis_tvalid : std_logic;
        signal cell_s_axis_tready : std_logic;

        signal fifo_rden  : std_logic;
        signal fifo_do    : std_logic_vector(FIFO_DATA_WIDTH-1 downto 0);
        signal fifo_empty : std_logic;
    begin
        cell_aresetn <= regs(cfg_reg_addr)(0) and aresetn;

        fifo_wren <=
            s_axi_wvalid and s_axi_wready when (reg_index_from_awaddr_reg = data_reg_addr) else
            '0';
        fifo_di <= regs(data_bmask_reg_addr)(BMASK_NUM_BITS-1 downto 0) & s_axi_wdata;

        fifo_rden <= cell_s_axis_tready and not fifo_empty;

        data_fifo : fifo_sync_macro
        generic map (
            DEVICE              => "7SERIES",       -- Target Device: "VIRTEX5, "VIRTEX6", "7SERIES"
            ALMOST_FULL_OFFSET  => X"0080",         -- Sets almost full threshold
            ALMOST_EMPTY_OFFSET => X"0080",         -- Sets the almost empty threshold
            DATA_WIDTH          => FIFO_DATA_WIDTH, -- Valid values are 1-72 (37-72 only valid when FIFO_SIZE="36Kb")
            FIFO_SIZE           => "36Kb")          -- Target BRAM, "18Kb" or "36Kb"
        port map (
            wren        => fifo_wren,       -- 1-bit input write enable
            di          => fifo_di,         -- Input data, width defined by DATA_WIDTH parameter
            almostfull  => open,            -- 1-bit output almost full
            full        => open,            -- 1-bit output full
            wrcount     => open,            -- Output write count, width determined by FIFO depth
            wrerr       => open,            -- 1-bit output write error

            rden        => fifo_rden,       -- 1-bit input read enable
            do          => fifo_do,         -- Output data, width defined by DATA_WIDTH parameter
            almostempty => open,            -- 1-bit output almost empty
            empty       => fifo_empty,      -- 1-bit output empty
            rdcount     => open,            -- Output read count, width determined by FIFO depth
            rderr       => open,            -- 1-bit output read error

            clk         => aclk,            -- 1-bit input clock
            rst         => not cell_aresetn -- 1-bit input reset
        );

        cell_s_axis_tdata  <= fifo_do(AXI_DATA_WIDTH-1 downto 0);
        cell_s_axis_tstrb  <= fifo_do(FIFO_DATA_WIDTH-1 downto FIFO_DATA_WIDTH-BMASK_NUM_BITS);
        cell_s_axis_tlast  <= '0';

        process (aclk) begin
            if (rising_edge(aclk)) then
                if (cell_aresetn = '0') then
                    cell_s_axis_tvalid <= '0';
                else
                    cell_s_axis_tvalid <= fifo_rden;
                end if;
            end if;
        end process;

        cell : pw_bit_cell
        generic map (
            COUNTER_WIDTH   => AXI_DATA_WIDTH,
            AXIS_DATA_WIDTH => AXI_DATA_WIDTH
        ) port map (
            txd => txd(i),

            s_axis_tdata  => cell_s_axis_tdata ,
            s_axis_tstrb  => cell_s_axis_tstrb ,
            s_axis_tlast  => cell_s_axis_tlast ,
            s_axis_tvalid => cell_s_axis_tvalid,
            s_axis_tready => cell_s_axis_tready,

            period  => regs(period_reg_addr ),
            duty_hi => regs(duty_hi_reg_addr),
            duty_lo => regs(duty_lo_reg_addr),

            aclk    => aclk        ,
            aresetn => cell_aresetn
        );
    end generate GEN_CELLS;
end arch;
