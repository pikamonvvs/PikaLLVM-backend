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

multiclass NotInst<bits<5> opcode, string opstr> {
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

defm ADD  : ALUInst<0b00000, "add", add>;
defm SUB  : ALUInst<0b00001, "sub", sub>;
defm MUL  : ALUInst<0b00010, "mul", mul>;
defm DIV  : ALUInst<0b00011, "div", sdiv>;

defm AND  : ALUInst<0b00100, "and", and>;
defm OR   : ALUInst<0b00101, "or ", or>;
defm NOT  : NotInst<0b00110, "not">;
defm XOR  : ALUInst<0b00111, "xor", xor>;

defm SHL  : ALUInst<0b01000, "shl", shl>;
defm SHR  : ALUInst<0b01001, "shr", srl>;
defm ASR  : ALUInst<0b01010, "asr", sra>;

//===----------------------------------------------------------------------===//
// Mov Instructions
//===----------------------------------------------------------------------===//
def MOVrr : PIKAInst<(outs GRRegs:$rd), (ins GRRegs:$rs),
                     "mov $rd, $rs",
                     [/* No pattern */]> {
  bits<4> rd;
  bits<4> rs;
  let Inst{31-27} = 0b01100;
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

def MOVriLO16 : MOVi<0b01110, "movl", (ins i32imm:$imm),
                  [(set i32:$rd, i32imm_lo:$imm)]>;
def MOVriHI16 : MOVi<0b01111, "movh", (ins GRRegs:$rs, i32imm:$imm),
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
// Comparison Instructions
//===----------------------------------------------------------------------===//

def CMP : PIKAInst<(outs), (ins GRRegs:$rs, GRRegs:$rt),
                    "cmp $rs, $rt", []> {
  bits<4> rs;
  bits<4> rt;
  let Inst{31-26} = 0b100000;
  let Inst{25-22} = 0b0000;
  let Inst{21-18} = rs;
  let Inst{17-14} = rt;
  let Inst{13-0} = 0;

  let Defs = [CPSR];
}

//===----------------------------------------------------------------------===//
// Branch Instructions
//===----------------------------------------------------------------------===//

let isTerminator = 1, isBranch = 1, isBarrier = 1 in {
  def JMP : PIKAInst<(outs), (ins b_target:$md),
                  "jmp $md", [(br bb:$md)]> {
    bits<22> md;
    let Inst{31-27} = 0b10001;
    let Inst{26} = 0b0;
    let Inst{25-22} = 0;
    let Inst{21-0} = md;
  }
}

let isTerminator = 1, isBranch = 1, Uses = [CPSR] in {
  def Jcc : PIKAInst<(outs), (ins cc_val:$cc, b_target:$rd),
                    "j$cc $rd",  []> {
    let Inst{31-27} = 0b10001;
    let Inst{26} = 0b1;
  }
}

//===----------------------------------------------------------------------===//
// Load/Store Instructions
//===----------------------------------------------------------------------===//

def LD : PIKAInst<(outs GRRegs:$rd), (ins memsrc:$ms),
                  "ld  $rd, $ms",
                  [(set i32:$rd, (load addr:$ms))]> {
  bits<4> rd;
  bits<22> ms;
  let Inst{31-26} = 0b100100;
  let Inst{25-22} = rd;
  let Inst{21-0} = ms;
}

def STR : PIKAInst<(outs), (ins GRRegs:$rs, memsrc:$md),
                  "str $rs, $md",
                  [(store i32:$rs, addr:$md)]> {
  bits<4> rs;
  bits<22> md;
  let Inst{31-26} = 0b100101;
  let Inst{25-22} = rs;
  let Inst{21-0} = md;
}

//===----------------------------------------------------------------------===//
// Call Instructions
//===----------------------------------------------------------------------===//

let isCall = 1, Defs = [LR], Uses = [SP] in {
  def CALL : PIKAInst<(outs), (ins GRRegs:$rs),
                      "call $rs",
                      [(pika_call i32:$rs)]> {
    bits<4> rs;
    let Inst{31-26} = 0b100110;
    let Inst{25-22} = rs;
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
