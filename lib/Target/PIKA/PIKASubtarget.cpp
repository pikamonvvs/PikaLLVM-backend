//===-- PIKASubtarget.cpp - PIKA Subtarget Information ------------------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file implements the PIKA specific subclass of TargetSubtargetInfo.
//
//===----------------------------------------------------------------------===//

#include "PIKASubtarget.h"
#include "PIKA.h"
#include "llvm/Support/TargetRegistry.h"

#define DEBUG_TYPE "pika-subtarget"

#define GET_SUBTARGETINFO_TARGET_DESC
#define GET_SUBTARGETINFO_CTOR
#include "PIKAGenSubtargetInfo.inc"

using namespace llvm;

void PIKASubtarget::anchor() {}

PIKASubtarget::PIKASubtarget(const Triple &TT, StringRef CPU, StringRef FS,
                           PIKATargetMachine &TM)
    : PIKAGenSubtargetInfo(TT, CPU, FS),
      DL("e-m:e-p:32:32-i1:8:32-i8:8:32-i16:16:32-i64:32-f64:32-a:0:32-n32"),
      InstrInfo(), TLInfo(TM), TSInfo(), FrameLowering() {}
