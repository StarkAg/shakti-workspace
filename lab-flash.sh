#!/usr/bin/env bash
#===============================================================================
# Lab Flash Script - Arty A7
#===============================================================================
# Run this at the lab when the Arty A7 is connected via USB.
# Usage: ./lab-flash.sh [PROGRAM] [TARGET]
#   PROGRAM = hello (default), malloc_test, gpio_led, etc.
#   TARGET  = artix7_35t (default, Arty A7 35T), or artix7_100t
#===============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "${SCRIPT_DIR}"

# Source environment (toolchain, elf2hex, OpenOCD)
source env.sh

PROGRAM="${1:-hello}"
TARGET="${2:-artix7_35t}"

echo "=========================================="
echo " Lab Flash: ${PROGRAM} → Arty A7 (${TARGET})"
echo "=========================================="
echo ""
echo "1. Ensure Arty A7 is connected via USB (JTAG)"
echo "2. Ensure VMware USB passthrough is enabled (if using VM)"
echo "3. Running: make upload PROGRAM=${PROGRAM} TARGET=${TARGET}"
echo ""

cd shakti-sdk
make upload PROGRAM="${PROGRAM}" TARGET="${TARGET}"

echo ""
echo "Done. Check UART output (115200 baud) for program output."
