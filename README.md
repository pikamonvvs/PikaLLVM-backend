# PikaLLVM-backend

Clang-3.8.1과 본 LLVM 백엔드를 이용하면 C언어로 작성된 소스 코드로부터 PIKA 아키텍처의 바이너리를 생성할 수 있습니다. Clang-3.8.1은 루트 프로젝트 내에 첨부해두었습니다.

## 1. 빌드 환경

아래 환경에서 빌드하였습니다.

```
Ubuntu 20.04
gcc 9.3.0
cmake 3.16.3
ninja 1.10.0
make 4.2.1
```

위의 도구들이 설치되어있지 않다면, 아래의 명령어로 설치할 수 있습니다.

```
sudo apt install -y gcc g++ make cmake ninja-build libncurses5
```

## 2. 빌드 방법

아래의 방법으로 빌드할 수 있습니다.

```
# 프로젝트 내려받기
git clone https://github.com/pikamonvvs/PikaProject.git
cd PikaProject
git submodule init && git submodule update
cd PikaLLVM-backend

# 빌드하기
mkdir build
cd build
cmake -G Ninja -DCMAKE_BUILD_TYPE="Debug" -DLLVM_TARGETS_TO_BUILD=PIKA ../
ninja (또는 ninja -j 8)
```

빌드되는 데에 약 1~2시간 정도 소요됩니다. (물론 환경에 따라 다릅니다.)
시간 단축을 위해 ninja 명령어에 -j 옵션을 줄 수 있습니다. 다만 Out-of-memory가 발생하지 않도록 주의하여야 합니다. 만약 OOM이 발생하여도, 다시 ninja를 실행함으로써 이어서 빌드할 수 있습니다.

## 3. 사용법

빌드가 완료되면 build/bin 폴더 안에 llc 등의 프로그램이 생성된 것을 볼 수 있습니다.

아래의 명령어들을 이용하여 원하는 파일을 생성할 수 있습니다.

### 3.1. 환경 변수 등록

본 프로젝트에서 제공되는 프로그램을 사용하기 위해 환경 변수 등록이 필요합니다.

아래 명령어들로 등록할 수 있습니다.

```
< 순서대로 입력해주세요 >
export PATH=/path/to/clang-3.8.1/bin:$PATH
export PATH=/path/to/PikaLLVM-backend/build/bin:$PATH
```

### 3.2. 파일 생성

아래 명령어들로 원하는 파일을 생성할 수 있습니다.

```
*.c			= C Source Code
*.ll		= LLVM Intermediate Representation
*.bc		= LLVM Bitcode
*.s			= Target Assembly Code (PIKA)
*.o			= Target Object (PIKA)
test.hex	= Target Dependent Code (PIKA) - PikaRISC의 입력으로 사용됨.
```

예) 파일명을 test.c 라고 할 때,
```
< .c -> .ll >
clang -emit-llvm -S -O0 -o test.ll test.c

< .ll -> .bc >
llvm-as -o test.bc test.ll

< .ll -> .s >
llc -march=pika -o test.s test.ll

< .ll -> .o >
llc -march=pika -filetype=obj -o test.o test.ll

< .bc -> .s >
llc -march=pika -o test.s test.bc

< .bc -> .o >
llc -march=pika -filetype=obj -o test.o test.bc

< .o 파일 덤프 출력 >
llvm-objdump -s test.o

< .o -> .hex >
llvm-objdump -s -j .text test.o | cut -d' ' -f3,4,5,6 | sed '1,4d' > test.hex

```

## 4. Future works

1. 옛날 버전의 LLVM 베이스 버전

2021년 7월 31일 기준, LLVM의 최신 버전은 12.0.1이며, 본 프로젝트에서는 3.8.1 버전을 사용하였습니다. 이는 참고했던 코드의 LLVM 버전이 3.8.1이었기 때문에, 코드 호환성 유지를 위해 동일 버전에 포팅하였기 때문입니다. 보다 많은 기능 및 안정성을 위해 높은 버전으로의 포팅하는 것은 의미있어 보입니다.

2. 에뮬레이터의 부재

실물 하드웨어 없이 기계어 코드를 검증할 수 있도록 PC용 에뮬레이터를 만드는 것도 개발 및 디버깅에 많은 도움이 될 것으로 보입니다.

