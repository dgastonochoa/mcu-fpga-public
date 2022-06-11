`define DT_EVEN 0
`define DT_ODD  1

/**
 * ADRESS: slave address
 * DATA_TYPE: what kind of data the slave will write.
 *            Just for testing purposes.
 * data_rdy: 1 when there is data avaiable to be read from `read_data`.
 *           0 otherwise.
 */
module i2c_slave
    #(parameter ADDRESS = 0,
      parameter DATA_TYPE = 0) (
    inout wire sda,
    inout wire scl,

    output reg busy,
    output reg data_rdy,
    output reg [7:0] read_data,

    input wire rst,

    input wire clk
);

    localparam
        CS_IDLE = 0,

        CS_READ_CMD = 1,
        CS_CMD_ACK = 2,
        CS_RELEASE_SDA = 3,

        CS_READ_DATA = 4,
        CS_DATA_ACK = 5,
        CS_RELEASE_SDA_2 = 6,

        CS_WRITE_DATA = 7,
        CS_RELEASE_SDA_3 = 8,
        CS_READ_ACK = 9,

        CS_WAIT_STOP = 10,
        CS_STOP = 11;

    localparam DATA_SIZE = 8;

    cell_sync cs0(clk, 1'b0, scl, sync_scl);
    pos_edge_det ped0(sync_scl, clk, p_scl);
    neg_edge_det ned0(sync_scl, clk, np_scl);

    cell_sync cs1(clk, 1'b0, sda, sync_sda);
    pos_edge_det ped1(sync_sda, clk, p_sda);
    neg_edge_det ned1(sync_sda, clk, np_sda);

    reg [3:0] idx, cs;
    reg [7:0] cmd_buff;
    reg [7:0] rd_buff;
    reg [7:0] data_write;
    reg sda_reg;
    reg scl_reg;
    reg data_dry_aux;
    reg [3:0] err_flags;
    reg [7:0] data_write_cnt;

    always @ (posedge clk) begin
        if (rst) begin
            cs <= CS_IDLE;
            idx <= DATA_SIZE - 1;
            cmd_buff <= 0;
            rd_buff <= 0;
            sda_reg <= 1'bz;
            scl_reg <= 1'bz;
            busy <= 0;
            err_flags <= 0;
            read_data <= 0;
            data_rdy <= 0;
            data_dry_aux <= 0;
            data_write_cnt <= 0;
            data_write <= 0;
        end else begin
            case (cs)

                CS_IDLE: begin
                    if (scl && !np_sda) begin
                        cs <= CS_READ_CMD;
                        idx <= DATA_SIZE - 1;
                        cmd_buff <= 0;
                        rd_buff <= 0;
                        sda_reg <= 1'bz;
                        scl_reg <= 1'bz;
                        busy <= 1;
                        err_flags <= 0;
                        read_data <= 0;
                        data_rdy <= 0;
                        data_dry_aux <= 0;

                        case (DATA_TYPE)
                            `DT_EVEN: data_write <= (2*data_write_cnt);
                            `DT_ODD: data_write <= (2*data_write_cnt) + 1;
                            default: data_write <= 8'hff;
                        endcase

                        data_write_cnt <= data_write_cnt + 1;
                    end
                end

                CS_READ_CMD: begin
                    if (p_scl) begin
                        cmd_buff[idx] <= sda;

                        if (idx == 0) begin
                            cs <= (cmd_buff[7:1] == ADDRESS ?
                                    CS_CMD_ACK : CS_STOP);
                        end else begin
                            idx <= idx - 1;
                        end
                    end
                end

                CS_CMD_ACK: begin
                    if (!np_scl) begin
                        sda_reg <= 0;
                        idx <= DATA_SIZE - 1;
                        cs <= (cmd_buff[0] == 1 ?
                                CS_WRITE_DATA : CS_RELEASE_SDA);
                    end
                end

                CS_RELEASE_SDA: begin
                    if (!np_scl) begin
                        sda_reg <= 1'bz;
                        cs <= CS_READ_DATA;
                    end
                end

                CS_WRITE_DATA: begin
                    if (!np_scl) begin
                        sda_reg <= (data_write[idx] == 0 ? 0 : 1'bz);

                        if (idx == 0)
                            cs <= CS_RELEASE_SDA_3;
                        else
                            idx <= idx - 1;
                    end
                end

                CS_RELEASE_SDA_3: begin
                    if (!np_scl) begin
                        sda_reg <= 1'bz;
                        cs <= CS_WAIT_STOP;
                    end
                end

                CS_READ_DATA: begin
                    if (p_scl) begin
                        rd_buff[idx] <= sda;

                        if (idx == 0)
                            cs <= CS_DATA_ACK;
                        else
                            idx <= idx - 1;
                    end
                end

                CS_DATA_ACK: begin
                    if (!np_scl) begin
                        sda_reg <= 0;
                        cs <= CS_RELEASE_SDA_2;
                        data_dry_aux <= 1;
                    end
                end

                CS_RELEASE_SDA_2: begin
                    if (!np_scl) begin
                        sda_reg <= 1'bz;
                        cs <= CS_WAIT_STOP;
                    end
                end

                CS_WAIT_STOP: begin
                    if (scl && p_sda) begin
                        sda_reg <= 1'bz;
                        cs <= CS_STOP;
                        read_data <= rd_buff;
                    end
                end

                CS_STOP: begin
                    busy <= 0;
                    cs <= CS_IDLE;
                    if (data_dry_aux)
                        data_rdy <= 1;
                end

            endcase
        end
    end

    assign sda = sda_reg;
    assign scl = scl_reg;

endmodule
