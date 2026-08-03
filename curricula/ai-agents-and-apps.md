# AI Agents and Applications

**Slug:** `ai-agents-and-apps`
**Duration:** 4-6 weeks · 3 sessions/week
**Level:** Intermediate-Advanced
**Prerequisites:** `llm-engineering` (all modules)

## Audience
Learners who can run and prompt LLMs and want to build full AI applications. Product-minded engineering focus. Common misconception: "multi-agent is always better than single-agent."

## Duration & Cadence
4-6 weeks, 3 sessions/week. Sessions: 90 min (architecture + live building). Async: building apps, user testing, eval iteration.

## Outcomes
1. Design AI app architectures with state management and error handling
2. Build tool-using agents with function calling and MCP
3. Implement multi-agent systems with clear role separation
4. Apply eval-driven development systematically
5. Ship polished demos with Gradio/Streamlit

## Modules

### Module 1: AI Application Architecture (Week 1-2)
**Objectives:** Design robust architectures for LLM-powered apps.
**Content:** Patterns (chatbot, copilot, autonomous agent, pipeline). State management (conversation history, session state, persistent memory, context window). Error handling (retries, fallbacks, timeouts). Streaming (SSE, token streaming). Configuration (model selection, temperature, system prompts, A/B testing).
**Lab:** Conversational AI app with persistent history, session isolation, configurable system prompts, streaming responses, structured error handling with fallbacks.
**Sources:** [Anthropic — Effective Agents](https://www.anthropic.com/engineering/building-effective-agents) · [LangChain Concepts](https://python.langchain.com/docs/concepts/) · [OpenAI Cookbook](https://cookbook.openai.com/)
**Exit check:** App handles 5+ concurrent sessions with state isolation and error recovery.

### Module 2: Tool Use and Function Calling (Week 2-3)
**Objectives:** Build agents that interact with external systems.
**Content:** Function calling (JSON schemas, validation, parallel calls). MCP protocol (Model Context Protocol, tool servers, resource servers). Tool design (atomic, composable, error propagation). Security (sandboxing, permission scoping, audit logging). Orchestration (sequential chains, conditional use, caching).
**Lab:** Agent with 5+ tools (web search, file ops, code exec, API calls, DB queries). JSON schemas, input validation, failure handling. Connect via MCP.
**Sources:** [Anthropic Tool Use](https://docs.anthropic.com/en/docs/agents-and-tools/tool-use/overview) · [MCP Specification](https://modelcontextprotocol.io/) · [OpenAI Function Calling](https://platform.openai.com/docs/guides/function-calling) · [LangChain Tools](https://python.langchain.com/docs/concepts/tools/)
**Exit check:** Agent completes multi-tool task with error handling and no security violations.

### Module 3: Multi-Agent Systems (Week 3-4)
**Objectives:** Design multi-agent collaboration.
**Content:** Patterns (supervisor/worker, debate, pipeline, hierarchical). CrewAI (role-based, task delegation). LangGraph (state machines, conditional edges, human-in-the-loop, checkpointing). AutoGen (conversation patterns, group chat). Communication (shared memory, message passing, conflict resolution).
**Lab:** Multi-agent research system: Planner decomposes, Researcher gathers, Coder analyzes, Reviewer validates. Use LangGraph for orchestration.
**Sources:** [LangGraph](https://langchain-ai.github.io/langgraph/) · [CrewAI](https://docs.crewai.com/) · [AutoGen](https://microsoft.github.io/autogen/) · [smolagents](https://huggingface.co/docs/smolagents/)
**Exit check:** Multi-agent system with clear role separation and documented handoffs.

### Module 4: Evaluation (Week 4-5)
**Objectives:** Eval-driven development for AI applications.
**Content:** Eval-driven dev (define metrics first, iterate on evals). Types (unit evals, integration evals, E2E user journeys). Eval datasets (golden sets, edge cases, adversarial inputs, regression tests). Metrics (task completion, latency, cost, satisfaction). Continuous eval (CI integration, regression detection, tracking).
**Lab:** Eval suite for your agent: 50+ test cases (happy path, edge cases, failures). Integrate into CI. Track metrics across iterations, demonstrate improvement.
**Sources:** [Anthropic Eval Guide](https://docs.anthropic.com/en/docs/test-and-evaluate/eval-tool) · [Braintrust](https://www.braintrust.dev/docs) · [LangSmith](https://docs.smith.langchain.com/evaluation)
**Exit check:** Eval suite catches deliberate regression; metrics tracked across 3+ iterations.

### Module 5: UI and Demos (Week 5-6)
**Objectives:** Build polished, shareable demos.
**Content:** Gradio (ChatInterface, Blocks, custom components, streaming). Streamlit (chat elements, session state, multipage). Demo design (progressive disclosure, loading states, examples). HF Spaces (deployment, hardware, storage, auth).
**Lab:** Gradio demo for multi-agent system: streaming, conversation history, file upload, example gallery. Run and share locally by default; deploy to HF Spaces only if the learner explicitly opts in.
**Sources:** [Gradio](https://www.gradio.app/docs/) · [Streamlit](https://docs.streamlit.io/) · [HF Spaces](https://huggingface.co/docs/hub/spaces)
**Exit check:** Demo with streaming, examples, and graceful error handling — running locally (deployment optional, on explicit request).

## Assessment

| Criterion | Pass condition |
|-----------|----------------|
| Architecture | 5+ concurrent sessions with state isolation |
| Tool use | Multi-tool tasks with error handling and validation |
| Multi-agent | Clear role separation and successful collaboration |
| Evaluation | Catches regressions; metrics tracked across iterations |
| Demo | Runs locally with streaming, examples, error handling |

## Exit Criteria
All exit checks met. Artifacts in `.training.mlt/`: app codebase, tool definitions, multi-agent system, eval suite, demo link.
