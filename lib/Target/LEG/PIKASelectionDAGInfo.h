//===-- PIKASelectionDAGInfo.h - PIKA SelectionDAG Info -------*- C++ -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file defines the PIKA subclass for TargetSelectionDAGInfo.
//
//===----------------------------------------------------------------------===//

#ifndef PIKASELECTIONDAGINFO_H
#define PIKASELECTIONDAGINFO_H

#include "llvm/Target/TargetSelectionDAGInfo.h"

namespace llvm {

class PIKASelectionDAGInfo : public TargetSelectionDAGInfo {
public:
  ~PIKASelectionDAGInfo();
};
}

#endif
