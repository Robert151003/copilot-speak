# copilot-speak

Read text aloud on Windows with [Fish Audio](https://fish.audio). A small PowerShell script: it sends text to the Fish TTS API and plays the audio. Only one voice plays at a time, because a new call cuts off the previous one. Long text is cleaned of markdown and trimmed to about 600 characters at a sentence boundary.

It uses Fish's free model (`s2.1-pro-free`), so no paid credit is needed.

## Requirements

- Windows 10/11 with Windows PowerShell 5.1 or later (built in)
- `curl.exe` (ships with Windows 10 1803+)
- A Fish Audio account and API key: <https://fish.audio/app/api-keys/>

## Install

```powershell
git clone https://github.com/Robert151003/copilot-speak "$env:USERPROFILE\.copilot\speak"
cd "$env:USERPROFILE\.copilot\speak"
.\toggle.ps1 key     # creates .env from the template and opens it; paste your key after FISH_API_KEY=
.\toggle.ps1 on      # turn speech on
```

If scripts are blocked, run once: `Set-ExecutionPolicy -Scope CurrentUser RemoteSigned`.

The `.env` file is gitignored, so your key is never committed. A `FISH_API_KEY` environment variable takes priority over the file.

## Use

```powershell
.\speak.ps1 "Hello from Fish Audio"
"some text" | .\speak.ps1 -Stdin
```

| Command | What it does |
| --- | --- |
| `.\toggle.ps1 on` | Enable speech |
| `.\toggle.ps1 off` | Disable speech (`speak.ps1` exits silently) |
| `.\toggle.ps1 status` | Show whether speech is on |
| `.\toggle.ps1 key` | Create/open `.env` to set your API key |

## Hooking it into an agent

Any tool that can run a command with the reply text works. For example, call `powershell -NoProfile -File "%USERPROFILE%\.copilot\speak\speak.ps1" -Stdin` from a hook and pipe the reply in.

## Notes

- Speech only plays while `enabled` exists, so you can leave hooks wired up and switch it off.
- The free model has rate limits. See Fish's [pricing page](https://docs.fish.audio/developer-guide/models-pricing/pricing-and-rate-limits).
- Each spoken reply sends its text to Fish Audio.
