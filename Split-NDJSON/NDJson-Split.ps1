$content = Get-Content "path to NDJSON file goes her"

foreach ($data in $content){

    $random = -join ((65..90) + (97..122) | Get-Random -Count 25 | % {[char]$_})
    $data | out-file "<output folder goes here>\$random.json"

}