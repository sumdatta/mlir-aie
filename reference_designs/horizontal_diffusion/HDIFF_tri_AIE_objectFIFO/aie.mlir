// (c) 2023 SAFARI Research Group at ETH Zurich, Gagandeep Singh, D-ITET
//
//===----------------------------------------------------------------------===//


module @hdiff_tri_AIE{
  %t75 = AIE.tile(7, 5)
  %t74 = AIE.tile(7, 4)
  %t73 = AIE.tile(7, 3)
  %t72 = AIE.tile(7, 2)
  %t71 = AIE.tile(7, 1)
  %t70 = AIE.tile(7, 0)
  
  %lock73_14 = AIE.lock(%t73, 14) { sym_name = "lock73_14" }
  %lock75_14 = AIE.lock(%t75, 14) { sym_name = "lock75_14" }

  %obj_fifo_in = AIE.objectFifo.createObjectFifo(%t70, {%t73,%t74}, 6) {sym_name = "" }: !AIE.objectFifo<memref<256xi32>>
  %obj_fifo_out_lap = AIE.objectFifo.createObjectFifo(%t73, {%t74}, 5){sym_name = "obj_out_lap" } : !AIE.objectFifo<memref<256xi32>>
  %obj_fifo_out_flux_inter1 = AIE.objectFifo.createObjectFifo(%t74, {%t75}, 6){sym_name = "obj_out_flux_inter1" } : !AIE.objectFifo<memref<512xi32>>
  // %obj_fifo_out_flux_inter2 = AIE.objectFifo.createObjectFifo(%t74, {%t75}, 2){sym_name = "obj_out_flux_inter2" } : !AIE.objectFifo<memref<1280xi32>>
  %obj_fifo_out_flux = AIE.objectFifo.createObjectFifo(%t75, {%t70}, 2){sym_name = "obj_out_flux" } : !AIE.objectFifo<memref<256xi32>>
   // DDR buffer
  %ext_buffer_in0  = AIE.external_buffer  {sym_name = "ddr_test_buffer_in0"}: memref<1536 x i32>
  %ext_buffer_out = AIE.external_buffer  {sym_name = "ddr_test_buffer_out"}: memref<512 x i32>
      
  // Register the external memory pointers to the object FIFOs.
  AIE.objectFifo.registerExternalBuffers(%t70, %obj_fifo_in : !AIE.objectFifo<memref<256xi32>>, {%ext_buffer_in0}) : (memref<1536xi32>)
  AIE.objectFifo.registerExternalBuffers(%t70, %obj_fifo_out_flux : !AIE.objectFifo<memref<256xi32>>, {%ext_buffer_out}) : (memref<512xi32>)


  func.func private @hdiff_lap(%AL: memref<256xi32>,%BL: memref<256xi32>, %CL:  memref<256xi32>, %DL: memref<256xi32>, %EL:  memref<256xi32>,  %OLL1: memref<256xi32>,  %OLL2: memref<256xi32>,  %OLL3: memref<256xi32>,  %OLL4: memref<256xi32>) -> ()
  func.func private @hdiff_flux1(%AF: memref<256xi32>,%BF: memref<256xi32>, %CF:  memref<256xi32>,   %OLF1: memref<256xi32>,  %OLF2: memref<256xi32>,  %OLF3: memref<256xi32>,  %OLF4: memref<256xi32>,  %OFI1: memref<512xi32>,  %OFI2: memref<512xi32>,  %OFI3: memref<512xi32>,  %OFI4: memref<512xi32>,  %OFI5: memref<512xi32>) -> ()
  func.func private @hdiff_flux2( %Inter1: memref<512xi32>,%Inter2: memref<512xi32>, %Inter3: memref<512xi32>,%Inter4: memref<512xi32>,%Inter5: memref<512xi32>,  %Out: memref<256xi32>) -> ()

  %c13 = AIE.core(%t73) { 
    
    %lb = arith.constant 0 : index
    %ub = arith.constant 2: index
    %step = arith.constant 1 : index
    AIE.useLock(%lock73_14, "Acquire", 0) // start the timer
    scf.for %iv = %lb to %ub step %step {  
      %obj_in_subview = AIE.objectFifo.acquire<Consume>(%obj_fifo_in : !AIE.objectFifo<memref<256xi32>>, 5) : !AIE.objectFifoSubview<memref<256xi32>>
      %row0 = AIE.objectFifo.subview.access %obj_in_subview[0] : !AIE.objectFifoSubview<memref<256xi32>> -> memref<256xi32>
      %row1 = AIE.objectFifo.subview.access %obj_in_subview[1] : !AIE.objectFifoSubview<memref<256xi32>> -> memref<256xi32>
      %row2 = AIE.objectFifo.subview.access %obj_in_subview[2] : !AIE.objectFifoSubview<memref<256xi32>> -> memref<256xi32>
      %row3 = AIE.objectFifo.subview.access %obj_in_subview[3] : !AIE.objectFifoSubview<memref<256xi32>> -> memref<256xi32>
      %row4 = AIE.objectFifo.subview.access %obj_in_subview[4] : !AIE.objectFifoSubview<memref<256xi32>> -> memref<256xi32>


      %obj_out_subview_lap = AIE.objectFifo.acquire<Produce>(%obj_fifo_out_lap : !AIE.objectFifo<memref<256xi32>>, 4 ) : !AIE.objectFifoSubview<memref<256xi32>>
      %obj_out_lap1 = AIE.objectFifo.subview.access %obj_out_subview_lap[0] : !AIE.objectFifoSubview<memref<256xi32>> -> memref<256xi32>
      %obj_out_lap2 = AIE.objectFifo.subview.access %obj_out_subview_lap[1] : !AIE.objectFifoSubview<memref<256xi32>> -> memref<256xi32>
      %obj_out_lap3 = AIE.objectFifo.subview.access %obj_out_subview_lap[2] : !AIE.objectFifoSubview<memref<256xi32>> -> memref<256xi32>
      %obj_out_lap4 = AIE.objectFifo.subview.access %obj_out_subview_lap[3] : !AIE.objectFifoSubview<memref<256xi32>> -> memref<256xi32>

      func.call @hdiff_lap(%row0,%row1,%row2,%row3,%row4,%obj_out_lap1,%obj_out_lap2,%obj_out_lap3,%obj_out_lap4) : (memref<256xi32>,memref<256xi32>, memref<256xi32>, memref<256xi32>, memref<256xi32>,  memref<256xi32>,  memref<256xi32>,  memref<256xi32>,  memref<256xi32>) -> ()
      AIE.objectFifo.release<Produce>(%obj_fifo_out_lap : !AIE.objectFifo<memref<256xi32>>, 1)
      AIE.objectFifo.release<Produce>(%obj_fifo_out_lap : !AIE.objectFifo<memref<256xi32>>, 1)
      AIE.objectFifo.release<Produce>(%obj_fifo_out_lap : !AIE.objectFifo<memref<256xi32>>, 1)
      AIE.objectFifo.release<Produce>(%obj_fifo_out_lap : !AIE.objectFifo<memref<256xi32>>, 1)
      AIE.objectFifo.release<Consume>(%obj_fifo_in : !AIE.objectFifo<memref<256xi32>>, 1)

    }
    AIE.objectFifo.release<Consume>(%obj_fifo_in : !AIE.objectFifo<memref<256xi32>>, 4)

    AIE.end
  } { link_with="hdiff_lap.o" }


  %c14 = AIE.core(%t74) { 
    %lb = arith.constant 0 : index
    %ub = arith.constant 2: index
    %step = arith.constant 1 : index
    scf.for %iv = %lb to %ub step %step {  
      %obj_in_subview = AIE.objectFifo.acquire<Consume>(%obj_fifo_in : !AIE.objectFifo<memref<256xi32>>, 5) : !AIE.objectFifoSubview<memref<256xi32>>
      // %row0 = AIE.objectFifo.subview.access %obj_in_subview[0] : !AIE.objectFifoSubview<memref<256xi32>> -> memref<256xi32>
      %row1 = AIE.objectFifo.subview.access %obj_in_subview[1] : !AIE.objectFifoSubview<memref<256xi32>> -> memref<256xi32>
      %row2 = AIE.objectFifo.subview.access %obj_in_subview[2] : !AIE.objectFifoSubview<memref<256xi32>> -> memref<256xi32>
      %row3 = AIE.objectFifo.subview.access %obj_in_subview[3] : !AIE.objectFifoSubview<memref<256xi32>> -> memref<256xi32>
      // %row4 = AIE.objectFifo.subview.access %obj_in_subview[4] : !AIE.objectFifoSubview<memref<256xi32>> -> memref<256xi32>
      %obj_out_subview_lap = AIE.objectFifo.acquire<Consume>(%obj_fifo_out_lap : !AIE.objectFifo<memref<256xi32>>, 4) : !AIE.objectFifoSubview<memref<256xi32>>
      %obj_out_lap1 = AIE.objectFifo.subview.access %obj_out_subview_lap[0] : !AIE.objectFifoSubview<memref<256xi32>> -> memref<256xi32>
      %obj_out_lap2 = AIE.objectFifo.subview.access %obj_out_subview_lap[1] : !AIE.objectFifoSubview<memref<256xi32>> -> memref<256xi32>
      %obj_out_lap3 = AIE.objectFifo.subview.access %obj_out_subview_lap[2] : !AIE.objectFifoSubview<memref<256xi32>> -> memref<256xi32>
      %obj_out_lap4 = AIE.objectFifo.subview.access %obj_out_subview_lap[3] : !AIE.objectFifoSubview<memref<256xi32>> -> memref<256xi32>

      %obj_out_subview_flux1 = AIE.objectFifo.acquire<Produce>(%obj_fifo_out_flux_inter1 : !AIE.objectFifo<memref<512xi32>>, 5) : !AIE.objectFifoSubview<memref<512xi32>>
      %obj_out_flux_inter1 = AIE.objectFifo.subview.access %obj_out_subview_flux1[0] : !AIE.objectFifoSubview<memref<512xi32>> -> memref<512xi32>

      // %obj_out_subview_flux2 = AIE.objectFifo.acquire<Produce>(%obj_fifo_out_flux_inter2 : !AIE.objectFifo<memref<1280xi32>>, 1) : !AIE.objectFifoSubview<memref<1280xi32>>
      %obj_out_flux_inter2 = AIE.objectFifo.subview.access %obj_out_subview_flux1[1] : !AIE.objectFifoSubview<memref<512xi32>> -> memref<512xi32>
      %obj_out_flux_inter3 = AIE.objectFifo.subview.access %obj_out_subview_flux1[2] : !AIE.objectFifoSubview<memref<512xi32>> -> memref<512xi32>
      %obj_out_flux_inter4 = AIE.objectFifo.subview.access %obj_out_subview_flux1[3] : !AIE.objectFifoSubview<memref<512xi32>> -> memref<512xi32>
      %obj_out_flux_inter5 = AIE.objectFifo.subview.access %obj_out_subview_flux1[4] : !AIE.objectFifoSubview<memref<512xi32>> -> memref<512xi32>

      func.call @hdiff_flux1(%row1,%row2,%row3,%obj_out_lap1,%obj_out_lap2,%obj_out_lap3,%obj_out_lap4, %obj_out_flux_inter1 , %obj_out_flux_inter2, %obj_out_flux_inter3, %obj_out_flux_inter4, %obj_out_flux_inter5) : (memref<256xi32>,memref<256xi32>, memref<256xi32>, memref<256xi32>, memref<256xi32>, memref<256xi32>,  memref<256xi32>,  memref<512xi32>,  memref<512xi32>,  memref<512xi32>,  memref<512xi32>,  memref<512xi32>) -> ()
      AIE.objectFifo.release<Consume>(%obj_fifo_out_lap : !AIE.objectFifo<memref<256xi32>>, 4)
      AIE.objectFifo.release<Produce>(%obj_fifo_out_flux_inter1 : !AIE.objectFifo<memref<512xi32>>, 1)
      AIE.objectFifo.release<Produce>(%obj_fifo_out_flux_inter1 : !AIE.objectFifo<memref<512xi32>>, 1)
      AIE.objectFifo.release<Produce>(%obj_fifo_out_flux_inter1 : !AIE.objectFifo<memref<512xi32>>, 1)
      AIE.objectFifo.release<Produce>(%obj_fifo_out_flux_inter1 : !AIE.objectFifo<memref<512xi32>>, 1)
      AIE.objectFifo.release<Produce>(%obj_fifo_out_flux_inter1 : !AIE.objectFifo<memref<512xi32>>, 1)
      AIE.objectFifo.release<Consume>(%obj_fifo_in : !AIE.objectFifo<memref<256xi32>>, 1)
    }
    AIE.objectFifo.release<Consume>(%obj_fifo_in : !AIE.objectFifo<memref<256xi32>>, 4)

    AIE.end
  } { link_with="hdiff_flux1.o" }

  %c15 = AIE.core(%t75) { 
    %lb = arith.constant 0 : index
    %ub = arith.constant 2: index
    %step = arith.constant 1 : index
    scf.for %iv = %lb to %ub step %step {  

      %obj_out_subview_flux_inter1 = AIE.objectFifo.acquire<Consume>(%obj_fifo_out_flux_inter1 : !AIE.objectFifo<memref<512xi32>>, 5) : !AIE.objectFifoSubview<memref<512xi32>>
      %obj_flux_inter_element1 = AIE.objectFifo.subview.access %obj_out_subview_flux_inter1[0] : !AIE.objectFifoSubview<memref<512xi32>> -> memref<512xi32>

      // %obj_out_subview_flux_inter2 = AIE.objectFifo.acquire<Consume>(%obj_fifo_out_flux_inter2 : !AIE.objectFifo<memref<1280xi32>>, 1) : !AIE.objectFifoSubview<memref<1280xi32>>
      %obj_flux_inter_element2 = AIE.objectFifo.subview.access %obj_out_subview_flux_inter1[1] : !AIE.objectFifoSubview<memref<512xi32>> -> memref<512xi32>
      %obj_flux_inter_element3 = AIE.objectFifo.subview.access %obj_out_subview_flux_inter1[2] : !AIE.objectFifoSubview<memref<512xi32>> -> memref<512xi32>
      %obj_flux_inter_element4 = AIE.objectFifo.subview.access %obj_out_subview_flux_inter1[3] : !AIE.objectFifoSubview<memref<512xi32>> -> memref<512xi32>
      %obj_flux_inter_element5 = AIE.objectFifo.subview.access %obj_out_subview_flux_inter1[4] : !AIE.objectFifoSubview<memref<512xi32>> -> memref<512xi32>

      %obj_out_subview_flux = AIE.objectFifo.acquire<Produce>(%obj_fifo_out_flux : !AIE.objectFifo<memref<256xi32>>, 1) : !AIE.objectFifoSubview<memref<256xi32>>
      %obj_out_flux_element = AIE.objectFifo.subview.access %obj_out_subview_flux[0] : !AIE.objectFifoSubview<memref<256xi32>> -> memref<256xi32>


      func.call @hdiff_flux2(%obj_flux_inter_element1, %obj_flux_inter_element2,%obj_flux_inter_element3, %obj_flux_inter_element4, %obj_flux_inter_element5,  %obj_out_flux_element ) : ( memref<512xi32>,  memref<512xi32>, memref<512xi32>, memref<512xi32>, memref<512xi32>, memref<256xi32>) -> ()
      AIE.objectFifo.release<Consume>(%obj_fifo_out_flux_inter1 : !AIE.objectFifo<memref<512xi32>>, 1)
      AIE.objectFifo.release<Consume>(%obj_fifo_out_flux_inter1 : !AIE.objectFifo<memref<512xi32>>, 1)
      AIE.objectFifo.release<Consume>(%obj_fifo_out_flux_inter1 : !AIE.objectFifo<memref<512xi32>>, 1)
      AIE.objectFifo.release<Consume>(%obj_fifo_out_flux_inter1 : !AIE.objectFifo<memref<512xi32>>, 1)
      AIE.objectFifo.release<Consume>(%obj_fifo_out_flux_inter1 : !AIE.objectFifo<memref<512xi32>>, 1)
      AIE.objectFifo.release<Produce>(%obj_fifo_out_flux : !AIE.objectFifo<memref<256xi32>>, 1)
    }
    AIE.useLock(%lock75_14, "Acquire", 0) // stop the timer

    AIE.end
  } { link_with="hdiff_flux2.o" }



}

