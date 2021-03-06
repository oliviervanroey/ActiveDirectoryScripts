
function Find-BadSIDS {
    Param(
    [Parameter(Mandatory=$true)][string]$folder
    )
    
    $badfilelist = @()
    $i=0
    
    $files = get-childitem $folder -recurse
    foreach ($file in $files){
        $acls = get-acl $file.fullname
        foreach ($acl in $acls){
            # $file.fullname
            foreach ($reference in $acl.access){
                #if ($reference.identityreference -match "^S\-\d{1}\-\d{1}\-\d{2}\-\d{9}\-\d{9}\-\d{9}\-\d{5}"){
                if ($reference.identityreference -match "^S-1-5-21"){
                     if ($reference.isinherited -eq "False") {
                        $badfile = new-object system.object
                        #$file.fullname + " " + $reference.identityreference
                        $badfile | add-member -type NoteProperty -name FileName -value $file.fullname
                	    $badfile | add-member -type NoteProperty -name BadSID -value $reference.identityreference
                        $badfile | add-member -type NoteProperty -name isInherted -value $reference.isinherited
                        $badfilelist += $badfile
                     }

                }
            }
        }
    }
    return $badfilelist
}

#Main

#add your shares here
$shares=('\\server1\users$','\\server2\users$')
Foreach ($share in $shares) {
	$sharename= $share -replace '\\',''
	$sharename= $sharename -replace '$',''
    $reportname= $sharename + "-badSIDreport.csv"
    $badSIDS=Find-badSIDS $share
    $badSIDS | export-csv $reportname
    }