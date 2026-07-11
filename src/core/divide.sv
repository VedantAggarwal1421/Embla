import core_pkg::*;

module divide (
    input logic clk,
    input logic rst,

    input logic                is_div,
    input muldiv_type_t        div_type,
    input logic         [31:0] dividend,
    input logic         [31:0] divisor,

    output logic [31:0] result,
    output logic        done
);

    typedef enum logic [1:0] {
        DIV_IDLE,
        DIV_RUN,
        DIV_FINISH
    } state_t;

    typedef struct packed {
        logic [31:0] prev_dividend;
        logic [31:0] prev_divisor;
        logic [31:0] prev_quotient;
        logic [32:0] prev_remainder;
    } prev_result_t;

    state_t state;
    prev_result_t prev_result;

    logic [31:0] divisor_abs;
    logic [31:0] dividend_abs;

    logic dividend_neg;
    logic divisor_neg;

    logic quotient_neg;
    logic remainder_neg;

    logic [31:0] quotient;
    logic [31:0] divisor_reg;

    logic [32:0] remainder;
    logic [5:0] count;

    logic signed_mode;
    logic rem_mode;

    always_comb begin
        signed_mode = (div_type == DIV) || (div_type == REM);
        rem_mode    = (div_type == REM) || (div_type == REMU);
    end

    logic [32:0] rem_shift;
    logic [32:0] rem_sub;

    assign rem_shift = {remainder[31:0], quotient[31]};
    assign rem_sub   = rem_shift - {1'b0, divisor_reg};

    logic [31:0] final_q;
    logic [31:0] final_r;
    assign final_q = (signed_mode && quotient_neg) ? ~quotient + 1'b1 : quotient;
    assign final_r = (signed_mode && remainder_neg)? ~remainder[31:0] + 1'b1:remainder[31:0];

    always_ff @(posedge clk or posedge rst) begin

        if (rst) begin
            state <= DIV_IDLE;
            done <= 0;
            result <= 0;
            prev_result <= '0;
        end else begin
            done <= 0;
            case (state)
                DIV_IDLE: begin
                    if (is_div) begin
                        if (divisor == 0) begin
                            done <= 1;
                            if (rem_mode) result <= dividend;
                            else result <= 32'hFFFFFFFF;
                        end
                        else if (signed_mode && (dividend == 32'h80000000) && (divisor  == 32'hFFFFFFFF)) begin
                            done <= 1;
                            if (rem_mode) result <= 0;
                            else result <= 32'h80000000;
                        end
                        else if(dividend == prev_result.prev_dividend && divisor == prev_result.prev_divisor) begin
                            done <= 1;
                            if (rem_mode) begin
                                result <= (signed_mode && dividend[31])? 
                                    ~prev_result.prev_remainder[31:0] + 1'b1 :
                                    prev_result.prev_remainder[31:0];
                            end else begin
                                result <= (signed_mode && (dividend[31]^divisor[31]))?
                                    ~prev_result.prev_quotient + 1'b1 :
                                    prev_result.prev_quotient;
                            end
                        end else begin
                            dividend_neg <= signed_mode && dividend[31];
                            divisor_neg <= signed_mode && divisor[31];

                            quotient_neg  <= signed_mode && (dividend[31] ^ divisor[31]);
                            remainder_neg <= signed_mode && dividend[31];
                            dividend_abs <= (signed_mode && dividend[31])? (~dividend + 1'b1) : dividend;

                            divisor_abs <= (signed_mode && divisor[31])? (~divisor + 1'b1) : divisor;
                            quotient <= (signed_mode && dividend[31])? (~dividend + 1'b1) : dividend;
                            divisor_reg <= (signed_mode && divisor[31])? (~divisor + 1'b1) : divisor;

                            remainder <= 33'd0;
                            count <= 6'd32;
                            state <= DIV_RUN;

                        end
                    end
                end
                DIV_RUN: begin
                    quotient <= {quotient[30:0], ~rem_sub[32]};
                    if (rem_sub[32]) remainder <= rem_shift;
                    else remainder <= rem_sub;
                    count <= count - 1'b1;
                    if (count == 6'd1) state <= DIV_FINISH;
                end
                DIV_FINISH: begin
                    if (rem_mode) result <= final_r;
                    else result <= final_q;

                    prev_result.prev_dividend <= dividend;
                    prev_result.prev_divisor <= divisor;
                    prev_result.prev_quotient <= quotient;
                    prev_result.prev_remainder <= remainder;

                    done <= 1;
                    state <= DIV_IDLE;
                end
                default: begin
                    state <= DIV_IDLE;
                end
            endcase
        end
    end
endmodule
