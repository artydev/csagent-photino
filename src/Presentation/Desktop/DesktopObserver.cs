using System.Text.Json;
using Photino.NET;

namespace CsAgentUI.Presentation.Desktop;

/// <summary>
/// Bridges agent events to the Photino window via web messages.
/// Each event is serialised as a JSON <c>{ type, data }</c> message matching
/// the Web UI contract and sent to the JS side with <c>SendWebMessage</c>.
/// </summary>
public class DesktopObserver : IAgentObserver
{
    private readonly PhotinoWindow _window;
    private TaskCompletionSource<bool>? _confirmTcs;

    public DesktopObserver(PhotinoWindow window)
    {
        _window = window;
    }

    private void Send(string type, object data)
    {
        var payload = new { type, data };
        var json = JsonSerializer.Serialize(payload);
        _window.SendWebMessage(json);
    }

    public Task OnStep(int n, int max) { Send("step", new { n, m = max }); return Task.CompletedTask; }
    public Task OnThought(string text) { Send("thought", text); return Task.CompletedTask; }
    public Task OnToolCall(string name, string args) { Send("call", new { n = name, a = args }); return Task.CompletedTask; }
    public Task OnToolResult(string result, bool isError) { Send("result", new { r = result, e = isError }); return Task.CompletedTask; }
    public Task OnDone(string message) { Send("done", message); return Task.CompletedTask; }
    public Task OnError(string message) { Send("error", message); return Task.CompletedTask; }
    public Task OnWarning(string message) { Send("warning", message); return Task.CompletedTask; }
    public Task OnDanger(string message) { Send("danger", message); return Task.CompletedTask; }

    /// <summary>
    /// Sends a <c>confirm</c> event to the JS side with the destructive tool
    /// name, then waits for the user's answer before returning.
    /// </summary>
    public Task<bool> Confirm(string toolName)
    {
        Send("confirm", new { tool = toolName });

        var tcs = new TaskCompletionSource<bool>(TaskCreationOptions.RunContinuationsAsynchronously);
        _confirmTcs = tcs;
        return tcs.Task;
    }

    /// <summary>
    /// Completes a pending confirmation with the user's answer.
    /// Called by the web-message handler when a <c>confirm-answer</c> arrives.
    /// </summary>
    public void ResolveConfirm(bool answer)
    {
        var tcs = _confirmTcs;
        _confirmTcs = null;
        tcs?.TrySetResult(answer);
    }
}
