# Intern AI Adoption Board (v1)

A private ZURU Deploy page that answers: **"How is the intern cohort getting on with AI this week, and what's one thing to try next?"**
Built for the 45 NZ summer interns (started 16 Nov 2026), then their managers and AI Champions, then Callum.

## What each number means

| Number | Definition | Source |
|---|---|---|
| Interns using skills | Interns with at least one SkillHub skill activation since the cohort started | Q1 |
| Ran the quickstart | Interns who activated `zuru-ai-quickstart` | Q1 |
| Used 2+ different skills | Interns with 2+ distinct skills (the skills step on the tier ladder) | Q1 |
| Active this week | Interns with any skill activation in the last 7 UTC days, vs the 7 days before | Q1 |
| Milestones | The same counts as a share of the cohort, plus "2+ days" and "5+ skills" | Q1 |
| Daily activity | Distinct interns with a skill activation, per UTC day since 16 Nov | Q1 |
| Popular with interns | Skills ranked by how many interns used them (counts only, no names) | Q1 + Q2 (prompts) |
| My next step | The viewer's own steps, found by hashing their sign-in email in the browser | Q1 + `window.zuru.me()` |

## Data and design choices

- **Cohort**: `people.people.employees` where `is_intern`, location country `NZL`, `hire_date = 2026-11-16`.
- **Activity**: `ai_integration.skillhub.skill_activation_events` (real-time; anyone who can see a skill can see who used it), joined to the cohort in SQL.
- **Matching**: 42 of 45 interns have no email in the people data yet, so the page derives `firstname.lastname@zuru.com`. Interns with another address show as "not seen yet", not "didn't do it".
- **Privacy**: no names or emails reach the browser. Each intern is a SHA-256 key of the derived email; the viewer's own key is computed client-side. The page shows cohort totals, never a ranking.
- **Performance**: two governed queries per load, run in parallel, aggregated in SQL (Q1 joins the cohort *inside* the activation aggregate so only intern rows are grouped; ~70 rows returned). Auto-refresh every 10 minutes while the tab is visible.
- **Not yet**: official tier ladder (`person_tier_daily`) — waiting on access and on the cohort appearing in the tier data.

## Files

- `index.html` — the page (kit blocks marked `data-zuru-kit="v1"`; Deploy swaps them for the hosted kit)
- `queries.sql` — every query the page runs, tested with `run_query`
- `sample-data.json` — **fake** data for offline preview (`python3 -m http.server 8000`)
- `CLAUDE.md` — rules for the agent working in this folder
