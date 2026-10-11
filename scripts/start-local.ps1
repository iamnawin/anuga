param(
    [string]$SupabaseUrl,
    [string]$PublicKey,
    [switch]$SkipBuild
)
$ErrorActionPreference = 'Stop'
$repoRoot = Split-Path $PSScriptRoot -Parent
Set-Location $repoRoot
if (-not $SupabaseUrl -and -not $PublicKey) {
    # These are public client settings already committed in PR #2.
    $workflow = Get-Content .github/workflows/deploy-staging.yml
    $SupabaseUrl = (($workflow | Select-String '^  STAGING_SUPABASE_URL:').Line -split ': ', 2)[1].Trim()
    $PublicKey = (($workflow | Select-String '^  STAGING_SUPABASE_ANON_KEY:').Line -split ': ', 2)[1].Trim()
}
if (-not $SupabaseUrl -or -not $PublicKey) { throw 'Provide both SupabaseUrl and PublicKey (anon/publishable only).' }
$backend = [uri]$SupabaseUrl
if ($backend.Host -notin @('vsvkllfgrnlbhdydysny.supabase.co', '127.0.0.1', 'localhost')) {
    throw 'Only the existing synthetic staging project or a loopback Supabase backend is allowed.'
}
if ($PublicKey.StartsWith('sb_secret_')) { throw 'Server keys must never be compiled into apps.' }
if ($PublicKey.StartsWith('eyJ')) {
    $payload = $PublicKey.Split('.')[1].Replace('-', '+').Replace('_', '/')
    $payload = $payload.PadRight([int]([math]::Ceiling($payload.Length / 4) * 4), '=')
    $claims = [Text.Encoding]::UTF8.GetString([Convert]::FromBase64String($payload)) | ConvertFrom-Json
    if ($claims.role -ne 'anon') { throw 'Only the public anon JWT belongs in apps.' }
} elseif (-not $PublicKey.StartsWith('sb_publishable_')) { throw 'Use an anon or publishable client key.' }
function Run-Checked([string]$Command, [string[]]$Arguments) {
    & $Command @Arguments
    if ($LASTEXITCODE -ne 0) { throw "$Command failed with exit $LASTEXITCODE" }
}
if (-not $SkipBuild) {
    Run-Checked 'pnpm' @('install', '--frozen-lockfile')
    $variables = @{
        OPS_STATIC_EXPORT = '1'; OPS_BASE_PATH = ''; NEXT_TELEMETRY_DISABLED = '1'
        NEXT_PUBLIC_SUPABASE_URL = $SupabaseUrl; NEXT_PUBLIC_SUPABASE_ANON_KEY = $PublicKey
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
    foreach ($app in @('family', 'companion')) {
        Push-Location "apps/${app}_app"
        try {
            Run-Checked 'flutter' @('pub', 'get')
            Run-Checked 'flutter' @('build', 'web', '--release', '--no-web-resources-cdn',
                "--dart-define=SUPABASE_URL=$SupabaseUrl", "--dart-define=SUPABASE_PUBLISHABLE_KEY=$PublicKey")
        } finally { Pop-Location }
    }
}
Write-Host 'Synthetic data only. Keep this terminal open. Ctrl+C stops all three apps.'
Run-Checked 'node' @('scripts/serve-local.mjs')
