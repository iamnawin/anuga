# Builds only the two surfaces used by the care-request journey. No deployment.
$ErrorActionPreference = 'Stop'
$repoRoot = Split-Path $PSScriptRoot -Parent
Set-Location $repoRoot
$settings = Get-Content .github/workflows/deploy-staging.yml
$stagingUrl = (($settings | Select-String '^  STAGING_SUPABASE_URL:').Line -split ': ', 2)[1].Trim()
$publicKey = (($settings | Select-String '^  STAGING_SUPABASE_ANON_KEY:').Line -split ': ', 2)[1].Trim()
if ($stagingUrl -ne 'https://vsvkllfgrnlbhdydysny.supabase.co') { throw 'Existing synthetic backend required.' }
function Run-Checked([string]$Command, [string[]]$Arguments) {
    $previousAction = $ErrorActionPreference
    try {
        # Windows PowerShell treats native stderr warnings as ErrorRecords.
        # Flutter's successful Wasm/font notices must not terminate the build.
        $ErrorActionPreference = 'Continue'
        & $Command @Arguments
        $commandExit = $LASTEXITCODE
    } finally { $ErrorActionPreference = $previousAction }
    if ($commandExit) { throw "$Command failed with exit $commandExit" }
}
foreach ($app in @('family_app', 'companion_app', 'anugacare_app')) {
    Push-Location "apps/$app"
    try { Run-Checked 'flutter' @('pub', 'get') } finally { Pop-Location }
}
Push-Location apps/anugacare_app
try {
    Run-Checked 'flutter' @('build', 'web', '--release', '--no-web-resources-cdn', '--base-href', '/app/',
        "--dart-define=SUPABASE_URL=$stagingUrl", "--dart-define=SUPABASE_PUBLISHABLE_KEY=$publicKey")
} finally { Pop-Location }
$variables = @{
    OPS_STATIC_EXPORT = '1'; OPS_BASE_PATH = '/ops'; NEXT_TELEMETRY_DISABLED = '1'
    NEXT_PUBLIC_SUPABASE_URL = $stagingUrl; NEXT_PUBLIC_SUPABASE_ANON_KEY = $publicKey
}
$previous = @{}
try {
    foreach ($name in $variables.Keys) {
        $previous[$name] = [Environment]::GetEnvironmentVariable($name, 'Process')
        [Environment]::SetEnvironmentVariable($name, $variables[$name], 'Process')
    }
    Run-Checked 'pnpm' @('--filter', '@companion/ops_console', 'build')
} finally {
    foreach ($name in $previous.Keys) { [Environment]::SetEnvironmentVariable($name, $previous[$name], 'Process') }
}
$output = Join-Path $repoRoot 'artifacts/care-preview/.vercel/output'
New-Item -ItemType Directory -Force "$output/static/app", "$output/static/ops" | Out-Null
Copy-Item apps/anugacare_app/build/web/* "$output/static/app" -Recurse -Force
Copy-Item apps/ops_console/out/* "$output/static/ops" -Recurse -Force
$utf8 = [Text.UTF8Encoding]::new($false)
[IO.File]::WriteAllText("$output/static/index.html", '<!doctype html><meta name="robots" content="noindex"><title>AnugaCare synthetic care preview</title><h1>AnugaCare care-request preview</h1><p>Synthetic data only. No payments or production launch.</p><p><a href="/app/">Family app</a></p><p><a href="/ops/">Ops console</a></p>', $utf8)
[IO.File]::WriteAllText("$output/config.json", '{"version":3,"routes":[{"src":"/(.*)","headers":{"X-Robots-Tag":"noindex, nofollow"},"continue":true},{"src":"^/(ops|app)$","status":308,"headers":{"Location":"/$1/"}},{"handle":"filesystem"},{"src":"^/(.+)/$","dest":"/$1/index.html"}]}', $utf8)
Write-Host "Synthetic preview built: $output (not deployed). Apply the reviewed care-request migration before hosted testing."
