// RUN: aiecc.py --sysroot=%VITIS_SYSROOT% --host-target=aarch64-linux-gnu %s -I%aie_runtime_lib% %aie_runtime_lib%/test_library.cpp %S/test.cpp -o test.elf

module @aie_module  {
  %t70 = AIE.tile(7, 0)
  %t72 = AIE.tile(7, 2)

  %10 = AIE.lock(%t72, 1) {sym_name = "inter_lock"}
  %lock1 = AIE.lock(%t70, 1) {sym_name = "input_lock"}
  %lock2 = AIE.lock(%t70, 2) {sym_name = "output_lock"}

  %11 = AIE.buffer(%t72) {sym_name = "buf1"} : memref<256xi32>
  %buf_i = AIE.external_buffer {sym_name = "input"} : memref<256xi32>
  %buf_o = AIE.external_buffer {sym_name = "output"} : memref<257xi32>

  %12 = AIE.mem(%t72)  {
    %srcDma = AIE.dmaStart("S2MM", 0, ^bb2, ^dma0)
  ^dma0:
    %dstDma = AIE.dmaStart("MM2S", 0, ^bb3, ^end)
  ^bb2:
    AIE.useLock(%10, Acquire, 0)
    AIE.dmaBd(<%11 : memref<256xi32>, 0, 256>, 0)
    AIE.useLock(%10, Release, 1)
    AIE.nextBd ^bb2
  ^bb3:
    AIE.useLock(%10, Acquire, 1)
    AIE.dmaBdPacket(0x6, 10)
    AIE.dmaBd(<%11 : memref<256xi32>, 0, 256>, 0)
    AIE.nextBd ^bb3
  ^end:
    AIE.end
  }

  %dma = AIE.shimDMA(%t70)  {
    AIE.dmaStart("MM2S", 0, ^bb0, ^dma0)
  ^dma0:
    AIE.dmaStart("S2MM", 0, ^bb1, ^end)
  ^bb0:
    AIE.useLock(%lock1, Acquire, 1)
    AIE.dmaBdPacket(0x2, 3)
    AIE.dmaBd(<%buf_i : memref<256xi32>, 0, 256>, 0)
    AIE.useLock(%lock1, Release, 0)
    AIE.nextBd ^bb0
  ^bb1:
    AIE.useLock(%lock2, Acquire, 0)
    AIE.dmaBd(<%buf_o : memref<257xi32>, 0, 257>, 0)
    AIE.useLock(%lock2, Release, 1)
    AIE.nextBd ^bb1
  ^end:
    AIE.end
  }

  AIE.packet_flow(0x3) {
    AIE.packet_source<%t70, DMA : 0>
    AIE.packet_dest<%t72, DMA : 0>
  }
  
  AIE.packet_flow(0xA) {
    AIE.packet_source<%t72, DMA : 0>
    AIE.packet_dest<%t70, DMA : 0>
  }
}
