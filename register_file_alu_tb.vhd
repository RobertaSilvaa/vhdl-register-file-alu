library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity register_file_alu_tb is
end entity register_file_alu_tb;

architecture test of register_file_alu_tb is
    constant DATA_WIDTH : positive := 32;

    signal clk                       : std_logic := '0';
    signal reset                     : std_logic := '0';
    signal write_enable              : std_logic := '0';
    signal instruction               : std_logic_vector(17 downto 0) := (others => '0');
    signal result                    : std_logic_vector(DATA_WIDTH - 1 downto 0);
    signal overflow                  : std_logic;
    signal register_5_initial_value  : std_logic_vector(DATA_WIDTH - 1 downto 0) := (others => '0');
    signal register_23_initial_value : std_logic_vector(DATA_WIDTH - 1 downto 0) := (others => '0');

    function encode_instruction(
        function_code : std_logic_vector(2 downto 0);
        source_a      : natural;
        source_b      : natural;
        destination   : natural
    ) return std_logic_vector is
    begin
        return function_code &
               std_logic_vector(to_unsigned(source_a, 5)) &
               std_logic_vector(to_unsigned(source_b, 5)) &
               std_logic_vector(to_unsigned(destination, 5));
    end function;
begin
    dut : entity work.register_file_alu
        generic map (
            DATA_WIDTH => DATA_WIDTH
        )
        port map (
            clk                       => clk,
            reset                     => reset,
            write_enable              => write_enable,
            instruction               => instruction,
            result                    => result,
            overflow                  => overflow,
            register_5_initial_value  => register_5_initial_value,
            register_23_initial_value => register_23_initial_value
        );

    stimulus : process
    begin
        register_5_initial_value  <= std_logic_vector(to_unsigned(10, DATA_WIDTH));
        register_23_initial_value <= std_logic_vector(to_unsigned(3, DATA_WIDTH));

        reset <= '1';
        wait for 1 ns;
        reset <= '0';
        wait for 1 ns;

        -- Read registers 5 and 23 and add them.
        instruction <= encode_instruction("000", 5, 23, 1);
        write_enable <= '0';
        wait for 1 ns;

        assert unsigned(result) = to_unsigned(13, DATA_WIDTH)
            report "Initial register values were not read correctly."
            severity error;
        assert overflow = '0'
            report "Unexpected overflow while adding initial register values."
            severity error;

        -- Write the ALU result (13) into register 1.
        write_enable <= '1';
        clk <= '0';
        wait for 1 ns;
        clk <= '1';
        wait for 1 ns;
        clk <= '0';
        write_enable <= '0';
        wait for 1 ns;

        -- Read register 1 through OR with register 0, which reset to zero.
        instruction <= encode_instruction("100", 1, 0, 0);
        wait for 1 ns;

        assert unsigned(result) = to_unsigned(13, DATA_WIDTH)
            report "Register write/read path is incorrect."
            severity error;

        -- Verify subtraction using the two initialized registers.
        instruction <= encode_instruction("001", 5, 23, 0);
        wait for 1 ns;

        assert unsigned(result) = to_unsigned(7, DATA_WIDTH)
            report "Subtraction through the register file is incorrect."
            severity error;
        assert overflow = '0'
            report "Unexpected subtraction borrow."
            severity error;

        -- Change reset values before asserting reset again.
        register_5_initial_value  <= std_logic_vector(to_unsigned(4, DATA_WIDTH));
        register_23_initial_value <= std_logic_vector(to_unsigned(9, DATA_WIDTH));
        wait for 1 ns;

        reset <= '1';
        wait for 1 ns;
        reset <= '0';
        wait for 1 ns;

        instruction <= encode_instruction("000", 5, 23, 0);
        wait for 1 ns;

        assert unsigned(result) = to_unsigned(13, DATA_WIDTH)
            report "Reset did not reload the configured initial register values."
            severity error;

        report "Register-file/ALU testbench completed successfully." severity note;
        wait;
    end process;
end architecture test;
