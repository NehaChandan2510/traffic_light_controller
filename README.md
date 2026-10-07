# Traffic Light Controller (Verilog, Vivado)

A 4-way traffic light controller I built in Verilog for Vivado. The main
idea here is that it's not a dumb fixed-timer light - each road gets a
green duration based on how many vehicles are actually waiting on it, and
there's a proper all-red gap built in so the intersection doesn't go
straight from one green to another.

## How it works

There are four roads - A, B, C, D - and they get served in a round-robin
order: A, then B, then C, then D, then back to A, and so on. Each road
goes through up to four phases:

1. Green - how long depends on the vehicle count (table below)
2. Yellow - always 5 seconds
3. All-red safety gap - always 2 seconds, everyone red so the
   intersection actually clears before the next road gets its green
4. Startup hold - this one only happens once, right after reset. All
   lights stay red for 2 seconds before the cycle even begins, instead of
   snapping straight to green the moment the board powers on

Each road's light is a 3-bit signal, one bit high at a time:
GREEN = 100, YELLOW = 010, RED = 001.

### Green time depends on traffic

| Vehicle count (per lane) | Green time |
|---------------------------|------------|
| 0 - 15                     | 30 sec     |
| 16 - 30                    | 60 sec     |
| more than 30                | 90 sec     |

The vehicle count gets read once, right when that road's turn is about to
start, through vehA / vehB / vehC / vehD (6-bit inputs, 0-63). Worth being
clear about: this module isn't counting cars itself - it just expects
that number to already be sitting on those input pins, coming from
whatever sensor or camera setup is feeding it.

### What's going on inside

- road - whose turn it is right now (0=A, 1=B, 2=C, 3=D)
- phase - 0=green, 1=yellow, 2=all-red gap, 3=startup hold
- timer - seconds elapsed in whatever phase we're currently in
- green_time - the green duration picked for the road currently active
- clk_div / slow_clk - just a clock divider so that one tick of slow_clk
  equals 1 real second. Everything above is timed off that.

## How to actually run this

If you just want to simulate it:
1. Add rtl/traffic_light_controller.v as a design source in Vivado, and
   tb/traffic_light_controller_tb.v as a simulation source.
2. Flow Navigator -> Run Simulation -> Run Behavioral Simulation.
3. Check the waveform for lightA/B/C/D and the internal road / phase /
   timer signals, or just read the $monitor prints in the Tcl console.

If you're putting it on actual hardware:
1. Bump clk_div's compare value in traffic_light_controller.v up to
   match your board's real clock - e.g. 49_999_999 if you're on a
   100 MHz clock, so slow_clk ticks once per second instead of once
   every few cycles like it does for simulation.
2. Add constraints/traffic_light.xdc and edit the pin numbers for
   whatever board you're actually using.
3. Generate Bitstream, program the device, done.

## Stuff this doesn't handle (yet)

Being upfront about the gaps rather than pretending this is a finished
product:

- No pedestrian signal or crossing button
- No way for an emergency vehicle to interrupt the cycle
- Vehicle counting itself isn't part of this — it's assumed to come in
  from outside
- If a lamp fails, or the FSM somehow ends up in a weird state, there's
  no fallback (a flashing all-red mode would be the obvious fix)
- The timing is just a basic clock divider, so it'll drift a little over
  long uptimes on real hardware — not an issue for a demo board, would
  matter for anything actually deployed on a real road
