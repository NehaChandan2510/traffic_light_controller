module traffic_light_controller_(
    input clk,
    input rst,
    input [5:0] vehA,
    input [5:0] vehB,
    input [5:0] vehC,
    input [5:0] vehD,
    output reg [2:0] lightA,
    output reg [2:0] lightB,
    output reg [2:0] lightC,
    output reg [2:0] lightD
    );
    
    reg [25:0] clk_div;
    reg slow_clk;
    
    always @(posedge clk or posedge rst) begin
    if (rst) begin
        clk_div  <= 26'd0;
        slow_clk <= 1'b0;
    end else begin
        if (clk_div == 26'd4) begin
           clk_div  <= 26'd0;
           slow_clk <= ~slow_clk;
        end else begin
            clk_div <= clk_div + 1'b1;
        end
    end
end

reg [1:0] road;
reg [1:0] phase;
reg [6:0] timer;
reg [6:0] green_time;

always @(posedge slow_clk or posedge rst) begin
    if (rst) begin
        road  <= 2'd0;
        phase <= 2'd3;      // go to startup hold first, not straight to green
        timer <= 7'd0;

        // pick the green time for road A, ready for when the hold ends
        if (vehA <= 6'd15)
            green_time <= 7'd30;       // 0-15 vehicles  -> 30 sec
        else if (vehA <= 6'd30)
            green_time <= 7'd60;       // 16-30 vehicles -> 60 sec
        else
            green_time <= 7'd90;       // more than 30   -> 90 sec
    end
    else begin

        if (phase == 2'd3) begin
            // STARTUP HOLD: everyone red for 2 time units before we start
            if (timer == 7'd1) begin
                phase <= 2'd0;          // begin normal cycle with road A green
                timer <= 7'd0;
            end else begin
                timer <= timer + 1'b1;
            end
        end

        else if (phase == 2'd0) begin
            // GREEN phase for the current road, length = green_time seconds
            if (timer == green_time - 1'b1) begin
                phase <= 2'd1;           // green finished -> yellow
                timer <= 7'd0;
            end else begin
                timer <= timer + 1'b1;
            end
        end

        else if (phase == 2'd1) begin
            // YELLOW phase, fixed length = 5 time units (seconds)
            if (timer == 7'd4) begin
                phase <= 2'd2;           // yellow finished -> all-red gap
                timer <= 7'd0;
            end else begin
                timer <= timer + 1'b1;
            end
        end

        else begin
            // phase == 2 : ALL-RED SAFETY GAP, fixed length = 2 time units
            if (timer == 7'd1) begin
                // gap finished -> move on to the next road and pick its green time
                timer <= 7'd0;
                phase <= 2'd0;

                if (road == 2'd0) begin
                    road <= 2'd1;
                    if (vehB <= 6'd15)
                        green_time <= 7'd30;
                    else if (vehB <= 6'd30)
                        green_time <= 7'd60;
                    else
                        green_time <= 7'd90;
                end
                else if (road == 2'd1) begin
                    road <= 2'd2;
                    if (vehC <= 6'd15)
                        green_time <= 7'd30;
                    else if (vehC <= 6'd30)
                        green_time <= 7'd60;
                    else
                        green_time <= 7'd90;
                end
                else if (road == 2'd2) begin
                    road <= 2'd3;
                    if (vehD <= 6'd15)
                        green_time <= 7'd30;
                    else if (vehD <= 6'd30)
                        green_time <= 7'd60;
                    else
                        green_time <= 7'd90;
                end
                else begin
                    road <= 2'd0;
                    if (vehA <= 6'd15)
                        green_time <= 7'd30;
                    else if (vehA <= 6'd30)
                        green_time <= 7'd60;
                    else
                        green_time <= 7'd90;
                end
            end else begin
                timer <= timer + 1'b1;
            end
        end
    end
end

always @(*) begin
    lightA = 3'b001;
    lightB = 3'b001;
    lightC = 3'b001;
    lightD = 3'b001;

    if (phase == 2'd0) begin
        // GREEN for the current road
        if (road == 2'd0) lightA = 3'b100;
        else if (road == 2'd1) lightB = 3'b100;
        else if (road == 2'd2) lightC = 3'b100;
        else lightD = 3'b100;
    end
    else if (phase == 2'd1) begin
        // YELLOW for the current road
        if (road == 2'd0) lightA = 3'b010;
        else if (road == 2'd1) lightB = 3'b010;
        else if (road == 2'd2) lightC = 3'b010;
        else lightD = 3'b010;
    end
end

endmodule
