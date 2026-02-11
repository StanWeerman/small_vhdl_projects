library ieee;
use ieee.std_logic_1164.all;
use IEEE.NUMERIC_STD.ALL;

entity me_wb_pipe is
    port (
        clk, rstb: in std_logic;
        me_reg_wr: in std_logic;
        wb_reg_wr: out std_logic;
        me_r0a: in natural range 0 to 7;
        me_r0d: in std_logic_vector(7 downto 0);
        wb_r0a: out natural range 0 to 7;
        wb_r0d: out std_logic_vector(7 downto 0)
    );
end me_wb_pipe;

architecture pipe of me_wb_pipe is
begin
    process (clk) is
    begin
        if(rstb='0') then
            wb_reg_wr <= '0';
        elsif(rising_edge(Clk)) then
            wb_reg_wr <= wb_reg_wr;
            wb_r0a <= me_r0a;
            wb_r0d <= me_r0d;
        end if;
    end process;

end pipe;
