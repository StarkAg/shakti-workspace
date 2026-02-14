#***************************************************************************
# * Project           		: shakti devt board
# * Name of the file	     	: setenv.sh
# * Brief Description of file   : Updates the PATH and sets SHAKTISDK env variables
# * Name of Author    	        : Anand Kumar S
# * Email ID                    : 007334@imail.iitm.ac.in
#
# Copyright (C) 2019  IIT Madras. All rights reserved.
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.
#
#***************************************************************************/


# Resolve SDK root and workspace
_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
_SDK_ROOT="${_SCRIPT_DIR}"
_WORKSPACE="$(cd "${_SCRIPT_DIR}/.." && pwd)"

# shakti-tools: support both submodule (sdk/shakti-tools) and sibling (workspace/shakti-tools)
if [[ -d "${_SDK_ROOT}/shakti-tools" ]]; then
    _TOOLS="${_SDK_ROOT}/shakti-tools"
elif [[ -d "${_WORKSPACE}/shakti-tools" ]]; then
    _TOOLS="${_WORKSPACE}/shakti-tools"
else
    echo "Warning: shakti-tools not found. Use workspace env.sh or set PATH manually."
fi

if [[ -n "${_TOOLS}" ]]; then
    export PATH="${PATH}:${_TOOLS}/bin:${_TOOLS}/riscv32/bin:${_TOOLS}/riscv64/bin"
fi
export SHAKTISDK="${_SDK_ROOT}"
