library ieee;
use ieee.std_logic_1164.all;

entity register_file_alu is
    generic (
        DATA_WIDTH : positive := 32
    );
    port (
        clk                       : in  std_logic;
        reset                     : in  std_logic;
        write_enable              : in  std_logic;
        instruction               : in  std_logic_vector(17 downto 0);
        result                    : out std_logic_vector(DATA_WIDTH - 1 downto 0);
        overflow                  : out std_logic;
        register_5_initial_value  : in  std_logic_vector(DATA_WIDTH - 1 downto 0);
        register_23_initial_value : in  std_logic_vector(DATA_WIDTH - 1 downto 0)
    );
end entity register_file_alu;

architecture structural of register_file_alu is
    signal register_outputs     : std_logic_vector((32 * DATA_WIDTH) - 1 downto 0);
    signal write_enables        : std_logic_vector(31 downto 0);

    signal function_code        : std_logic_vector(2 downto 0);
    signal source_register_a    : std_logic_vector(4 downto 0);
    signal source_register_b    : std_logic_vector(4 downto 0);
    signal destination_register : std_logic_vector(4 downto 0);

    signal operand_a            : std_logic_vector(DATA_WIDTH - 1 downto 0);
    signal operand_b            : std_logic_vector(DATA_WIDTH - 1 downto 0);
    signal alu_result           : std_logic_vector(DATA_WIDTH - 1 downto 0);
    signal alu_overflow         : std_logic;
begin
    function_code        <= instruction(17 downto 15);
    source_register_a    <= instruction(14 downto 10);
    source_register_b    <= instruction(9 downto 5);
    destination_register <= instruction(4 downto 0);

    write_decoder : entity work.decoder_5_to_32
        port map (
            address      => destination_register,
            write_enable => write_enable,
            enable_lines => write_enables
        );

    registers : entity work.register_array
        generic map (
            DATA_WIDTH => DATA_WIDTH
        )
        port map (
            clk                       => clk,
            reset                     => reset,
            write_enables             => write_enables,
            data_in                   => alu_result,
            register_5_initial_value  => register_5_initial_value,
            register_23_initial_value => register_23_initial_value,
            outputs_flat              => register_outputs
        );

    source_a_mux : entity work.mux_32_to_1
        generic map (
            DATA_WIDTH => DATA_WIDTH
        )
        port map (
            inputs       => register_outputs,
            select_lines => source_register_a,
            output_data  => operand_a
        );

    source_b_mux : entity work.mux_32_to_1
        generic map (
            DATA_WIDTH => DATA_WIDTH
        )
        port map (
            inputs       => register_outputs,
            select_lines => source_register_b,
            output_data  => operand_b
        );

    arithmetic_logic_unit : entity work.alu
        generic map (
            DATA_WIDTH => DATA_WIDTH
        )
        port map (
            operand_a     => operand_a,
            operand_b     => operand_b,
            function_code => function_code,
            result        => alu_result,
            overflow      => alu_overflow
        );

    result   <= alu_result;
    overflow <= alu_overflow;
end architecture structural;
