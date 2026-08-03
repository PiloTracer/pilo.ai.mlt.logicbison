# Lab: Prompt Engineering

## Prerequisites
- Python 3.10+
- ollama installed and running (see [eng-01-local-llm.md](eng-01-local-llm.md))
- 8GB+ RAM
- 2GB free disk space

## Setup

```bash
ollama pull llama3.2:1b
python -m venv .training.mlt/labs/prompt-engineering/.venv
source .training.mlt/labs/prompt-engineering/.venv/bin/activate
pip install requests
```

Note: `ollama pull` downloads ~1.3GB once. Skip it if the model is already present from drill eng-01.

## Objectives
- Implement zero-shot, few-shot, and chain-of-thought prompting against a local model
- Score strategies automatically on classification, extraction, and reasoning tasks
- Analyze which strategy wins per task type

## Code

```python
import requests

OLLAMA_URL = "http://localhost:11434/api/generate"
MODEL = "llama3.2:1b"

# 10 fixed tasks: 4 classification, 3 extraction, 3 reasoning.
# check "exact": expected string must appear in the model's final answer line.
# check "keywords": every expected string must appear anywhere in the response.
TASKS = [
    {"id": "C1", "type": "classification",
     "instruction": "Classify the sentiment as positive or negative. Reply with one word.",
     "input": "I absolutely loved this movie, it was fantastic!",
     "expected": ["positive"], "check": "exact"},
    {"id": "C2", "type": "classification",
     "instruction": "Classify the sentiment as positive or negative. Reply with one word.",
     "input": "The service was terrible and the food arrived cold.",
     "expected": ["negative"], "check": "exact"},
    {"id": "C3", "type": "classification",
     "instruction": "Classify the topic as sports or technology. Reply with one word.",
     "input": "The striker scored twice in the final minutes of the match.",
     "expected": ["sports"], "check": "exact"},
    {"id": "C4", "type": "classification",
     "instruction": "Classify the topic as sports or technology. Reply with one word.",
     "input": "The new processor doubles battery life on laptops.",
     "expected": ["technology"], "check": "exact"},
    {"id": "E1", "type": "extraction",
     "instruction": "Extract the destination city. Reply with only the city name.",
     "input": "Maria flew from Berlin to Tokyo last Tuesday.",
     "expected": ["tokyo"], "check": "keywords"},
    {"id": "E2", "type": "extraction",
     "instruction": "Extract the person's name. Reply with only the name.",
     "input": "Please call Dr. Smith about the test results.",
     "expected": ["smith"], "check": "keywords"},
    {"id": "E3", "type": "extraction",
     "instruction": "Extract the meeting date. Reply with only the date.",
     "input": "The review meeting is scheduled for March 15 at 3pm.",
     "expected": ["march 15"], "check": "keywords"},
    {"id": "R1", "type": "reasoning",
     "instruction": "Answer the math question with a single number.",
     "input": "If you have 3 apples and buy 5 more, how many apples do you have?",
     "expected": ["8"], "check": "keywords"},
    {"id": "R2", "type": "reasoning",
     "instruction": "Answer yes or no.",
     "input": "All cats are animals. Tom is a cat. Is Tom an animal?",
     "expected": ["yes"], "check": "exact"},
    {"id": "R3", "type": "reasoning",
     "instruction": "Answer the math question with a single number.",
     "input": "A train travels 60 km in 2 hours. What is its speed in km per hour?",
     "expected": ["30"], "check": "keywords"},
]

# Few-shot examples per task type (distinct from the test tasks).
FEW_SHOT = {
    "classification": (
        "Text: This phone is amazing, best purchase ever.\nAnswer: positive\n\n"
        "Text: The battery died after one hour. Awful.\nAnswer: negative\n\n"
        "Text: The goalkeeper saved the penalty kick.\nAnswer: sports\n\n"
        "Text: The software update fixes a security bug.\nAnswer: technology\n\n"
    ),
    "extraction": (
        "Text: John moved to Paris in 2019.\nAnswer: Paris\n\n"
        "Text: The invoice total is 250 dollars.\nAnswer: 250 dollars\n\n"
        "Text: The flight from Oslo to Rome departs at noon.\nAnswer: Rome\n\n"
    ),
    "reasoning": (
        "Text: A pen costs 2 dollars. How much do 4 pens cost?\nAnswer: 8\n\n"
        "Text: Sara has 10 stickers and gives away 3. How many stickers does she have left?\nAnswer: 7\n\n"
    ),
}

STRATEGIES = ["zero_shot", "few_shot", "chain_of_thought"]


def build_prompt(task, strategy):
    """Assemble the prompt for one task under one strategy."""
    if strategy == "zero_shot":
        return f"{task['instruction']}\nText: {task['input']}\nAnswer:"
    if strategy == "few_shot":
        examples = FEW_SHOT[task["type"]]
        return f"{task['instruction']}\n\n{examples}Text: {task['input']}\nAnswer:"
    # chain_of_thought: ask for reasoning, final answer after "Answer:"
    return (
        f"{task['instruction']}\nText: {task['input']}\n"
        "Think step by step, then give the final answer after 'Answer:'."
    )


def query(prompt):
    """Send a prompt to the local ollama server. Deterministic decoding."""
    resp = requests.post(OLLAMA_URL, json={
        "model": MODEL,
        "prompt": prompt,
        "stream": False,
        "options": {"temperature": 0, "seed": 42, "num_predict": 150},
    }, timeout=120)
    resp.raise_for_status()
    return resp.json()["response"].strip()


def check(task, response):
    """Score one response: exact match on final line, or keyword presence."""
    out = response.lower()
    if task["check"] == "exact":
        final_line = out.strip().splitlines()[-1].strip().strip(".")
        return task["expected"][0] in final_line
    return all(k in out for k in task["expected"])


def main():
    # Fail fast if the local server is not reachable.
    try:
        requests.get("http://localhost:11434/api/tags", timeout=5)
    except requests.exceptions.ConnectionError:
        raise SystemExit("ollama is not running. Start it with: ollama serve")

    results = {}
    for task in TASKS:
        results[task["id"]] = {}
        for strategy in STRATEGIES:
            response = query(build_prompt(task, strategy))
            passed = check(task, response)
            results[task["id"]][strategy] = passed
            print(f"{task['id']} {strategy:<16} {'PASS' if passed else 'FAIL'}")

    # Results table.
    print("\n=== Results ===")
    print(f"{'Task':<6}{'Type':<16}{'Zero-shot':<12}{'Few-shot':<12}{'CoT':<6}")
    for task in TASKS:
        row = results[task["id"]]
        marks = ["+" if row[s] else "-" for s in STRATEGIES]
        print(f"{task['id']:<6}{task['type']:<16}{marks[0]:<12}{marks[1]:<12}{marks[2]:<6}")

    # Totals per strategy.
    print("\n=== Totals ===")
    for s in STRATEGIES:
        total = sum(results[t["id"]][s] for t in TASKS)
        print(f"{s:<16} {total}/{len(TASKS)}")

    # Winning strategy per task type.
    print("\n=== Winner per task type ===")
    for typ in ["classification", "extraction", "reasoning"]:
        subset = [t for t in TASKS if t["type"] == typ]
        scores = {s: sum(results[t["id"]][s] for t in subset) for s in STRATEGIES}
        best = max(scores, key=scores.get)
        print(f"{typ:<16} winner: {best} ({scores[best]}/{len(subset)})  {scores}")


if __name__ == "__main__":
    main()
```

## Expected Output
- 30 scored runs (10 tasks x 3 strategies), each printed as PASS or FAIL
- A results table with `+`/`-` per task and strategy
- Totals per strategy: on these easy tasks all three score high (a verified run gave zero-shot 10/10, few-shot 9/10, CoT 9/10); ties are common, and a 1B model occasionally refuses or misreads a few-shot prompt
- A winner per task type with the full score dict, e.g. `classification winner: zero_shot (4/4) {'zero_shot': 4, 'few_shot': 4, 'chain_of_thought': 3}`
- The analysis is the deliverable: note where strategies tie, where extra prompt structure helps or hurts, and how that changes with model size

## Troubleshooting
- `ollama is not running`: start the server with `ollama serve` in a separate terminal
- `model 'llama3.2:1b' not found`: run `ollama pull llama3.2:1b`
- Very slow runs on CPU: close other applications; a 1B model on CPU takes a few seconds per call, 30 calls take a few minutes
- Inconsistent scores between runs: keep `temperature: 0` and the fixed `seed` in `options`; the 1B model is small, so a borderline task flipping is expected

## Cleanup
```bash
deactivate
rm -rf .training.mlt/labs/prompt-engineering/.venv
```

Optionally free the model (only if no later drill needs it):
```bash
ollama rm llama3.2:1b
```
