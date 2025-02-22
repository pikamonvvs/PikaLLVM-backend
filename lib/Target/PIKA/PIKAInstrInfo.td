//===-- PIKAInstrInfo.td - Target Description for PIKA ---*- tablegen -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file describes the PIKA instructions in TableGen format.
//
//===----------------------------------------------------------------------===//

include "PIKAInstrFormats.td"
include "PIKAOperators.td"

//===----------------------------------------------------------------------===//
// Type Profiles.
//===----------------------------------------------------------------------===//

def SDT_PIKACmp          : SDTypeProfile<0, 2, [SDTCisSameAs<0, 1>]>;
def SDT_PIKABrCC         : SDTypeProfile<0, 2, [SDTCisVT<0, OtherVT>,
                                               SDTCisVT<1, i32>]>;

//===----------------------------------------------------------------------===//
// PIKA Specific Node Definitions.
//===----------------------------------------------------------------------===//

def PIKAcmp     : SDNode<"PIKAISD::CMP", SDT_PIKACmp, [SDNPOutGlue]>;
def PIKAbrcc    : SDNode<"PIKAISD::BR_CC", SDT_PIKABrCC, [SDNPHasChain,
                                                       SDNPInGlue]>;

//===----------------------------------------------------------------------===//
// Mov Instructions
//===----------------------------------------------------------------------===//
def MOVrr : PIKAInst<(outs GRRegs:$rd), (ins GRRegs:$rs),
                     "mov $rd, $rs",
                     [/* No pattern */]> {
  bits<4> rd;
  bits<4> rs;
  let Inst{31-27} = 0b00000;
  let Inst{26} = 0b0;
  let Inst{25-22} = rd;
  let Inst{21-18} = rs;
  let Inst{17-0} = 0;
}

//===----------------------------------------------------------------------===//
// Mov Immediate Instructions
//===----------------------------------------------------------------------===//

class MOVi<bits<5> opcode, string opstr, dag ins, list<dag>pattern>
    : PIKAInst<(outs GRRegs:$rd), ins,
              !strconcat(opstr, " $rd, $imm"), pattern> {
  bits<5> opcode;
  bits<4> rd;
  bits<18> imm;
  let Inst{31-27} = opcode;
  let Inst{26} = 0b1;
  let Inst{25-22} = rd;
  let Inst{17-0} = imm;
}

def MOVriLO16 : MOVi<0b00010, "movl", (ins i32imm:$imm),
                  [(set i32:$rd, i32imm_lo:$imm)]>;
def MOVriHI16 : MOVi<0b00011, "movh", (ins GRRegs:$rs, i32imm:$imm),
                  [/* No Pattern */]> {
  bits<4> rs;
  let Inst{21-18} = rs;
}

def MOVri : PIKAInst<(outs GRRegs:$rd), (ins i32imm:$src), "",
                     [(set i32:$rd, (movei32 imm:$src))]> {
  let isPseudo = 1;
}

def : Pattern<(i32 (load_sym tglobaladdr:$addr)), [(MOVri $addr)]>;

//===----------------------------------------------------------------------===//
// ALU Instructions
//===----------------------------------------------------------------------===//

multiclass ALUInst<bits<5> opcode, string opstr, SDNode opnode> {
  def rr : PIKAInst<(outs GRRegs:$rd),
                   (ins GRRegs:$rs, GRRegs:$rt),
                   !strconcat(opstr, " $rd, $rs, $rt"),
                   [(set i32:$rd, (opnode i32:$rs, i32:$rt))]> {
    bits<4> rd;
    bits<4> rs;
    bits<4> rt;
    let Inst{31-27} = opcode;
    let Inst{26} = 0b0;
    let Inst{25-22} = rd;
    let Inst{21-18} = rs;
    let Inst{17-14} = rt;
    let Inst{13-0} = 0;
  }
  def ri : PIKAInst<(outs GRRegs:$rd),
                   (ins GRRegs:$rs, i32imm:$imm),
                   !strconcat(opstr, " $rd, $rs, $imm"),
                   [(set i32:$rd, (opnode i32:$rs, PIKAimm32:$imm))]> {
    bits<4> rd;
    bits<4> rs;
    bits<18> imm;
    let Inst{31-27} = opcode;
    let Inst{26} = 0b1;
    let Inst{25-22} = rd;
    let Inst{21-18} = rs;
    let Inst{17-0} = imm;
  }
}

multiclass NOTInst<bits<5> opcode, string opstr> {
  def r : PIKAInst<(outs GRRegs:$rd), (ins GRRegs:$rs),
                   !strconcat(opstr, " $rd, $rs"),
                   [(set GRRegs:$rd, (not GRRegs:$rs))]> {
    bits<4> rd;
    bits<4> rs;
    let Inst{31-27} = opcode;
    let Inst{26} = 0b0;
    let Inst{25-22} = rd;
    let Inst{21-18} = rs;
    let Inst{17-14} = 0;
    let Inst{13-0} = 0;
  }
  def i : PIKAInst<(outs GRRegs:$rd), (ins i32imm:$imm),
                   !strconcat(opstr, " $rd, $imm"),
                   [(set GRRegs:$rd, (not PIKAimm32:$imm))]> {
    bits<4> rd;
    bits<18> imm;
    let Inst{31-27} = opcode;
    let Inst{26} = 0b1;
    let Inst{25-22} = rd;
    let Inst{21-18} = 0;
    let Inst{17-0} = imm;
  }
}

defm ADD  : ALUInst<0b00100, "add", add>;
defm SUB  : ALUInst<0b00101, "sub", sub>;
defm MUL  : ALUInst<0b00110, "mul", mul>;
defm DIV  : ALUInst<0b00111, "div", sdiv>;

defm AND  : ALUInst<0b01000, "and", and>;
defm OR   : ALUInst<0b01001, "or ", or>;
defm NOT  : NOTInst<0b01010, "not">;
defm XOR  : ALUInst<0b01011, "xor", xor>;

defm SHL  : ALUInst<0b01100, "shl", shl>;
defm SHR  : ALUInst<0b01101, "shr", srl>;
defm ASR  : ALUInst<0b01110, "asr", sra>;

//===----------------------------------------------------------------------===//
// Comparison Instructions
//===----------------------------------------------------------------------===//

//def CMP : PIKAInst<(outs), (ins GRRegs:$rs, GRRegs:$rt),
//                    "cmp $rs, $rt", []> {
//  bits<4> rs;
//  bits<4> rt;
//  let Inst{31-26} = 0b100000;
//  let Inst{25-22} = 0b0000;
//  let Inst{21-18} = rs;
//  let Inst{17-14} = rt;
//  let Inst{13-0} = 0;
//
//  let Defs = [CPSR];
//}

multiclass CMPInst<bits<5> opcode, string opstr> {
  def rr : PIKAInst<(outs),
                    (ins GRRegs:$rs, GRRegs:$rt),
                    !strconcat(opstr, " $rs, $rt"),
                    [(PIKAcmp GRRegs:$rs, GRRegs:$rt)]> {
    bits<4> rs;
    bits<4> rt;
    let Inst{31-27} = opcode;
    let Inst{26} = 0b0;
    let Inst{25-22} = 0b0000;
    let Inst{21-18} = rs;
    let Inst{17-14} = rt;
    let Inst{13-0} = 0;
    let Defs = [CPSR];
  }
  def ri : PIKAInst<(outs),
                    (ins GRRegs:$rs, i32imm:$imm),
                    !strconcat(opstr, " $rs, $imm"),
                    [(PIKAcmp GRRegs:$rs, PIKAimm32:$imm)]> {
    bits<4> rs;
    bits<18> imm;
    let Inst{31-27} = opcode;
    let Inst{26} = 0b1;
    let Inst{25-22} = 0b0000;
    let Inst{21-18} = rs;
    let Inst{17-0} = imm;
    let Defs = [CPSR];
  }
}

defm CMP : CMPInst<0b10000, "cmp">;

//===----------------------------------------------------------------------===//
// Branch Instructions
//===----------------------------------------------------------------------===//

let isTerminator = 1, isBranch = 1, isBarrier = 1 in {
  def JMP : PIKAInst<(outs), (ins b_target:$offset),
                  "jmp $offset", [(br bb:$offset)]> {
    bits<22> offset;
    let Inst{31-27} = 0b10001;
    let Inst{26} = 0b0;
    let Inst{25-22} = 0;
    let Inst{21-0} = offset;
  }
}

let isTerminator = 1, isBranch = 1, Uses = [CPSR] in {
  def Jcc : PIKAInst<(outs), (ins cc_val:$cc, b_target:$offset),
                    "j$cc $offset",  [(PIKAbrcc bb:$offset, imm:$cc)]> {
    bits<4> cc;
    bits<22> offset;
    let Inst{31-27} = 0b10001;
    let Inst{26} = 0b1;
    let Inst{25-22} = cc;
    let Inst{21-0} = offset;
  }
}

//===----------------------------------------------------------------------===//
// Load/Store Instructions
//===----------------------------------------------------------------------===//

def LD : PIKAInst<(outs GRRegs:$rd), (ins memsrc:$mem),
                  "ld  $rd, $mem",
                  [(set GRRegs:$rd, (load addr:$mem))]> {
  bits<4> rd;
  bits<22> mem;
  let Inst{31-26} = 0b100100;
  let Inst{25-22} = rd;
  let Inst{21-0} = mem;
}

def STR : PIKAInst<(outs), (ins GRRegs:$rd, memsrc:$mem),
                  "str $rd, $mem",
                  [(store GRRegs:$rd, addr:$mem)]> {
  bits<4> rd;
  bits<22> mem;
  let Inst{31-26} = 0b100101;
  let Inst{25-22} = rd;
  let Inst{21-0} = mem;
}

//===----------------------------------------------------------------------===//
// Call Instructions
//===----------------------------------------------------------------------===//

let isCall = 1, Defs = [LR], Uses = [SP] in {
  def CALL : PIKAInst<(outs), (ins GRRegs:$rd),
                      "call $rd",
                      [(pika_call i32:$rd)]> {
    bits<4> rd;
    let Inst{31-26} = 0b100110;
    let Inst{25-22} = rd;
    let Inst{21-0} = 0;
  }
}

//===----------------------------------------------------------------------===//
// Return Instructions
//===----------------------------------------------------------------------===//

let isTerminator = 1, isReturn = 1, isBarrier = 1, Uses = [LR] in {
  def RET : PIKAInst<(outs), (ins variable_ops),
                    "ret",  [(PIKARetFlag)]> {
    let Inst{31-26} = 0b100111;
    let Inst{25-0} = 0;
  }
}

//===----------------------------------------------------------------------===//
// Pseudo Instructions
//===----------------------------------------------------------------------===//

let Defs = [SP], Uses = [SP] in {
def ADJCALLSTACKDOWN : PseudoInst<(outs), (ins i32imm:$amt),
                                    "# ADJCALLSTACKDOWN $amt",
                                    [(callseq_start timm:$amt)]>;
def ADJCALLSTACKUP   : PseudoInst<(outs), (ins i32imm:$amt1, i32imm:$amt2),
                                    "# ADJCALLSTACKUP $amt1",
                                    [(callseq_end timm:$amt1, timm:$amt2)]>;
}
