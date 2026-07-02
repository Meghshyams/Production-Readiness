## Phase 10: AI/LLM Safety

**Note**: This phase applies only to projects that integrate an LLM/AI provider. If Phase 1 (Detection) found no AI SDK or model API usage, skip this phase with a note: "No AI/LLM integration detected — skipping AI safety checks."

**Detection signal**: an AI integration is present if `package.json` (or the language equivalent) includes any of `openai`, `@anthropic-ai/sdk`, `@ai-sdk/*` / `ai` (Vercel AI SDK), `langchain` / `@langchain/*`, `llamaindex`, `@google/generative-ai` / `@google/genai`, `cohere-ai`, `@mistralai/mistralai`, `ollama`, `replicate`, `groq-sdk`, `bedrock` / `@aws-sdk/client-bedrock-runtime`, or Python `openai` / `anthropic` / `langchain` / `litellm` / `google-generativeai`; or if code calls a model endpoint (`/v1/chat/completions`, `messages.create`, `chat.completions.create`, `generateText`, `streamText`).

### 10.1 Prompt Injection Surfaces

Untrusted input (user messages, retrieved documents, tool/function results, scraped web content) flowing into a prompt is the #1 LLM risk.

- Find where user input is concatenated directly into a system prompt or instruction (string interpolation/templating into the `system` field or a prompt that also carries instructions).
- Check that untrusted content is clearly delimited from instructions (e.g., placed in a `user`/tool role, fenced, or XML-tagged) rather than blended into the system prompt.
- For RAG / agent tool outputs: check that retrieved or tool-returned text is treated as data, not as instructions.
- Flag prompts that instruct the model to follow instructions found inside user/document content.
- **Severity**: WARNING for untrusted input merged into a system/instruction prompt; CRITICAL if the model's output then drives a privileged action (SQL, shell, file writes, payments) without validation.

### 10.2 Secret & PII Leakage into Prompts

- Check that API keys, internal URLs, full DB rows, or other secrets aren't being interpolated into prompts sent to a third-party provider.
- Check whether PII (emails, names, payment data, health data) is sent to external model APIs without consent/redaction — relevant for GDPR/CCPA/HIPAA.
- Verify provider API keys are server-side only — flag any model SDK initialized in client/browser code (e.g., `dangerouslyAllowBrowser: true`, an `OpenAI`/Anthropic client in a React component, or a key in a `NEXT_PUBLIC_*` / `VITE_*` env var).
- **Severity**: CRITICAL if a provider key is exposed client-side or a `NEXT_PUBLIC_*`/`VITE_*` var holds an AI key; WARNING for unredacted PII sent to external providers.

### 10.3 Untrusted Output Handling

LLM output is untrusted input to the rest of your system.

- Model output rendered as HTML/markdown: check for sanitization before `dangerouslySetInnerHTML` / `v-html` (XSS via generated content).
- Model output used to build SQL, shell commands, file paths, or HTTP requests: check for validation/parameterization (prompt-injection → code execution / SSRF).
- Agent/tool-calling setups: check that tools the model can invoke are scoped (allow-list, least privilege) and that destructive tools require confirmation.
- Structured output: check that JSON from the model is schema-validated (zod/pydantic) before use, not blindly `JSON.parse`d and trusted.
- **Severity**: CRITICAL if model output reaches an interpreter/privileged sink unvalidated; WARNING for unsanitized rendering.

### 10.4 Token & Cost Guardrails

- Check for `max_tokens` / `maxOutputTokens` limits on completion calls (unbounded generation = runaway cost).
- Check for input-length limits / truncation on user-supplied content before it hits the model.
- Check for per-user / per-IP rate limiting or quotas on AI endpoints (abuse and cost-bombing protection).
- Check for a request timeout / abort on model calls so a hung provider request can't pile up.
- **Severity**: WARNING if no `max_tokens` or no rate limiting on public AI endpoints; INFO for missing input truncation.

### 10.5 Model & SDK Pinning

- Check whether model identifiers are pinned to explicit snapshots vs floating aliases (a moving alias can silently change behavior, cost, and output shape in production).
- Check that the AI SDK itself is version-pinned (not a floating `^`/`latest` that could ship breaking changes).
- Check for a configurable/fallback model strategy (degrade gracefully if the primary model is unavailable or rate-limited).
- **Severity**: INFO — recommend pinning models and SDKs for reproducible production behavior.

### 10.6 AI Endpoint Reliability & Error Handling

- Check that model calls are wrapped in error handling (provider 429/500/timeout) and don't crash the request or leak raw provider errors to the client.
- Check for retry-with-backoff on transient provider failures (and that retries are bounded).
- Streaming responses: check that a mid-stream provider error is handled and surfaced cleanly to the UI.
- Check for a fallback/user-facing message when the AI feature is down rather than a hard failure.
- **Severity**: WARNING if model calls have no error handling; INFO for missing retry/backoff.

### 10.7 AI Observability & Abuse Controls

- Check whether prompts/completions, token usage, latency, and cost are logged or traced (LangSmith, Helicone, Langfuse, OpenTelemetry GenAI, or custom) — needed to debug and control spend.
- Verify that logged prompts/completions don't persist secrets or PII (ties to 5.5 and 10.2).
- Check for content moderation / safety filtering on user input and/or model output where the product surface warrants it (user-generated, public-facing).
- Check for an abuse/jailbreak guard on sensitive flows (system-prompt extraction attempts, off-topic abuse).
- **Severity**: INFO — recommend AI observability and moderation for production AI features; WARNING if prompts containing secrets/PII are logged in plain text.
