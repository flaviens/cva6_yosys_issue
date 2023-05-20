// Copyright Flavien Solt, ETH Zurich.
// Licensed under the General Public License, Version 3.0, see LICENSE for details.
// SPDX-License-Identifier: GPL-3.0-only

#include "testbench.h"
#include "string.h"

// Stops when zero data is written to address 0, or if the PC is tainted (if applicable)
#define RUNMORETICKS_AFTER_STOP 50 // Run a bit longer in case something interesting still happens
static inline long tb_run_ticks_stoppable(Testbench *tb, int simlen, bool reset = false) {
  if (reset)
    tb->reset();

  int curr_float_req_dump_id = 0;

  auto start = std::chrono::steady_clock::now();
  for (size_t step_id = 0; step_id < simlen; step_id++) {
    tick_req_t tick_req = tb->tick();

    // Check whether we got a register dump request.
    if (tick_req.type == REQ_FLOATREGDUMP) {
      if (curr_float_req_dump_id == 3) {
        printf("Dump of reg: 0x%016lx.\n", tick_req.content);
        if (tick_req.content == 0x7ff8000000000000ULL) {
          std::cout << "TEST SUCCESSFUL." << std::endl;
        } else {
          std::cout << "TEST FAILED." << std::endl;
        }
        auto stop = std::chrono::steady_clock::now();
        long ret = std::chrono::duration_cast<std::chrono::milliseconds>(stop - start).count();
        return ret;
      }
      curr_float_req_dump_id++;
    }
  }
  std::cout << "ERROR: Did not reach floating register dump." << std::endl;

  auto stop = std::chrono::steady_clock::now();
  long ret = std::chrono::duration_cast<std::chrono::milliseconds>(stop - start).count();
  return ret;
}

/**
 * Runs the testbench.
 *
 * @param tb a pointer to a testbench instance
 * @param simlen the number of cycles to run
 */
static unsigned long run_test(Testbench *tb, int simlen, bool reset) {
    return tb_run_ticks_stoppable(tb, simlen, reset);
}

int main(int argc, char **argv, char **env) {

  Verilated::commandArgs(argc, argv);
  Verilated::traceEverOn(VM_TRACE);

  ////////
  // Initialize testbench.
  ////////

  Testbench *tb = new Testbench();

  ////////
  // Run the testbench.
  ////////

  unsigned int duration = run_test(tb, 10000, true);

  std::cout << "Elapsed time: " << std::dec << duration << "ms." << std::endl;

  delete tb;
  exit(0);
}
