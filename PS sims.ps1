
$allSims = @()
$auth = '*username*:*password*';



$base64 = [Convert]::ToBase64String( [System.Text.Encoding]::UTF8.GetBytes($auth))
Write-Output($base64);

#Obtain API Access Token
$headers = @{}
$headers.Add("Accept", "application/json")
$headers.Add("Content-Type", "application/json")
$headers.Add("Authorization", "Basic $base64")


$response = Invoke-WebRequest -Uri 'https://api.1nce.com/management-api/oauth/token' -Method POST -Headers $headers -ContentType 'application/json' -Body '{"grant_type":"client_credentials"}'


$response = $response.content | ConvertFrom-Json

$token = $response.access_token
Write-Output($token)

$outputFile = "D:\export.txt"

$simData = ""
$x = 'true'
$pageNr = 1

while ($x.equals('true')) {
  Write-Output (" Now getting data for page " + $pageNr)
  $pageNr += 1;
  $simData = GetSimsForPage($pageNr)
 

  Write-Output($simData.Count)
    

  foreach ($sim in $simData) {
    $allSims += $sim

  }
  if ($simData.Count -lt 99) {  
    $x = 'false'
  }

  if ($pageNr.Equals(2)) {
    $x = 'false'

  }     
}

$output = "ICCID`tStatus`tMSISDN`tACTIVATION DATE`tStatus`r`n"
foreach ($sim in $allSims) {
  Write-Host "$($sim.iccid)-$($sim.status)	$($sim.current_quota)	$($sim.quota_status.description)"
  $output += "$($sim.iccid)`t$($sim.status)`t$($sim.msisdn)`t$($sim.activation_date)`t$($sim.quota_status.description)`r`n"
}

$output | Out-File -FilePath $outputFile


function GetSimsForPage {
  param ($page)

  $url = "https://api.1nce.com/management-api/v1/sims?page=" + $page + "&pageSize=100"


  $headers = @{}
  $headers.Add("Accept", "application/json")
  $headers.Add("Authorization", "Bearer $token")
  $response = Invoke-WebRequest -Uri $url  -Method GET -Headers $headers

  $simData = $response.Content  | ConvertFrom-Json

  Write-Verbose($response.Content)


  return $simData
}
