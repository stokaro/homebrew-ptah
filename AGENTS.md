# AGENTS.md

This repository is the Homebrew tap for Ptah releases and the development
build. [README.md](README.md) describes installation and the relationship
between generated release definitions and the hand-written edge formula.

## PR and issue writing

- Write PR and issue titles in plain American English. Name the concrete
  problem or intended result using familiar words. Follow the repository's
  title convention, but do not make readers decode internal component
  names, unexplained acronyms, or abstract architecture terms to understand
  the purpose. Do not add tool signatures or generated-with footers.
- Start every PR with the template's `Summary`, before `Why`. In a short
  paragraph, usually two to four sentences, explain who or what is affected,
  what is wrong, missing, or unnecessarily difficult, and why it matters.
  Assume the reader knows what the project does but has not followed this
  work. Keep architecture and implementation details in later sections.
- Start every issue with the same kind of plain-English introduction,
  including issues created through a CLI or API. With an issue form, put
  this explanation in the first description field. Follow it with the
  evidence, reproduction steps, expected behavior, constraints, or proposal
  relevant to that issue.
- For maintenance, documentation, and internal changes, explain the
  concrete problem for contributors or maintainers. Do not invent an
  effect on end users, an incident, or a benefit that the evidence does
  not establish.
- Before publishing, read the title and opening without the rest of the
  description. They must explain the problem and why it matters without
  requiring the reader to inspect code, follow links, or reconstruct the
  investigation. Explain unfamiliar terms where they first appear.
- When updating a PR or issue, read its current title and description
  first. Keep the title and introduction accurate as the scope changes.

## Pull request descriptions

### Purpose and scope

- Read and follow `.github/pull_request_template.md`, including when
  creating or updating a PR through a CLI or API. Keep its headings and
  remove drafting comments and unused optional content.
- Establish intent from the request, issue, discussion, and supporting
  evidence. Do not invent user impact, urgency, performance gains, or
  security benefits. Ask for clarification when missing information
  materially changes the goal, scope, acceptable risk, or completion
  criteria.
- Use `Summary` for the plain-English problem and its consequence, `Why`
  for supporting evidence and reasoning, and `What changes` for delivered
  behavior and scope. Add information in each section instead of retelling
  the same explanation.
- For a bug fix, explain the established cause. Distinguish observations,
  conclusions drawn from code, and hypotheses.
- Describe meaningful limitations and non-obvious decisions. Include
  implementation details when they help assess correctness, risk, or use.
  Avoid file inventories, commit histories, and repeated summaries.
- Keep the essential explanation in the PR. Link issues that define its
  scope, required companion changes, and relevant remaining work.
  Use closing keywords only when the PR fully resolves an issue.

### Evidence and maintenance

- Report observed validation results and important coverage gaps.
  Explain what each significant check establishes. Do not present lint,
  compilation, skipped checks, or planned work as proof of behavior they
  do not verify.
- State the engines, versions, platforms, or component combinations
  actually exercised when they affect the claim. Provide manual steps
  only where they add useful verification.
- Before publishing, inspect the complete diff from the actual base
  branch to the current head.
- After substantive changes, revise the description for the complete
  current PR. Update behavior, scope, risks, dependencies, and validation
  claims; replace stale text instead of appending a development diary.
- Keep the description proportional to the change. Put essential results,
  material risks, and remaining uncertainty in the main text. Link or
  collapse lengthy supporting evidence.
- Follow all repository-specific testing, documentation, safety, and
  compatibility requirements alongside this description standard.

The shared wording of these sections and the PR template is maintained in
[`stokaro/ptah`](https://github.com/stokaro/ptah). Keep copies aligned across
Ptah repositories; put repository-specific additions in a separate section.

## Homebrew PR context

- State whether a package change affects the released build, the edge build,
  or both. Describe changes to installed binaries, dependencies, supported
  platforms, and switching between the two packages when relevant.
- Release-generated definitions are maintained in
  [Ptah's release configuration](https://github.com/stokaro/ptah/blob/master/.goreleaser.yaml).
  Change their source there and link the companion PR; a direct edit to a
  generated file here is overwritten by the next release. The edge formula
  is maintained here.
- For installation claims, record the package version or source commit,
  operating system, architecture, command, and observed result. Distinguish
  syntax and build-configuration checks from a completed Homebrew install
  or upgrade.
- The [edge formula workflow](.github/workflows/edge-formula.yml) defines the
  existing release-build consistency checks. Report their results when the
  change affects that relationship.
