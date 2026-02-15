library ieee;
use ieee.std_logic_1164.all;
use IEEE.NUMERIC_STD.ALL;

entity cpu is
    port (
        clk, rst, en : in std_logic
        --instruction : in std_logic_vector(15 downto 0);
        --d_in : in std_logic_vector(7 downto 0);
        --d_out : out std_logic_vector(7 downto 0);
    );
end cpu;

architecture cpu of cpu is
    -- HDU signals
    signal stall_hdu: std_logic;

    -- IF signals
    signal if_instruction: std_logic_vector(15 downto 0);

    -- ID signals
    signal id_r0a, id_r1a, id_r2a : natural range 0 to 7;
    signal id_r0d, id_r1d, id_r2d : std_logic_vector(7 downto 0);
    signal id_imm : integer range 0 to 255;
    signal id_reg_wr : std_logic;
    signal id_control: std_logic_vector(6 downto 0);
    signal id_mov, id_jump, id_branch, id_beq_bne_b, id_alu, id_memtoreg : std_logic;
    signal id_m_rd, id_m_wr : std_logic;
    signal id_r0f1, id_r1f1, id_r2f1, id_r0f2, id_r1f2, id_r2f2: std_logic;
    signal id_wff : std_logic;
        -- PC signals
        signal id_branch_success: std_logic;
        signal id_branch_address, id_pco: natural range 0 to 65535;

    -- EX signals
    signal ex_r0a, ex_r1a, ex_r2a : natural range 0 to 7;
    signal ex_wd, ex_r0d, ex_r1d, ex_r2d  : std_logic_vector(7 downto 0);
    signal ex_imm : integer range 0 to 255;
    signal ex_reg_wr : std_logic;
    signal ex_mov, ex_memtoreg, ex_alu : std_logic;
    signal ex_m_rd, ex_m_wr : std_logic;
    signal ex_r0f1, ex_r1f1, ex_r2f1, ex_r0f2, ex_r1f2, ex_r2f2: std_logic;
    signal ex_r0df, ex_r1df, ex_r2df: std_logic_vector(7 downto 0);
    signal sign, add, sub, and_or, c_and, c_or: std_logic;

    -- ME signals
    signal me_r0a, me_r1a, me_r2a : natural range 0 to 7;
    signal me_wd, me_r0d, me_r1d, me_r2d  : std_logic_vector(7 downto 0);
    signal me_reg_wr, me_memtoreg : std_logic;
    signal me_a : natural range 0 to 65535;
    signal me_d_in, m_d_out: std_logic_vector(7 downto 0);
    signal me_m_rd, me_m_wr : std_logic;

    -- WB signals
    signal wb_r0a: natural range 0 to 7;
    signal wb_wd : std_logic_vector(7 downto 0);
    signal wb_reg_wr : std_logic;

    -- ALU signals
    signal alu_output: std_logic_vector(7 downto 0);
    signal c_out: std_logic;

    -- Register File signals
    signal reg_0_data, reg_1_data, reg_2_data: std_logic_vector(7 downto 0);
    signal write_data: std_logic_vector(7 downto 0);

begin

-- IF work
    -- PC inst
    pc: entity work.pc
    port map(
        clk => clk,
        rstb => not rst,
        en => not stall_hdu,
        jmp => id_jump,
        branch => id_branch_success,
        jmp_address => id_branch_address,
        pco => id_pco
    );
    -- Instruction Memory inst
    ins_mem: entity work.memory
     generic map(
        data_width => 16,
        ROM_FILE => "/Users/stanweerman/Documents/verilog_projects/small_verilog_projects/8_bit_cpu/assembler/tests/build/add",
        LOAD => 1
    )
     port map(
        clk => clk,
        rd => '1',
        wr => '0',
        a => id_pco,
        d_in => (others => '0'),
        d_out => if_instruction
    );

-- IF/ID pipe inst
    if_id_pipe: entity work.if_id_pipe
     port map(
        clk => clk,
        rstb => not rst,
        en => not stall_hdu,
        wff_in => id_jump or id_branch_success,
        id_wff => id_wff,
        if_instruction => if_instruction,
        id_control => id_control,
        id_r0a => id_r0a,
        id_r1a => id_r1a,
        id_r2a => id_r2a,
        imm => id_imm
    );

-- ID work
    -- Control bits
    control: process(all) is
        variable branch_success : std_logic;
    begin
        if id_wff or stall_hdu then
            id_reg_wr <= '0';
            id_m_rd <= '0';
            id_m_wr <= '0';
        else
            id_reg_wr <= id_alu or id_m_rd;
            id_m_rd <= '0' when id_alu else id_control(2);
            id_m_wr <= '0' when id_alu else id_control(1);
        end if;
        id_mov <= id_control(1);
        id_jump <= '0' when (id_alu or id_branch) else id_control(4);
        id_branch <= '0' when id_alu else id_control(3);
        id_beq_bne_b <= id_control(4);
        id_alu <= id_control(0);
        id_memtoreg <= not id_alu;

        branch_success := id_beq_bne_b xor '0' when (unsigned(id_r0d) /= 0) else '1';
        id_branch_success <= id_branch and branch_success;
        id_branch_address <= to_integer(unsigned(id_r1d & id_r2d));
    end process;

    -- Reg file inst
    reg_file: entity work.reg_file
    generic map(DEBUG => 1)
    port map(
        clk => clk,
        reg_wr => wb_reg_wr,
        r0a => wb_r0a,
        r1a => id_r1a,
        r2a => id_r2a,
        r0d => id_r0d,
        r1d => id_r1d,
        r2d => id_r2d,
        wd => wb_wd
    );

    -- HDU inst
    hdu: entity work.hdu
     port map(
        id_r0a => id_r0a,
        id_r1a => id_r1a,
        id_r2a => id_r2a,
        ex_r0a => ex_r0a,
        me_r0a => me_r0a,
        ex_reg_wr => ex_reg_wr,
        me_reg_wr => me_reg_wr,
        ex_mem => (ex_m_rd or ex_m_wr),
        me_mem => (me_m_rd or me_m_wr),
        id_br => id_branch or id_jump,
        id_nop => not (id_reg_wr or id_m_wr),
        stall_hdu => stall_hdu
    );
    -- FU inst
    fu_inst: entity work.fu
     port map(
        id_r0a => id_r0a,
        id_r1a => id_r1a,
        id_r2a => id_r2a,
        ex_r0a => ex_r0a,
        me_r0a => me_r0a,
        ex_reg_wr => ex_reg_wr,
        me_reg_wr => me_reg_wr,
        ex_alu => ex_alu,
        id_r0f1 => id_r0f1,
        id_r1f1 => id_r1f1,
        id_r2f1 => id_r2f1,
        id_r0f2 => id_r0f2,
        id_r1f2 => id_r1f2,
        id_r2f2 => id_r2f2
    );


-- ID/EX pipe inst
    id_ex_pipe: entity work.id_ex_pipe
    port map(
        clk => clk,
        rstb => not rst,
        en => '1',
        id_control => id_control,
        id_reg_wr => id_reg_wr,
        id_mov => id_mov,
        id_memtoreg => id_memtoreg,
        id_m_rd => id_m_rd,
        id_m_wr => id_m_wr,
        id_alu => id_alu,
        ex_reg_wr => ex_reg_wr,
        ex_mov => ex_mov,
        ex_memtoreg => ex_memtoreg,
        ex_m_rd => ex_m_rd,
        ex_m_wr => ex_m_wr,
        ex_alu => ex_alu,
        sign => sign,
        add => add,
        sub => sub,
        and_or => and_or,
        c_and => c_and,
        c_or => c_or,
        id_r0f1 => id_r0f1,
        id_r1f1 => id_r1f1,
        id_r2f1 => id_r2f1,
        id_r0f2 => id_r0f2,
        id_r1f2 => id_r1f2,
        id_r2f2 => id_r2f2,
        ex_r0f1 => ex_r0f1,
        ex_r1f1 => ex_r1f1,
        ex_r2f1 => ex_r2f1,
        ex_r0f2 => ex_r0f2,
        ex_r1f2 => ex_r1f2,
        ex_r2f2 => ex_r2f2,
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
    -- Forwarding Muxes
    ex_r0df <= me_r0d when ex_r0f1 else wb_wd when ex_r0f2 else ex_r0d;
    ex_r1df <= me_r0d when ex_r1f1 else wb_wd when ex_r1f2 else ex_r1d;
    ex_r2df <= me_r0d when ex_r2f1 else wb_wd when ex_r2f2 else ex_r2d;

    -- ALU inst
    alu: entity work.alu
     port map(
        a => ex_r1df,
        b => ex_r2df,
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
    ex_wd <= ex_r0df when ex_memtoreg else std_logic_vector(to_unsigned(ex_imm, ex_wd'length)) when ex_mov else alu_output;

-- EX/ME pipe inst
    ex_me_pipe: entity work.ex_me_pipe
    port map(
        clk => clk,
        rstb => not rst,
        en => '1',
        ex_reg_wr => ex_reg_wr,
        ex_memtoreg => ex_memtoreg,
        ex_m_rd => ex_m_rd,
        ex_m_wr => ex_m_wr,
        me_reg_wr => me_reg_wr,
        me_memtoreg => me_memtoreg,
        me_m_rd => me_m_rd,
        me_m_wr => me_m_wr,
        ex_r0a => ex_r0a,
        ex_r1a => ex_r1a,
        ex_r2a => ex_r2a,
        ex_r0d => ex_wd,
        ex_r1d => ex_r1d,
        ex_r2d => ex_r2d,
        me_r0a => me_r0a,
        me_r1a => me_r1a,
        me_r2a => me_r2a,
        me_r0d => me_r0d,
        me_r1d => me_r1d,
        me_r2d => me_r2d
    );

-- ME work
    me_wd <= me_r0d when not me_memtoreg else m_d_out;
    me_a <= to_integer(unsigned(me_r1d & me_r2d));
    ram: entity work.memory
     generic map(
        data_width => 8
    )
     port map(
        clk => clk,
        rd => me_m_rd,
        wr => me_m_wr,
        a => me_a,
        d_in => me_r0d,
        d_out => m_d_out
    );

-- ME/WB pipe inst
    me_wb_pipe: entity work.me_wb_pipe
    port map(
        clk => clk,
        rstb => not rst,
        en => '1',
        me_reg_wr => me_reg_wr,
        wb_reg_wr => wb_reg_wr,
        me_r0a => me_r0a,
        me_r0d => me_wd,
        wb_r0a => wb_r0a,
        wb_r0d => wb_wd
    );
end;
