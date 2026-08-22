#!/bin/bash
# Test whether agent_memory.json is created in the user's working directory
# when running the wrapped executable.

set -e

# Clean up any previous test artifacts
rm -rf /tmp/wrap_mem_test
mkdir -p /tmp/wrap_mem_test
cd /tmp/wrap_mem_test

echo "=== Running wrapped executable from: $(pwd) ==="
echo "=== ALBERT_API_KEY set? ${ALBERT_API_KEY:+yes} ==="

# Run the wrapper with --version first (no prompting needed)
echo ""
echo "--- Test 1: --version ---"
/home/python/projects/csagent-photino/dist/CsAgentUI-wrapper --version
echo "Exit code: $?"

echo ""
echo "--- Check for agent_memory.json after --version ---"
if [ -f /tmp/wrap_mem_test/agent_memory.json ]; then
    echo "FOUND in user CWD: /tmp/wrap_mem_test/agent_memory.json"
else
    echo "NOT found in user CWD"
fi

echo ""
echo "--- Check /tmp for agent_memory.json ---"
if [ -f /tmp/agent_memory.json ]; then
    echo "FOUND at /tmp/agent_memory.json"
else
    echo "NOT found at /tmp/agent_memory.json"
fi

echo ""
echo "--- Check temp wrapper dirs for agent_memory.json ---"
for d in /tmp/photino_wrapper_*/; do
    if [ -f "$d/agent_memory.json" ]; then
        echo "FOUND in $d/agent_memory.json"
    fi
done
echo "(done checking temp dirs)"
