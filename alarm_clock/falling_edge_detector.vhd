library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_unsigned.all;
USE IEEE.NUMERIC_STD.ALL;
use IEEE.math_real.all;

entity falling_edge_detector is
    generic (
        PORT_WIDTH : INTEGER range 1 to (INTEGER'high) := 5
    );
    port (
        clk: in STD_LOGIC;
        SIGNAL_IN: in STD_LOGIC_VECTOR ((PORT_WIDTH - 1) downto 0);
        SIGNAL_FALL: out STD_LOGIC_VECTOR ((PORT_WIDTH - 1) downto 0)
    );
end falling_edge_detector;

architecture falling_edge_detector of falling_edge_detector is

signal SIGNAL_PREV: STD_LOGIC_VECTOR(PORT_WIDTH-1 downto 0);

begin

    detect: process (clk) is
    begin
        if rising_edge(clk) then
            SIGNAL_PREV <= SIGNAL_IN;
            SIGNAL_FALL <= (others => '0');
            for index in 0 to (PORT_WIDTH - 1) loop
                if SIGNAL_PREV(index) = '1' and SIGNAL_IN(index) = '0' then
                    SIGNAL_FALL(index) <= '1';
                --else SIGNAL_FALL(index) <= '0';
                end if;
            end loop;
        end if;
    end process detect;

end falling_edge_detector;
