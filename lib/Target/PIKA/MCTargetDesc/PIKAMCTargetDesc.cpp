//===-- PIKAMCTargetDesc.cpp - PIKA Target Descriptions -----------------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file provides PIKA specific target descriptions.
//
//===----------------------------------------------------------------------===//

#include "PIKAMCTargetDesc.h"
#include "InstPrinter/PIKAInstPrinter.h"
#include "PIKAMCAsmInfo.h"
#include "llvm/MC/MCCodeGenInfo.h"
#include "llvm/MC/MCInstrInfo.h"
#include "llvm/MC/MCRegisterInfo.h"
#include "llvm/MC/MCSubtargetInfo.h"
#include "llvm/MC/MCStreamer.h"
#include "llvm/Support/ErrorHandling.h"
#include "llvm/Support/FormattedStream.h"
#include "llvm/Support/TargetRegistry.h"

#define GET_INSTRINFO_MC_DESC
#include "PIKAGenInstrInfo.inc"

#define GET_SUBTARGETINFO_MC_DESC
#include "PIKAGenSubtargetInfo.inc"

#define GET_REGINFO_MC_DESC
#include "PIKAGenRegisterInfo.inc"

using namespace llvm;

static MCInstrInfo *createPIKAMCInstrInfo() {
  MCInstrInfo *X = new MCInstrInfo();
  InitPIKAMCInstrInfo(X);
  return X;
}

static MCRegisterInfo *createPIKAMCRegisterInfo(const Triple &TT) {
  MCRegisterInfo *X = new MCRegisterInfo();
  InitPIKAMCRegisterInfo(X, PIKA::LR);
  return X;
}

static MCSubtargetInfo *createPIKAMCSubtargetInfo(const Triple &TT,
                                                 StringRef CPU,
                                                 StringRef FS) {
  return createPIKAMCSubtargetInfoImpl(TT, CPU, FS);
}

static MCAsmInfo *createPIKAMCAsmInfo(const MCRegisterInfo &MRI,
                                     const Triple &TT) {
  return new PIKAMCAsmInfo(TT);
}

static MCCodeGenInfo *createPIKAMCCodeGenInfo(const Triple &TT, Reloc::Model RM,
                                             CodeModel::Model CM,
                                             CodeGenOpt::Level OL) {
  MCCodeGenInfo *X = new MCCodeGenInfo();
  if (RM == Reloc::Default) {
    RM = Reloc::Static;
  }
  if (CM == CodeModel::Default) {
    CM = CodeModel::Small;
  }
  if (CM != CodeModel::Small && CM != CodeModel::Large) {
    report_fatal_error("Target only supports CodeModel Small or Large");
  }

  X->initMCCodeGenInfo(RM, CM, OL);
  return X;
}

static MCInstPrinter *
createPIKAMCInstPrinter(const Triple &TT, unsigned SyntaxVariant,
                       const MCAsmInfo &MAI, const MCInstrInfo &MII,
                       const MCRegisterInfo &MRI) {
  return new PIKAInstPrinter(MAI, MII, MRI);
}

// Force static initialization.
extern "C" void LLVMInitializePIKATargetMC() {
  // Register the MC asm info.
  RegisterMCAsmInfoFn X(ThePIKATarget, createPIKAMCAsmInfo);

  // Register the MC codegen info.
  TargetRegistry::RegisterMCCodeGenInfo(ThePIKATarget, createPIKAMCCodeGenInfo);

  // Register the MC instruction info.
  TargetRegistry::RegisterMCInstrInfo(ThePIKATarget, createPIKAMCInstrInfo);

  // Register the MC register info.
  TargetRegistry::RegisterMCRegInfo(ThePIKATarget, createPIKAMCRegisterInfo);

  // Register the MC subtarget info.
  TargetRegistry::RegisterMCSubtargetInfo(ThePIKATarget,
                                          createPIKAMCSubtargetInfo);

  // Register the MCInstPrinter
  TargetRegistry::RegisterMCInstPrinter(ThePIKATarget, createPIKAMCInstPrinter);

  // Register the ASM Backend.
  TargetRegistry::RegisterMCAsmBackend(ThePIKATarget, createPIKAAsmBackend);

  // Register the MCCodeEmitter
  TargetRegistry::RegisterMCCodeEmitter(ThePIKATarget, createPIKAMCCodeEmitter);
}
