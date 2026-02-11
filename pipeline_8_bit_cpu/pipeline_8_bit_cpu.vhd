library ieee;
use ieee.std_logic_1164.all;
use IEEE.NUMERIC_STD.ALL;

entity cpu is
    port (
        clk, rst, en : in std_logic;
        instruction : in std_logic_vector(15 downto 0);
        d_in : in std_logic_vector(7 downto 0);
        d_out : out std_logic_vector(7 downto 0);
        me_m_rd, me_m_wr : out std_logic;
        a, pco : out integer range 0 to 65535
    );
end cpu;

architecture cpu of cpu is
    -- Control signals
    signal id_control: std_logic_vector(6 downto 0);

    -- PC signals
    signal branch_success: std_logic;

    -- ID signals
    signal id_r0a, id_r1a, id_r2a : natural range 0 to 7;
    signal id_r0d, id_r1d, id_r2d : std_logic_vector(7 downto 0);
    signal id_imm : integer range 0 to 255;
    signal id_reg_wr : std_logic;
    signal id_mov, id_jump, id_branch, id_beq_bne_b, id_alu, id_memtoreg : std_logic;
    signal id_m_rd, id_m_wr : std_logic;

    -- EX signals
    signal ex_r0a, ex_r1a, ex_r2a : natural range 0 to 7;
    signal ex_r0d, ex_r1d, ex_r2d  : std_logic_vector(7 downto 0);
    signal ex_imm : integer range 0 to 255;
    signal ex_reg_wr : std_logic;
    signal ex_mov, ex_memtoreg : std_logic;
    signal ex_m_rd, ex_m_wr : std_logic;
    signal sign, add, sub, and_or, c_and, c_or: std_logic;

    -- ME signals
    signal me_r0a, me_r1a, me_r2a : natural range 0 to 7;
    signal me_r0d, me_r1d, me_r2d  : std_logic_vector(7 downto 0);
    signal me_imm : integer range 0 to 255;
    signal me_reg_wr, me_memtoreg : std_logic;
    --signal me_m_rd, me_m_wr : std_logic;

    -- WB signals
    signal wb_r0a, wb_r1a, wb_r2a : natural range 0 to 7;
    signal wb_r0d, wb_r1d, wb_r2d, wb_wd : std_logic_vector(7 downto 0);
    signal wb_imm : integer range 0 to 255;
    signal wb_reg_wr : std_logic;

    -- ALU signals
    signal alu_output: std_logic_vector(7 downto 0);
    signal c_out: std_logic;

    -- Register File signals
    signal reg_0_data, reg_1_data, reg_2_data: std_logic_vector(7 downto 0);
    signal write_data: std_logic_vector(7 downto 0);

begin

-- IF work

    branch_success <= id_branch and id_beq_bne_b xor '0' when (unsigned(reg_0_data) /= 0) else '1';
    a <= to_integer(unsigned(reg_1_data & reg_2_data));

    -- PC inst
    pc_inst: entity work.pc
    port map(
        clk => clk,
        rstb => not rst,
        en => en,
        jmp => id_jump,
        branch => id_branch,
        jmp_address => a,
        pco => pco
    );

-- IF/ID pipe inst
    if_id_pipe_inst: entity work.if_id_pipe
     port map(
        clk => clk,
        rstb => not rst,
        wb_in => '0',
        wb_out => open,
        instruction_in => instruction,
        id_control => id_control,
        id_r0a => id_r0a,
        id_r1a => id_r1a,
        id_r2a => id_r2a,
        imm => id_imm
    );

-- ID work
    -- Control bits
    id_control <= instruction(6 downto 0);
    id_mov <= id_control(1);
    id_jump <= '0' when (id_alu or id_branch) else id_control(4);
    id_branch <= '0' when id_alu else id_control(3);
    id_beq_bne_b <= id_control(4);
    id_m_rd <= '0' when id_alu else id_control(2);
    id_m_wr <= '0' when id_alu else id_control(1);
    id_alu <= id_control(0);
    id_reg_wr <= id_alu or id_m_rd;
    id_memtoreg <= not id_alu;

    -- Reg file inst
    reg_file_inst: entity work.reg_file
    generic map(DEBUG => 1)
    port map(
        clk => clk,
        reg_wr => wb_reg_wr,
        r0a => id_r0a,
        r1a => id_r1a,
        r2a => id_r2a,
        r0d => id_r0d,
        r1d => id_r0d,
        r2d => id_r0d,
        wd => wb_wd
    );

-- ID/EX pipe inst
    id_ex_pipe_inst: entity work.id_ex_pipe
    port map(
        clk => clk,
        rstb => not rst,
        id_control => id_control,
        id_reg_wr => id_reg_wr,
        id_mov => id_mov,
        id_memtoreg => id_memtoreg,
        id_m_rd => id_m_rd,
        id_m_wr => id_m_wr,
        ex_reg_wr => ex_reg_wr,
        ex_mov => ex_mov,
        ex_memtoreg => ex_memtoreg,
        ex_m_rd => ex_m_rd,
        ex_m_wr => ex_m_wr,
        sign => sign,
        add => add,
        sub => sub,
        and_or => and_or,
        c_and => c_and,
        c_or => c_or,
        id_r0a => id_r0a,
        id_r1a => id_r1a,
        id_r2a => id_r2a,
        id_r0d => id_r0d,
        id_r1d => id_r1d,
        id_r2d => id_r2d,
        id_imm => id_imm,
        ex_r0a => ex_r0a,
        ex_r1a => ex_r1a,
        ex_r2a => ex_r2a,
        ex_r0d => ex_r0d,
        ex_r1d => ex_r1d,
        ex_r2d => ex_r2d,
        ex_imm => ex_imm
    );

-- EX work
    -- ALU inst
    alu_inst: entity work.alu
     port map(
        a => ex_r1d,
        b => ex_r2d,
        c => alu_output,
        c_out => c_out,
        mov => ex_mov,
        sign => sign,
        add => add,
        sub => sub,
        and_or => and_or,
        c_and => c_and,
        c_or => c_or
    );
    ex_wd <= ex_imm when mov else alu_output;

-- EX/ME pipe inst

    d_out <= write_data;
end;
