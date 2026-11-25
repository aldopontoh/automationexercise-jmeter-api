# End-to-End Traceability Matrix (API -> PRD -> Test Case -> JMeter)

This matrix guarantees **100% bidirectional traceability** across all 14 documented AutomationExercise REST APIs (`https://automationexercise.com/api_list`), 16 atomic requirements (`API-REQ-*`), 16 ISTQB test cases (`API-TC-*`), and every JMeter Thread Group, Sampler, and Assertion in `plans/automationexercise-api-suite.jmx`.

## Coverage Summary

| Metric | Count | Coverage |
| :--- | :---: | :---: |
| Documented AutomationExercise APIs | 14 / 14 | **100%** |
| Atomic Requirements (`API-REQ-*`) | 16 (7 CAT + 9 ACC) | **100%** |
| ISTQB Test Cases (`API-TC-*`) | 16 (7 CAT + 9 ACC) | **100%** |
| JMeter Thread Groups | 2 | **100%** |
| JMeter HTTP Samplers | 14 | **100%** |
| JMeter Response & Duration Assertions | 14 ResponseAssertions + 2 TG-level DurationAssertions | **100%** |

## Complete Traceability Mapping

| API # | Endpoint & Method | PRD Requirement ID | Test Case ID | JMeter Thread Group | JMeter Sampler / Element | JMeter Assertions |
| :---: | :--- | :--- | :--- | :--- | :--- | :--- |
| API 1 | `GET /api/productsList` | `API-REQ-CAT-01` | `API-TC-CAT-01` | `TG1 - Catalog & Search APIs (APIs 1-6)` | `API 01 - GET /api/productsList` | `Assert API 01 - JSON responseCode 200 & products` + `SLA Duration Assertion (<= 8000ms)` |
| API 2 | `POST /api/productsList` | `API-REQ-CAT-02` | `API-TC-CAT-02` | `TG1 - Catalog & Search APIs (APIs 1-6)` | `API 02 - POST /api/productsList (405)` | `Assert API 02 - JSON responseCode 405 & unsupported method` + `SLA Duration Assertion (<= 8000ms)` |
| API 3 | `GET /api/brandsList` | `API-REQ-CAT-03` | `API-TC-CAT-03` | `TG1 - Catalog & Search APIs (APIs 1-6)` | `API 03 - GET /api/brandsList` | `Assert API 03 - JSON responseCode 200 & brands` + `SLA Duration Assertion (<= 8000ms)` |
| API 4 | `PUT /api/brandsList` | `API-REQ-CAT-04` | `API-TC-CAT-04` | `TG1 - Catalog & Search APIs (APIs 1-6)` | `API 04 - PUT /api/brandsList (405)` | `Assert API 04 - JSON responseCode 405 & unsupported method` + `SLA Duration Assertion (<= 8000ms)` |
| API 5 | `POST /api/searchProduct` | `API-REQ-CAT-05` | `API-TC-CAT-05` | `TG1 - Catalog & Search APIs (APIs 1-6)` | `API 05 - POST /api/searchProduct` (`CSV - Search Terms`) | `Assert API 05 - JSON responseCode 200 & products` + `SLA Duration Assertion (<= 8000ms)` |
| API 6 | `POST /api/searchProduct` (missing param) | `API-REQ-CAT-06` | `API-TC-CAT-06` | `TG1 - Catalog & Search APIs (APIs 1-6)` | `API 06 - POST /api/searchProduct Missing Param (400)` | `Assert API 06 - JSON responseCode 400 & missing param` + `SLA Duration Assertion (<= 8000ms)` |
| APIs 1–6 | Concurrent SLA & Pass Rate | `API-REQ-CAT-07` | `API-TC-CAT-07` | `TG1 - Catalog & Search APIs (APIs 1-6)` | `Pacing Timer (500ms)` + TG1 Concurrency (`3` threads) | `SLA Duration Assertion (<= 8000ms)` + `scripts/verify-results.ps1` |
| API 11 | `POST /api/createAccount` | `API-REQ-ACC-01` | `API-TC-ACC-01` | `TG2 - Account & Auth Lifecycle (APIs 7-14)` | `API 11 - POST /api/createAccount` (`Dynamic User Identity`) | `Assert API 11 - JSON responseCode 201 & User created!` + `SLA Duration Assertion (<= 8000ms)` |
| API 7 | `POST /api/verifyLogin` (valid) | `API-REQ-ACC-02` | `API-TC-ACC-02` | `TG2 - Account & Auth Lifecycle (APIs 7-14)` | `API 07 - POST /api/verifyLogin (Valid)` | `Assert API 07 - JSON responseCode 200 & User exists!` + `SLA Duration Assertion (<= 8000ms)` |
| API 14 | `GET /api/getUserDetailByEmail` | `API-REQ-ACC-03` | `API-TC-ACC-03` | `TG2 - Account & Auth Lifecycle (APIs 7-14)` | `API 14 - GET /api/getUserDetailByEmail` | `Assert API 14 - JSON responseCode 200 & user detail` + `SLA Duration Assertion (<= 8000ms)` |
| API 13 | `PUT /api/updateAccount` | `API-REQ-ACC-04` | `API-TC-ACC-04` | `TG2 - Account & Auth Lifecycle (APIs 7-14)` | `API 13 - PUT /api/updateAccount` (`Form URL-Encoded Header`) | `Assert API 13 - JSON responseCode 200 & User updated!` + `SLA Duration Assertion (<= 8000ms)` |
| API 8 | `POST /api/verifyLogin` (missing email) | `API-REQ-ACC-05` | `API-TC-ACC-05` | `TG2 - Account & Auth Lifecycle (APIs 7-14)` | `API 08 - POST /api/verifyLogin Missing Email (400)` | `Assert API 08 - JSON responseCode 400 & missing param` + `SLA Duration Assertion (<= 8000ms)` |
| API 9 | `DELETE /api/verifyLogin` | `API-REQ-ACC-06` | `API-TC-ACC-06` | `TG2 - Account & Auth Lifecycle (APIs 7-14)` | `API 09 - DELETE /api/verifyLogin (405)` | `Assert API 09 - JSON responseCode 405 & unsupported method` + `SLA Duration Assertion (<= 8000ms)` |
| API 10 | `POST /api/verifyLogin` (invalid) | `API-REQ-ACC-07` | `API-TC-ACC-07` | `TG2 - Account & Auth Lifecycle (APIs 7-14)` | `API 10 - POST /api/verifyLogin Invalid (404)` | `Assert API 10 - JSON responseCode 404 & User not found!` + `SLA Duration Assertion (<= 8000ms)` |
| API 12 | `DELETE /api/deleteAccount` | `API-REQ-ACC-08` | `API-TC-ACC-08` | `TG2 - Account & Auth Lifecycle (APIs 7-14)` | `API 12 - DELETE /api/deleteAccount` (`Form URL-Encoded Header`) | `Assert API 12 - JSON responseCode 200 & Account deleted!` + `SLA Duration Assertion (<= 8000ms)` |
| APIs 7–14 | Concurrent Isolation & SLA | `API-REQ-ACC-09` | `API-TC-ACC-09` | `TG2 - Account & Auth Lifecycle (APIs 7-14)` | `Dynamic User Identity (Per Iteration)` + `Pacing Timer (500ms)` | `SLA Duration Assertion (<= 8000ms)` + `scripts/verify-results.ps1` |
