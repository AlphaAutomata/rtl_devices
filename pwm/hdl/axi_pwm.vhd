library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity axi_pwm is
	generic (
		AXI_ID_WIDTH   : integer := 1;
		AXI_DATA_WIDTH : integer := 32;
		AXI_ADDR_WIDTH : integer := 8;
		
		NUM_OUTPUTS : integer := 4
	);
	port (
		pwm : out std_logic_vector(NUM_OUTPUTS-1 downto 0);
		
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
end axi_pwm;

architecture arch of axi_pwm is
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
	
	--------------------
	-- Register Banks --
	--------------------
	
	type reg_bank is array (
		2*(NUM_OUTPUTS+2)-1 downto 0
	) of std_logic_vector(
		AXI_DATA_WIDTH-1 downto 0
	);
	
	signal regs      : reg_bank;
	signal regs_next : reg_bank;
	
	constant AXADDR_REG_JUSTFY_BITS : integer := integer(ceil(log2(real(AXI_DATA_WIDTH/8))));
	
	signal reg_index_from_araddr     : integer;
	signal reg_index_from_awaddr_reg : integer;
	
	signal cfg_count_up_down : std_logic;
	signal cfg_polarity      : std_logic_vector(AXI_DATA_WIDTH-1 downto 0);
	signal cfg_period        : std_logic_vector(AXI_DATA_WIDTH-1 downto 0);
	
	------------------------
	-- PWM Period Counter --
	------------------------
	
	signal up_ndown      : boolean;
	signal up_ndown_next : boolean;
	
	signal counter      : std_logic_vector(AXI_DATA_WIDTH-1 downto 0);
	signal counter_next : std_logic_vector(AXI_DATA_WIDTH-1 downto 0);
	
	signal counter_plus_period  : std_logic_vector(AXI_DATA_WIDTH-1 downto 0);
	signal counter_minus_period : std_logic_vector(AXI_DATA_WIDTH-1 downto 0);
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
								(8*(i+1)-1 downto 8*i)      <= s_axi_wdata(8*(i+1)-1 downto 8*i);
						end if;
					end loop;
					
					s_axi_wready_next <= '0';
					
					s_axi_bid_next    <= s_axi_awid_reg;
					if (reg_index_from_awaddr_reg < 2*(NUM_OUTPUTS+2)) then
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
					if (reg_index_from_araddr < 2*(NUM_OUTPUTS+2)) then
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
	-- PWM Period Counter --
	------------------------
	
	cfg_count_up_down <= regs(0)(1);
	cfg_period        <= regs(1);
	cfg_polarity      <= regs(2);
	
	counter_plus_period  <= std_logic_vector(signed(counter) + signed(cfg_period));
	counter_minus_period <= std_logic_vector(signed(counter) - signed(cfg_period));
	
	process (
		up_ndown,
		cfg_count_up_down,
		cfg_period,
		counter
	) begin
		up_ndown_next <= up_ndown;
		
		if (cfg_count_up_down = '1') then
			if (signed(counter) <= 0) then
				up_ndown_next <= true;
			elsif (signed(counter) >= signed(cfg_period)/2) then
				up_ndown_next <= false;
			end if;
			
			case (up_ndown) is
				when true  => counter_next <= std_logic_vector(signed(counter) + 1);
				when false => counter_next <= std_logic_vector(signed(counter) - 1);
			end case;
		else
			if (signed(counter) >= signed(cfg_period)-1) then
				counter_next <= (others => '0');
			else
				counter_next <= std_logic_vector(signed(counter) + 1);
			end if;
		end if;
	end process;
	
	process (aclk) begin
		if (rising_edge(aclk)) then
			if (aresetn = '0') then
				up_ndown <= true;
				counter  <= (others => '0');
			else
				up_ndown <= up_ndown_next;
				counter  <= counter_next;
			end if;
		end if;
	end process;
	
	------------------------
	-- PWM Cell Instances --
	------------------------
	
	GEN_CELLS : for i in 0 to NUM_OUTPUTS-1 generate
		constant duty_reg_addr  : integer := 2*(i+2);
		constant pahse_reg_addr : integer := 2*(i+2)+1;
		
		component pwm_cell is
			generic (
				COUNTER_WIDTH : integer := 32
			);
			port (
				pwm : out std_logic;
				
				counter              : in std_logic_vector(COUNTER_WIDTH-1 downto 0);
				counter_plus_period  : in std_logic_vector(COUNTER_WIDTH-1 downto 0);
				counter_minus_period : in std_logic_vector(COUNTER_WIDTH-1 downto 0);
				
				count_up_down : in std_logic;
				polarity      : in std_logic;
				
				duty  : in std_logic_vector(COUNTER_WIDTH-1 downto 0);
				phase : in std_logic_vector(COUNTER_WIDTH-1 downto 0)
			);
		end component;
	begin
		cell : pwm_cell
		generic map (
			COUNTER_WIDTH => AXI_DATA_WIDTH
		) port map (
			pwm => pwm(i),
			
			counter              => counter             ,
			counter_plus_period  => counter_plus_period ,
			counter_minus_period => counter_minus_period,
			
			count_up_down => cfg_count_up_down,
			polarity      => cfg_polarity(i),
			
			duty  => regs(duty_reg_addr ),
			phase => regs(pahse_reg_addr)
		);
	end generate GEN_CELLS;
end arch;
