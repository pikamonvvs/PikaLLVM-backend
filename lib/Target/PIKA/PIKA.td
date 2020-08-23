//===-- PIKA.td - Describe the PIKA Target Machine -------*- tabPIKAen -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This is the top level entry point for the PIKA target.
//
//===----------------------------------------------------------------------===//

//===----------------------------------------------------------------------===//
// Target-independent interfaces which we are implementing
//===----------------------------------------------------------------------===//

include "llvm/Target/Target.td"

//===----------------------------------------------------------------------===//
// Descriptions
//===----------------------------------------------------------------------===//

include "PIKARegisterInfo.td"
include "PIKAInstrInfo.td"
include "PIKACallingConv.td"

def PIKAInstrInfo : InstrInfo;

//===----------------------------------------------------------------------===//
// PIKA processors supported.
//===----------------------------------------------------------------------===//

class Proc<string Name, list<SubtargetFeature> Features>
    : Processor<Name, NoItineraries, Features>;

def : Proc<"generic", []>;

//===----------------------------------------------------------------------===//
// Declare the target which we are implementing
//===----------------------------------------------------------------------===//

def PIKA : Target {
  let InstructionSet = PIKAInstrInfo;
}
