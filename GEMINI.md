# Governance & Engineering Standards — AutomationExercise JMeter API Suite

This document codifies non-negotiable QA Architecture, Performance Engineering, and Code Review rules for `automationexercise-jmeter-api`.

## 1. Live-Site Safety & Load Control
- **No Unthrottled Load**: Never flood `https://automationexercise.com` with aggressive concurrency or zero-think-time loops.
- **Controlled Concurrency**: Keep CI/smoke thread counts conservative (2–5 threads per Thread Group, explicit `ramp_time`, and `ConstantTimer` / pacing between samplers).
- **Dynamic Account Hygiene**: Every user account created via `POST /api/createAccount` MUST:
  1. Use a unique per-thread, per-iteration email generated once per iteration (e.g., `qa_${__threadNum}_${__time()}@example.com` stored in a thread variable via `UserParameters`).
  2. Be deleted in the same iteration via `DELETE /api/deleteAccount` so zero orphaned test accounts accumulate on the target system.

## 2. HTTP Transport vs. JSON `responseCode` Assertion Rules
- AutomationExercise APIs consistently return **HTTP 200** at the transport layer even for negative/error responses (400, 404, 405) and return `Content-Type: text/html; charset=utf-8` with a JSON body.
- **Never rely solely on HTTP status codes** or assert `Content-Type: application/json`.
- Every HTTP sampler MUST attach:
  1. A `ResponseAssertion` validating the exact JSON `"responseCode"` value (e.g., `"responseCode": 200`, `"responseCode": 201`, `"responseCode": 400`, `"responseCode": 404`, `"responseCode": 405`).
  2. A `ResponseAssertion` validating expected payload keys or exact `"message"` strings (e.g., `"products"`, `"brands"`, `"user"`, `"User created!"`, `"Account deleted!"`, `"This request method is not supported."`).
  3. A `DurationAssertion` enforcing the endpoint latency SLA (default `8000` ms, tuned for external public host tail latency).

## 3. Apache JMeter 5.6.3 XML Hygiene
- All `.jmx` files MUST be valid Apache JMeter 5.6.3 XML (`jmeter="5.6.3"`) with strictly balanced `<hashTree>` pairs after every test element.
- **No GUI-Only Listeners in CI Plans**: Never include `View Results Tree`, `Summary Report`, `Graph Results`, or `Aggregate Report` listeners in CI `.jmx` plans. Generate reports via non-GUI flags (`-l results.jtl -e -o report-html`).
- **Externalized Test Data**: Keep reusable input datasets (such as product search queries) in CSV files under `data/` using relative paths (`data/search_terms.csv`) so execution works identically across developer workstations and Jenkins agents.
- **PUT & DELETE Form Bodies**: Because AutomationExercise expects `application/x-www-form-urlencoded` request bodies for `PUT /api/updateAccount` and `DELETE /api/deleteAccount`, configure those samplers with `HTTPSampler.postBodyRaw=true` and an explicit `Content-Type: application/x-www-form-urlencoded` `HeaderManager`.

## 4. Traceability Rules (`API-REQ` -> `API-TC` -> JMeter)
- Every functional and non-functional requirement MUST have a unique atomic ID (`API-REQ-<MOD>-XX`) in `docs/prd/<module>.md` with Given/When/Then acceptance criteria.
- Every requirement MUST map 1:1 (or 1:N) to ISTQB-compliant test cases (`API-TC-<MOD>-XX`) in `docs/test-cases/<module>.md`.
- `docs/TRACEABILITY.md` MUST maintain 100% forward and backward mapping across all 14 APIs:
  `API #` -> `API-REQ-<MOD>-XX` -> `API-TC-<MOD>-XX` -> JMeter Thread Group, Sampler, and Assertions.

## 5. Security & Secret Hygiene
- Never commit API tokens, personal credentials, Jenkins tokens, or hardcoded production passwords.
- Dynamic test accounts created during execution must use synthetic disposable passwords and immediately self-delete.
