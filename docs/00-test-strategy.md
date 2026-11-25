# Risk-Based API Test & Performance Strategy — AutomationExercise (APIs 1–14)

## 1. Document Control
- **Target System**: AutomationExercise Public REST API (`https://automationexercise.com/api/*`)
- **API Specification Reference**: `https://automationexercise.com/api_list` (APIs 1–14)
- **Tooling**: Apache JMeter 5.6.3 (Non-GUI CLI execution), Windows PowerShell JTL SLA Gate, Jenkins CI/CD (`automationexercise-jmeter-api-ci`)
- **Methodology**: ISTQB Risk-Based Testing, Contract & Payload Verification, Controlled Concurrency Performance Testing

## 2. Scope

### In Scope
All 14 documented endpoints grouped into two functional domains:
1. **Catalog & Search APIs (APIs 1–6)**:
   - `GET /api/productsList` (API 1) and `POST /api/productsList` (API 2)
   - `GET /api/brandsList` (API 3) and `PUT /api/brandsList` (API 4)
   - `POST /api/searchProduct` with valid `search_product` (API 5) and missing parameter (API 6)
2. **Account & Authentication Lifecycle APIs (APIs 7–14)**:
   - `POST /api/createAccount` (API 11)
   - `POST /api/verifyLogin` — valid (API 7), missing email (API 8), invalid credentials (API 10)
   - `DELETE /api/verifyLogin` (API 9)
   - `GET /api/getUserDetailByEmail` (API 14)
   - `PUT /api/updateAccount` (API 13)
   - `DELETE /api/deleteAccount` (API 12)
3. **Non-Functional Verification**:
   - Per-request latency SLA enforcement (`DurationAssertion <= 8000 ms` + CI JTL verification gate)
   - Controlled concurrent thread safety and dynamic test data isolation/cleanup

### Out of Scope
- Destructive stress/soak/DDoS testing against the shared public `automationexercise.com` server
- Web UI / browser-level workflows (covered separately outside this API suite)
- Third-party payment gateways or undocumented internal endpoints

## 3. Empirical Protocol Findings (Live API Inspection)
Direct inspection of all 14 live endpoints revealed critical behavioral characteristics that shape test design:
1. **HTTP 200 Wrapper Pattern**: All endpoints—including `400`, `404`, `405`, and `201` business outcomes—return **HTTP 200** at the transport layer and embed the semantic status in JSON (`"responseCode": 200|201|400|404|405`). Relying on JMeter's default HTTP status check alone would yield false positives on every error scenario.
2. **Response Content-Type**: Responses return `Content-Type: text/html; charset=utf-8` despite containing valid JSON bodies. Assertions validate JSON response text rather than `application/json` headers.
3. **Form-Encoded Request Bodies for `PUT` and `DELETE`**: `PUT /api/updateAccount` and `DELETE /api/deleteAccount` require `application/x-www-form-urlencoded` request bodies. In JMeter 5.6.3, these samplers use `HTTPSampler.postBodyRaw=true` with explicit `Content-Type: application/x-www-form-urlencoded` headers to prevent parameters from being moved into URL query strings.
4. **Field Name Mapping on User Detail**: `createAccount`/`updateAccount` accept `birth_date`, `firstname`, and `lastname`, whereas `getUserDetailByEmail` returns `birth_day`, `first_name`, and `last_name` inside the `"user"` object.

## 4. Risk-Based Test Matrix

| Risk ID | Area / Endpoint | Failure Mode | Likelihood | Impact | Risk Level | Mitigation in Suite |
| :--- | :--- | :--- | :---: | :---: | :---: | :--- |
| RSK-01 | All APIs (1–14) | HTTP 200 masks JSON 400/404/405/500 errors | High | Critical | **Critical** | Explicit JSON `"responseCode"` + `"message"`/key `ResponseAssertion` on every sampler |
| RSK-02 | Account Lifecycle (APIs 11, 7, 14, 13, 12) | Email collision across concurrent threads or runs | High | High | **High** | Unique per-thread, per-iteration email (`qa_${__threadNum}_${__time()}@example.com`) evaluated once via `UserParameters` |
| RSK-03 | Account Cleanup (API 12) | Orphaned synthetic test users left on shared live site | Medium | High | **High** | Mandatory `DELETE /api/deleteAccount` step at end of every TG2 iteration with `"Account deleted!"` assertion |
| RSK-04 | `PUT` / `DELETE` Encoding (APIs 12, 13) | JMeter sends DELETE params in query string instead of body | High | High | **High** | `postBodyRaw=true` + URL-encoded body + `Content-Type: application/x-www-form-urlencoded` header |
| RSK-05 | Shared Public Host Rate Limiting | Excessive concurrency triggers throttling or latency spikes | Medium | High | **High** | Conservative load profile (3 + 2 threads), ramp-up (3 s / 4 s), 500 ms `ConstantTimer` pacing |
| RSK-06 | Search API (API 5) | Hardcoded search input misses query variance | Low | Medium | **Medium** | Externalized `data/search_terms.csv` (`top`, `tshirt`, `jean`, `dress`, `men`) with `CSVDataSet` |
| RSK-07 | Latency Degradation | Endpoint response exceeds acceptable threshold | Medium | Medium | **Medium** | `DurationAssertion` (8,000 ms) inside JMeter + PowerShell JTL verification gate in Jenkins |

## 5. Controlled Load & Concurrency Profile

To respect the public AutomationExercise server while still validating concurrent safety and performance SLAs:

| Parameter | TG1: Catalog & Search (APIs 1–6) | TG2: Account & Auth Lifecycle (APIs 7–14) |
| :--- | :---: | :---: |
| Virtual Users (`num_threads`) | `3` (`${__P(cat.threads,3)}`) | `2` (`${__P(acc.threads,2)}`) |
| Ramp-Up Period (`ramp_time`) | `3 s` (`${__P(cat.rampup,3)}`) | `4 s` (`${__P(acc.rampup,4)}`) |
| Loop Count (`loops`) | `1` (`${__P(cat.loops,1)}`) | `1` (`${__P(acc.loops,1)}`) |
| Inter-Request Pacing | `500 ms` `ConstantTimer` | `500 ms` `ConstantTimer` |
| Total Samples per Run | `3 × 6 = 18` | `2 × 8 = 16` |
| Combined Samples per CI Run | **34 samples** (14 distinct API endpoints) | |

## 6. SLA & Quality Gate Thresholds

| Metric | Target Threshold | Enforcement Mechanism |
| :--- | :--- | :--- |
| Functional / Assertion Pass Rate | **100%** (`0` failed samples) | JMeter `ResponseAssertion` + `scripts/verify-results.ps1` |
| Maximum Single-Sample Duration | **≤ 8,000 ms** | JMeter `DurationAssertion` + `scripts/verify-results.ps1` |
| Traceability Coverage | **100%** (All 14 APIs mapped) | `docs/TRACEABILITY.md` audit |
| Orphaned Account Count | **0** | Self-cleaning TG2 lifecycle (`createAccount` -> `deleteAccount`) |

## 7. Test Data Isolation & Hygiene
- **Catalog Search Inputs**: Stored in `data/search_terms.csv` (read-only, recycled across threads via `CSVDataSet`, `sharingMode=shareMode.all`).
- **Dynamic Account Data**: Each TG2 thread iteration synthesizes `testEmail = qa_${__threadNum}_${__time()}@example.com` and `testPassword = QaPerfPass123!` once via `UserParameters` (`per_iteration=true`). All stateful samplers (`createAccount`, `verifyLogin`, `getUserDetailByEmail`, `updateAccount`, `deleteAccount`) reference `${testEmail}` and `${testPassword}`.
- **Negative Auth Credentials**: `API 10` uses a deterministic non-existent email (`nonexistent_qa_invalid@example.com`) so it never collides with live or active test accounts.

## 8. Entry & Exit Criteria

### Entry Criteria
- Target host `https://automationexercise.com` is reachable over HTTPS.
- Apache JMeter 5.6.3 and Java 11+ are installed and available on PATH.
- All PRDs (`docs/prd/`), Test Case Matrices (`docs/test-cases/`), and `docs/TRACEABILITY.md` are reviewed and 100% aligned.

### Exit Criteria
- Non-GUI JMeter execution (`jmeter -n -t plans/automationexercise-api-suite.jmx -l results.jtl -e -o report-html`) completes with exit code `0` and zero JMeter XML/runtime errors in `jmeter.log`.
- `scripts/verify-results.ps1` exits `0` with 100% `success=true` across all 34 samples and max elapsed time ≤ 8,000 ms.
- Jenkins pipeline `automationexercise-jmeter-api-ci` completes with `SUCCESS` and archives `results.jtl` and `report-html/**`.
