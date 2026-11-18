-- Intern AI Adoption Board — every query the page runs. Tested with zuru-deploy run_query.
-- Design: 2 governed queries per page load (each governed query has a fixed RLS cost),
-- aggregated in SQL, slice client-side. No names or emails are sent to the browser:
-- each intern is a SHA-256 key of their derived work email, so the page can find "me"
-- by hashing the viewer's own email, but never shows anyone else's identity.

-- Q1 · activity: one row per (intern, UTC day, skill) since the cohort started,
--      plus one row per intern with no activity yet (day/skill NULL) so the cohort size is exact.
WITH cohort AS (
  SELECT
    e.employee_id,
    et.functional_team_id AS team,
    lower(replace(e.preferred_name, ' ', '') || '.' || replace(e.family_name, ' ', '')) || '@zuru.com' AS email
  FROM people.people.employees e
  JOIN people.people.locations l ON e.location_id = l.location_id
  LEFT JOIN people.people.employee_team et ON et.zuru_id = e.zuru_id
  WHERE e.is_intern = true
    AND l.country_code = 'NZL'
    AND e.hire_date = DATE '2026-11-16'
),
acts AS (
  -- Join to the cohort INSIDE the aggregate so only intern rows are grouped,
  -- not every activation in the org since the start date.
  SELECT c.email, a.day, a.skill_id, COUNT(*) AS n
  FROM ai_integration.skillhub.skill_activation_events a
  JOIN cohort c ON lower(a.actor_email) = c.email
  WHERE a.activated_at >= TIMESTAMP '2026-11-12 00:00:00'
  GROUP BY 1, 2, 3
)
SELECT
  encode(sha256(c.email), 'hex') AS k,
  c.team,
  CAST(x.day AS VARCHAR) AS d,
  s.name AS skill,
  x.n
FROM cohort c
LEFT JOIN acts x ON x.email = c.email
LEFT JOIN ai_integration.skillhub.skills_catalog s ON s.skill_id = x.skill_id
ORDER BY k, d;

-- Q2 · skills: catalog details (description + example prompt) for the starter set,
--      used by the "Try this" cards. Static list, so check_page can dry-run it.
SELECT name, description, example_prompt
FROM ai_integration.skillhub.skills_catalog
WHERE name IN ('zuru-ai-quickstart', 'ask-zuru', 'explain-zuru-role', 'get-meeting-transcript',
               'zuru-hr-knowledge-intl', 'ui-kit-documents', 'zuru-brand-guidelines', 'ask-about-ai-at-zuru')
  AND deleted_at IS NULL;
