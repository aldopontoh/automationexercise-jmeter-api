# AutomationExercise API Performance & Functional Verification Suite (Apache JMeter 5.6.3)

End-to-end functional, contract, negative-path, and controlled performance verification suite covering all 14 documented REST endpoints at [https://automationexercise.com/api_list](https://automationexercise.com/api_list).

## Repository Layout

```text
automationexercise-jmeter-api/
├── plans/
│   └── automationexercise-api-suite.jmx   # JMeter 5.6.3 non-GUI CI test plan (APIs 1–14)
├── data/
│   └── search_terms.csv                   # Externalized product search terms for API 5
├── docs/
│   ├── 00-test-strategy.md                # Risk-based API test strategy, load profile & SLAs
│   ├── TRACEABILITY.md                    # 100% API -> API-REQ -> API-TC -> JMeter matrix
│   ├── prd/
│   │   ├── 00-system-overview.md          # Target API architecture & shared conventions
│   │   ├── catalog-search-api.md          # PRD for APIs 1–6 (API-REQ-CAT-01..08)
│   │   └── account-auth-api.md            # PRD for APIs 7–14 (API-REQ-ACC-01..10)
│   └── test-cases/
│       ├── catalog-search-api.md          # ISTQB test case matrix for APIs 1–6
│       └── account-auth-api.md            # ISTQB test case matrix for APIs 7–14
├── scripts/
│   └── verify-results.ps1                 # JTL SLA & failure gate validator for CI
├── Jenkinsfile                            # Windows-compatible declarative Jenkins pipeline
├── GEMINI.md                              # Engineering & QA governance rules
└── .gitignore                             # Excludes JTL, HTML reports, and JMeter logs
```

## Prerequisites

- **Java**: JDK 11+ (17 recommended)
- **Apache JMeter**: 5.6.3 available on system `PATH` (`jmeter --version`)
- **PowerShell**: Windows PowerShell 5.1+ (for CI JTL verification)

## Running Locally (Non-GUI Mode)

From the repository root:

```cmd
cd "D:\Work\Automation Projects\Playwright\automationexercise-jmeter-api"
jmeter -n -t plans\automationexercise-api-suite.jmx -l results.jtl -e -o report-html
```

To run the CI SLA verification gate locally:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File scripts\verify-results.ps1 -JtlPath results.jtl -MaxDurationMs 8000
```

> **Note:** Before re-running with `-e -o report-html`, remove any existing `results.jtl` and `report-html` directory so JMeter can generate a fresh HTML dashboard.

## Load Profile & SLA Thresholds

| Thread Group | APIs Covered | Virtual Users | Ramp-Up | Loops | Pacing Timer | Max Sample SLA | Error Rate Target |
| :--- | :--- | :---: | :---: | :---: | :---: | :---: | :---: |
| TG1: Catalog & Search APIs | APIs 1–6 | 3 threads | 3 s | 1 | 500 ms | ≤ 8,000 ms | 0.0% |
| TG2: Account & Auth Lifecycle | APIs 7–14 | 2 threads | 4 s | 1 | 500 ms | ≤ 8,000 ms | 0.0% |

All thread counts, ramp-up periods, and SLA limits are parameterized via JMeter User Defined Variables (`${__P(...)}`) so CI overrides remain safe without editing XML.

## Jenkins CI/CD Pipeline (`automationexercise-jmeter-api-ci`)

The declarative `Jenkinsfile` executes the following stages on Windows:
1. **Checkout**: Pulls `main` from `https://github.com/aldopontoh/automationexercise-jmeter-api.git`.
2. **Clean Workspace Artifacts**: Removes prior `results.jtl`, `report-html/`, and `jmeter.log`.
3. **Run JMeter Non-GUI Suite**: Executes `jmeter -n -t plans/automationexercise-api-suite.jmx -l results.jtl -e -o report-html`.
4. **Verify JTL & SLA Gate**: Runs `scripts/verify-results.ps1` and fails the build (`exit 1`) if any sample reports `success != true` or exceeds the 8,000 ms duration SLA.
5. **Post (Always)**: Archives `results.jtl` and `report-html/**` (`allowEmptyArchive: true`).
