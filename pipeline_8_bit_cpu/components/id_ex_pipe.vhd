library ieee;
use ieee.std_logic_1164.all;
use IEEE.NUMERIC_STD.ALL;

entity id_ex_pipe is
    port (
        clk, rstb: in std_logic;
        id_control: in std_logic_vector(6 downto 0);
        id_reg_wr, id_mov, id_memtoreg, id_m_rd, id_m_wr: in std_logic;
        ex_reg_wr, ex_mov, ex_memtoreg, ex_m_rd, ex_m_wr: out std_logic;
        sign, add, sub, and_or, c_and, c_or: out std_logic;
        id_r0a, id_r1a, id_r2a: in natural range 0 to 7;
        id_r0d, id_r1d, id_r2d: in std_logic_vector(7 downto 0);
        id_imm: in integer range 0 to 255;
        ex_r0a, ex_r1a, ex_r2a: out natural range 0 to 7;
        ex_r0d, ex_r1d, ex_r2d: out std_logic_vector(7 downto 0);
        ex_imm: out integer range 0 to 255
    );
end id_ex_pipe;

architecture pipe of id_ex_pipe is
begin
    -- Control bits
    sign <= id_control(2);
    add <= not id_control(2);
    sub <= id_control(2);
    and_or <= id_control(3);
    c_and <= id_control(2);
    c_or <= not id_control(2);

    process (clk, rstb) is
    begin
        if(rstb='0') then
            ex_reg_wr <= '0';
            ex_memtoreg <= '0';
            ex_m_rd <= '0';
            ex_m_wr <= '0';
        elsif(rising_edge(clk)) then
            ex_reg_wr <= id_reg_wr;
            ex_memtoreg <= id_memtoreg;
            ex_m_rd <= id_m_rd;
            ex_m_wr <= id_m_wr;
            ex_mov <= id_mov;
            ex_r0a <= id_r0a;
            ex_r1a <= id_r1a;
            ex_r2a <= id_r2a;
            ex_imm <= id_imm;
            ex_r0d <= id_r0d;
            ex_r1d <= id_r1d;
            ex_r2d <= id_r2d;
        end if;
    end process;

end pipe;
