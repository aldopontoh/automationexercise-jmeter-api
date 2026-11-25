# PRD: Catalog & Search APIs (APIs 1–6)

## 1. Module Overview
Covers read-only catalog retrieval (`productsList`, `brandsList`), unsupported HTTP method handling on catalog endpoints, and form-based product search (`searchProduct`) including negative missing-parameter validation.

## 2. Endpoint Summary

| API # | Endpoint | HTTP Method | Request Parameters | Expected HTTP | Expected JSON `responseCode` |
| :---: | :--- | :---: | :--- | :---: | :---: |
| API 1 | `/api/productsList` | `GET` | None | `200` | `200` |
| API 2 | `/api/productsList` | `POST` | None | `200` | `405` |
| API 3 | `/api/brandsList` | `GET` | None | `200` | `200` |
| API 4 | `/api/brandsList` | `PUT` | None | `200` | `405` |
| API 5 | `/api/searchProduct` | `POST` | `search_product` (form-urlencoded) | `200` | `200` |
| API 6 | `/api/searchProduct` | `POST` | None (missing `search_product`) | `200` | `400` |

## 3. Atomic Functional & Non-Functional Requirements

### `API-REQ-CAT-01` — Retrieve Complete Products Catalog (API 1)
- **Endpoint**: `GET https://automationexercise.com/api/productsList`
- **Acceptance Criteria (Given / When / Then)**:
  - **Given** the AutomationExercise API service is operational,
  - **When** a client sends an HTTP `GET` request to `/api/productsList`,
  - **Then** the response returns HTTP `200`, JSON contains `"responseCode": 200`, and a non-empty `"products"` array containing product attributes (`"id"`, `"name"`, `"price"`, `"brand"`, `"category"`).

### `API-REQ-CAT-02` — Reject Unsupported POST on Products List (API 2)
- **Endpoint**: `POST https://automationexercise.com/api/productsList`
- **Acceptance Criteria (Given / When / Then)**:
  - **Given** `/api/productsList` only supports `GET` requests,
  - **When** a client sends an HTTP `POST` request to `/api/productsList`,
  - **Then** the response returns JSON `"responseCode": 405` and `"message": "This request method is not supported."`.

### `API-REQ-CAT-03` — Retrieve Complete Brands List (API 3)
- **Endpoint**: `GET https://automationexercise.com/api/brandsList`
- **Acceptance Criteria (Given / When / Then)**:
  - **Given** the AutomationExercise API service is operational,
  - **When** a client sends an HTTP `GET` request to `/api/brandsList`,
  - **Then** the response returns HTTP `200`, JSON contains `"responseCode": 200`, and a non-empty `"brands"` array containing brand entries (`"id"`, `"brand"`).

### `API-REQ-CAT-04` — Reject Unsupported PUT on Brands List (API 4)
- **Endpoint**: `PUT https://automationexercise.com/api/brandsList`
- **Acceptance Criteria (Given / When / Then)**:
  - **Given** `/api/brandsList` only supports `GET` requests,
  - **When** a client sends an HTTP `PUT` request to `/api/brandsList`,
  - **Then** the response returns JSON `"responseCode": 405` and `"message": "This request method is not supported."`.

### `API-REQ-CAT-05` — Search Products by Keyword Parameter (API 5)
- **Endpoint**: `POST https://automationexercise.com/api/searchProduct`
- **Input Dataset**: Externalized CSV `data/search_terms.csv` (`top`, `tshirt`, `jean`, `dress`, `men`).
- **Acceptance Criteria (Given / When / Then)**:
  - **Given** a valid search term from `data/search_terms.csv` (e.g., `top`, `tshirt`, `jean`, `dress`, `men`),
  - **When** a client sends an HTTP `POST` request to `/api/searchProduct` with form parameter `search_product=<term>`,
  - **Then** the response returns HTTP `200`, JSON contains `"responseCode": 200`, and a `"products"` array containing matching items.

### `API-REQ-CAT-06` — Reject Product Search Missing Required Parameter (API 6)
- **Endpoint**: `POST https://automationexercise.com/api/searchProduct`
- **Acceptance Criteria (Given / When / Then)**:
  - **Given** `search_product` is a mandatory form parameter for `/api/searchProduct`,
  - **When** a client sends an HTTP `POST` request to `/api/searchProduct` without the `search_product` parameter,
  - **Then** the response returns JSON `"responseCode": 400` and `"message": "Bad request, search_product parameter is missing in POST request."`.

### `API-REQ-CAT-07` — Catalog & Search Latency SLA Under Controlled Concurrency
- **Scope**: APIs 1–6 in JMeter Thread Group 1 (`3` threads, `3 s` ramp-up, `1` loop, `500 ms` pacing).
- **Acceptance Criteria (Given / When / Then)**:
  - **Given** Thread Group 1 executes APIs 1–6 concurrently with controlled pacing,
  - **When** all 18 samples complete in non-GUI execution,
  - **Then** 100% of samples pass all assertions (`success=true`) and every individual sample completes in `<= 8,000 ms`.
