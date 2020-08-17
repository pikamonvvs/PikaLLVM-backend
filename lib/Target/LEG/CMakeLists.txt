set(LLVM_TARGET_DEFINITIONS PIKA.td)

tablegen(LLVM PIKAGenRegisterInfo.inc -gen-register-info)
tablegen(LLVM PIKAGenInstrInfo.inc -gen-instr-info)
tablegen(LLVM PIKAGenAsmWriter.inc -gen-asm-writer)
tablegen(LLVM PIKAGenDAGISel.inc -gen-dag-isel)
tablegen(LLVM PIKAGenCallingConv.inc -gen-callingconv)
tablegen(LLVM PIKAGenSubtargetInfo.inc -gen-subtarget)
tablegen(LLVM PIKAGenMCCodeEmitter.inc -gen-emitter)
add_public_tablegen_target(PIKACommonTableGen)

add_llvm_target(PIKACodeGen
  PIKASubtarget.cpp
  PIKATargetMachine.cpp
  PIKARegisterInfo.cpp
  PIKAInstrInfo.cpp
  PIKAFrameLowering.cpp
  PIKAISelLowering.cpp
  PIKASelectionDAGInfo.cpp
  PIKAISelDAGToDAG.cpp
  PIKAAsmPrinter.cpp
  PIKAMCInstLower.cpp
  )

add_subdirectory(InstPrinter)
add_subdirectory(TargetInfo)
add_subdirectory(MCTargetDesc)
