# Push to GitHub

The repo is ready locally. To create and push to **github.com/Starkag/shakti-workspace**:

## Option 1: GitHub Web + Git Push

1. **Create the repo on GitHub**:
   - Go to https://github.com/new
   - Owner: **Starkag**
   - Repository name: **shakti-workspace**
   - Description: `Shakti RISC-V workspace for Mac M4 / Apple Silicon (ACAD labs)`
   - Public
   - Do **not** initialize with README (we already have one)

2. **Push** (remote is already set):

   ```bash
   cd /home/stark/shakti_workspace
   git push -u origin main
   ```

   Use your GitHub credentials when prompted (or set up SSH keys / token).

## Option 2: GitHub CLI

1. **Log in** (one-time, interactive):

   ```bash
   gh auth login
   ```

   Follow prompts (browser or token).

2. **Create repo and push**:

   ```bash
   cd /home/stark/shakti_workspace
   gh repo create Starkag/shakti-workspace --public --source=. --remote=origin --push
   ```

---

After pushing, students can clone with:

```bash
git clone https://github.com/Starkag/shakti-workspace.git
```
