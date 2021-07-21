//===-- PIKAFixupKinds.h - PIKA-Specific Fixup Entries ------------*- C++ -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_PIKAFIXUPKINDS_H
#define LLVM_PIKAFIXUPKINDS_H

#include "llvm/MC/MCFixup.h"

namespace llvm {
namespace PIKA {
enum Fixups {
  fixup_pika_mov_hi16_pcrel = FirstTargetFixupKind,
  fixup_pika_mov_lo16_pcrel,

  // Pure 32 but data fixup
  fixup_PIKA_NONE,
  fixup_PIKA_32,

  // Marker
  LastTargetFixupKind,
  NumTargetFixupKinds = LastTargetFixupKind - FirstTargetFixupKind
};
}
}

#endif

