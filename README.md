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
| Read the message | Runs `cat mensagem.txt` to confirm the file persists across steps |

Key concept: steps inside the same job run on the same runner and share the workspace directory, so files created in one step persist for the next.

---

### 3. Isolation Between Jobs — `trabalho-entre-jobs.yml`

**Trigger:** push to `main`

Demonstrates that **jobs do not share a filesystem**. `job_1` writes `mensagem.txt`, but `job_2` runs on a fresh runner and cannot see that file — `cat mensagem.txt` will fail.

| Job | Step | What it does |
| --- | ---- | ------------ |
| job_1 | Check Ubuntu version | Runs `cat /etc/os-release` |
| job_1 | Write a message | Creates `mensagem.txt` on its runner |
| job_2 | List directory | Runs `ls -lha` — the file is absent |
| job_2 | Read the message | Attempts `cat mensagem.txt` — fails, proving isolation |

Key concept: each job gets its own isolated runner. Files written in one job are not available to another job without an explicit transfer mechanism.

---

### 4. Sharing Files Between Jobs via Artifacts — `trabalho-entre-jobs-2.yml`

**Trigger:** push to `main`

Solves the isolation problem from workflow 3 using GitHub's artifact system (`actions/upload-artifact` and `actions/download-artifact`). `job_2` declares `needs: job_1` to enforce ordering and then downloads the artifact before reading it.

| Job | Step | What it does |
| --- | ---- | ------------ |
| job_1 | Check Ubuntu version | Runs `cat /etc/os-release` |
| job_1 | Write a message | Writes `mensagem.txt` to `${{ github.workspace }}` |
| job_1 | Upload artifact | Uploads `mensagem.txt` as artifact `strigus-upload` |
| job_2 | List directory | Confirms runner starts with an empty workspace |
| job_2 | Download artifact | Downloads `strigus-upload` into the `strigus/` folder |
| job_2 | List directory | Verifies the artifact landed |
| job_2 | Move file | Moves `mensagem.txt` out of `strigus/` and removes the folder |
| job_2 | List directory | Confirms the final state |
| job_2 | Read the message | Runs `cat mensagem.txt` — succeeds |

Key concepts:

- **`needs`** — declares a dependency between jobs, forcing `job_2` to wait for `job_1` to succeed before starting.
- **`actions/upload-artifact`** — stores files produced by a job in GitHub's artifact storage.
- **`actions/download-artifact`** — retrieves those files in a later job.
- **`${{ github.workspace }}`** — the absolute path to the runner's workspace directory, used to ensure the artifact path is unambiguous.

---

## Key Concepts Covered

- **Workflow file** — a YAML file under `.github/workflows/` that defines automation
- **Event (`on`)** — what triggers the workflow (e.g. `push`, `pull_request`, `schedule`)
- **Job** — a group of steps that run on the same runner
- **Runner** — the virtual machine that executes the job (`ubuntu-latest`, `windows-latest`, etc.)
- **Step** — an individual task inside a job; steps share the job's filesystem
- **`run`** — executes a shell command on the runner
- **`needs`** — enforces job ordering by declaring dependencies between jobs
- **Artifacts** — files uploaded by one job and downloaded by another, bridging the isolation between runners

## Course

[LinuxTips — Criando Pipelines e Automações com Github Actions](https://linuxtips.io)
