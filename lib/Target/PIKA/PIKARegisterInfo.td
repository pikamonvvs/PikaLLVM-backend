//===-- PIKARegisterInfo.td - PIKA Register defs ---------*- tablegen -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

//===----------------------------------------------------------------------===//
//  Declarations that describe the PIKA register file
//===----------------------------------------------------------------------===//

class PIKAReg<bits<16> Enc, string n> : Register<n> {
  let HWEncoding = Enc;
  let Namespace = "PIKA";
}

// CPU registers
def R0  : PIKAReg< 0, "r0">;
def R1  : PIKAReg< 1, "r1">;
def R2  : PIKAReg< 2, "r2">;
def R3  : PIKAReg< 3, "r3">;
def R4  : PIKAReg< 4, "r4">;
def R5  : PIKAReg< 5, "r5">;
def R6  : PIKAReg< 6, "r6">;
def R7  : PIKAReg< 7, "r7">;
def R8  : PIKAReg< 8, "r8">;
def R9  : PIKAReg< 9, "r9">;
def R10  : PIKAReg< 10, "r10">;
def R11  : PIKAReg< 11, "r11">;
def R12  : PIKAReg< 12, "r12">;
def R13  : PIKAReg< 13, "r13">;

def SP  : PIKAReg<14, "sp">;
def LR  : PIKAReg<15, "lr">;

def CPSR  : PIKAReg<16, "cpsr">;

// Register classes.
//
def GRRegs : RegisterClass<"PIKA", [i32], 32,
  // Return values and arguments
  (add R0, R1, R2, R3, R4, R5, R6, R7,
       R8, R9, R10, R11, R12, R13, SP)>;
