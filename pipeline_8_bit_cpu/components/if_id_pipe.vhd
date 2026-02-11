library ieee;
use ieee.std_logic_1164.all;
use IEEE.NUMERIC_STD.ALL;

entity if_id_pipe is
    port (
        clk, rstb: in std_logic;
        wb_in : in std_logic;
        wb_out : out std_logic;
        instruction_in : in std_logic_vector(15 downto 0);
        id_control: out std_logic_vector(6 downto 0);
        id_r0a, id_r1a, id_r2a: out natural range 0 to 7;
        imm: out integer range 0 to 255
    );
end if_id_pipe;

architecture pipe of if_id_pipe is
begin
    process (clk) is
    begin
        if(rstb='0') then
            wb_out <= '0';
        elsif(rising_edge(Clk)) then
            wb_out <= wb_in;
            id_control <= instruction_in(6 downto 0);
            id_r0a <= to_integer(unsigned(instruction_in(15 downto 13)));
            id_r1a <= to_integer(unsigned(instruction_in(12 downto 10)));
            id_r2a <= to_integer(unsigned(instruction_in(9 downto 7)));
            imm <= to_integer(unsigned(instruction_in(12 downto 5)));
        end if;
    end process;

end pipe;
