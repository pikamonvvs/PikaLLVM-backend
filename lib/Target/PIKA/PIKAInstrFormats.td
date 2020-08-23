//===-- PIKAInstrFormats.td - PIKA Instruction Formats ---*- tablegen -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

//===----------------------------------------------------------------------===//
// Instruction format superclass
//===----------------------------------------------------------------------===//
class PIKAInst<dag outs, dag ins, string asmstr, list<dag> pattern>
    : Instruction {
  field bits<32> Inst;

  let Namespace = "PIKA";
  dag OutOperandList = outs;
  dag InOperandList = ins;
  let AsmString = asmstr;
  let Pattern = pattern;
  let Size = 4;
}

// PIKA pseudo instructions format
class PseudoInst<dag outs, dag ins, string asmstr, list<dag> pattern>
    : PIKAInst<outs, ins, asmstr, pattern> {
  let isPseudo = 1;
}

