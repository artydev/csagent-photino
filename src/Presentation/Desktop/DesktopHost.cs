using System.Drawing;
using System.Text;
using System.Text.Json;
using CsAgentUI.Shared;
using Photino.NET;

namespace CsAgentUI.Presentation.Desktop;

/// <summary>
/// Desktop host — native window via Photino (PhotinoAOT).
/// </summary>
public static class DesktopHost
{
    // The observer for the currently-running agent, so the web-message
    // handler can resolve pending confirmations.
    private static DesktopObserver? _currentObserver;

    public static void Run(AgentArguments args)
    {
        var apiKey = Environment.GetEnvironmentVariable("ALBERT_API_KEY") ?? "";
        if (string.IsNullOrEmpty(apiKey))
        {
            Console.WriteLine("Error: ALBERT_API_KEY env var not set.");
            return;
        }

        var window = new PhotinoWindow();
        window
            .SetTitle("CSAgent")
            .SetUseOsDefaultSize(false)
            .SetSize(new Size(1280, 800))
            .Center()
            .SetResizable(true)
            .RegisterCustomSchemeHandler("app", ServeEmbeddedAsset)
            .RegisterWebMessageReceivedHandler((sender, message) =>
            {
                HandleWebMessage(args, apiKey, window, message);
            })
            // Load the embedded HTML directly as a string. Photino only
            // accepts http/https/file URLs or an HTML string for the initial
            // navigation, so the custom "app" scheme is used only for the
            // sub-resources (app.js, styles.css) referenced from the HTML.
            .LoadRawString(DesktopAssets.HtmlUI);

        window.WaitForClose();
    }

    /// <summary>
    /// Routes an incoming web message. A <c>confirm-answer</c> resolves a
    /// pending confirmation; anything else is treated as a user prompt.
    /// </summary>
    private static void HandleWebMessage(AgentArguments args, string apiKey, PhotinoWindow window, string message)
    {
        // Try to parse as a JSON control message (e.g. confirm-answer).
        if (TryParseControlMessage(message, out var type, out var value))
        {
            if (type == "confirm-answer" && _currentObserver is not null)
            {
                _currentObserver.ResolveConfirm(value);
            }
            return;
        }

        // Otherwise treat the message as a user prompt and run the agent.
        _ = Task.Run(() => RunAgentAsync(args, apiKey, window, message));
    }

    /// <summary>
    /// Attempts to parse a JSON control message of the form
    /// <c>{ "type": "...", "value": ... }</c>. Returns <c>false</c> if the
    /// message is not such a control message.
    /// </summary>
    private static bool TryParseControlMessage(string message, out string type, out bool value)
    {
        type = "";
        value = false;

        if (string.IsNullOrWhiteSpace(message) || !message.TrimStart().StartsWith("{"))
            return false;

        try
        {
            using var doc = JsonDocument.Parse(message);
            var root = doc.RootElement;
            if (!root.TryGetProperty("type", out var typeEl))
                return false;

            type = typeEl.GetString() ?? "";
            if (type != "confirm-answer")
                return false;

            value = root.TryGetProperty("value", out var valueEl) && valueEl.ValueKind == JsonValueKind.True;
            return true;
        }
        catch (JsonException)
        {
            return false;
        }
    }

    /// <summary>
    /// Runs the <see cref="CodingAgent"/> for a user prompt, streaming events
    /// to the window through a <see cref="DesktopObserver"/>.
    /// </summary>
    private static async Task RunAgentAsync(AgentArguments args, string apiKey, PhotinoWindow window, string prompt)
    {
        if (string.IsNullOrWhiteSpace(prompt))
            return;

        var messages = await MemoryStore.LoadAsync(args.MemoryFile);
        if (messages.Count == 0)
            messages.Add(CodingAgent.SystemMessage(OperatingSystem.IsWindows()));

        messages.Add(JsonHelpers.Message("user", prompt));

        var model = args.ModelOverride ?? LlmSettings.Model;
        var observer = new DesktopObserver(window);
        _currentObserver = observer;

        using var agent = new CodingAgent(
            apiKey,
            LlmSettings.Endpoint,
            model,
            new AgentOptions(Confirm: true, DryRun: args.IsDryRun),
            observer);

        await agent.RunAsync(messages, args.MemoryFile);

        _currentObserver = null;
    }

    /// <summary>
    /// Serves the embedded desktop assets (HTML/CSS/JS) over the custom
    /// "app" scheme, so the Photino window can load them from resources
    /// instead of loose files on disk.
    /// </summary>
    private static Stream ServeEmbeddedAsset(object sender, string scheme, string url, out string contentType)
    {
        var path = url.Contains("://") ? url[(url.IndexOf("://") + 3)..] : url;
        path = path.Split('?')[0];

        switch (path)
        {
            case "index.html":
                contentType = "text/html";
                return new MemoryStream(Encoding.UTF8.GetBytes(DesktopAssets.HtmlUI));
            case "app.js":
                contentType = "text/javascript";
                return new MemoryStream(Encoding.UTF8.GetBytes(DesktopAssets.JsUI));
            case "styles.css":
                contentType = "text/css";
                return new MemoryStream(Encoding.UTF8.GetBytes(DesktopAssets.CssUI));
            default:
                contentType = "text/plain";
                return new MemoryStream(Encoding.UTF8.GetBytes("Not found"));
        }
    }
}
