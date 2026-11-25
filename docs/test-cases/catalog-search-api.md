# ISTQB API Test Case Matrix — Catalog & Search APIs (APIs 1–6)

- **Module PRD**: [`docs/prd/catalog-search-api.md`](../prd/catalog-search-api.md)
- **JMeter Thread Group**: `TG1 - Catalog & Search APIs (APIs 1-6)`
- **Test Design Techniques**: Equivalence Partitioning (EP), Negative/Error Guessing, Contract Validation, Performance SLA Verification

## Test Case Matrix

| Test Case ID | Req ID | API # | Test Title | ISTQB Technique | Priority | Preconditions | Test Data / Input | Execution Steps | Expected Result (Transport + JSON + SLA) |
| :--- | :--- | :---: | :--- | :--- | :---: | :--- | :--- | :--- | :--- |
| `API-TC-CAT-01` | `API-REQ-CAT-01` | API 1 | Verify `GET /api/productsList` returns full products catalog | EP (Valid), Contract | P0 | Service reachable over HTTPS | None | Send `GET /api/productsList` | HTTP `200`; JSON contains `"responseCode": 200`, `"products"`, `"price"`, `"category"`; duration `<= 8000 ms` |
| `API-TC-CAT-02` | `API-REQ-CAT-02` | API 2 | Verify `POST /api/productsList` returns JSON 405 unsupported method | Negative (Unsupported Method) | P1 | Service reachable over HTTPS | Empty body | Send `POST /api/productsList` | HTTP `200`; JSON contains `"responseCode": 405` and `"This request method is not supported."`; duration `<= 8000 ms` |
| `API-TC-CAT-03` | `API-REQ-CAT-03` | API 3 | Verify `GET /api/brandsList` returns full brands catalog | EP (Valid), Contract | P0 | Service reachable over HTTPS | None | Send `GET /api/brandsList` | HTTP `200`; JSON contains `"responseCode": 200`, `"brands"`, `"brand"`; duration `<= 8000 ms` |
| `API-TC-CAT-04` | `API-REQ-CAT-04` | API 4 | Verify `PUT /api/brandsList` returns JSON 405 unsupported method | Negative (Unsupported Method) | P1 | Service reachable over HTTPS | Empty body | Send `PUT /api/brandsList` | HTTP `200`; JSON contains `"responseCode": 405` and `"This request method is not supported."`; duration `<= 8000 ms` |
| `API-TC-CAT-05` | `API-REQ-CAT-05` | API 5 | Verify `POST /api/searchProduct` returns matching products using CSV dataset | Data-Driven EP (Valid), Boundary/Keyword | P0 | `data/search_terms.csv` loaded via `CSVDataSet` | `search_product` ∈ `{top, tshirt, jean, dress, men}` | Send `POST /api/searchProduct` with form param `search_product=${search_product}` | HTTP `200`; JSON contains `"responseCode": 200` and `"products"` array; duration `<= 8000 ms` |
| `API-TC-CAT-06` | `API-REQ-CAT-06` | API 6 | Verify `POST /api/searchProduct` without `search_product` returns JSON 400 | Negative (Missing Required Param) | P1 | Service reachable over HTTPS | No form parameters | Send `POST /api/searchProduct` with empty body | HTTP `200`; JSON contains `"responseCode": 400` and `"Bad request, search_product parameter is missing in POST request."`; duration `<= 8000 ms` |
| `API-TC-CAT-07` | `API-REQ-CAT-07` | APIs 1–6 | Verify Catalog & Search concurrent SLA compliance | Performance / SLA Verification | P0 | JMeter 5.6.3 non-GUI mode; 3 threads, 3 s ramp-up, 500 ms pacing | `data/search_terms.csv` | Execute TG1 (18 total samples) and run `scripts/verify-results.ps1` | 18/18 samples `success=true`; 0 assertion errors; max elapsed `<= 8000 ms` |
