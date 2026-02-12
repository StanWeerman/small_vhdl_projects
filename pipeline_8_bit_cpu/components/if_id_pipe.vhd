library ieee;
use ieee.std_logic_1164.all;
use IEEE.NUMERIC_STD.ALL;

entity if_id_pipe is
    port (
        clk, rstb, en: in std_logic;
        wff_in : in std_logic;
        id_wff : out std_logic;
        if_instruction : in std_logic_vector(15 downto 0);
        id_control: out std_logic_vector(6 downto 0);
        id_r0a, id_r1a, id_r2a: out natural range 0 to 7;
        imm: out integer range 0 to 255
    );
end if_id_pipe;

architecture pipe of if_id_pipe is
begin
    process (clk, rstb) is
    begin
        if(rstb='0') then
            id_wff <= '0';
            id_control <= (others => '0');
        elsif(rising_edge(clk)) then
            if (en) then
                id_wff <= wff_in;
                id_control <= if_instruction(6 downto 0);
                id_r0a <= to_integer(unsigned(if_instruction(15 downto 13)));
                id_r1a <= to_integer(unsigned(if_instruction(12 downto 10)));
                id_r2a <= to_integer(unsigned(if_instruction(9 downto 7)));
                imm <= to_integer(unsigned(if_instruction(12 downto 5)));
            end if;
        end if;
    end process;

end pipe;
