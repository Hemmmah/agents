#!/usr/bin/env bash
# Idempotent Cloud Agent bootstrap for the lev-os/agents skills workspace.
#
# Prepares everything needed to run the `lev-skills` CLI (skill discovery,
# inventory, validation), the Convex skills-manifest Node tooling, the Python
# test suite, and the pre-commit security hooks (gitleaks + hardcoded-paths).
#
# Safe to run repeatedly: submodule sync, pinned installs, and cache rebuild
# all converge to the same state.
set -euo pipefail

REPO_ROOT="$(git rev-parse --show-toplevel)"
cd "$REPO_ROOT"

# 1. Populate the skill-catalog submodules (external skill repos + Convex
#    skills). The CLI's discover/inventory scan these paths.
git submodule update --init --recursive

# 2. Python tooling. PyYAML backs YAML frontmatter parsing in the CLI;
#    pre-commit drives the repo's secret/path security hooks. Installed to the
#    user site so no root is required; ~/.local/bin is already on PATH via
#    ~/.profile.
python3 -m pip install --user --quiet --upgrade pyyaml pre-commit

# 3. Convex skills-manifest project (prettier formatting + tsx test runner).
npm --prefix convex ci

# 4. Warm the generated (gitignored) skill caches so `lev-skills discover`,
#    `inventory`, and `pick` are ready immediately.
python3 lev-skills.sh inventory --rebuild >/dev/null

echo "Cloud Agent environment ready."
