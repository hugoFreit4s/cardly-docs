# Card review rules (specification)

## 1. General

- Each card has a **level** (`none`, `easy`, `medium`, `hard`) and a **next review date** (or “due after” date).
- Once a card has a **due date**, the user **must not** answer it **before** that date. Answering **on** the due date or **any time after** is allowed. Cards **without** a due date yet (e.g. never opened) follow product rules for **new** cards and are not blocked by this rule until they are scheduled.
- The scheduling rules below apply **when** a valid answer is submitted.

## 2. New card (no level yet)

- **Wrong** → **Medium**, next interval **3 days**.
- **Right** → **Easy**, right-streak = **1**, next interval **5 days**.

A card **never** starts as **hard**. **Hard** only appears after **medium + wrong** (or later transitions).

## 3. Medium

- **Fixed delay:** the next review is scheduled **3 days** ahead (from when the answer is processed).
- **Medium is a short stop:** there is **no streak** at medium; the **next** answer always leaves medium.

Transitions:

- **Wrong** → **Hard**, wrong-streak = **1**, interval = **2 days**.
- **Right** → **Easy**, right-streak = **1**, interval = **5 days**.

## 4. Easy

### 4.1 Intervals by consecutive right answers (streak)

After each **right** answer while **easy**, the **right-streak** increases by **1** (must be **consecutive** rights). Intervals:

- Right-streak **1** → **5 days**
- Right-streak **2** → **7 days**
- Right-streak **3+** → **9 days** (maximum)

When you **enter easy from medium** with a right, that counts as **right-streak = 1** → **5 days**.

### 4.2 Wrong answers while easy (gradual demotion)

While **easy**, **wrong** answers are **gradual**; level stays **easy** until the last step:

- Current interval **9 days** + wrong → next interval **7 days** (still easy).
- Current interval **7 days** + wrong → next interval **5 days** (still easy).
- Current interval **5 days** + wrong → **Medium**, next interval **3 days**.

A **wrong** breaks the **right-streak** (consecutive rights reset for streak purposes).

## 5. Hard

### 5.1 Wrong answers while hard (gradual tightening)

- **Hard** at **2 days** + wrong → next interval **1 day** (still hard); wrong-streak increases (consecutive wrongs).
- **Hard** at **1 day** + wrong → stays **1 day** (still hard).

When you **enter hard from medium** with a wrong, that counts as **wrong-streak = 1** → **2 days** to the next review.

### 5.2 Right answers while hard (gradual recovery)

- **Hard** at **2 days** + right → **Medium**, next interval **3 days**.
- **Hard** at **1 day** + right → next interval **2 days** (still **hard**).
- **Hard** at **2 days** + right again → **Medium**, next interval **3 days**.

A **right** breaks the **wrong-streak** (consecutive wrongs reset).

## 6. Streaks

- **Right-streak** and **wrong-streak** count **only consecutive** answers of that type.
- **Wrong** resets **right-streak**; **right** resets **wrong-streak**.
- **Medium** does not maintain its own streak; streak counters matter again once the card is **easy** or **hard**.

## 7. Summary transitions

- **None** + right → **Easy**, streak 1, **5 days**.
- **None** + wrong → **Medium**, **3 days**.
- **Medium** + right → **Easy**, streak 1, **5 days**.
- **Medium** + wrong → **Hard**, wrong-streak 1, **2 days**.
- **Easy:** rights advance interval per §4.1; wrongs step down per §4.2; at **5 days** wrong → **medium**, **3 days**.
- **Hard:** wrongs per §5.1; rights per §5.2.

## 8. Due dates and lateness

The **3 / 5 / 7 / 9 / 2 / 1 days** values define the **next due date** after an answer. The user **cannot** answer **before** that date; answering **on** the due date or **later** is allowed. When they submit a valid answer, these rules update **level**, **streaks**, and **next interval** as above.
