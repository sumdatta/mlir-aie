//===- Passes.h - AIE Vector Passes -----------------------------*- C++ -*-===//
//
// This file is licensed under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
// (c) Copyright 2022 Xilinx Inc.
//
//===----------------------------------------------------------------------===//
// Register all the AIE vectorization passes
//===----------------------------------------------------------------------===//

#ifndef AIE_DIALECT_AIEVEC_TRANSFORMS_PASSES_H
#define AIE_DIALECT_AIEVEC_TRANSFORMS_PASSES_H

#include "mlir/Pass/Pass.h"
#include "mlir/Pass/PassOptions.h"
#include <limits>

namespace mlir {

class AffineDialect;

namespace func {
class FuncDialect;
} // end namespace func

namespace arith {
class ArithDialect;
} // end namespace arith

namespace memref {
class MemRefDialect;
} // end namespace memref

namespace scf {
class SCFDialect;
} // end namespace scf

namespace vector {
class VectorDialect;
} // end namespace vector

} // end namespace mlir

//===----------------------------------------------------------------------===//
// Registration
//===----------------------------------------------------------------------===//

namespace mlir {
namespace func {
class FuncOp;
} // namespace func
} // namespace mlir

namespace xilinx {
namespace aievec {

#define GEN_PASS_DECL
#define GEN_PASS_CLASSES
#include "aie/Dialect/AIEVec/Transforms/Passes.h.inc"

std::unique_ptr<Pass> createAIEVectorizePass();

std::unique_ptr<Pass>
createConvertVectorToAIEVecPass(const ConvertVectorToAIEVecOptions &options);

/// Generate the code for registering passes.
#define GEN_PASS_REGISTRATION
#include "aie/Dialect/AIEVec/Transforms/Passes.h.inc"

} // end namespace aievec
} // end namespace xilinx

#endif // AIE_DIALECT_AIEVEC_TRANSFORMS_PASSES_H
