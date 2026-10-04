# Traffic Light Controller (Verilog, Vivado)

An adaptive 4-way traffic light controller written in Verilog. Instead of a
fixed-time cycle, each road's green duration is picked from how many
vehicles are waiting on it, with a safety gap built in between phases.

## How it works

Four roads — A, B, C, D — are served in round-robin order (A -> B -> C -> D -> A...).
Each road goes through up to four phases:

1. **Green** — duration depends on vehicle count (see table below)
2. **Yellow** — fixed, 5 seconds
3. **All-red safety gap** — fixed, 2 seconds (every road red, so the
   intersection has time to clear before the next road gets green)
4. *(once, only right after reset)* **Startup hold** — 2 seconds all-red
   before the very first green, instead of jumping straight into green

Light encoding per road (3 bits, one bit ON at a time):
`GREEN = 100`, `YELLOW = 010`, `RED = 001`.

### Adaptive green time

| Vehicle count (per lane) | Green time |
|---------------------------|------------|
| 0 - 15                     | 30 sec     |
| 16 - 30                    | 60 sec     |
| more than 30                | 90 sec     |

The vehicle count for a road is read once, right as that road's turn is
about to start (from `vehA`/`vehB`/`vehC`/`vehD`, 6-bit inputs, 0-63) —
this module does not count vehicles itself, it expects that number from an
external sensor/vision system.

### Internal registers

- `road` — which road currently has the turn (0=A, 1=B, 2=C, 3=D)
- `phase` — 0=green, 1=yellow, 2=all-red gap, 3=startup hold
- `timer` — seconds elapsed in the current phase
- `green_time` — the chosen green duration for the current road
- `clk_div` / `slow_clk` — divides the input clock down so one `slow_clk`
  tick = 1 second, which is the "time unit" everything above is measured in

## Repo structure

```
traffic_light_controller/
├── README.md
├── .gitignore
├── rtl/
│   └── traffic_light_controller.v    # the design (module traffic_light_controller_)
├── tb/
│   └── traffic_light_controller_tb.v # testbench
└── constraints/
    └── traffic_light.xdc             # example board pin mapping (Basys3-style)
```

## Running it in Vivado

**Simulation:**
1. Create/open the Vivado project, add `rtl/traffic_light_controller.v` as a
   design source and `tb/traffic_light_controller_tb.v` as a simulation source.
2. Flow Navigator -> Run Simulation -> Run Behavioral Simulation.
3. Watch `lightA/B/C/D` and the internal `road`/`phase`/`timer` in the
   waveform, or read the `$monitor` output in the Tcl console.

**On real hardware:**
1. Change `clk_div`'s compare value in `traffic_light_controller.v` from the
   small simulation value back up to match your board's real clock (e.g.
   `49_999_999` for a 100 MHz clock, so `slow_clk` ticks once per second).
2. Add `constraints/traffic_light.xdc`, editing the pin numbers for your
   actual board.
3. Generate Bitstream -> program device.

## Known limitations & ideas for improvement

- No pedestrian phase or push button.
- No emergency-vehicle preemption input.
- Vehicle counts are read as plain inputs — the sensor/vision circuit that
  produces them isn't part of this design.
- No fault detection if a lamp fails or the FSM lands in an unexpected
  state (e.g. due to a glitch) — a flashing-all-red fallback would be a
  good addition for real deployment.
- Timing is based on a simple clock-divider prescaler, which will drift
  slightly over long uptimes on real hardware — fine for a demo/portfolio
  board, not for a certified traffic system.
