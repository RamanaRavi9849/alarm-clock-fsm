`timescale 1ns / 1ps



module alram_clock_fsm(

    input clk,
    input rst,
    input alarm_enable,
    input snooze,
    input [7:0] alarm_time,     // Time format: HHMM (example: 8'b01110101 for 7:15)
    input [7:0] current_time,   // Current time 
    output reg alarm_ring
);

parameter IDLE     = 2'b00,
          ALARM_ON = 2'b01,
          SNOOZE   = 2'b10;

reg [1:0] current_state, next_state;

// Snooze timer counter ( 5 clock cycles)
reg [3:0] snooze_counter;


always @(posedge clk or posedge rst) begin
    if (rst)
        current_state <= IDLE;
    else
        current_state <= next_state;
end

// Next state logic
always @(*) begin
    case (current_state)
        IDLE: begin
            if (alarm_enable && (current_time == alarm_time))
                next_state = ALARM_ON;
            else
                next_state = IDLE;
        end

        ALARM_ON: begin
            if (snooze)
                next_state = SNOOZE;
            else if (!alarm_enable || rst)
                next_state = IDLE;
            else
                next_state = ALARM_ON;
        end

        SNOOZE: begin
            if (snooze_counter == 4'd5)
                next_state = ALARM_ON;
            else if (!alarm_enable || rst)
                next_state = IDLE;
            else
                next_state = SNOOZE;
        end

        default: next_state = IDLE;
    endcase
end

// Output logic and snooze timer
always @(posedge clk or posedge rst) begin
    if (rst) begin
        alarm_ring <= 1'b0;
        snooze_counter <= 4'd0;
    end else begin
        case (current_state)
            IDLE: begin
                alarm_ring <= 1'b0;
                snooze_counter <= 4'd0;
            end

            ALARM_ON: begin
                alarm_ring <= 1'b1;
                snooze_counter <= 4'd0;
            end

            SNOOZE: begin
                alarm_ring <= 1'b0;
                snooze_counter <= snooze_counter + 1;
            end

            default: begin
                alarm_ring <= 1'b0;
                snooze_counter <= 4'd0;
            end
        endcase
    end
end
  

endmodule
