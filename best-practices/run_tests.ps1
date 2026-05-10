$ErrorActionPreference = "Stop"

$ProjectRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$RepoRoot = Resolve-Path (Join-Path $ProjectRoot "..")
$WebRoot = Join-Path $ProjectRoot "web"
$OutputDir = Join-Path $ProjectRoot "results"
$VenvPython = Join-Path $RepoRoot ".venv\Scripts\python.exe"
$Python = if (Test-Path $VenvPython) { $VenvPython } else { "python" }

function Test-PortInUse {
    param([int]$Port)

    $client = [System.Net.Sockets.TcpClient]::new()
    try {
        $connection = $client.BeginConnect("127.0.0.1", $Port, $null, $null)
        if (-not $connection.AsyncWaitHandle.WaitOne(250, $false)) {
            return $false
        }

        $client.EndConnect($connection)
        return $true
    }
    catch {
        return $false
    }
    finally {
        $client.Close()
    }
}

$Port = if ($env:PORT) { [int]$env:PORT } else { 8010 }
if (-not $env:PORT) {
    while (Test-PortInUse -Port $Port) {
        $Port++
    }
}

$BaseUrl = "http://127.0.0.1:$Port"

$serverArgs = @(
    "-m", "http.server", "$Port",
    "--bind", "127.0.0.1",
    "--directory", "$WebRoot"
)

$server = Start-Process -FilePath $Python -ArgumentList $serverArgs -PassThru -WindowStyle Hidden

try {
    $serverReady = $false
    for ($attempt = 0; $attempt -lt 30; $attempt++) {
        try {
            $response = Invoke-WebRequest -UseBasicParsing -Uri $BaseUrl -TimeoutSec 1
            if ($response.StatusCode -lt 500) {
                $serverReady = $true
                break
            }
        }
        catch {
            Start-Sleep -Milliseconds 250
        }
    }

    if (-not $serverReady) {
        throw "Local web server did not start at $BaseUrl"
    }

    & $Python -m robot --variablefile (Join-Path $ProjectRoot "variables\local.py") --variable BASE_URL:$BaseUrl --variable SELENIUM_SPEED:0.5s --outputdir $OutputDir (Join-Path $ProjectRoot "tests")
    exit $LASTEXITCODE
}
finally {
    if ($server -and -not $server.HasExited) {
        Stop-Process -Id $server.Id
    }
}
