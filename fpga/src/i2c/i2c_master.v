/**
 * cmd: address + r/w
 * data: data to be written if the cmd[0] = 0.
 * read_data: output buffer for the data read if cmd[0] = 1.
 * data_rdy: 1 when there is data available to read in `read_data`.
 */
module i2c_master(
    inout wire sda,
    inout wire scl,

    input wire en,
    input wire rst,
    input wire [7:0] cmd,
    input wire [7:0] data,

    output reg busy,
    output reg [7:0] read_data,
    output reg data_rdy,

    input wire clk
);
    localparam
        CS_IDLE = 0,
        CS_START = 1,

        CS_SEND_CMD = 2,
        CS_RELEASE_SDA = 3,
        CS_READ_CMD_ACK = 4,

        CS_SEND_DATA = 5,
        CS_RELEASE_SDA_2 = 6,
        CS_READ_DATA_ACK = 7,

        CS_READ_DATA = 8,
        CS_SEND_ACK = 9,
        CS_RELEASE_SDA_3 = 10,

        CS_STOP_1 = 11,
        CS_STOP_2 = 12,
        CS_STOP_3 = 13;

    localparam DATA_SIZE = 8;
    localparam I2C_CLK_DIV = 20;

    wire p_en;
    wire p_scl;
    wire sda_clk;

    reg [3:0] cs;
    reg [5:0] err_flags;
    reg [7:0] idx;
    reg [7:0] data_buff;
    reg [7:0] cmd_buff;
    reg sda_reg;
    reg scl_en;
    reg data_rdy_aux;


    cell_sync cs0(clk, 1'b0, scl_en, sync_scl_en);
    double_clk_gen #(.CLK_DIV(I2C_CLK_DIV)) dcg(sda_clk, scl, sync_scl_en, clk);

    cell_sync cs1(clk, 1'b0, sda_clk, sync_sda_clk);
    pos_edge_det ped2(sync_sda_clk, clk, p_sda_clk);

    cell_sync cs2(clk, 1'b0, scl, sync_scl);
    pos_edge_det ped3(sync_scl, clk, p_scl);

    cell_sync cs3(clk, 1'b0, en, sync_en);
    pos_edge_det ped(sync_en, clk, p_en);

    cell_sync cs4(clk, 1'b0, rst, sync_rst);

    always @ (posedge clk) begin
        if (sync_rst) begin
            busy <= 0;
            cs <= CS_IDLE;
            idx <= DATA_SIZE - 1;
            sda_reg <= 1'bz;
            scl_en <= 0;
            err_flags <= 0;
            read_data <= 0;
            data_buff <= 0;
            cmd_buff <= 0;
            data_rdy <= 0;
            data_rdy_aux <= 0;
        end else begin
            case (cs)
                CS_IDLE: begin
                    if (p_en) begin
                        cs <= CS_START;
                        idx <= DATA_SIZE - 1;
                        busy <= 1;
                        sda_reg <= 0;
                        err_flags <= 0;
                        read_data <= 0;
                        data_buff <= data;
                        cmd_buff <= cmd;
                        data_rdy <= 0;
                        data_rdy_aux <= 0;
                    end
                end

                CS_START: begin
                    scl_en <= 1;
                    cs <= CS_SEND_CMD;
                end

                CS_SEND_CMD: begin
                    if (p_sda_clk) begin
                        sda_reg <= (cmd_buff[idx] == 0 ? 0 : 1'bz);

                        if (idx == 0)
                            cs <= CS_RELEASE_SDA;
                        else
                            idx <= idx - 1;
                    end
                end

                CS_RELEASE_SDA: begin
                    if (p_sda_clk) begin
                        sda_reg <= 1'bz;
                        cs <= CS_READ_CMD_ACK;
                    end
                end

                CS_READ_CMD_ACK: begin
                    if (p_scl) begin
                        if (sda != 0) begin
                            err_flags <= err_flags | 1;
                            cs <= CS_STOP_1;
                        end else begin
                            idx <= DATA_SIZE - 1;
                            cs <= (cmd_buff[0] == 0 ? CS_SEND_DATA : CS_READ_DATA);
                        end
                    end
                end

                CS_READ_DATA: begin
                    if (p_scl) begin
                        read_data[idx] <= sda;

                        if (idx == 0)
                            cs <= CS_RELEASE_SDA_3;
                        else
                            idx <= idx - 1;
                    end
                end

                CS_RELEASE_SDA_3: begin
                    if (p_sda_clk) begin
                        data_rdy_aux <= 1;
                        sda_reg <= 1'bz;
                        cs <= CS_STOP_1;
                    end
                end

                CS_SEND_DATA: begin
                    if (p_sda_clk) begin
                        sda_reg <= (data_buff[idx] == 0 ? 0 : 1'bz);

                        if (idx == 0)
                            cs <= CS_RELEASE_SDA_2;
                        else
                            idx <= idx - 1;
                    end
                end

                CS_RELEASE_SDA_2: begin
                    if (p_sda_clk) begin
                        sda_reg <= 1'bz;
                        cs <= CS_READ_DATA_ACK;
                    end
                end

                CS_READ_DATA_ACK: begin
                    if (p_scl) begin
                        if (sda != 0)
                            err_flags <= err_flags | (1 << 1);

                        cs <= CS_STOP_1;
                    end
                end

                CS_STOP_1: begin
                    if (p_sda_clk) begin
                        sda_reg <= 0;
                        cs <= CS_STOP_2;
                    end
                end

                CS_STOP_2: begin
                    if (p_scl) begin
                        scl_en <= 0;
                        cs <= CS_STOP_3;
                    end
                end

                CS_STOP_3: begin
                    sda_reg <= 1'bz;
                    cs <= CS_IDLE;
                    busy <= 0;
                    data_buff <= 0;
                    cmd_buff <= 0;

                    if (data_rdy_aux)
                        data_rdy <= 1;
                end

            endcase
        end
    end

    assign sda = sda_reg;

endmodule
