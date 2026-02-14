# Shakti RISC-V Setup Guide: MacBook M4 / Apple Silicon

A complete step-by-step guide for ACAD students on Mac M4 to set up the Shakti RISC-V development environment for lab work. The official guide uses VirtualBox + Ubuntu, but **VirtualBox does not run on Apple Silicon**. This document describes the verified substitute using **UTM + Ubuntu ARM64**.

---

## Prerequisites

- **MacBook M4** (or any Apple Silicon Mac)
- **~50 GB free disk space** (VM + toolchain build)
- **~4 GB RAM** for the VM (8 GB recommended for comfortable build)
- **This workspace** (shakti_workspace with SDK, bin/elf2hex, env.sh, lab-flash.sh)

> **Clone the repo**: `git clone https://github.com/Starkag/shakti-workspace.git`  
> The repo includes SDK fixes (GCC 15 compatibility), elf2hex, and env.sh. **shakti-tools** is excluded (2.7 GB); you build your own RISC-V toolchain. See "Verifying the Workspace" below.

---

## Part 1: Install UTM and Create Ubuntu VM

### Step 1.1: Install UTM

UTM is a free, native virtualization app for Apple Silicon.

- **Download**: https://mac.getutm.app/
- **Or via Homebrew**: `brew install --cask utm`

### Step 1.2: Download Ubuntu 24.04 ARM64

- **Server ISO**: https://ubuntu.com/download/server/arm  
- **Desktop ISO** (optional, if you prefer GUI): https://ubuntu.com/download/desktop (choose ARM64)

### Step 1.3: Create VM in UTM

1. Open UTM → **Create a New Virtual Machine**
2. Choose **Virtualize** (not Emulate)
3. Select **Linux**
4. **Browse** to the Ubuntu ARM64 ISO
5. Configure:
   - **Memory**: 4–6 GB (6 GB recommended for toolchain build)
   - **CPU cores**: 4
   - **Disk**: 40 GB minimum (toolchain build needs ~10–15 GB)
6. **Save** and start the VM
7. Install Ubuntu (standard installation; create a user, set password)
8. Reboot when prompted

---

## Part 2: Inside Ubuntu VM – System Packages

Open a terminal in the Ubuntu VM and run:

```bash
sudo apt update
sudo apt install -y build-essential git autoconf automake libtool texinfo \
    flex bison libmpc-dev libmpfr-dev libgmp-dev gawk python3 python3-pip \
    openocd tmux
```

- **build-essential, autoconf, etc.**: Required for building the RISC-V toolchain
- **openocd**: ARM64-native OpenOCD for flashing (shakti-tools OpenOCD is x86_64 only)
- **tmux**: Optional, used by `shakti.sh` for debug sessions

---

## Part 3: Build RISC-V Toolchain from Source

The prebuilt shakti-tools are **x86_64 only** and do not run on ARM64 Ubuntu. You must build the toolchain from source.

### Step 3.1: Clone riscv-gnu-toolchain

```bash
cd ~
git clone https://github.com/riscv-collab/riscv-gnu-toolchain
cd riscv-gnu-toolchain
```

### Step 3.2: Configure and Build

```bash
./configure --prefix=$HOME/riscv32 --with-arch=rv32imac --with-abi=ilp32
make -j$(nproc)
```

- **Time**: ~30–60 minutes depending on CPU and RAM
- **Result**: Toolchain installed to `$HOME/riscv32/bin/` (e.g. `riscv32-unknown-elf-gcc`, `riscv32-unknown-elf-objcopy`, etc.)

### Step 3.3: Verify Toolchain

```bash
$HOME/riscv32/bin/riscv32-unknown-elf-gcc --version
```

You should see GCC (e.g. 15.x).

### Step 3.4: libgcc.a (If Build Fails or Linker Complains)

If you get errors about `libgcc.a` not found when building examples, copy it from shakti-tools:

```bash
# Find your GCC version (e.g. 15.2.0)
ls $HOME/riscv32/lib/gcc/riscv32-unknown-elf/
# Copy libgcc.a from shakti-tools (adjust paths)
cp /path/to/shakti_workspace/shakti-tools/riscv32/lib/gcc/riscv32-unknown-elf/*/libgcc.a \
   $HOME/riscv32/lib/gcc/riscv32-unknown-elf/YOUR_GCC_VERSION/
```

---

## Part 4: Get the Workspace into the VM

### Option A: Shared Folder (UTM)

1. In UTM: VM Settings → Sharing → add a directory (e.g. your Mac's `Downloads` or project folder)
2. Inside Ubuntu: the share is usually under `/media` or `/mnt`

### Option B: Git Clone (Recommended)

Inside the Ubuntu VM:

```bash
cd ~
git clone https://github.com/Starkag/shakti-workspace.git
# Rename to shakti_workspace if desired
mv shakti-workspace shakti_workspace
```

Or from your Mac, SCP into the VM:

```bash
scp -r shakti_workspace user@VM_IP:~/
```

### Option C: USB Drive

Copy `shakti_workspace` to a USB drive, connect to VM (UTM supports USB passthrough), and copy into the home directory.

---

## Part 5: Build and Verify

### Step 5.1: Source Environment

```bash
cd ~/shakti_workspace   # or wherever you placed it
source env.sh
```

You should see: `Shakti environment ready [self-built].`

### Step 5.2: Build Hello Example

```bash
cd shakti-sdk
make software PROGRAM=hello TARGET=parashu
```

Or for Arty A7:

```bash
make software PROGRAM=hello TARGET=artix7_35t
```

### Step 5.3: Verify Output

The ELF should be at:

```
shakti-sdk/software/examples/uart_applns/hello/output/hello.shakti
```

---

## Part 6: Lab Flash (Arty A7)

When you are at the lab with the Arty A7 connected via USB:

### Step 6.1: USB Passthrough (UTM)

1. Connect Arty A7 to your Mac via USB
2. In UTM: **VM → Removable Devices → [Digilent USB Device] → Connect**
3. The device should appear inside the VM (`lsusb` should show it)

### Step 6.2: Flash

```bash
cd ~/shakti_workspace
source env.sh
./lab-flash.sh hello artix7_35t
```

Or manually:

```bash
source env.sh
cd shakti-sdk
make upload PROGRAM=hello TARGET=artix7_35t
```

- **sudo**: OpenOCD needs root for USB JTAG; you will be prompted
- **UART**: Use 115200 baud (PuTTY, screen, minicom) to see program output

---

## Workspace Contents (What You Should Have)

| Path | Purpose |
|------|---------|
| `env.sh` | Sources toolchain, sets OPENOCD, PATH (source before building) |
| `lab-flash.sh` | One-command flash at lab |
| `bin/elf2hex` | Python-based ELF→hex (ARM64 compatible) |
| `shakti-sdk/` | Shakti SDK (with GCC 15 / rv32imac_zicsr fixes) |
| `shakti-tools/` | Excluded from repo (2.7 GB). Optional: clone from [GitLab](https://gitlab.com/shaktiproject/software/shakti-tools) if you need `libgcc.a` workaround |

---

## Verifying the Workspace

If you have a vanilla Shakti SDK and builds fail, you may need these fixes (already applied in this workspace):

1. **MARCH**: `rv32imac` → `rv32imac_zicsr`, `rv64imac` → `rv64imac_zicsr` (GCC 15 CSR support) in `software/examples/Makefile` and `software/projects/Makefile`
2. **BSP fixes**: Pointer casts in `bsp/drivers/pwm/`, `clint/`, `qspi/`; `#include <stdio.h>` in `hello.c`; etc.
3. **elf2hex**: Use `bin/elf2hex` (Python) instead of x86_64 binary
4. **OpenOCD**: Use system OpenOCD (`apt install openocd`); `env.sh` sets `OPENOCD=/usr/bin/openocd`

---

## Quick Reference

| Task | Command |
|------|---------|
| Setup environment | `source env.sh` |
| Build hello (Parashu) | `make software PROGRAM=hello TARGET=parashu` |
| Build hello (Arty A7) | `make software PROGRAM=hello TARGET=artix7_35t` |
| List examples | `make list_applns` |
| List targets | `make list_targets` |
| Flash at lab | `./lab-flash.sh hello artix7_35t` |
| UART (115200) | `screen /dev/ttyUSB1 115200` or PuTTY |

---

## Troubleshooting

### "Exec format error" when running elf2hex or openocd

You are using the x86_64 shakti-tools binaries. Use `bin/elf2hex` and system OpenOCD. Ensure you `source env.sh` before building.

### "riscv32-unknown-elf-gcc: command not found"

Toolchain not in PATH. Run `source env.sh`. If you built the toolchain to `$HOME/riscv32`, env.sh will pick it up.

### Build fails with CSR / undefined reference errors

The Makefile needs `rv32imac_zicsr` (not `rv32imac`) for GCC 15. Check `software/examples/Makefile` and `software/projects/Makefile`.

### USB device not visible in VM

In UTM: VM → Removable Devices → select the Digilent USB device → Connect. You may need to disconnect it from the host first.

### OpenOCD fails: "Error: libusb_open() failed"

Ensure the USB device is passed through to the VM and you run with `sudo` (OpenOCD needs root for USB JTAG).

---

## Summary

1. Install UTM and create Ubuntu 24.04 ARM64 VM  
2. Install system packages (`build-essential`, `openocd`, etc.)  
3. Build RISC-V toolchain: `riscv-gnu-toolchain` → `$HOME/riscv32`  
4. Copy shakti_workspace into the VM  
5. `source env.sh` and `make software PROGRAM=hello TARGET=artix7_35t`  
6. At lab: connect Arty A7, USB passthrough, `./lab-flash.sh hello artix7_35t`  

Good luck with your lab!
