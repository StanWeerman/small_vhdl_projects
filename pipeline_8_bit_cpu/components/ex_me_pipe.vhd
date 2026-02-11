library ieee;
use ieee.std_logic_1164.all;
use IEEE.NUMERIC_STD.ALL;

entity ex_me_pipe is
    port (
        clk, rstb: in std_logic;
        ex_reg_wr, ex_memtoreg, ex_m_rd, ex_m_wr: in std_logic;
        me_reg_wr, me_memtoreg, me_m_rd, me_m_wr: out std_logic;
        ex_r0a, ex_r1a, ex_r2a: in natural range 0 to 7;
        ex_r0d, ex_r1d, ex_r2d: in std_logic_vector(7 downto 0);
        me_r0a, me_r1a, me_r2a: out natural range 0 to 7;
        me_r0d, me_r1d, me_r2d: out std_logic_vector(7 downto 0)
    );
end ex_me_pipe;

architecture pipe of ex_me_pipe is
begin
    process (clk) is
    begin
        if(rstb='0') then
            me_reg_wr <= '0';
            me_memtoreg <= '0';
            me_m_rd <= '0';
            me_m_wr <= '0';
        elsif(rising_edge(Clk)) then
            me_reg_wr <= ex_reg_wr;
            me_memtoreg <= ex_memtoreg;
            me_m_rd <= ex_m_rd;
            me_m_wr <= ex_m_wr;
            me_r0a <= ex_r0a;
            me_r1a <= ex_r1a;
            me_r2a <= ex_r2a;
            me_r0d <= ex_r0d;
            me_r1d <= ex_r1d;
            me_r2d <= ex_r2d;
        end if;
    end process;

end pipe;
