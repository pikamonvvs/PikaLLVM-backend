//===-- PIKATargetMachine.h - Define TargetMachine for PIKA ---*- C++ -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file declares the PIKA specific subclass of TargetMachine.
//
//===----------------------------------------------------------------------===//

#ifndef PIKATARGETMACHINE_H
#define PIKATARGETMACHINE_H

#include "PIKA.h"
#include "PIKAFrameLowering.h"
#include "PIKAISelLowering.h"
#include "PIKAInstrInfo.h"
#include "PIKASelectionDAGInfo.h"
#include "PIKASubtarget.h"
#include "llvm/IR/DataLayout.h"
#include "llvm/Target/TargetMachine.h"

namespace llvm {

class PIKATargetMachine : public LLVMTargetMachine {
  PIKASubtarget Subtarget;
  std::unique_ptr<TargetLoweringObjectFile> TLOF;

public:
  PIKATargetMachine(const Target &T, const Triple &TT, StringRef CPU,
                   StringRef FS, const TargetOptions &Options, Reloc::Model RM,
                   CodeModel::Model CM, CodeGenOpt::Level OL);
  
  const PIKASubtarget * getSubtargetImpl() const {
    return &Subtarget;
  }
  
  virtual const TargetSubtargetInfo *
  getSubtargetImpl(const Function &) const override {
    return &Subtarget;
  }

  // Pass Pipeline Configuration
  virtual TargetPassConfig *createPassConfig(PassManagerBase &PM) override;
  
  TargetLoweringObjectFile *getObjFileLowering() const override {
    return TLOF.get();
  }
};

} // end namespace llvm

#endif
