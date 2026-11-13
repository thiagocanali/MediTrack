# Firestore security foundation (not deployed)

## Current state
The legacy Flutter app reads and writes the global collection `/medications` and does not attach an owner UID. This is **not** compatible with the new owner-scoped rules.

**Do not deploy `firestore.rules` to a Firebase project used by the legacy app before migrating the client and validating all reads/writes in the Emulator Suite.** Deploying early would deny legacy access. No Firebase deployment was performed by this PR.

## Proposed layout
```
users/{uid}
users/{uid}/medications/{medicationId}
users/{uid}/medications/{medicationId}/doseLogs/{occurrenceId}
```

- User documents: self get/create/update/delete; no global listing.
- Medications: owner-only CRUD, minimal name/active/stock validation.
- Dose logs: read-only to owner for now; writes denied pending occurrence/transition design.
- Other collections, including legacy top-level `medications`, denied by default.

## Required before production
1. Identify actual Firebase project and deployed rules; export backups with restricted access.
2. Test anonymous, owner and non-owner access, including collection group queries, nested paths and malformed payloads.
3. Enforce field types, timestamp semantics, schedule structure, stock bounds and immutable ownership via rules and backend where appropriate.
4. Implement transactional/idempotent dose confirmation; never trust client clocks as authoritative for audit.
5. Define delete/export account data workflow and retention policy.
6. Check query indexes and rules with Emulator Suite; enable App Check with monitored rollout.
7. Verify local notifications on Android/iOS, time zones and daylight saving transitions.

## Suggested emulator commands (after configuring Firebase CLI)
```bash
firebase emulators:start --only firestore,auth
```

This rules file is a security baseline, **not proof of compliance or production readiness**.
