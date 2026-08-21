namespace CsAgentUI;

public interface IAgentObserver
{
    Task OnStep(int n, int max);
    Task OnThought(string text);
    Task OnToolCall(string name, string args);
    Task OnToolResult(string result, bool isError);
    Task OnDone(string message);
    Task OnError(string message);
    Task OnWarning(string message);
    Task OnDanger(string message);

    /// <summary>
    /// Asks the user to confirm a destructive tool call.
    /// Returns <c>true</c> if the tool may run, <c>false</c> to decline.
    /// </summary>
    Task<bool> Confirm(string toolName);
}
