---
name: navigation
description: Read before changing how the Navigator routes a proposal that comes from a modal session.
---

- Turbo proposes a redirect after a form submission as an advance. A form in a modal that redirects to the default context therefore pushes the redirected page on top of the page beneath the modal, and Back returns to that page even when the form deleted or moved what it showed.
- Nothing in the redirect says the page beneath the modal was acted on, so the Navigator must not guess. The modal's own path rule declares it with `replaces_presenting_page_on_redirect`, and only then is the proposal rewritten to a replace. Pushing stays right for forms that create something, such as a new message or a copy.
- The property is read from the modal session's active visitable, before the modal is dismissed. Do not use the session's topmost visitable: it is only set once a visit has completed, so it is empty while the form is still being submitted.
- The replace is routed like any other: the last page is replaced, or the stack pops when the target is the page before it. Do not add stack changes of your own.
- Never put the property on a rule whose page beneath the modal survives the form, such as a list; the page people expect on Back would be dropped.
