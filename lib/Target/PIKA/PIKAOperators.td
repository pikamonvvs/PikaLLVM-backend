//===-- PIKAOperators.td - PIKA-specific operators ------*- tblgen-*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

//===----------------------------------------------------------------------===//
// Type profiles
//===----------------------------------------------------------------------===//

def MoveImm32Ty : SDTypeProfile<1, 1, [
  SDTCisSameAs<0, 1>, SDTCisInt<0>
]>;

def SDT_PIKACallSeqStart : SDCallSeqStart<[ SDTCisVT<0, i32> ]>;

def SDT_PIKACallSeqEnd   : SDCallSeqEnd<[
  SDTCisVT<0, i32>, SDTCisVT<1, i32>
]>;

def PIKARetFlag    : SDNode<"PIKAISD::RET_FLAG", SDTNone,
                           [SDNPHasChain, SDNPOptInGlue, SDNPVariadic]>;
def callseq_start : SDNode<"ISD::CALLSEQ_START", SDT_PIKACallSeqStart,
                           [SDNPHasChain, SDNPOutGlue]>;
def callseq_end   : SDNode<"ISD::CALLSEQ_END",   SDT_PIKACallSeqEnd,
                           [SDNPHasChain, SDNPOptInGlue, SDNPOutGlue]>;

def SDT_PIKACall    : SDTypeProfile<0, -1, [SDTCisPtrTy<0>]>;

//===----------------------------------------------------------------------===//
// Custom SDNodes.
//===----------------------------------------------------------------------===//

def load_sym : SDNode<"PIKAISD::LOAD_SYM", SDTIntUnaryOp>;

def movei32 : SDNode<"PIKAISD::MOVEi32", MoveImm32Ty>;

def pika_call
    : SDNode<"PIKAISD::CALL", SDT_PIKACall,
             [ SDNPHasChain, SDNPOptInGlue, SDNPOutGlue, SDNPVariadic ]>;

//===----------------------------------------------------------------------===//
// Operand Definitions.
//===----------------------------------------------------------------------===//

def bl_target : Operand<i32>;

def b_target : Operand<OtherVT>;

def cc_val : Operand<i32> {
  let PrintMethod = "printCondCode";
}

def memsrc : Operand<i32> {
  let MIOperandInfo = (ops GRRegs, i32imm);
  let PrintMethod = "printAddrModeMemSrc";
  let EncoderMethod = "getMemSrcValue";
}

def i32imm_lo : Operand<i32>, ImmLeaf<i32, [{
  return Imm >= 0 && Imm < 65536;
}]>;

def PIKAimm32 : Operand<i32>, ImmLeaf<i32, [{
  return Imm >= 0 && Imm < 4294967296;
}]>;

//===----------------------------------------------------------------------===//
// Complex Pattern Definitions.
//===----------------------------------------------------------------------===//

def addr : ComplexPattern<iPTR, 2, "SelectAddr", [], []>;

