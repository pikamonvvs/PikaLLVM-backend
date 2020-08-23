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

namespace llvm {
class TargetMachine;
class PIKATargetMachine;

FunctionPass *createPIKAISelDag(PIKATargetMachine &TM,
                               CodeGenOpt::Level OptLevel);
} // end namespace llvm;

#endif
