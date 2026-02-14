#!/usr/bin/env bash
#===============================================================================
# Shakti RISC-V Development Environment
#===============================================================================
# Source this file to set up the RISC-V toolchain and Shakti SDK for development.
# Usage: source env.sh
#===============================================================================

set -e

# Resolve workspace root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [[ -n "${SHAKTI_WORKSPACE}" ]]; then
    WORKSPACE_ROOT="${SHAKTI_WORKSPACE}"
elif [[ -d "${SCRIPT_DIR}/shakti-sdk" ]]; then
    WORKSPACE_ROOT="${SCRIPT_DIR}"
else
    echo "Error: Cannot find shakti-sdk. Set SHAKTI_WORKSPACE or run from workspace root."
    return 1 2>/dev/null || exit 1
fi

SHAKTI_TOOLS="${WORKSPACE_ROOT}/shakti-tools"
SHAKTI_SDK="${WORKSPACE_ROOT}/shakti-sdk"

# Toolchain: prefer self-built (for ARM/Apple Silicon) over prebuilt (x86_64 only)
if [[ -d "${HOME}/riscv32/bin" ]] && [[ -x "${HOME}/riscv32/bin/riscv32-unknown-elf-gcc" ]]; then
    TOOLCHAIN_32="${HOME}/riscv32/bin"
    TOOLCHAIN_64="${HOME}/riscv64/bin"
    TOOLCHAIN_SOURCE="self-built"
else
    TOOLCHAIN_32="${SHAKTI_TOOLS}/riscv32/bin"
    TOOLCHAIN_64="${SHAKTI_TOOLS}/riscv64/bin"
    TOOLCHAIN_SOURCE="shakti-tools"
fi
# On ARM64/Mac: shakti-tools openocd/elf2hex are x86_64; use system openocd + workspace elf2hex
WORKSPACE_BIN="${WORKSPACE_ROOT}/bin"
if [[ -x "${WORKSPACE_BIN}/elf2hex" ]]; then
    ELF2HEX_BIN="${WORKSPACE_BIN}"
else
    ELF2HEX_BIN="${SHAKTI_TOOLS}/bin"
fi
# Prefer system openocd (arm64) over shakti-tools (x86_64 only)
if command -v /usr/bin/openocd &>/dev/null; then
    export OPENOCD="/usr/bin/openocd"
else
    export OPENOCD="${SHAKTI_TOOLS}/bin/openocd"
fi
# PATH: elf2hex first, then toolchain; openocd via OPENOCD env var
export PATH="${ELF2HEX_BIN}:${TOOLCHAIN_32}:${TOOLCHAIN_64}:${PATH}"
export SHAKTISDK="${SHAKTI_SDK}"
export SHAKTITOOLS="${SHAKTI_TOOLS}"

# Verify toolchain
if command -v riscv32-unknown-elf-gcc &>/dev/null; then
    echo "Shakti environment ready [${TOOLCHAIN_SOURCE}]. (riscv32-unknown-elf-gcc: $(which riscv32-unknown-elf-gcc))"
else
    echo "Warning: riscv32-unknown-elf-gcc not found. Build toolchain: see README 'Mac M4 Setup' section."
fi
