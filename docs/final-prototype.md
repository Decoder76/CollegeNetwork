# CollegeNetwork — Final Prototype Blueprint (2026)

This document turns the current repository into a **final prototype specification** aligned with current market patterns and the likely 5-year direction for student networking products.

## 1) Product Direction (Industry + 5-Year Trend)

### Why this version is future-ready
1. **Verified trust graph**: identity, campus affiliation, and role verification are first-class.
2. **Career + community convergence**: students increasingly expect one app for peer networking, project discovery, and internship pathways.
3. **AI-assisted matching**: explainable and controllable recommendations are baseline in modern social apps.
4. **Privacy and safety by default**: granular audience controls, moderation workflows, and auditability are required expectations.
5. **Portable profile data**: users should keep ownership and exportability of their profile/project footprint.

### Product thesis
CollegeNetwork should be a **professional-first student network** where learners:
- build credible profiles,
- discover peers and teams,
- collaborate on opportunities,
- and convert social activity into career outcomes.

## 2) Final Prototype Scope

### Core user roles
- **Student** (default)
- **Mentor/Alumni**
- **Recruiter/Partner**
- **Moderator/Admin**

### Core experiences
1. **Onboarding + verification**
   - Email/SSO login
   - Campus domain check + optional document verification
   - Academic/career intent capture

2. **Profile + portfolio**
   - Structured skills, projects, achievements
   - Privacy controls per section
   - Public profile slug

3. **Network graph + discovery**
   - Follow/connect models
   - Intent-based search ("cofounder", "hackathon", "study group")
   - Recommendation feed with transparent reason tags

4. **Communities and groups**
   - Campus groups, interest clubs, project teams
   - Membership roles, approvals, group moderation

5. **Opportunity marketplace**
   - Internships, campus jobs, collaborative projects, events
   - Saved opportunities + application tracking

6. **Messaging + collaboration**
   - 1:1 and group conversations
   - Link preview, attachments metadata

7. **Safety + trust**
   - Reporting, block, mute
   - Content status lifecycle + moderation notes
   - Immutable audit logs

8. **Analytics + success metrics**
   - Activation funnel
   - Week-4 retention
   - Connection quality and opportunity conversion

## 3) Current Application State (Target Prototype Baseline)

### Functional baseline
- Product requirements: defined in this doc
- Data model: provided in `database/schema.sql`
- Deployment target: PostgreSQL + API service + web/mobile clients
- Next implementation step: scaffold service layer against this schema

### Non-functional baseline
- Multi-tenant safe by design (institution-scoped access patterns)
- Time-series friendly event logging
- Strong referential integrity
- Soft-delete strategy where user trust/safety requires history

## 4) Data Model Summary

The initial schema supports:
- identity and verification,
- institutions and memberships,
- profiles/skills/projects,
- social graph,
- groups and posts,
- opportunities and applications,
- messaging,
- moderation and audit events,
- notifications.

Refer to: `database/schema.sql` for the canonical model.

## 5) Suggested API Surface (v1)

### Auth + identity
- `POST /v1/auth/register`
- `POST /v1/auth/login`
- `POST /v1/auth/verify-campus`
- `GET /v1/users/me`

### Profiles
- `GET /v1/profiles/{userId}`
- `PATCH /v1/profiles/{userId}`
- `POST /v1/profiles/{userId}/skills`
- `POST /v1/profiles/{userId}/projects`

### Network
- `POST /v1/connections/request`
- `POST /v1/connections/{id}/accept`
- `GET /v1/discovery/recommendations`

### Groups + content
- `POST /v1/groups`
- `POST /v1/groups/{groupId}/join`
- `POST /v1/posts`
- `POST /v1/posts/{postId}/report`

### Opportunities
- `POST /v1/opportunities`
- `GET /v1/opportunities`
- `POST /v1/opportunities/{id}/apply`

### Messaging
- `POST /v1/conversations`
- `POST /v1/messages`
- `GET /v1/conversations/{id}/messages`

## 6) Recommended Stack (Prototype-to-Scale)

- **Frontend**: Next.js + TypeScript (web), React Native (mobile)
- **Backend**: Node.js (NestJS/Fastify) or Go for service APIs
- **DB**: PostgreSQL
- **Cache/Queue**: Redis + background workers
- **Search**: Postgres FTS initially, OpenSearch/Meilisearch later
- **Storage**: S3-compatible object storage for media/docs
- **Observability**: OpenTelemetry + centralized logs

## 7) Roadmap (Practical 3-Phase)

### Phase 1 (0–8 weeks)
- Auth, verification, profiles, connections
- Basic groups, posts, and messaging
- Opportunity listing and apply flow

### Phase 2 (2–4 months)
- Recommendation ranking v1
- Moderation console and trust score signals
- Notification personalization and digesting

### Phase 3 (4–9 months)
- Institution admin dashboards
- AI profile coach + explainable matching
- Credential integrations and portfolio export

## 8) KPIs for "Final Prototype" sign-off

- Onboarding completion rate >= 70%
- Week-4 retention >= 30%
- 14-day connection acceptance >= 35%
- Opportunity apply-through >= 12%
- Median moderation response time < 24 hours

## 9) Open Questions

- Which identity providers are required for launch institutions?
- Should recruiter capabilities be launch-day or phase-2?
- Do we prioritize campus-only graph first or mixed global discovery from day 1?

