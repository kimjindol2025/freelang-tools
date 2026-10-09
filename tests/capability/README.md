# Phase 0 capability fixture

Pinned runtime:

```text
dialect: FreeLang v11 canonical
runtime: /root/freelang-surface-v0-clean-ek3qo2/v11/bootstrap.js
commit: e73c58378a1bb1afb776b7abc4b43eb859006530
```

`runtime-capability.fl` proves the currently observed `load`, function call, and
`try/catch`/`throw` behavior. The fixture reports `CAP_EFFECT_TAPE=BLOCKED`
because the pinned runtime's user-facing FreeLang API does not expose a native
`trace_effects`/Effect Tape operation. Internal runtime effect enforcement is not
treated as a user-level Tape capability.
