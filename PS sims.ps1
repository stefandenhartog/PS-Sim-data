
$allSims = @()
$apiKey ="4c421fd3-ad58-4ad7-96ed-e9f4279a5cdf"
$outputFile = "D:\export.txt"

$simData = ""
$x = 'true'
$pageNr = 1

while($x.equals('true')) {
Write-Output (" Now getting data for page " + $pageNr)
  $pageNr+=1;
    $simData = GetSimsForPage($pageNr)
 

    Write-Output($simData.Count)
    

        foreach($sim in $simData)
        {
        $allSims += $sim

        }
     if($simData.Count -lt 99){  
        $x = 'false'
      }

      if($pageNr.Equals(2)){
        $x= 'false'

      }     
}

$output = "ICCID`tStatus`tMSISDN`tACTIVATION DATE`tStatus`r`n"
foreach($sim in $allSims){
$bla = $sim.iccid+""+$sim.current_quota
Write-Host "$($sim.iccid)-$($sim.status)	$($sim.current_quota)	$($sim.quota_status.description)"
 $output += "$($sim.iccid)`t$($sim.status)`t$($sim.msisdn)`t$($sim.activation_date)`t$($sim.quota_status.description)`r`n"
}

 $output | Out-File -FilePath $outputFile


function GetSimsForPage {
param ($page)

$url = "https://api.1nce.com/management-api/v1/sims?page="+ $page+"&pageSize=100"


$headers=@{}
$headers.Add("Accept", "application/json")
$headers.Add("Authorization", "Bearer $apiKey")
$response = Invoke-WebRequest -Uri $url  -Method GET -Headers $headers

$simData = $response.Content  | ConvertFrom-Json

Write-Verbose($response.Content)


return $simData
}
