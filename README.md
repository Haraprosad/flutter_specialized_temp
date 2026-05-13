# Claude Code Setup — Read Me First

This bundle gives your Flutter project an opinionated, disciplined Claude Code workflow tuned for the `flutter_specialized_temp` template.

## What's in here

```
.
├── CLAUDE.md                       # Project memory — loads on every conversation
├── WORKFLOW.md                     # Step-by-step usage guide (read this second)
├── README.md                       # This file
└── .claude/
    ├── agents/                     # Specialist personas (invoke with @name)
    │   ├── design-system-architect.md
    │   ├── mock-backend-builder.md
    │   ├── feature-developer.md
    │   └── ui-polish-specialist.md
    └── skills/                     # Auto-triggering rule sets
        ├── flutter-template-core/SKILL.md
        ├── design-system-setup/SKILL.md
        ├── json-server-mocking/SKILL.md
        ├── tdd-workflow/SKILL.md
        └── ui-polish-performance/SKILL.md
```

## Where to put these files

Copy this entire bundle's contents into the **root of your Flutter project**:

```
<your-flutter-project>/
├── CLAUDE.md                       ← here
├── WORKFLOW.md                     ← here
├── .claude/                        ← here
├── lib/
├── pubspec.yaml
└── ...
```

After copying, you can delete this README. The other files stay where they are.

## The mental model (one paragraph)

**`CLAUDE.md`** is the always-loaded project rulebook. **Skills** under `.claude/skills/` auto-activate based on what you're working on (talking about models, BLoCs, tests, etc. triggers the right skill). **Agents** under `.claude/agents/` are specialists you summon by name (`@design-system-architect`, `@feature-developer`) for major phases of work. **`WORKFLOW.md`** is your runbook — read it once, then refer back to it when starting a new feature.

## Why this is split up

Your original SKILL.md was excellent but tried to do everything in one file. Claude loads the entire SKILL.md every time it activates — putting design system rules, TDD rules, polish rules, and core architecture into one file means Claude wastes context on irrelevant rules every turn. Splitting by concern means only the relevant rules load. The trade-off is more files, but each is tightly focused and easier to maintain.

## What to do next

1. Copy these files into your project root.
2. Read `CLAUDE.md` once — confirm the 12 non-negotiables match your intent. Adjust if needed.
3. Read `WORKFLOW.md` once — understand the phase flow.
4. Start Phase 0 (template setup from the template's `docs/01_GETTING_STARTED.md`).
5. Invoke `@design-system-architect` to do Phase 1.
6. Loop: spec a feature → `@mock-backend-builder` → `@feature-developer` → `@ui-polish-specialist`.

## Customizing

These files are meant to be edited:

- **CLAUDE.md** — add project-specific rules, conventions, links.
- **Skills** — refine over time as you discover new patterns or pitfalls.
- **Agents** — extend or split if a single agent gets too broad.

When you change a rule, change it in the **one place** it lives. Don't duplicate rules across files — that's how they drift out of sync.

## Tested with

This setup assumes:
- Claude Code (CLI) or the Claude Desktop app with the project mounted
- Flutter 3.x / Dart 3.x
- The `flutter_specialized_temp` template structure

If you're on a different template, the architectural rules in `CLAUDE.md` and `flutter-template-core/SKILL.md` will need adapting.
