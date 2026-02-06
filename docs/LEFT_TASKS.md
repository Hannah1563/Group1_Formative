# Group 1 — Remaining Tasks (Full 30/30 Target)

> **Due:** Sun Feb 13, 2026 at 11:59 PM | **Repo:** Hannah1563/Group1_Formative

---

## Done So Far

| What | Who | Status |
|---|---|---|
| Assignments screen (full CRUD, filters, priority, ALU colors) | Promesse | Done |
| App colors, nav skeleton, main.dart | Gentil | Done |

**Dashboard and Schedule screens are empty. Hugues has no commits yet.**

---

## Task Assignments

### Gentil — Nav Refactor + Local Storage + Code Quality

**Branch:** `christian-nav-storage`

1. [ ] Move models (`Assignment`, `Priority`, `AssignmentType`) to `lib/models/assignment.dart`
2. [ ] Create `lib/models/session.dart` (id, title, date, startTime, endTime, location, sessionType, attendanceStatus)
3. [ ] Refactor `main.dart`: use `IndexedStack` + shared `BottomNavigationBar` (replace current `pushNamed` routing)
4. [ ] Hold assignment + session lists at top-level state so Dashboard can read them
5. [ ] App opens on Dashboard tab by default
6. [ ] Implement local storage with `shared_preferences` — save/load assignments + sessions on app start and on every change
7. [ ] Ensure folder structure: `lib/models/`, `lib/screens/`, `lib/widgets/`, `lib/constants/`
8. [ ] Extract reusable widgets (e.g. shared bottom nav) into `lib/widgets/`
9. [ ] Consistent ALU branding, input validation, no pixel overflow
10. [ ] Add comments to your code
11. [ ] Update `README.md` (purpose, folder structure, how to run)

---

### Hannah — Dashboard Screen

**Branch:** `hannah-dashboard`

1. [ ] Build `lib/screens/dashboard_screen.dart` showing:
   - Today's date + current academic week
   - Today's scheduled sessions (from session list)
   - Assignments due within next 7 days
   - Attendance percentage (sessions marked Present / total recorded)
   - Red warning banner when attendance < 75%
   - Count of pending (incomplete) assignments
2. [ ] Add comments to your code
3. [ ] Fill in the group contribution tracker (make a copy of the template from the assignment page) and include link in PDF

---

### Hugues — Schedule Screen + Attendance

**Branch:** `hugues-schedule`

1. [ ] Build `lib/screens/schedule_screen.dart` with:
   - **Create** session: title (required), date picker, start/end time pickers, location (optional), session type dropdown (Class / Mastery Session / Study Group / PSL Meeting)
   - **View** weekly schedule of all sessions
   - **Edit** session details
   - **Delete** session with confirmation
   - **Attendance toggle** per session (Present / Absent)
2. [ ] Attendance % auto-calculated from session records (used by Dashboard)
3. [ ] Add comments to your code

---

### Promesse — Assignments (DONE) + Demo Video

**Branch:** `promesse-assignments` (already merged)

1. [x] Assignments screen — complete
2. [ ] Record the demo video (tutorial-style, NOT just a screen recording):
   - For each feature: show empty state, point to code, explain line by line with Flutter terms, then demo the result
   - Cover: navigation, assignments CRUD, schedule, attendance, dashboard, UI choices, local storage
   - **Must run on emulator or physical device** (browser-only = not graded)

---

### Everyone

- [ ] **Git:** Each person must have meaningful commits on their own branch. Push regularly.
- [ ] **PDF write-up** — each member writes a short paragraph on what they struggled with and how they solved it
- [ ] **PDF includes:** GitHub repo link, demo video link, contribution tracker link
- [ ] **File name:** `Group1_Formative_Assignment1.pdf`

---

## Rubric (30 pts)

| Criterion | Pts | Owner |
|---|---|---|
| Code Quality & Documentation | 7 | Gentil + Everyone |
| Video Demo Walkthrough | 5 | Promesse |
| Core Features (assignments, schedule, attendance) | 5 | Promesse + Hugues |
| Navigation & Screen Structure | 4 | Gentil |
| UI/UX Design | 4 | Gentil + Everyone |
| Local Storage | 5 | Gentil |

---

## Reminders

- **Must run on emulator or physical device** — browser-only = 0 marks
- **AI policy:** >50% AI-generated = penalty. You must explain every line in the video.
- **Deadline:** Sun Feb 13, 2026 at 11:59 PM
