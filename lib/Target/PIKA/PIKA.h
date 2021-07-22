//===-- PIKA.h - Top-level interface for PIKA representation --*- C++ -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file contains the entry points for global functions defined in the LLVM
// PIKA back-end.
//
//===----------------------------------------------------------------------===//

#ifndef TARGET_PIKA_H
#define TARGET_PIKA_H

#include "MCTargetDesc/PIKAMCTargetDesc.h"
#include "llvm/Target/TargetMachine.h"

namespace PIKACC {
  // PIKA specific condition codes
  enum CondCodes {
//    COND_U      = 0,    // unconditional
//    COND_C      = 8,    // carry
//    COND_N      = 4,    // negative
//    COND_V      = 2,    // overflow
//    COND_Z      = 1,    // zero
//    COND_NC     = 7,    // not carry
//    COND_NN     = 11,   // not negative
//    COND_NV     = 13,   // not overflow
//    COND_NZ     = 14,   // not zero
//    COND_GE     = 6,    // greater or equal
//    COND_L      = 9,    // less than
                        //                   U L G E
    COND_EQ     = 1,    // equal             0 0 0 1
    COND_GT     = 2,    // greater than      0 0 1 0
    COND_GE     = 3,    // greater or equal  0 0 1 1
    COND_LT     = 4,    // less than         0 1 0 0
    COND_LE     = 5,    // less or equal     0 1 0 1
    COND_NE     = 6,    // not equal         0 1 1 0

    COND_INVALID = -1
  };
}

namespace llvm {
class TargetMachine;
class PIKATargetMachine;

FunctionPass *createPIKAISelDag(PIKATargetMachine &TM,
                               CodeGenOpt::Level OptLevel);
} // end namespace llvm;

#endif
