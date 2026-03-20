# Adding Tool Calling Support to a Custom Ollama Gemma 3 Model

This documents how to patch an existing Ollama model that lacks tool calling support (e.g. `MHKetbi/Unsloth_gemma3-27b-it:q3_K_M`) by replacing its `TEMPLATE` with a tools-compatible one, without re-downloading any weights.

## Problem

`MHKetbi/Unsloth_gemma3-27b-it:q3_K_M` is a fine-tuned/quantised Gemma 3 27B model that fits in VRAM but was published to Ollama without tool calling support. Claude Code (and other agent frameworks) fail with:

```
Error: model does not support tools
```

This is a Modelfile `TEMPLATE` issue — the weights are capable, but the template doesn't include the `{{ .Tools }}` / `{{ .ToolCalls }}` directives Ollama needs to enable the tools API.

## Diagnosis

First, confirm the locally available Gemma 3 models:

```bash
ollama list | grep -i gemma
```

Then inspect the Modelfile of the target model and any locally available tools-compatible variants:

```bash
ollama show MHKetbi/Unsloth_gemma3-27b-it:q3_K_M --modelfile
ollama show gemma3:27b --modelfile
ollama show gemma3:27b-it-qat --modelfile
```

In this case, none of the locally available models (`gemma3:27b`, `gemma3:27b-16k`, `gemma3:27b-it-qat`) had tool calling support either — their templates only handle `user`, `system`, and `assistant` roles with no `{{ .Tools }}` directives.

The tools-compatible template was sourced from the community project [IllFil/gemma3-ollama-tools](https://github.com/IllFil/gemma3-ollama-tools).

## Solution

Create a new Modelfile (`gemma3-q3-tools.Modelfile`) that:

1. Points `FROM` at the existing model (reuses weights, no re-download)
2. Replaces the `TEMPLATE` with a tools-compatible one

### The Modelfile

```
FROM MHKetbi/Unsloth_gemma3-27b-it:q3_K_M
TEMPLATE """{{- if .Messages }}
{{- if or .System .Tools }}
<start_of_turn>user
{{- if .System }}
{{ .System }}
{{- end }}
{{- if .Tools }}
# Tools
You may call one or more functions to assist with the user query.
Provide function definitions as JSON within the following XML-like block:
<tools>
{{- range .Tools }}
{"type": "function", "function": {{ .Function }}}
{{- end }}
</tools>
For each function call, return a JSON object with the function name and arguments within:
<tool_call>
{"name": <function-name>, "arguments": <args-json-object>}
</tool_call>
{{- end }}
<end_of_turn>
{{- end }}
{{- range $i, $_ := .Messages }}
{{- $last := eq (len (slice $.Messages $i)) 1 -}}
{{- if eq .Role "user" }}
<start_of_turn>user
{{ .Content }}<end_of_turn>
{{ else if eq .Role "assistant" }}
<start_of_turn>model
{{ if .Content }}{{ .Content }}
{{- else if .ToolCalls }}
<tool_call>
{{- range .ToolCalls }}
{"name": "{{ .Function.Name }}", "arguments": {{ .Function.Arguments }}}
{{- end }}
</tool_call>
{{- end }}
{{ if not $last }}<end_of_turn>{{ end }}
{{ else if eq .Role "tool" }}
<start_of_turn>user
<tool_response>
{{ .Content }}
</tool_response>
<end_of_turn>
{{ end }}
{{- if and (ne .Role "assistant") $last }}
<start_of_turn>model
{{ end }}
{{- end }}
{{- else }}
{{- if .System }}
<start_of_turn>user
{{ .System }}<end_of_turn>
{{ end }}
{{ if .Prompt }}
<start_of_turn>user
{{ .Prompt }}<end_of_turn>
{{ end }}
<start_of_turn>model
{{ .Response }}{{ if .Response }}<end_of_turn>{{ end }}
{{- end }}"""
PARAMETER stop <end_of_turn>
PARAMETER temperature 1
PARAMETER top_k 64
PARAMETER top_p 0.95
LICENSE gemma
```

### Key template additions vs the original

| Feature | Original template | Tools template |
|---|---|---|
| System message | Prepended to first user turn | Separate `<start_of_turn>user` block |
| Tool definitions | Not supported | Injected via `{{ .Tools }}` inside `<tools>` tags |
| Tool calls (model output) | Not supported | `{{ .ToolCalls }}` rendered as `<tool_call>` JSON |
| Tool results (user input) | Not supported | `tool` role wrapped in `<tool_response>` tags |
| Completion fallback | No | Yes — handles non-chat `.Prompt`/`.Response` mode |

### Build the new model

```bash
ollama create MHKetbi/Unsloth_gemma3-27b-it:q3_K_M-tools \
  -f gemma3-q3-tools.Modelfile
```

Ollama reuses the existing weight layers — only a new manifest is written. The original model is untouched.

### Verify

```bash
ollama list | grep q3_K_M
```

Expected output:

```
MHKetbi/Unsloth_gemma3-27b-it:q3_K_M-tools    ...    13 GB    ...
MHKetbi/Unsloth_gemma3-27b-it:q3_K_M          ...    13 GB    ...
```

## Usage

Change the model reference in your config/project to:

```
MHKetbi/Unsloth_gemma3-27b-it:q3_K_M-tools
```

## Notes

- The blob path shown in `ollama show --modelfile` (`/usr/share/ollama/.ollama/models/blobs/...`) requires root to access directly. Use the model name in `FROM` instead.
- The `PARAMETER` values (`temperature`, `top_k`, `top_p`) are copied from the official `gemma3:27b` Modelfile to match Google's recommended defaults.
- Template source: [IllFil/gemma3-ollama-tools](https://github.com/IllFil/gemma3-ollama-tools)
