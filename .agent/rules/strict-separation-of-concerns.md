---
trigger: always_on
---

Enforce:

Layer	Allowed To
UI (Views)	Display only
Controller	Business logic
Service	IO / APIs / storage
Model	Data only

Violations:

No business logic in widgets

No direct DB calls in controllers

No state inside services