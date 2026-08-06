# Lab: Tool-Using Agent

## Prerequisites
- Python 3.10+
- ollama installed and running (see [eng-01-local-llm.md](eng-01-local-llm.md))
- 8GB+ RAM
- 2GB disk space (llama3.2:1b is ~1.3GB, one-time pull)

## Setup

```bash
python -m venv .work.mlt/labs/tool-using-agent/.venv
source .work.mlt/labs/tool-using-agent/.venv/bin/activate
pip install requests
ollama pull llama3.2:1b
```

## Objectives
- Build a hand-rolled ReAct loop against a local ollama model
- Implement 3 tools: calculator (safe eval), sandboxed file reader, datetime
- Produce tool-call traces for 3 multi-step tasks
- Observe small-model failure modes and handle them with validation and retries

## Code

Save as `agent.py` and run with `python agent.py` from the repo root.

```python
import ast
import json
import operator
import re
from datetime import datetime
from pathlib import Path

import requests

# --- Configuration ---
MODEL = "llama3.2:1b"  # fallback: qwen2.5-coder:1.5b
OLLAMA_URL = "http://localhost:11434/api/generate"
SANDBOX_DIR = Path(__file__).resolve().parent / "fixtures"
MAX_STEPS = 8  # runaway protection for small models

# --- Fixtures (sandboxed files the agent may read) ---
FIXTURES = {
    "expenses.txt": "coffee 4.50\nlunch 12.00\ntaxi 18.75\nbook 9.99\n",
    "prices.txt": "apple: 1.20 each\nbread: 2.50 per loaf\nmilk: 1.80 per liter\n",
    "notes.txt": "Project deadline is Friday. Team has 3 developers. Budget 12000 euros.\n",
}
SANDBOX_DIR.mkdir(exist_ok=True)
for name, content in FIXTURES.items():
    path = SANDBOX_DIR / name
    if not path.exists():
        path.write_text(content)

# --- Tool 1: calculator (AST whitelist, never raw eval) ---
ALLOWED_OPS = {
    ast.Add: operator.add, ast.Sub: operator.sub,
    ast.Mult: operator.mul, ast.Div: operator.truediv,
    ast.Mod: operator.mod, ast.Pow: operator.pow,
    ast.USub: operator.neg,
}

def safe_eval(expr: str) -> float:
    def _eval(node):
        if isinstance(node, ast.Expression):
            return _eval(node.body)
        if isinstance(node, ast.Constant) and isinstance(node.value, (int, float)):
            return node.value
        if isinstance(node, ast.BinOp) and type(node.op) in ALLOWED_OPS:
            return ALLOWED_OPS[type(node.op)](_eval(node.left), _eval(node.right))
        if isinstance(node, ast.UnaryOp) and type(node.op) in ALLOWED_OPS:
            return ALLOWED_OPS[type(node.op)](_eval(node.operand))
        raise ValueError("disallowed expression")
    return _eval(ast.parse(expr, mode="eval"))

def calculator(expression: str) -> str:
    try:
        return str(safe_eval(expression))
    except Exception as e:
        return f"Error: {e}"

# --- Tool 2: file reader, confined to SANDBOX_DIR ---
def read_file(filename: str) -> str:
    try:
        path = (SANDBOX_DIR / filename).resolve()
        if not path.is_relative_to(SANDBOX_DIR):
            return "Error: path escapes sandbox"
        if not path.is_file():
            return f"Error: no such file: {filename}"
        return path.read_text()[:2000]
    except Exception as e:
        return f"Error: {e}"

# --- Tool 3: datetime ---
def get_datetime() -> str:
    return datetime.now().strftime("%Y-%m-%d %H:%M:%S (%A)")

TOOLS = {
    "calculator": calculator,
    "read_file": read_file,
    "get_datetime": get_datetime,
}

# --- Prompt: rigid format + one few-shot example (1B models need this) ---
SYSTEM_PROMPT = """You are an agent that solves tasks step by step using tools.

Available tools:
- calculator(expression: str): evaluate a math expression. Example input: {"expression": "2 + 3 * 4"}
- read_file(filename: str): read a text file. Example input: {"filename": "expenses.txt"}
- get_datetime(): current date and time, no arguments. Example input: {}

Use this exact format, one action per step:
Thought: <reasoning about the next step>
Action: <tool name>
Action Input: <JSON arguments>
You then receive: Observation: <tool result>

When you have the answer:
Thought: I know the answer
Final Answer: <answer>

Example:
Task: How much is 15 plus 27?
Thought: I need to add two numbers.
Action: calculator
Action Input: {"expression": "15 + 27"}
Observation: 42
Thought: I know the answer
Final Answer: 42

Rules: never invent observations, never skip the Action Input line.
"""

def llm(prompt: str, stop: list | None = None) -> str:
    options = {"temperature": 0}  # deterministic, the seed-equivalent for LLM calls
    if stop:
        options["stop"] = stop
    resp = requests.post(
        OLLAMA_URL,
        json={"model": MODEL, "prompt": prompt, "stream": False, "options": options},
        timeout=300,
    )
    resp.raise_for_status()
    return resp.json()["response"]

def parse_action(text: str) -> tuple[str, dict]:
    m_action = re.search(r"Action:\s*(\w+)", text)
    m_input = re.search(r"Action Input:\s*(\{.*?\})", text, re.DOTALL)
    if not m_action or not m_input:
        raise ValueError("could not parse Action / Action Input")
    return m_action.group(1), json.loads(m_input.group(1))

def run_agent(task: str) -> None:
    print(f"\n{'=' * 60}\nTASK: {task}\n{'=' * 60}")
    scratchpad = ""
    for step in range(1, MAX_STEPS + 1):
        prompt = SYSTEM_PROMPT + f"\nTask: {task}\n{scratchpad}\nThought:"
        # stop sequence prevents the model from hallucinating its own observations
        completion = llm(prompt, stop=["Observation:"])
        step_text = "Thought:" + completion
        print(f"\n--- Step {step} ---\n{step_text.strip()}")
        if "Final Answer:" in step_text:
            answer = step_text.split("Final Answer:")[-1].strip()
            print(f"\nFINAL: {answer}")
            return
        # Validation + retry: bad output becomes an observation, loop continues
        try:
            name, args = parse_action(step_text)
            if name not in TOOLS:
                raise ValueError(f"unknown tool '{name}'")
            result = TOOLS[name](**args)
        except (ValueError, TypeError, json.JSONDecodeError) as e:
            result = f"Error: {e}. Fix the format and try again."
        print(f"Observation: {result}")
        scratchpad += f"{step_text}\nObservation: {result}\n"
    print("\nStopped: step limit reached without a final answer.")

TASKS = [
    "Read the file expenses.txt, add up all the amounts, and give the total.",
    "Read the file prices.txt, then calculate the total cost of 3 apples and 2 loaves of bread.",
    "Get the current date and time, then multiply the current hour by 3600 to get seconds.",
]

if __name__ == "__main__":
    for task in TASKS:
        run_agent(task)
```

## Expected Output
- A trace per task: numbered steps with `Thought`, `Action`, `Action Input`, `Observation`
- Task 1: `read_file` then `calculator`, final answer `45.24`
- Task 2: `read_file` then `calculator`, final answer `8.6`
- Task 3: `get_datetime` then `calculator`, final answer = current hour x 3600
- Occasional `Error: ...` observations followed by a corrected retry are normal for a 1B model

## Failure Modes and Validation
- Format drift: model skips `Action Input` or invents tools -> parse error fed back as observation, retry
- Hallucinated observations: model writes its own `Observation:` -> blocked by the stop sequence
- Bad JSON / wrong arg names: `json.JSONDecodeError` / `TypeError` caught and fed back
- Sandbox escape (`../`): rejected by the `is_relative_to` check in `read_file`
- Runaway loops: capped by `MAX_STEPS`
- Unsafe math: AST whitelist in `safe_eval`, raw `eval()` is never used

## Troubleshooting
- Connection refused: start ollama with `ollama serve` or launch the desktop app
- Model not found: run `ollama pull llama3.2:1b`
- Agent loops without finishing: shorten the task, raise `MAX_STEPS`, or switch `MODEL` to `qwen2.5-coder:1.5b`
- Slow responses on CPU: expected at 1B params; keep `temperature: 0` and short prompts
- Repeated parse errors: verify the model tag is exact (`ollama list`), tiny models are format-sensitive

## Cleanup
```bash
deactivate
rm -rf .work.mlt/labs/tool-using-agent/.venv
rm -rf fixtures agent.py
```
