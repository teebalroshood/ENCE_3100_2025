module Debouncer(
    input clk,
    input rst,
    input btn_in,
    output reg btn_out
);
    reg [15:0] cnt;
    reg sync_0, sync_1;

    always @(posedge clk or posedge rst) begin
        if(rst) begin
            sync_0 <= 0; sync_1 <= 0;
            cnt <= 0; btn_out <= 0;
        end else begin
            sync_0 <= btn_in;
            sync_1 <= sync_0;

            if(sync_1 != btn_out) begin
                cnt <= cnt + 1;
                if(cnt == 16'hFFFF) btn_out <= sync_1;
            end else cnt <= 0;
        end
    end
endmodule
