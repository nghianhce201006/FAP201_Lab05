library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity lab05_tb is
end entity lab05_tb;

architecture SIM of lab05_tb is
    constant CLK_PERIOD : time := 20 ns;
    constant C_SIM_LFSR_WIDTH : positive := 3;
    
    signal i_Clk      : std_logic := '0';
    signal i_Rst      : std_logic := '1';
    signal i_Switch_1 : std_logic := '0';
    signal i_Switch_2 : std_logic := '0';
    signal o_LED_1    : std_logic;
    signal o_LED_2    : std_logic;
    signal o_LED_3    : std_logic;
    signal o_LED_4    : std_logic;

    component lab05 is
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
    end component;
begin

    i_Clk <= not i_Clk after CLK_PERIOD / 2;

    DUT : lab05
        generic map (
            G_LFSR_WIDTH => C_SIM_LFSR_WIDTH
        )
        port map (
            i_Clk      => i_Clk,
            i_Rst      => i_Rst,
            i_Switch_1 => i_Switch_1,
            i_Switch_2 => i_Switch_2,
            o_LED_1    => o_LED_1,
            o_LED_2    => o_LED_2,
            o_LED_3    => o_LED_3,
            o_LED_4    => o_LED_4
        );

    STIMULUS : process
        procedure check_selection (
            constant p_Sw2       : in std_logic;
            constant p_Sw1       : in std_logic;
            constant p_LED_Index : in integer
        ) is
            variable v_Seen_Low  : boolean := false;
            variable v_Seen_High : boolean := false;
        begin
            i_Switch_2 <= p_Sw2;
            i_Switch_1 <= p_Sw1;
            wait for 1 ns;
            
            for k in 0 to 24 loop
                wait until rising_edge(i_Clk);
                wait for 1 ns;
                case p_LED_Index is
                    when 1 =>
                        assert o_LED_2 = '0' and o_LED_3 = '0' and o_LED_4 = '0'
                            report "FAIL: LED 00 error" severity error;
                        if o_LED_1 = '0' then v_Seen_Low := true; else v_Seen_High := true; end if;
                    when 2 =>
                        assert o_LED_1 = '0' and o_LED_3 = '0' and o_LED_4 = '0'
                            report "FAIL: LED 01 error" severity error;
                        if o_LED_2 = '0' then v_Seen_Low := true; else v_Seen_High := true; end if;
                    when 3 =>
                        assert o_LED_1 = '0' and o_LED_2 = '0' and o_LED_4 = '0'
                            report "FAIL: LED 10 error" severity error;
                        if o_LED_3 = '0' then v_Seen_Low := true; else v_Seen_High := true; end if;
                    when 4 =>
                        assert o_LED_1 = '0' and o_LED_2 = '0' and o_LED_3 = '0'
                            report "FAIL: LED 11 error" severity error;
                        if o_LED_4 = '0' then v_Seen_Low := true; else v_Seen_High := true; end if;
                    when others =>
                        assert false report "Error" severity failure;
                end case;
            end loop;
            
            assert v_Seen_Low and v_Seen_High
                report "FAIL: No blink" severity error;
        end procedure;
    begin
        i_Rst <= '1';
        wait for 4 * CLK_PERIOD;
        wait until rising_edge(i_Clk);
        wait for 1 ns;
        i_Rst <= '0';

        check_selection('0', '0', 1);
        check_selection('0', '1', 2);
        check_selection('1', '0', 3);
        check_selection('1', '1', 4);

        assert false report "Simulation Finish" severity failure;
        wait;
    end process;
end architecture SIM;
