//===-- PIKAMCAsmInfo.h - PIKA asm properties --------------------*- C++ -*--===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file contains the declaration of the PIKAMCAsmInfo class.
//
//===----------------------------------------------------------------------===//

#ifndef PIKATARGETASMINFO_H
#define PIKATARGETASMINFO_H

#include "llvm/MC/MCAsmInfoELF.h"

namespace llvm {
class StringRef;
class Target;
class Triple;

class PIKAMCAsmInfo : public MCAsmInfoELF {
  virtual void anchor();

public:
  explicit PIKAMCAsmInfo(const Triple &TT);
};

} // namespace llvm

#endif
