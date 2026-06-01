# linuxtips-github-actions

Examples from the **"Criando Pipelines e Automações com Github Actions"** course by [LinuxTips](https://linuxtips.io).

## About

This repository contains hands-on workflow examples built throughout the course. Each workflow introduces a new concept about GitHub Actions, from the very first trigger to sharing data between steps.

## Prerequisites

- A GitHub account
- A repository with Actions enabled (enabled by default on all repos)

No local tooling is required — all workflows run on GitHub-hosted runners.

## Workflows

### 1. First Workflow — `meu-primeiro-workflow.yml`

**Trigger:** push to `main`

Introduces the basic anatomy of a workflow: events, jobs, runners, and steps.

| Step | What it does |
| ------ | ------------- |
| Check Ubuntu version | Runs `cat /etc/os-release` to inspect the runner OS |
| Display a message | Prints a confirmation message to the Actions log |

```yaml
on:
  push:
    branches:
      - main

jobs:
  giropops:
    runs-on: ubuntu-latest
    steps:
      - name: Confere versao do ubuntu
        run: cat /etc/os-release

      - name: Exebir uma mensagem
        run: echo "Estou fazendo um curso de Github Actions da LinuxTips"
```

---

### 2. Sharing Data Between Steps — `trabalho-entre-steps.yml`

**Trigger:** push to `main`

Builds on the first workflow by writing output from one step to a file (`mensagem.txt`) so subsequent steps can consume it — demonstrating how steps within the same job share the same filesystem.

| Step | What it does |
| ------ | ------------- |
| Check Ubuntu version | Runs `cat /etc/os-release` |
| Write a message | Redirects `echo` output to `mensagem.txt` |
| _(next step)_ | Reads or processes `mensagem.txt` |

Key concept: steps inside the same job run on the same runner and share the workspace directory, so files created in one step persist for the next.

---

## Key Concepts Covered

- **Workflow file** — a YAML file under `.github/workflows/` that defines automation
- **Event (`on`)** — what triggers the workflow (e.g. `push`, `pull_request`, `schedule`)
- **Job** — a group of steps that run on the same runner
- **Runner** — the virtual machine that executes the job (`ubuntu-latest`, `windows-latest`, etc.)
- **Step** — an individual task inside a job; steps share the job's filesystem
- **`run`** — executes a shell command on the runner

## Course

[LinuxTips — Criando Pipelines e Automações com Github Actions](https://linuxtips.io)
