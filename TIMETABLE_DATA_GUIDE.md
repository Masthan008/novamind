# Timetable Data Configuration Guide

## Period Timings Structure

Your timetables use a **5-period format**:

| Period | Time Slot | Description |
|--------|-----------|-------------|
| **P1** | 9:00 AM - 10:40 AM | Morning Session (100 mins) |
| **P2** | 11:00 AM - 11:50 AM | Late Morning (50 mins) |
| **P3** | 1:00 PM - 1:50 PM | After Lunch (50 mins) |
| **P4** | 1:50 PM - 2:40 PM | Mid Afternoon (50 mins) |
| **P5** | 3:00 PM - 5:00 PM | Lab Session (120 mins) |

### Break Times
- **Morning Break**: 10:40 AM - 11:00 AM
- **Lunch Break**: 11:50 AM - 1:00 PM
- **Tea Break**: 2:40 PM - 3:00 PM

---

## Data Format in `timetable_data.dart`

Each section has 6 days, and each day has 5 periods:

```dart
'ECE_A': {
  // [P1, P2, P3, P4, P5]
  'Monday': ['CHE', 'CE', 'DEVC', 'Free', 'NWA LAB'],
  'Tuesday': ['CHE LAB', 'CHE LAB', 'BME', 'Free', 'CE'],
  // ...
},
```

### Rules:
1. **Lab Sessions** that span 2 periods (like `CHE LAB` from 9:00-11:50):
   - Enter the lab name in BOTH P1 and P2 slots
   - Example: `['CHE LAB', 'CHE LAB', ...]`

2. **Empty Periods** (no class scheduled):
   - Use `'Free'` as the value
   - Period 4 (1:50-2:40) is often free

3. **Combined Subjects**:
   - For merged classes, use `'SUBJECT1+SUBJECT2'`
   - Example: `'DEVC+BME'`

---

## How to Read the Timetable Images

Look at the image header columns:
```
DAY | 9.00-10.40 | 11.00-11.50 | 1.00-1.50 | 1.50-2.40 | 3.00-5.00 (S.H)
      P1           P2            P3          P4          P5
```

When a cell spans multiple columns:
- Labs from 9:00-11:50 span P1+P2 → Enter the subject twice
- If the cell spans P1+P2, that's a morning lab session

---

## Section Mapping

| Branch | Sections | File Key Pattern |
|--------|----------|------------------|
| ECE | A, B, C, D | `ECE_A`, `ECE_B`, etc. |
| EEE | A, B | `EEE_A`, `EEE_B` |
| ME | A, B | `ME_A`, `ME_B` |
| CIVIL | A | `CIVIL_A` |
| CSE (AI&ML) | A, B, C, D | `CSE-AIML_A`, etc. |
| CSE (Core) | A, B, C, D, E, F | `CSE_A`, `CSE_B`, etc. |
| CSE (DS) | A, B, C, D | `CSE-DS_A`, etc. |
| CSE (CS) | A, B | `CSE-CS_A`, `CSE-CS_B` |

---

## Screenshot to Data Mapping

Your screenshots are in `timetable/` folder:

| Screenshot Name | Section |
|-----------------|---------|
| Screenshot 2026-02-05 205346.png | ECE - A |
| Screenshot 2026-02-05 205354.png | ECE - B |
| Screenshot 2026-02-05 205402.png | ECE - C |
| Screenshot 2026-02-05 205410.png | ECE - D |
| Screenshot 2026-02-05 205419.png | EEE - A |
| Screenshot 2026-02-05 205425.png | EEE - B |
| Screenshot 2026-02-05 205435.png | ME - A |
| Screenshot 2026-02-05 205442.png | ME - B |
| Screenshot 2026-02-05 205449.png | CIVIL - A |
| Screenshot 2026-02-05 205456.png | CSE-AIML - A |
| Screenshot 2026-02-05 205507.png | CSE-AIML - D |
| ... | etc. |

---

## Quick Fix Checklist

When you find incorrect data:

1. **Open the timetable image**
2. **Find the corresponding key** in `timetable_data.dart`
3. **Update each day's array** with exactly 5 values:
   ```dart
   'Day': ['P1_Subject', 'P2_Subject', 'P3_Subject', 'P4_Subject', 'P5_Subject'],
   ```
4. **Use 'Free' for empty periods**
5. **Save and hot reload the app**

---

## Verified Sections ✅

- [x] ECE_A (Fixed Feb 7, 2026)
- [ ] ECE_B
- [ ] ECE_C
- [ ] ECE_D
- [ ] EEE_A
- [ ] EEE_B
- [ ] ME_A
- [ ] ME_B
- [ ] CIVIL_A
- [ ] CSE-AIML_A
- [ ] CSE-AIML_B
- [ ] CSE-AIML_C
- [x] CSE-AIML_D (Verified)
- [ ] CSE_A
- [ ] CSE_B
- [ ] CSE_C
- [ ] CSE_D
- [ ] CSE_E
- [ ] CSE_F
- [ ] CSE-DS_A
- [ ] CSE-DS_B
- [ ] CSE-DS_C
- [ ] CSE-CS_A
- [ ] CSE-CS_B

Mark each section with [x] after verifying it matches the image!
