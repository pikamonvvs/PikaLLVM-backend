//===-- PIKARegisterInfo.cpp - PIKA Register Information ----------------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file contains the PIKA implementation of the MRegisterInfo class.
//
//===----------------------------------------------------------------------===//

#include "PIKARegisterInfo.h"
#include "PIKA.h"
#include "PIKAFrameLowering.h"
#include "PIKAInstrInfo.h"
#include "PIKAMachineFunctionInfo.h"
#include "llvm/ADT/BitVector.h"
#include "llvm/ADT/STLExtras.h"
#include "llvm/CodeGen/MachineFrameInfo.h"
#include "llvm/CodeGen/MachineFunction.h"
#include "llvm/CodeGen/MachineInstrBuilder.h"
#include "llvm/CodeGen/MachineModuleInfo.h"
#include "llvm/CodeGen/MachineRegisterInfo.h"
#include "llvm/CodeGen/RegisterScavenging.h"
#include "llvm/IR/Function.h"
#include "llvm/IR/Type.h"
#include "llvm/Support/Debug.h"
#include "llvm/Support/ErrorHandling.h"
#include "llvm/Support/MathExtras.h"
#include "llvm/Support/raw_ostream.h"
#include "llvm/Target/TargetFrameLowering.h"
#include "llvm/Target/TargetMachine.h"
#include "llvm/Target/TargetOptions.h"

#define GET_REGINFO_TARGET_DESC
#include "PIKAGenRegisterInfo.inc"

using namespace llvm;

PIKARegisterInfo::PIKARegisterInfo() : PIKAGenRegisterInfo(PIKA::LR) {}

const uint16_t *
PIKARegisterInfo::getCalleeSavedRegs(const MachineFunction *MF) const {
  static const uint16_t CalleeSavedRegs[] = { PIKA::R6,  PIKA::R7,  PIKA::R8,
                                              PIKA::R9,  PIKA::R10, PIKA::R11,
                                              PIKA::R12, PIKA::R13,
                                              0 };
  return CalleeSavedRegs;
}

BitVector PIKARegisterInfo::getReservedRegs(const MachineFunction &MF) const {
  BitVector Reserved(getNumRegs());

  Reserved.set(PIKA::SP);
  Reserved.set(PIKA::LR);
  return Reserved;
}

const uint32_t *PIKARegisterInfo::getCallPreservedMask(const MachineFunction &MF,
                                                      CallingConv::ID) const {
  return CC_Save_RegMask;
}

bool
PIKARegisterInfo::requiresRegisterScavenging(const MachineFunction &MF) const {
  return true;
}

bool
PIKARegisterInfo::trackLivenessAfterRegAlloc(const MachineFunction &MF) const {
  return true;
}

bool PIKARegisterInfo::useFPForScavengingIndex(const MachineFunction &MF) const {
  return false;
}

void PIKARegisterInfo::eliminateFrameIndex(MachineBasicBlock::iterator II,
                                          int SPAdj, unsigned FIOperandNum,
                                          RegScavenger *RS) const {
  MachineInstr &MI = *II;
  const MachineFunction &MF = *MI.getParent()->getParent();
  const MachineFrameInfo *MFI = MF.getFrameInfo();
  MachineOperand &FIOp = MI.getOperand(FIOperandNum);
  unsigned FI = FIOp.getIndex();

  // Determine if we can eliminate the index from this kind of instruction.
  unsigned ImmOpIdx = 0;
  switch (MI.getOpcode()) {
  default:
    // Not supported yet.
    return;
  case PIKA::LD:
  case PIKA::STR:
    ImmOpIdx = FIOperandNum + 1;
    break;
  }

  // FIXME: check the size of offset.
  MachineOperand &ImmOp = MI.getOperand(ImmOpIdx);
  int Offset = MFI->getObjectOffset(FI) + MFI->getStackSize() + ImmOp.getImm();
  FIOp.ChangeToRegister(PIKA::SP, false);
  ImmOp.setImm(Offset);
}

unsigned PIKARegisterInfo::getFrameRegister(const MachineFunction &MF) const {
  return PIKA::SP;
}
