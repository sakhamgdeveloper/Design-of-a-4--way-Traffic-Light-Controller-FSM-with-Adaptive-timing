# 🚦 Adaptive 4-Way Traffic Light Controller FSM with Density-Based Timing



## 📋 Project Overview

This project implements a **Finite State Machine (FSM)**-based 4-way traffic light controller in Verilog HDL. The controller manages traffic signals for all four directions — **North, South, East, and West** — and adapts green light duration dynamically based on a **traffic density input**.

Designed and verified as part of **PROJECT-4: Design of a 4-Way Traffic Light Controller FSM with Adaptive Timing**.

---

## 👥 Team

| Name | Enrollment No. | Year / Division |
|------|----------------|-----------------|
| Tanish | 202401100700195 | 2nd / C |
| Saksham Gupta | 202401100700152 | 2nd / C |

**Department of Electronics & Communication Engineering**
**Venue:** Advanced VLSI Design (CoE), B-207 | **Date:** 5th May 2026

---

## 🗂️ Repository Structure

```
├── next_node.v          # RTL Design — FSM Traffic Light Controller
├── next_node_tb.v       # Testbench — Verification of all scenarios
└── README.md            # Project documentation (this file)
```

---

## ⚙️ Design Specification

### Signal Encoding (2-bit)

| Signal | Encoding |
|--------|----------|
| GREEN  | `2'b10`  |
| YELLOW | `2'b01`  |
| RED    | `2'b00`  |

### FSM States

| State | Encoding | NS Pair | EW Pair |
|-------|----------|---------|---------|
| S0 | `2'b00` | GREEN | RED |
| S1 | `2'b01` | YELLOW | RED |
| S2 | `2'b10` | RED | GREEN |
| S3 | `2'b11` | RED | YELLOW |

### Timing Parameters

| Parameter | Value | Description |
|-----------|-------|-------------|
| `GREEN_LOW` | 5 cycles | Short green duration (low density) |
| `GREEN_HIGH` | 9 cycles | Extended green duration (high density) |
| `YELLOW_DUR` | 3 cycles | Fixed yellow duration |

---

## 🧠 How It Works

### Basic Operation
- Only **one direction pair** (NS or EW) gets GREEN at a time — no conflicting signals.
- All other directions remain **RED** while one pair is active.
- Every green phase **must transition through YELLOW** before switching to the opposite pair.

### Adaptive Timing
- When `density = 1` (HIGH traffic): Green phase **extends** by reloading `GREEN_HIGH` (9 cycles).
- When `density = 0` (LOW traffic): Green phase ends normally at `GREEN_LOW` (5 cycles) and advances to Yellow.
- Yellow phases are **always fixed** at 3 cycles regardless of density.

### FSM Architecture (3-Block Moore Design)
1. **Sequential Block** `always @(posedge clk)` — Updates `current_state` and down-counter `timer`.
2. **Next-State Logic** `always @(*)` — Computes `next_state`, `load_val`, and `timer_done` combinationally.
3. **Output Block** `always @(*)` — Drives `N_sig`, `S_sig`, `E_sig`, `W_sig` from `current_state`.

---

## 📁 Module: `next_node`

### Ports

| Port | Direction | Width | Description |
|------|-----------|-------|-------------|
| `clk` | Input | 1-bit | System clock |
| `rst` | Input | 1-bit | Synchronous active-high reset |
| `density` | Input | 1-bit | Traffic density (0=Low, 1=High) |
| `N_sig` | Output | 2-bit | North traffic signal |
| `S_sig` | Output | 2-bit | South traffic signal |
| `E_sig` | Output | 2-bit | East traffic signal |
| `W_sig` | Output | 2-bit | West traffic signal |

---

## 🧪 Testbench: `next_node_tb`

The testbench covers all required verification scenarios:

| Phase | Stimulus | What It Verifies |
|-------|----------|-----------------|
| Reset | `rst=1` for 3 cycles | FSM initialises to S0, timer loads correctly |
| LOW Density | `density=0`, 30 cycles | Full S0→S1→S2→S3→S0 cycle at short green |
| HIGH Density | `density=1`, 20 cycles | Green phases extend to 9-cycle duration |
| Return LOW | `density=0`, 20 cycles | Short green timing resumes correctly |
| Mid Reset | `rst=1` during operation | FSM returns to S0 immediately and safely |
| Post Reset | 15 more cycles | Normal operation resumes after reset release |

**Clock:** 10 ns period (`#5` toggle) | **Total Sim Time:** 905 ns

### Testbench Features
- ✅ Clock generation (`always #5 clk = ~clk`)
- ✅ Reset handling (initial and mid-operation)
- ✅ Multiple traffic density conditions
- ✅ `$display` for phase boundary markers
- ✅ `$monitor` for continuous signal logging
- ✅ `$dumpvars` for VCD waveform export

---

## 🖥️ Simulation Results

Simulated using **Cadence SimVision / ncsim**.

### Console Output (Key Transitions)
```
--- Reset Applied ---
--- Reset Released | density = LOW ---
Time=75000  | N=01 | S=01 | E=00 | W=00   ← NS Yellow (S0→S1)
Time=115000 | N=00 | S=00 | E=10 | W=10   ← EW Green  (S2)
Time=215000 | N=10 | S=10 | E=00 | W=00   ← NS Green  (back to S0)
--- Density = HIGH (green will extend) ---
Time=325000 | N=00 | S=00 | E=10 | W=10   ← EW Green extended
--- Density = LOW ---
--- Reset mid-operation ---
Time=725000 | N=10 | S=10 | E=00 | W=00   ← Reset → S0
--- Simulation Done ---
```

### Waveform Summary
- `N_sig` / `S_sig` toggle between GREEN↔YELLOW↔RED correctly across all phases.
- `E_sig` / `W_sig` are always complementary to NS pair — no conflicting greens observed.
- Density HIGH visibly spaces out transitions on the waveform (9 vs 5 cycle gap).
- Mid-operation reset immediately snaps all outputs to the S0 (NS Green) state.

---

## ▶️ How to Run

### Using Cadence ncsim
```bash
ncverilog next_node.v next_node_tb.v +access+r
```

### Using Icarus Verilog (iverilog)
```bash
iverilog -o sim next_node.v next_node_tb.v
vvp sim
gtkwave next_node_tb.vcd
```

---

## 📊 Evaluation Criteria (Total: 50 Marks)

## 📄 License

This project was created for academic purposes as part of RTL Innovate: Digital VLSI Hackfest 2026 at KIET Group of Institutions.
