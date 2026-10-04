module traffic_light_controller_tb;

reg clk;
reg rst;
reg [5:0] vehA, vehB, vehC, vehD;
wire [2:0] lightA, lightB, lightC, lightD;

// Connect the module under test
traffic_light_controller_ uut (
    .clk(clk),
    .rst(rst),
    .vehA(vehA),
    .vehB(vehB),
    .vehC(vehC),
    .vehD(vehD),
    .lightA(lightA),
    .lightB(lightB),
    .lightC(lightC),
    .lightD(lightD)
);

// Generate a clock: toggles every 5 ns, so one full clock period = 10 ns
always #5 clk = ~clk;

initial begin
    clk = 0;
    rst = 1;

    // Pick one vehicle count from each bracket in the table so you can
    // see all three green times appear:
    //   vehA = 10 -> bracket 0-15  -> green = 30 sec
    //   vehB = 20 -> bracket 16-30 -> green = 60 sec
    //   vehC = 45 -> bracket > 30  -> green = 90 sec
    //   vehD = 2  -> bracket 0-15  -> green = 30 sec
    vehA = 6'd10;
    vehB = 6'd20;
    vehC = 6'd45;
    vehD = 6'd2;

    #20 rst = 0;      // release reset after a couple of clock edges

    // print every time any output changes, so you can read the sequence
    $monitor("time=%0t  A=%b  B=%b  C=%b  D=%b  (vehA=%0d vehB=%0d vehC=%0d vehD=%0d)",
              $time, lightA, lightB, lightC, lightD, vehA, vehB, vehC, vehD);

    #100000;            // let it run long enough to see a full cycle
    $finish;
end

endmodule
