# Shakti RISC-V Development Workspace

A professional development environment for the Shakti RISC-V processor family, combining the SDK, toolchain, and development tools in a unified workspace.

## Workspace Structure

```
shakti_workspace/
├── docs/               # Documentation (MAC_M4_SETUP.md for Apple Silicon)
├── env.sh              # Environment setup script (source before building)
├── lab-flash.sh        # One-command flash at lab (Arty A7 + USB)
├── bin/elf2hex         # ARM64-compatible ELF→hex (Python wrapper)
├── shakti.sh           # tmux-based development session launcher
├── shakti-sdk/         # Shakti Software Development Kit
│   ├── bsp/            # Board Support Package (drivers, platform configs)
│   ├── software/       # Examples and projects
│   │   ├── examples/   # Peripheral examples (GPIO, UART, I2C, SPI, etc.)
│   │   └── projects/   # Application projects
│   └── doc/            # Documentation
└── shakti-tools/       # RISC-V toolchain and OpenOCD
    ├── bin/            # OpenOCD, elf2hex
    ├── riscv32/        # 32-bit RISC-V toolchain (rv32imac)
    └── riscv64/        # 64-bit RISC-V toolchain (rv64imac)
```

## Quick Start

### 1. Environment Setup

Source the environment script before building:

```bash
source env.sh
```

Or when working from the SDK directory:

```bash
source setenv.sh
```

### 2. Build an Example

```bash
cd shakti-sdk
make software PROGRAM=hello TARGET=parashu
```

### 3. List Available Targets

```bash
make list_targets
```

Supported targets: `artix7_35t`, `artix7_100t`, `pinaka`, `parashu`, `vajra`, `moushik`

### 4. List Examples

```bash
make list_applns
```

### 5. Development Session (tmux)

For debugging with OpenOCD, UART, and GDB:

```bash
./shakti.sh
```

## Requirements

- **OS**: Ubuntu 18.04 or 20.04 (verified)
- **Tools**: tmux (for `shakti.sh`), python3-serial (for UART)
- **Hardware**: Digilent Arty-7 FPGA board or compatible Shakti platform

---

## MacBook M4 / Apple Silicon Setup (Lab Substitute)

The official ACAD guide uses VirtualBox on Ubuntu. **VirtualBox does not run on Apple Silicon.** Use this substitute.

> **Full setup guide for future students**: See **[docs/MAC_M4_SETUP.md](docs/MAC_M4_SETUP.md)** for the complete step-by-step Mac M4 setup.

### Option A: UTM + Ubuntu ARM64 (Recommended for labs)

1. **Install UTM** (free, native on M4):  
   https://mac.getutm.app/ or `brew install --cask utm`

2. **Download Ubuntu 24.04 ARM64**:  
   https://ubuntu.com/download/server/arm (or Ubuntu Desktop ARM64)

3. **Create VM in UTM**:
   - New → Virtualize → Linux
   - Memory: 4–6 GB | CPU: 4 cores | Disk: 40 GB minimum
   - Attach Ubuntu ARM64 ISO and install

4. **Inside Ubuntu VM, build RISC-V toolchain** (prebuilt shakti-tools are x86_64 only):

   ```bash
   sudo apt update && sudo apt install -y build-essential git autoconf automake \
       libtool texinfo flex bison libmpc-dev libmpfr-dev libgmp-dev \
       gawk python3 python3-pip
   git clone https://github.com/riscv-collab/riscv-gnu-toolchain
   cd riscv-gnu-toolchain
   ./configure --prefix=$HOME/riscv32 --with-arch=rv32imac --with-abi=ilp32
   make -j$(nproc)
   ```

5. **Copy your shakti_workspace into the VM** (shared folder or SCP), then:

   ```bash
   export PATH=$PATH:$HOME/riscv32/bin
   cd shakti-sdk && make software PROGRAM=hello TARGET=parashu
   ```

6. **OpenOCD / elf2hex**: This workspace includes `bin/elf2hex` (Python) and uses system OpenOCD (`apt install openocd`). Lab flash is ready—see "Lab Flash" below.

### Option B: Native macOS (advanced)

Build the toolchain on macOS and point the SDK at it. Requires `brew install` deps and building `riscv-gnu-toolchain` from source. See [riscv-gnu-toolchain](https://github.com/riscv-collab/riscv-gnu-toolchain).

### Why this works

- UTM gives a real Linux environment (same as lab)
- Ubuntu ARM64 runs at native speed (no x86 emulation)
- You build the RISC-V toolchain once; SDK Makefiles use `riscv32-unknown-elf-gcc` etc.

## Documentation

- [Shakti SDK User Manual](http://shakti.org.in/docs/user_manual.pdf)
- [Shakti Boot Sequence](http://shakti.org.in/docs/boot_manual.pdf)
- [PLIC User Manual](http://shakti.org.in/docs/plic_user_manual.pdf)

## Lab Flash (Arty A7)

When at the lab with the Arty A7 connected via USB:

```bash
source env.sh
./lab-flash.sh hello artix7_35t
```

Or manually:

```bash
source env.sh
cd shakti-sdk
make upload PROGRAM=hello TARGET=artix7_35t
```

- **VMware users**: Enable USB passthrough (VM → Removable Devices → Connect Digilent USB).
- **sudo**: OpenOCD requires root for USB JTAG access; you'll be prompted.
- **UART**: Use 115200 baud to see program output (e.g. PuTTY, screen, minicom).

## Common Commands

| Command | Description |
|---------|-------------|
| `make software PROGRAM=X TARGET=Y` | Build example X for board Y |
| `make project PROGRAM=X TARGET=Y` | Build project X for board Y |
| `make upload PROGRAM=X TARGET=Y` | Build and upload to flash |
| `make debug PROGRAM=X TARGET=Y` | Build with debug symbols |
| `make clean` | Clean all build artifacts |

## License

Components are under their respective licenses. Shakti SDK is GPLv3. See individual repository headers for details.
