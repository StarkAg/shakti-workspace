#!/usr/bin/env bash
# Shakti RISC-V Development Session (tmux)
# Launches OpenOCD, UART terminal, GDB, and build shell

set -e

SESSION="shakti-dev"
WORKSPACE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SDK_ROOT="${WORKSPACE_ROOT}/shakti-sdk"
OCD_CFG="${SDK_ROOT}/bsp/third_party/parashu/ftdi.cfg"

# Optional: source environment for toolchain
if [[ -f "${WORKSPACE_ROOT}/env.sh" ]]; then
    # shellcheck source=env.sh
    source "${WORKSPACE_ROOT}/env.sh"
fi

if ! command -v tmux &>/dev/null; then
    echo "tmux not installed. Run: sudo apt install tmux"
    exit 1
fi

if ! tmux has-session -t "$SESSION" 2>/dev/null; then
    tmux new-session -d -s "$SESSION"
    tmux split-window -h
    tmux split-window -v
    tmux select-pane -t 0
    tmux split-window -v

    # Pane 0: OpenOCD
    tmux send-keys -t 0 "openocd -f ${OCD_CFG}" C-m

    # Pane 1: UART terminal (adjust /dev/ttyUSB1 and 19200 as needed)
    tmux send-keys -t 1 "python3 -m serial.tools.miniterm /dev/ttyUSB1 19200" C-m

    # Pane 2: GDB
    tmux send-keys -t 2 "riscv32-unknown-elf-gdb" C-m

    # Pane 3: Build terminal
    tmux send-keys -t 3 "cd ${SDK_ROOT}" C-m
fi

tmux attach -t "$SESSION"
