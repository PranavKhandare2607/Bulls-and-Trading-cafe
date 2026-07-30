# Contributing to Bull's & Trading Cafe

Thank you for your interest in contributing! This is an open source café management system.

## How to Contribute

### Reporting Bugs
Open a GitHub Issue with:
- What you did
- What you expected to happen
- What actually happened
- Browser + device you were using

### Suggesting Features
Open a GitHub Issue tagged `enhancement` with a clear description of the feature and why it would be useful.

### Submitting Code
1. Fork the repository
2. Create a branch: `git checkout -b feature/your-feature-name`
3. Make your changes
4. Test in a browser (Chrome, Firefox, Safari, mobile)
5. Submit a Pull Request with a clear description

## Project Guidelines

- **No build step** — this is intentionally a single-file project. Keep it that way.
- **No external JS frameworks** — vanilla JS only for the management system.
- **Supabase only** — all backend logic goes through Supabase (no additional servers).
- **Mobile first** — all UI changes must work on mobile screens (375px+).
- **Don't break existing auth** — any changes to login/signup must be tested end-to-end.

## File Responsibilities

| File | What it does | Who should edit |
|---|---|---|
| `bulls-trading-cafe.html` | Public café website | Anyone |
| `bulls-cafe-management.html` | Full management system | Careful — large file |
| `supabase-schema.sql` | Database schema | DBA / backend devs |
| `rls-policies.sql` | Security policies | DBA / backend devs |

## Questions?

Open a GitHub Discussion or reach out via the repository.
