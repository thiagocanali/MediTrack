# GitHub CI and merge policy

## Current state (audit)
- Default branch: `flutcode` (legacy; not renamed).
- Squash merge enabled. Auto-merge disabled. No repository settings changed.
- Workflows: `flutter.yml`, `firestore-rules.yml`, `postgres-schema.yml`; each currently has path filters.
- Branch protection/ruleset requirements were not available through the connected actions. Do not assume they are absent.
- No open PR was found before this CI batch.

## Change set
- `AGENTS.md` defines batches, reuse of PRs, CI gates and high-risk review.
- All three workflows have read-only token permissions and concurrency cancellation.
- Firestore tests use Node 22; PostgreSQL Node tests explicitly use Node 22.
- `pr-policy.yml` runs for every PR and checks title/body metadata.
- No deployment or production secrets involved.

## Protection review before enabling auto-merge
1. Inspect actual branch protection and repository rulesets in GitHub settings.
2. Confirm whether PR reviews and status checks are required; do not remove them.
3. Prefer an always-running aggregate check if requiring checks on PRs that do not touch Flutter, backend or Firestore; path-filtered jobs may remain pending.
4. Verify first successful PR workflow and permissions before changing repository merge settings.
5. If approved later, enable auto-merge only for non-sensitive complete PRs with passing required checks and required approvals.
6. Avoid triggering Vercel previews for intermediate pushes; no Vercel configuration changed here.

## Validation
- Pending GitHub Actions on this PR. Do not merge before required checks and reviews pass.
