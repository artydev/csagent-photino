#!/bin/bash
# Test whether agent_memory.json is created in the user's working directory
# when running the wrapped executable with a real prompt.

set -e

# Clean up test artifacts
rm -rf /tmp/wrap_prompt_test
mkdir -p /tmp/wrap_prompt_test
cd /tmp/wrap_prompt_test

echo "=== Running wrapped executable from: $(pwd) ==="
echo "=== ALBERT_API_KEY set? ${ALBERT_API_KEY:+yes} ==="

# Run the wrapper with a simple prompt
echo ""
echo "--- Running wrapper with prompt 'say hello' ---"
timeout 60 /home/python/projects/csagent-photino/dist/CsAgentUI-wrapper "say hello" 2>&1 | head -50
echo "Exit code: ${PIPESTATUS[0]}"

echo ""
echo "--- Check for agent_memory.json in user CWD ---"
if [ -f /tmp/wrap_prompt_test/agent_memory.json ]; then
    echo "FOUND in user CWD: /tmp/wrap_prompt_test/agent_memory.json"
    echo "Content:"
    head -c 300 /tmp/wrap_prompt_test/agent_memory.json
    echo ""
else
    echo "NOT found in user CWD"
fi

echo ""
echo "--- Check /tmp/agent_memory.json ---"
if [ -f /tmp/agent_memory.json ]; then
    echo "FOUND at /tmp/agent_memory.json"
    echo "Content:"
    head -c 300 /tmp/agent_memory.json
    echo ""
else
    echo "NOT found at /tmp/agent_memory.json"
fi

echo ""
echo "--- Check newest temp wrapper dir ---"
latest=$(ls -dt /tmp/photino_wrapper_*/ 2>/dev/null | head -1)
if [ -n "$latest" ]; then
    echo "Latest temp dir: $latest"
    ls -la "$latest" 2>/dev/null
    if [ -f "$latest/agent_memory.json" ]; then
        echo "agent_memory.json FOUND in $latest"
    fi
fi
