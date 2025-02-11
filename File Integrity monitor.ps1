#ask the question
Write-Host ""
Write-Host "what to do?"
Write-Host ""
Write-Host "    A) Collect new Baseline (Recommended for initial launch)"
Write-Host "    B) Monitor existing Baselines"
Write-Host ""

#ask for respose
$response = Read-Host -prompt "Please enter 'A' or 'B' " 

#functions
Function Calculate-File_Hash($filepath){
    $filehash = Get-FileHash -Path $filepath -Algorithm SHA512
    return $filehash
}

Function Erase-Baseline-If-Aready-Exists($filepath){
    $baselineExists = Test-Path -Path .\baseline.txt
    
    if($baselineExists){
    #yeet it
    Remove-Item -Path .\baseline.txt
    }
}

#if option A
if ($response -eq "A".ToUpper()){
    #delete baseline if it already exists
    Erase-Baseline-If-Aready-Exists

    #pull the hash and store it in a new baseline text  file
    #Write-Host "Calculating hashes and making a baseline file" -ForegroundColor Cyan

    #Collect files in the target folder
    $files = Get-ChildItem -Path .\Samplefile

    #For each file calculate the bhash in store in baseline.txt
    foreach ($f in $files){
        $hash = Calculate-File_Hash $f.Fullname
        "$($hash.Path)|$($hash.Hash)" | Out-File -FilePath .\baseline.txt -Append
    }

}

#if option B
elseif ($response -eq "B".ToUpper()){

    $fileHashDictionary = @{}

    #load file|hash frome baseline.text and store them in a dictionary
    $filePathsAndHashes = Get-Content -Path .\baseline.txt
    
    foreach ($f in $filePathsAndHashes){
        $fileHashDictionary.add($f.Split("|")[0],$f.Split("|")[1])
    }


    #monitor the existing file for tampering

    #for file addition
    While ($true){
        Start-Sleep -Seconds 2
        
        $files = Get-ChildItem -Path .\Samplefile

        #For each file calculate the bhash in store in baseline.txt
        foreach ($f in $files){
            $hash = Calculate-File_Hash $f.Fullname
            #"$($hash.Path)|$($hash.Hash)" | Out-File -FilePath .\baseline.txt -Append
        
            #if a new file has been created
            if ($fileHashDictionary[$hash.Path] -eq $null) {
                Write-Host "$($hash.Path) has been added!" -ForegroundColor Green
            }

            else{
                #for file tampering
                if($fileHashDictionary[$hash.Path] -eq $hash.Hash){
                    #file not changed
                }
                else{
                    #file compromised
                    Write-Host "$($hash.Path) has been tampered!!!" -ForegroundColor Yellow
                }
            }
        }

        foreach ($key in $fileHashDictionary.keys){
                $baselineFileStillExists = Test-Path -Path $key
                if (-Not $baselineFileStillExists){
                    Write-Host "$($key) has been deleted!!!" -ForegroundColor Red
                }    
        } 
    }

    
}