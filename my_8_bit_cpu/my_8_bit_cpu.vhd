library ieee;
use ieee.std_logic_1164.all;
use IEEE.NUMERIC_STD.ALL;

entity cpu is
    port (
        clk, rst, en : in std_logic;
        instruction : in std_logic_vector(15 downto 0);
        d_in : in std_logic_vector(7 downto 0);
        d_out : out std_logic_vector(7 downto 0);
        m_rd, m_wr : out std_logic;
        a, pco : out integer range 0 to 65535
    );
end cpu;

architecture cpu of cpu is
    -- Control signals
    signal control: std_logic_vector(6 downto 0);
    signal mov, jump, branch, beq_bne_b, mem_rd, mem_wr, alu, reg_wr, memtoreg : std_logic;

    -- PC signals
    signal branch_success: std_logic;

    -- ALU signals
    signal alu_output: std_logic_vector(7 downto 0);
    signal c_out: std_logic;

    -- Register File signals
    signal reg_0_data, reg_1_data, reg_2_data: std_logic_vector(7 downto 0);
    signal write_data: std_logic_vector(7 downto 0);
begin
    -- Control bits
    control <= instruction(6 downto 0);
    mov <= control(1);
    jump <= '0' when (alu or branch) else control(4);
    branch <= '0' when alu else control(3);
    beq_bne_b <= control(4);
    mem_rd <= '0' when alu else control(2);
    mem_wr <= '0' when alu else control(1);
    alu <= control(0);
    reg_wr <= alu or mem_rd;
    memtoreg <= not alu;

    -- PC init
    pc_inst: entity work.pc
     port map(
        clk => clk,
        rstb => not rst,
        en => en,
        jmp => jump,
        branch => branch,
        jmp_address => a,
        pco => pco
    );

    -- ALU init
    alu_inst: entity work.alu
     port map(
        a => reg_1_data,
        b => reg_2_data,
        c => alu_output,
        c_out => c_out,
        control => control
    );

    reg_file_inst: entity work.reg_file
     port map(
        clk => clk,
        reg_wr => reg_wr,
        r0a => to_integer(unsigned(instruction(15 downto 13))),
        r1a => to_integer(unsigned(instruction(12 downto 10))),
        r2a => to_integer(unsigned(instruction(9 downto 7))),
        r0d => reg_0_data,
        r1d => reg_1_data,
        r2d => reg_2_data,
        wd => write_data
    );

    --branch_success <= branch and '1' when (reg_0_data = (others => '0')) else '0' when beq_bne_b else '1' when (reg_0_data /= (others => '0')) else '0';
    branch_success <= branch and beq_bne_b xor '0' when (unsigned(reg_0_data) /= 0) else '1';

    process (all) is
    begin
        if memtoreg then
            write_data <= d_in when mem_rd else reg_0_data;
        else
            write_data <= instruction(12 downto 5) when mov else alu_output;
        end if;
    end process;
end cpu;
