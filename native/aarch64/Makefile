# On an arm64 machine (Apple Silicon, or AArch64 Linux): builds and runs natively.
# Anywhere else: cross-compiles with clang for aarch64 Linux and runs under qemu.
#   needs: clang, lld, an aarch64 sysroot (gcc-aarch64-linux-gnu), qemu-user

ARCH := $(shell uname -m)

ifneq ($(filter arm64 aarch64,$(ARCH)),)
  CC  ?= cc
  RUN :=
else
  CC      := clang --target=aarch64-linux-gnu --sysroot=/usr/aarch64-linux-gnu -fuse-ld=lld -static
  RUN     := qemu-aarch64
endif

CFLAGS  ?= -O2 -g
CFLAGS  += -std=gnu11 -Wall -Wextra

SRC := rt.c harness.c rt_asm.S $(wildcard actors/*.S)
HDR := rt.h actor.h

spike: $(SRC) $(HDR)
	$(CC) $(CFLAGS) $(SRC) -o $@

test: spike
	RUN="$(RUN)" ./t/run.sh

bench: spike
	$(RUN) ./spike bench

clean:
	rm -f spike

.PHONY: test bench clean
