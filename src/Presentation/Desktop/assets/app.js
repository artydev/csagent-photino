// =============================================================================
// CSAgent Desktop — Frontend Application (Photino bridge)
// =============================================================================
// Responsibilities:
//   1. Parse Markdown and apply Prism syntax highlighting
//   2. Send user prompts to .NET via window.external.sendMessage
//   3. Receive agent events from .NET via window.external.receiveMessage
//   4. Render messages into the log container
//   5. Display step counter in the header
//   6. Show confirmation dialog for destructive actions
// =============================================================================

// -----------------------------------------------------------------------------
// SECTION 1 — Markdown & Syntax Highlighting
// -----------------------------------------------------------------------------

/**
 * Normalise language class names so Prism can highlight them correctly.
 */
function normaliseLanguageClass(className) {
    let result = className;

    result = result.replace("language-html", "language-markup");
    result = result.replace("language-xml", "language-markup");

    result = result.replace(
        /language-(text|plain|plaintext)/g,
        "language-none"
    );

    return result;
}

/**
 * Ensure Prism language aliases are set up globally.
 */
function ensurePrismAliases() {
    if (typeof Prism === "undefined") return;

    if (Prism.languages.markup && !Prism.languages.html) {
        Prism.languages.html = Prism.languages.markup;
    }
    if (Prism.languages.markup && !Prism.languages.xml) {
        Prism.languages.xml = Prism.languages.markup;
    }
}

/**
 * Fix language classes on every code/pre element inside a container.
 */
function fixCodeLanguageClasses(container) {
    const selector = 'code[class*="language-"], pre[class*="language-"]';
    container.querySelectorAll(selector).forEach((element) => {
        element.className = normaliseLanguageClass(element.className);
    });
}

/**
 * Parse a Markdown string into an HTML element and apply syntax highlighting.
 */
function parseMarkdown(text) {
    const container = document.createElement("div");
    container.className = "markdown-content";
    container.innerHTML = marked.parse(text);

    ensurePrismAliases();
    fixCodeLanguageClasses(container);
    Prism.highlightAllUnder(container);

    return container;
}

// -----------------------------------------------------------------------------
// SECTION 2 — Message Rendering
// -----------------------------------------------------------------------------

/**
 * Create a DOM element for a "done" message (task completed).
 */
function createDoneMessage() {
    const div = document.createElement("div");
    div.className = "done";
    div.innerText = "✓ Task completed successfully";
    return div;
}

/**
 * Create a DOM element for a "warning" message.
 */
function createWarningMessage(text) {
    const div = document.createElement("div");
    div.className = "warning";
    div.innerText = "⚠ " + text;
    return div;
}

/**
 * Create a DOM element for a "danger" (error) message.
 */
function createDangerMessage(text) {
    const div = document.createElement("div");
    div.className = "danger";
    div.innerText = "✗ " + text;
    return div;
}

/**
 * Create a DOM element for a tool call message.
 */
function createToolCallMessage(name, argsJson) {
    const div = document.createElement("div");
    div.className = "call";

    const header = document.createElement("div");
    header.className = "call-header";

    const toolLabels = {
        "write_file": "📝 Write File",
        "read_file": "📖 Read File",
        "list_dir": "📂 List Directory",
        "search_files": "🔍 Search Files",
        "sh": "💻 Shell Command",
        "switch_model": "🔄 Switch Model"
    };
    header.innerHTML = `<strong>${toolLabels[name] || "🔧 " + name}</strong>`;
    div.appendChild(header);

    try {
        const args = JSON.parse(argsJson);
        const argList = document.createElement("div");
        argList.className = "call-args";

        for (const [key, value] of Object.entries(args)) {
            const argRow = document.createElement("div");
            argRow.className = "call-arg-row";

            const keySpan = document.createElement("span");
            keySpan.className = "call-arg-key";
            keySpan.textContent = key + ":";
            argRow.appendChild(keySpan);

            const valSpan = document.createElement("span");
            valSpan.className = "call-arg-value";

            let displayVal = String(value);
            if (displayVal.length > 300) {
                displayVal = displayVal.substring(0, 300) + `... (${displayVal.length} chars total)`;
            }
            valSpan.textContent = displayVal;
            argRow.appendChild(valSpan);

            argList.appendChild(argRow);
        }

        div.appendChild(argList);
    } catch {
        const raw = document.createElement("pre");
        raw.className = "call-raw";
        raw.textContent = argsJson;
        div.appendChild(raw);
    }

    return div;
}

/**
 * Create a DOM element for a tool result message.
 */
function createToolResultMessage(content, isError) {
    const div = document.createElement("div");
    div.className = isError ? "danger" : "result";

    const header = document.createElement("div");
    header.className = "result-header";
    header.textContent = isError ? "✗ Error" : "✓ Result";
    div.appendChild(header);

    const pre = document.createElement("pre");
    pre.className = "result-content";
    pre.textContent = content;
    div.appendChild(pre);

    return div;
}

/**
 * Create a DOM element for a generic log message.
 */
function createGenericMessage(type, content) {
    const div = document.createElement("div");
    div.className = type;

    if (type === "thought") {
        div.appendChild(parseMarkdown(content));
    } else {
        div.innerText = `[${type}] ${content}`;
    }

    return div;
}

/**
 * Route an incoming agent event to the correct renderer and append it to the log.
 */
function appendMessageToLog(message, log) {
    let element;

    switch (message.type) {
        case "done":
            element = createDoneMessage();
            break;
        case "warning":
            element = createWarningMessage(
                typeof message.data === "string" ? message.data : JSON.stringify(message.data)
            );
            break;
        case "danger":
            element = createDangerMessage(
                typeof message.data === "string" ? message.data : JSON.stringify(message.data)
            );
            break;
        case "call":
            if (message.data && typeof message.data === "object" && message.data.n) {
                element = createToolCallMessage(message.data.n, message.data.a);
            } else {
                element = createGenericMessage(message.type, JSON.stringify(message.data));
            }
            break;
        case "result":
            if (message.data && typeof message.data === "object" && "r" in message.data) {
                element = createToolResultMessage(message.data.r, message.data.e);
            } else {
                element = createGenericMessage(message.type, JSON.stringify(message.data));
            }
            break;
        default:
            element = createGenericMessage(
                message.type,
                typeof message.data === "string" ? message.data : JSON.stringify(message.data)
            );
            break;
    }

    log.appendChild(element);
}

/**
 * Scroll the log container to the bottom.
 */
function scrollToBottom(log) {
    log.scrollTop = log.scrollHeight;
}

// -----------------------------------------------------------------------------
// SECTION 3 — Step Counter
// -----------------------------------------------------------------------------

/**
 * Update the step counter in the header.
 */
function updateStepCounter(data) {
    const counter = document.getElementById("step-counter");
    if (!counter) return;

    if (data && typeof data.n === "number" && typeof data.m === "number") {
        counter.textContent = `Step ${data.n} of ${data.m}`;
    }
}

/**
 * Reset the step counter to its idle state.
 */
function resetStepCounter() {
    const counter = document.getElementById("step-counter");
    if (counter) counter.textContent = "Ready";
}

// -----------------------------------------------------------------------------
// SECTION 4 — User Input
// -----------------------------------------------------------------------------

/**
 * Append the user's prompt to the log as a styled message.
 */
function appendUserMessage(prompt, log) {
    const userDiv = document.createElement("div");
    userDiv.className = "user-msg";
    userDiv.innerHTML = `<strong>> User:</strong> ${prompt}`;
    log.appendChild(userDiv);
}

// -----------------------------------------------------------------------------
// SECTION 5 — Confirmation Dialog
// -----------------------------------------------------------------------------

/**
 * Handle a `confirm` event by showing a dialog and sending the user's
 * yes/no answer back to .NET.
 *
 * @param {object} data — The confirm event data (e.g. { tool: "sh" })
 */
function handleConfirm(data) {
    const toolName = data && data.tool ? data.tool : "unknown tool";
    const message = `Allow destructive action '${toolName}'?`;

    // Show a native confirmation dialog.
    const allowed = window.confirm(message);

    // Send the answer back to .NET with a distinguishable payload.
    sendMessage({ type: "confirm-answer", value: allowed });
}

// -----------------------------------------------------------------------------
// SECTION 6 — Photino Bridge
// -----------------------------------------------------------------------------

/**
 * Send a raw message to the .NET backend via the Photino bridge.
 *
 * @param {*} payload — The value to send (stringified if not a string)
 */
function sendMessage(payload) {
    if (window.external && window.external.sendMessage) {
        const message = typeof payload === "string" ? payload : JSON.stringify(payload);
        window.external.sendMessage(message);
    } else {
        console.warn("window.external.sendMessage not available");
    }
}

/**
 * Send a user prompt to the .NET backend via the Photino bridge.
 *
 * @param {string} prompt — The user's input prompt
 */
function sendPrompt(prompt) {
    sendMessage(prompt);
}

/**
 * Receive agent events from the .NET backend via the Photino bridge.
 */
function receiveMessage(callback) {
    if (window.external && window.external.receiveMessage) {
        window.external.receiveMessage(function (message) {
            try {
                const parsed = JSON.parse(message);
                callback(parsed);
            } catch (e) {
                console.error("Failed to parse web message:", message, e);
            }
        });
    } else {
        console.warn("window.external.receiveMessage not available");
    }
}

// -----------------------------------------------------------------------------
// SECTION 7 — Main Entry Point
// -----------------------------------------------------------------------------

/**
 * Main entry point — called when the user presses Enter in the input field.
 *
 * Reads the prompt, displays it in the log, clears the input, and sends it
 * to the .NET backend via the Photino bridge.
 */
function run() {
    const input = document.getElementById("in");
    const prompt = input.value.trim();
    if (!prompt) return;

    const log = document.getElementById("log");

    appendUserMessage(prompt, log);
    input.value = "";
    scrollToBottom(log);

    sendPrompt(prompt);
}

// -----------------------------------------------------------------------------
// SECTION 8 — Wire up the bridge on load
// -----------------------------------------------------------------------------

document.addEventListener("DOMContentLoaded", function () {
    const log = document.getElementById("log");

    receiveMessage(function (message) {
        // Handle step events in the header counter, not in the log
        if (message.type === "step") {
            updateStepCounter(message.data);
            return;
        }

        // Handle confirm events with a dialog (not rendered in the log)
        if (message.type === "confirm") {
            handleConfirm(message.data);
            return;
        }

        appendMessageToLog(message, log);
        scrollToBottom(log);

        if (message.type === "done" || message.type === "error" || message.type === "danger") {
            resetStepCounter();
        }
    });
});
