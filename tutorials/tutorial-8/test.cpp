//===- test.cpp -------------------------------------------------*- C++ -*-===//
//
// This file is licensed under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
// Copyright (C) 2022, Advanced Micro Devices, Inc.
//
//===----------------------------------------------------------------------===//

#include "test_library.h"
#include <cassert>
#include <cmath>
#include <cstdio>
#include <cstring>
#include <fcntl.h>
#include <stdlib.h>
#include <sys/mman.h>
#include <thread>
#include <unistd.h>
#include <xaiengine.h>

#include "aie_inc.cpp"

int main(int argc, char *argv[]) {
  printf("Tutorial-8 test start.\n");

  // Standard helper function for initializing and configuring AIE array.
  // The host is used to initialize/ configure/ program the AIE array.
  // ------------------------------------------------------------------------
  // aie_libxaie_ctx_t - AIE config struct
  // mlir_aie_init_device ##### TODO #######
  // mlir_aie_configure_cores - Reset cores and locks. Load elfs.
  // mlir_aie_configure_switchboxes - Switchboxes not used in this example.
  // mlir_aie_configure_dmas - TileDMAs not used in this example.
  // mlir_aie_initialize_locks - Locks not used in this example.
  aie_libxaie_ctx_t *_xaie = mlir_aie_init_libxaie();
  mlir_aie_init_device(_xaie);
  mlir_aie_configure_cores(_xaie);
  mlir_aie_configure_switchboxes(_xaie);
  mlir_aie_configure_dmas(_xaie);
  mlir_aie_initialize_locks(_xaie);

  int errors = 0;

  // Helper function to clear tile data memory
  mlir_aie_clear_tile_memory(_xaie, 2, 3);

  // Check the buffer value at index 3 to ensure it is zeroed out
  // prior to running our simple kernel.
  // ------------------------------------------------------------------------
  // mlir_aie_read_buffer_a14 - helper function to read tile local
  // memory at an offset (offset=3 in this case). _a14 maps to the
  // symbolic buffer name defined in aie.mlir.
  //
  // mlir_aie_check - helper function to compare values to expected
  // golden value and print error message to stdout and increment
  // "errors" variable if mismatch occurs.
  mlir_aie_check("Before start cores:", mlir_aie_read_buffer_a23(_xaie, 5), 0,
                 errors);

  // Helper function to enable all AIE cores
  printf("Start cores\n");
  mlir_aie_start_cores(_xaie);

  // Wait time for cores to run. Number used here is much larger than needed.
  if (mlir_aie_acquire_lock_13_2(_xaie, 1, 1000) == XAIE_OK)
    printf("Acquired lock_13_2 (1) in tile (1,3). Done.\n");
  else
    printf("Timed out (1000) while trying to acquire lock_13_2 (1).\n");

  // Check buffer at index 5 again for expected value of 114 for tile(2,3)
  printf("Checking buf[5] = 114 for tile(2,3).\n");
  mlir_aie_check("After start cores:", mlir_aie_read_buffer_a23(_xaie, 5), 114,
                 errors);

  // Print Pass/Fail result of our test
  int res = 0;
  if (!errors) {
    printf("PASS!\n");
    res = 0;
  } else {
    printf("Fail!\n");
    res = -1;
  }

  // Teardown and cleanup of AIE array
  mlir_aie_deinit_libxaie(_xaie);

  printf("Tutorial-8 test done.\n");
  return res;
}
