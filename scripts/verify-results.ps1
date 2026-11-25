param(
    [Parameter(Mandatory = $false)]
    [string]$JtlPath = "results.jtl",

    [Parameter(Mandatory = $false)]
    [int]$MaxDurationMs = 8000
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path -Path $JtlPath)) {
    Write-Error "JTL file not found at path: $JtlPath"
    exit 1
}

$samples = Import-Csv -Path $JtlPath
if (-not $samples -or $samples.Count -eq 0) {
    Write-Error "JTL file '$JtlPath' contains zero samples."
    exit 1
}

$total = $samples.Count
$failedSamples = @()
$slaBreaches = @()
$maxObservedMs = 0

foreach ($row in $samples) {
    $elapsed = [int]$row.elapsed
    if ($elapsed -gt $maxObservedMs) {
        $maxObservedMs = $elapsed
    }

    if ($row.success -ne 'true') {
        $failedSamples += [PSCustomObject]@{
            Label          = $row.label
            ResponseCode   = $row.responseCode
            ElapsedMs      = $elapsed
            FailureMessage = $row.failureMessage
        }
    }

    if ($elapsed -gt $MaxDurationMs) {
        $slaBreaches += [PSCustomObject]@{
            Label     = $row.label
            ElapsedMs = $elapsed
            LimitMs   = $MaxDurationMs
        }
    }
}

$passed = $total - $failedSamples.Count
Write-Host "============================================================"
Write-Host "JMeter JTL Verification Summary"
Write-Host "============================================================"
Write-Host "JTL File        : $JtlPath"
Write-Host "Total Samples   : $total"
Write-Host "Passed Samples  : $passed"
Write-Host "Failed Samples  : $($failedSamples.Count)"
Write-Host "Max Elapsed (ms): $maxObservedMs (SLA Limit: $MaxDurationMs ms)"
Write-Host "SLA Breaches    : $($slaBreaches.Count)"
Write-Host "============================================================"

if ($failedSamples.Count -gt 0) {
    Write-Host "`n[FAIL] Samples with success != true:" -ForegroundColor Red
    $failedSamples | Format-Table -AutoSize | Out-String | Write-Host
}

if ($slaBreaches.Count -gt 0) {
    Write-Host "`n[FAIL] Samples exceeding $MaxDurationMs ms SLA:" -ForegroundColor Red
    $slaBreaches | Format-Table -AutoSize | Out-String | Write-Host
}

if ($failedSamples.Count -gt 0 -or $slaBreaches.Count -gt 0) {
    Write-Error "Quality gate FAILED: $($failedSamples.Count) functional/assertion failure(s), $($slaBreaches.Count) SLA breach(es)."
    exit 1
}

Write-Host "[PASS] All $total JMeter samples passed assertions and met the <= $MaxDurationMs ms SLA." -ForegroundColor Green
exit 0
