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

**Trigger:** manual (`workflow_dispatch`)

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

### 5. Challenge 1 — `primeiro-desafio.yml`

**Trigger:** manual (`workflow_dispatch`)

**Branch:** `primeiro-desafio`

The first hands-on challenge of the course. The goal was to build a manually triggered workflow that accepts a Docker image name as input, pulls it on the runner, lists the local images to confirm the pull, and runs a vulnerability scan with Docker Scout.

**Required input:**

| Field | Description | Default |
| ----- | ----------- | ------- |
| `imagem_docker` | Name and tag of the Docker image to test (e.g. `alpine:latest`) | `alpine:latest` |

| Step | What it does |
| ---- | ------------ |
| Checkout | Checks out the repository on the runner |
| Docker Hub login | Authenticates with Docker Hub using `DOCKERHUB_USERNAME` and `DOCKERHUB_TOKEN` secrets |
| Pull Docker image | Runs `docker pull` with the image provided via input |
| List Docker images | Runs `docker images` to confirm the pull succeeded |
| Vulnerability scan with Docker Scout | Uses the `docker/scout-action@v1` action to scan the image and print the CVE report to the logs |

```yaml
on:
  workflow_dispatch:
    inputs:
      imagem_docker:
        description: 'Enter the Docker image name and tag'
        required: true
        default: 'alpine:latest'
        type: string
```

Key concepts:

- **`workflow_dispatch`** — manual trigger that runs the workflow from the GitHub Actions UI without requiring a push or pull request event.
- **`inputs`** — input fields defined under `workflow_dispatch`; the value typed by the user is available throughout the workflow via `${{ inputs.imagem_docker }}`.
- **Secrets** — sensitive credentials (Docker Hub username and token) stored as repository secrets and never hardcoded in the YAML.
- **`docker/scout-action`** — Docker's official action for CVE vulnerability analysis, integrated directly as a step inside the job.

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

## Triggers

A **trigger** is the event configured under `on:` that tells GitHub when to run a workflow. This repo uses two of them:

| Trigger | Used in | Fires when |
| ------- | ------- | ---------- |
| `push` | `trabalho-entre-steps.yml`, `trabalho-entre-jobs.yml`, `trabalho-entre-jobs-2.yml` | A commit is pushed to the `main` branch |
| `workflow_dispatch` | `meu-primeiro-workflow.yml`, `primeiro-desafio.yml` | Someone manually runs the workflow from the **Actions** tab (optionally with `inputs`) |

```yaml
# push — runs automatically on every commit to main
on:
  push:
    branches:
      - main

# workflow_dispatch — runs only when triggered manually, with optional inputs
on:
  workflow_dispatch:
    inputs:
      imagem_docker:
        description: 'Enter the Docker image name and tag'
        required: true
        default: 'alpine:latest'
        type: string
```

Other common triggers not used in this repo, for reference:

| Trigger | Fires when |
| ------- | ---------- |
| `pull_request` | A PR is opened, synchronized, or reopened against a target branch |
| `schedule` | On a cron schedule (e.g. `cron: '0 3 * * *'`) |
| `release` | A release is published/created/edited |
| `workflow_call` | The workflow is invoked by another workflow (reusable workflows) |

A workflow can also combine multiple triggers under the same `on:` key (e.g. `push` **and** `workflow_dispatch`), so it can run automatically and still be launched manually when needed.

## Git Flow & Repository Practices

Beyond the workflow files themselves, this repository follows a few baseline Git practices that go hand-in-hand with CI/CD: a lightweight Git Flow branching model, pull requests for every change, and branch protection rules on the main branches.

### Git Flow

This repo uses a simplified version of the **Git Flow** branching model:

| Branch | Purpose |
| ------ | ------- |
| `main` | Always reflects stable, reviewed code. Protected — no direct pushes. |
| `develop` | Integration branch where finished features land before going to `main`. |
| `feature/*` | Short-lived branches for new work (e.g. `feature/primeiro-desafio`). Branched off `develop`, merged back via pull request, then deleted. |

Typical flow for a change:

1. Branch off: `git checkout -b feature/my-change develop`
2. Commit small, focused changes with clear messages.
3. Push the branch and open a pull request targeting `develop` (or `main` for hotfixes).
4. After review and passing checks, merge and delete the branch.

This keeps `main` stable, makes history easier to follow, and gives every change a place — the PR — to be reviewed and discussed before it lands.

### Understanding Pull Requests

A **pull request (PR)** is a request to merge changes from one branch into another. It's not just a "merge button" — it's the unit of code review:

- **Diff view** — shows exactly what changed, file by file.
- **Discussion thread** — reviewers can comment on specific lines or the PR as a whole.
- **Checks** — any CI workflows triggered by `pull_request` (tests, linting, vulnerability scans, etc.) run automatically and report status directly on the PR.
- **Merge methods** — GitHub offers three ways to bring a PR in:
  - **Merge commit** — keeps full history and adds a merge commit (used in this repo).
  - **Squash and merge** — collapses all PR commits into one, keeping the target branch history linear.
  - **Rebase and merge** — replays commits on top of the target branch without a merge commit.

**Best practices:**

- Keep PRs small and focused on a single concern — easier to review, easier to revert.
- Write a descriptive title and summary: what changed and why, not just what.
- Reference the related branch or issue (e.g. `feature/primeiro-desafio` → "Challenge 1").
- Let CI checks finish before merging — don't merge against a red or pending status.
- Delete the branch after merging to keep the branch list clean.

### Branch Protection Rules

**Branch protection rules** are settings GitHub lets you apply to specific branches (typically `main` and `develop`) to enforce quality gates before code lands there. They prevent force-pushes, accidental deletions, and merges that skip review or CI.

Common rules and what they do:

| Rule | Effect |
| ---- | ------ |
| Require a pull request before merging | Blocks direct pushes — all changes must go through a PR. |
| Require approvals | A PR needs at least N approving reviews before it can be merged. |
| Require status checks to pass | A PR can't be merged until selected CI workflows (e.g. a GitHub Actions job) succeed. |
| Require branches to be up to date before merging | Forces the PR branch to be in sync with the latest target branch before merging, avoiding "it passed CI but broke after merge." |
| Require conversation resolution | All review comments must be marked resolved before merging. |
| Restrict who can push | Limits direct push access to specific people or teams. |
| Block force pushes / branch deletion | Protects branch history from being rewritten or removed. |

### Configuring Branch Protection on GitHub

These rules live under the repository settings and don't require any code changes:

1. Go to **Settings → Branches** (or **Settings → Rules → Rulesets** on newer GitHub UIs).
2. Under **Branch protection rules**, click **Add rule** (or **Add branch ruleset**).
3. Set the branch name pattern to protect (e.g. `main`, `develop`).
4. Enable the checks that fit the project, for example:
   - "Require a pull request before merging", with a minimum number of approvals.
   - "Require status checks to pass before merging" → select the relevant job(s) from the workflows defined in `.github/workflows/`.
   - "Do not allow bypassing the above settings" to apply the rule to administrators as well.
5. Save the rule.

Once configured, GitHub automatically blocks merges on the protected branch until the required reviews and checks are satisfied — the same checks that show up as ✅/❌ on every pull request in this repo.

### Using CODEOWNERS

A **CODEOWNERS** file tells GitHub which individuals or teams are responsible for specific paths in the repository. When a pull request touches a path that has an owner, GitHub automatically requests a review from that owner — removing the need to manually pick reviewers on every PR.

How it works:

1. Create a `CODEOWNERS` file in one of these locations: the repository root, `.github/CODEOWNERS`, or `docs/CODEOWNERS`.
2. Each line maps a file pattern to one or more owners (a GitHub username or team, prefixed with `@`):

```text
# Default owner for everything in the repo
*                       @csarsantos96

# Only this user can be requested for workflow changes
/.github/workflows/     @csarsantos96

# A team owns everything under /docs
/docs/                  @my-org/docs-team
```

1. Patterns follow the same syntax as `.gitignore` and are matched top-to-bottom, with the **last matching pattern** taking precedence.

Why it matters together with branch protection:

- Combine it with **"Require a pull request before merging"** and **"Require approvals"**, then enable **"Require review from Code Owners"** on the protected branch. This forces every PR touching an owned path to get sign-off from the right person or team before it can be merged.
- Keeps review responsibility explicit and discoverable — anyone can open `CODEOWNERS` and see who to ping for a given part of the codebase, instead of relying on tribal knowledge.

## Course

[LinuxTips — Criando Pipelines e Automações com Github Actions](https://linuxtips.io)

[[LinuxTips — Creating Pipelines and Automations with GitHub Actions](https://linuxtips.io)
]
