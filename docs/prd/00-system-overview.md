# System Overview — AutomationExercise REST API Suite

## 1. Purpose
This Product Requirements Overview defines the shared technical contract, transport behavior, and non-functional constraints for the AutomationExercise REST API (`https://automationexercise.com/api/*`), covering all 14 endpoints published on [https://automationexercise.com/api_list](https://automationexercise.com/api_list).

## 2. Architecture & Base Endpoint
- **Protocol**: HTTPS (`443`)
- **Host**: `automationexercise.com`
- **Base Path**: `/api`
- **Backend Characteristics**: Django-based REST endpoints returning UTF-8 JSON payloads serialized within HTTP `200 OK` responses (`Content-Type: text/html; charset=utf-8`).

## 3. Shared Response Envelope Convention
All 14 endpoints follow a uniform JSON envelope:

| Category | HTTP Status | JSON `responseCode` | Primary Payload Key |
| :--- | :---: | :---: | :--- |
| Successful Read (Products / Brands / User) | `200` | `200` | `"products"`, `"brands"`, or `"user"` |
| Successful Mutation (Login / Update / Delete) | `200` | `200` | `"message"` |
| Resource Creation (`createAccount`) | `200` | `201` | `"message": "User created!"` |
| Missing Required Parameter | `200` | `400` | `"message": "Bad request, ..."` |
| Resource / Credentials Not Found | `200` | `404` | `"message": "User not found!"` |
| Unsupported HTTP Method | `200` | `405` | `"message": "This request method is not supported."` |

## 4. Module Decomposition

| Module | PRD Document | Test Case Matrix | Endpoints Covered | Requirement ID Range |
| :--- | :--- | :--- | :--- | :--- |
| Catalog & Search APIs | `docs/prd/catalog-search-api.md` | `docs/test-cases/catalog-search-api.md` | APIs 1–6 | `API-REQ-CAT-01` .. `API-REQ-CAT-07` |
| Account & Auth Lifecycle APIs | `docs/prd/account-auth-api.md` | `docs/test-cases/account-auth-api.md` | APIs 7–14 | `API-REQ-ACC-01` .. `API-REQ-ACC-09` |

## 5. Global Non-Functional Constraints
- **Latency SLA**: Every API endpoint MUST respond within `8,000 ms` under controlled concurrency.
- **Data Hygiene**: No synthetic test user may persist after an Account Lifecycle iteration completes.
- **No Secret Leakage**: Test scripts and plans must contain zero real user credentials or API tokens.
