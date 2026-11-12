library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity lab05 is
    generic (
        G_LFSR_WIDTH : positive := 22 
    );
    port (
        i_Clk      : in  std_logic;
        i_Rst      : in  std_logic;
        i_Switch_1 : in  std_logic;
        i_Switch_2 : in  std_logic;
        o_LED_1    : out std_logic;
        o_LED_2    : out std_logic;
        o_LED_3    : out std_logic;
        o_LED_4    : out std_logic
    );
end entity lab05;

architecture RTL of lab05 is
    
    constant C_ZERO     : std_logic_vector(G_LFSR_WIDTH-1 downto 0) := (others => '0');
    signal r_LFSR       : std_logic_vector(G_LFSR_WIDTH-1 downto 0) := (others => '0');
    signal w_XNOR       : std_logic;
    signal w_LFSR_Done  : std_logic;

   
    signal r_LFSR_Toggle : std_logic := '0';
    
    
    signal w_Blink_Source : std_logic;
begin

  
    w_XNOR <= r_LFSR(G_LFSR_WIDTH-1) xnor r_LFSR(G_LFSR_WIDTH-2);

    process (i_Clk)
        variable v_Next : std_logic_vector(G_LFSR_WIDTH-1 downto 0);
    begin
        if rising_edge(i_Clk) then
           
            if i_Rst = '0' then 
                r_LFSR      <= C_ZERO;
                w_LFSR_Done <= '0';
            else
                v_Next := r_LFSR(G_LFSR_WIDTH-2 downto 0) & w_XNOR;
                r_LFSR <= v_Next;
                
                if v_Next = C_ZERO then
                    w_LFSR_Done <= '1';
                else
                    w_LFSR_Done <= '0';
                end if;
            end if;
        end if;
    end process;


    
    process (i_Clk)
    begin
        if rising_edge(i_Clk) then
            
            if i_Rst = '0' then 
                r_LFSR_Toggle <= '0';
            elsif w_LFSR_Done = '1' then
                r_LFSR_Toggle <= not r_LFSR_Toggle;
            end if;
        end if;
    end process;

    w_Blink_Source <= r_LFSR_Toggle;


    
    process (w_Blink_Source, i_Switch_1, i_Switch_2)
        variable v_Sel : std_logic_vector(1 downto 0);
    begin
      
        o_LED_1 <= '0';
        o_LED_2 <= '0';
        o_LED_3 <= '0';
        o_LED_4 <= '0';
        
        v_Sel := i_Switch_2 & i_Switch_1;
        
        case v_Sel is
            when "00" => o_LED_1 <= w_Blink_Source; 
            when "01" => o_LED_2 <= w_Blink_Source; 
            when "10" => o_LED_3 <= w_Blink_Source; 
            when "11" => o_LED_4 <= w_Blink_Source; 
            when others => null;
        end case;
    end process;

end architecture RTL;
