# PRD: Account & Authentication Lifecycle APIs (APIs 7–14)

## 1. Module Overview
Covers the complete self-cleaning user account lifecycle (`createAccount` -> `verifyLogin` -> `getUserDetailByEmail` -> `updateAccount` -> `deleteAccount`) together with authentication negative-path and unsupported-method verifications (`verifyLogin` missing email, `DELETE /api/verifyLogin`, and invalid credentials).

## 2. Endpoint Summary

| API # | Endpoint | HTTP Method | Request Parameters / Encoding | Expected HTTP | Expected JSON `responseCode` |
| :---: | :--- | :---: | :--- | :---: | :---: |
| API 11 | `/api/createAccount` | `POST` | 17 form-urlencoded fields (`name`, `email`, `password`, `title`, `birth_date`, `birth_month`, `birth_year`, `firstname`, `lastname`, `company`, `address1`, `address2`, `country`, `zipcode`, `state`, `city`, `mobile_number`) | `200` | `201` |
| API 7 | `/api/verifyLogin` | `POST` | `email`, `password` (form-urlencoded, valid) | `200` | `200` |
| API 14 | `/api/getUserDetailByEmail` | `GET` | `email` (query parameter) | `200` | `200` |
| API 13 | `/api/updateAccount` | `PUT` | 17 form-urlencoded fields in request body | `200` | `200` |
| API 8 | `/api/verifyLogin` | `POST` | `password` only (missing `email`, form-urlencoded) | `200` | `400` |
| API 9 | `/api/verifyLogin` | `DELETE` | None | `200` | `405` |
| API 10 | `/api/verifyLogin` | `POST` | Invalid `email`, `password` (form-urlencoded) | `200` | `404` |
| API 12 | `/api/deleteAccount` | `DELETE` | `email`, `password` (form-urlencoded request body) | `200` | `200` |

## 3. Atomic Functional & Non-Functional Requirements

### `API-REQ-ACC-01` — Register New Dynamic User Account (API 11)
- **Endpoint**: `POST https://automationexercise.com/api/createAccount`
- **Acceptance Criteria (Given / When / Then)**:
  - **Given** a unique per-thread, per-iteration synthetic email (`qa_${__threadNum}_${__time()}@example.com`) and complete 17-field profile payload,
  - **When** a client sends an HTTP `POST` request to `/api/createAccount` with form-urlencoded parameters,
  - **Then** the response returns JSON `"responseCode": 201` and `"message": "User created!"`.

### `API-REQ-ACC-02` — Verify Login with Valid Credentials (API 7)
- **Endpoint**: `POST https://automationexercise.com/api/verifyLogin`
- **Acceptance Criteria (Given / When / Then)**:
  - **Given** the synthetic user account was created in `API-REQ-ACC-01`,
  - **When** a client sends an HTTP `POST` request to `/api/verifyLogin` with the matching `email` and `password`,
  - **Then** the response returns JSON `"responseCode": 200` and `"message": "User exists!"`.

### `API-REQ-ACC-03` — Retrieve Account Details by Email (API 14)
- **Endpoint**: `GET https://automationexercise.com/api/getUserDetailByEmail?email=${testEmail}`
- **Acceptance Criteria (Given / When / Then)**:
  - **Given** the synthetic user account exists in the backend,
  - **When** a client sends an HTTP `GET` request to `/api/getUserDetailByEmail` with query parameter `email=${testEmail}`,
  - **Then** the response returns JSON `"responseCode": 200` and a `"user"` object containing `"email": "${testEmail}"` and profile fields (`"id"`, `"name"`, `"first_name"`, `"last_name"`, `"birth_day"`, `"country"`).

### `API-REQ-ACC-04` — Update Existing User Account Profile (API 13)
- **Endpoint**: `PUT https://automationexercise.com/api/updateAccount`
- **Acceptance Criteria (Given / When / Then)**:
  - **Given** the synthetic user account exists and `PUT` form parameters are encoded in an `application/x-www-form-urlencoded` body,
  - **When** a client sends an HTTP `PUT` request to `/api/updateAccount` with updated profile attributes (`name`, `firstname`, `address1`, `zipcode`, `mobile_number`) for `${testEmail}` and `${testPassword}`,
  - **Then** the response returns JSON `"responseCode": 200` and `"message": "User updated!"`.

### `API-REQ-ACC-05` — Reject Verify Login Missing Email Parameter (API 8)
- **Endpoint**: `POST https://automationexercise.com/api/verifyLogin`
- **Acceptance Criteria (Given / When / Then)**:
  - **Given** both `email` and `password` are mandatory for `/api/verifyLogin`,
  - **When** a client sends an HTTP `POST` request to `/api/verifyLogin` containing only `password` (omitting `email`),
  - **Then** the response returns JSON `"responseCode": 400` and `"message": "Bad request, email or password parameter is missing in POST request."`.

### `API-REQ-ACC-06` — Reject Unsupported DELETE on Verify Login (API 9)
- **Endpoint**: `DELETE https://automationexercise.com/api/verifyLogin`
- **Acceptance Criteria (Given / When / Then)**:
  - **Given** `/api/verifyLogin` only supports `POST` requests,
  - **When** a client sends an HTTP `DELETE` request to `/api/verifyLogin`,
  - **Then** the response returns JSON `"responseCode": 405` and `"message": "This request method is not supported."`.

### `API-REQ-ACC-07` — Reject Verify Login with Invalid Credentials (API 10)
- **Endpoint**: `POST https://automationexercise.com/api/verifyLogin`
- **Acceptance Criteria (Given / When / Then)**:
  - **Given** a non-existent email (`nonexistent_qa_invalid@example.com`) and invalid password,
  - **When** a client sends an HTTP `POST` request to `/api/verifyLogin`,
  - **Then** the response returns JSON `"responseCode": 404` and `"message": "User not found!"`.

### `API-REQ-ACC-08` — Self-Clean Delete Dynamic User Account (API 12)
- **Endpoint**: `DELETE https://automationexercise.com/api/deleteAccount`
- **Acceptance Criteria (Given / When / Then)**:
  - **Given** the synthetic user account created in `API-REQ-ACC-01` has completed all lifecycle assertions,
  - **When** a client sends an HTTP `DELETE` request to `/api/deleteAccount` with `email` and `password` in an `application/x-www-form-urlencoded` request body,
  - **Then** the response returns JSON `"responseCode": 200` and `"message": "Account deleted!"`, leaving zero orphaned test accounts on the server.

### `API-REQ-ACC-09` — Account Lifecycle SLA & Concurrent Isolation
- **Scope**: APIs 7–14 in JMeter Thread Group 2 (`2` threads, `4 s` ramp-up, `1` loop, `500 ms` pacing).
- **Acceptance Criteria (Given / When / Then)**:
  - **Given** Thread Group 2 runs 2 isolated virtual users concurrently, each generating a unique `${testEmail}` once per iteration via `UserParameters`,
  - **When** all 16 samples complete in non-GUI execution,
  - **Then** 100% of samples pass all assertions (`success=true`), zero cross-thread email collisions occur, and every individual sample completes in `<= 8,000 ms`.
