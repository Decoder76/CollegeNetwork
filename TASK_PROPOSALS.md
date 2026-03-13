# Task Proposals from Codebase Review

## 1) Typo fix task
**Issue found:** The PWA metadata uses `"CollegeNetwork"` (no space), while the HTML layout title uses `"College Network"` (with a space). This inconsistency reads like a product-name typo and can show up in install banners and homescreen labels.

**Proposed task:** Normalize branding text in PWA files and layout title so the app name is consistently `College Network` everywhere.

**Suggested acceptance criteria:**
- `app/views/pwa/manifest.json.erb` uses `"College Network"` for `name` (and optionally add a matching `short_name`).
- Any other user-facing app name references are consistent with the chosen canonical string.

## 2) Bug fix task
**Issue found:** `users.yml` fixtures are empty (`one: {}` / `two: {}`), but `posts.yml` and `profiles.yml` reference `user: one` / `user: two` and DB schema requires non-null user references. This can break fixture loading or make tests brittle/invalid.

**Proposed task:** Create valid `users` fixtures that include required columns (at least `email`, `encrypted_password`, and `name`) and ensure associated fixtures remain valid.

**Suggested acceptance criteria:**
- `test/fixtures/users.yml` contains realistic, valid user rows.
- Rails test suite loads fixtures without relation/validation errors.

## 3) Comment/documentation discrepancy task
**Issue found:** `README.md` is still the default Rails template and does not document this project’s actual setup, authentication model, or domain entities.

**Proposed task:** Replace placeholder README content with project-specific documentation (setup, env vars, DB setup, running tests, and feature overview).

**Suggested acceptance criteria:**
- README includes concrete local setup steps (`bundle install`, DB setup, run server, run tests).
- README describes core models (`User`, `Profile`, `Post`, `Message`) and authentication via Devise.

## 4) Test improvement task
**Issue found:** Scaffold-style controller tests mostly assert redirects/success statuses and do not verify meaningful behavior (e.g., changed attributes, expected notices, or failure paths).

**Proposed task:** Strengthen controller tests to assert state changes and key response content, and add at least one negative-path test per controller.

**Suggested acceptance criteria:**
- Update tests to assert record attributes actually change after `PATCH`.
- Add tests for invalid params path (`unprocessable_entity`) once model validations are in place.
- Ensure tests are deterministic and not solely scaffold smoke checks.
