library ieee;
use ieee.std_logic_1164.all;
use IEEE.NUMERIC_STD.ALL;

entity memory is
    generic (
        data_width: integer := 8
    );
    port (
        clk, rd, wr : in std_logic;
        a : in natural range 0 to 65535;
        d_in : in std_logic_vector(data_width-1 downto 0);
        d_out : out std_logic_vector(data_width-1 downto 0)
    );
end memory;

architecture memory of memory is
    type memory is array (0 to 65535) of std_logic_vector(data_width-1 downto 0);
    signal mem : memory;
begin
    d_out <= mem(a) when rd else (others => '0');
    read : process(clk) is
        begin
            if rising_edge(clk) then
                if wr then
                    mem(a) <= d_in;
                end if;
            end if;
        end process;

end memory;
