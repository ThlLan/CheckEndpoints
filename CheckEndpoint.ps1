# version 1.00 cleartext xml file
# version 1.01 encrypted xml file 
# version 1.02 cleartext xml file, and auth.xml contains now the authentications and can be used in an encyrpted


[CmdletBinding()]
Param
    (
        [Parameter(Mandatory=$true)]
           [String]$name,
        [Parameter(Mandatory=$false)]
        [AllowEmptyString()]
        [AllowNull()]
           [String]$email,
        [Parameter(Mandatory=$false)]
        [AllowEmptyString()]
        [AllowNull()]
           [String]$userid,
        [AllowEmptyString()]
        [AllowNull()]
           [String]$phone
    ) 


<########################## Functions ###########################>
function ReadXMLAttrib 
{
    param (
             [Parameter(Mandatory=$true,Position=1)]   
             [String]$Attrib,
             [Parameter(Mandatory=$true,Position=2)]   
             [String]$Path
           )
      
    $rc=$null
    $node=$null

    if ($Path -ne "")
    {
        $node=$XmlDocument.SelectSingleNode($Path)
    }


    if ($node -ne $null)
    {
        $rc=$node.Attributes[$attrib].Value
    }
 
 
    return $rc
}


function ReadXMLAttrib2 
{
    param (
             [Parameter(Mandatory=$true,Position=2)]   
             [String]$Path,
             [Parameter(Mandatory=$true,Position=1)]   
             [String]$cmpA,
             [Parameter(Mandatory=$true,Position=2)]   
             [String]$cmpW,
             [Parameter(Mandatory=$true,Position=2)]   
             [String]$Attrib

           )
      
    $rc=$null
    $node=$null

    if ($Path -ne "")
    {
        $node=$XmlDocument.SelectSingleNode($Path)
    }

    if ($node -ne $null)
    {
        foreach ($xmlNode in $node.ChildNodes)
        {
            if ($rc -eq $null)
            {
                if ($xmlNode.Attributes.Count -gt 0)
                { 
                    if ($xmlNode.Attributes[$cmpA].Value -eq $cmpW)
                    {
                        $rc=$xmlNode.Attributes[$attrib].Value ;
                    }
                }

            }
        }
    }

    return $rc
}



function ReadXMLNode 
{
    param (
             [Parameter(Mandatory=$true,Position=1)]   
             [String]$Path
           )
      
    $rc=$null
    $node=$null

    if ($Path -ne "")
    {
       $node=$XmlDocument.SelectSingleNode($Path)
    }


    if ($node -ne $null)
    {
        $rc=$node.InnerText
    }
 
 
    return $rc
}



function CallEndPoint
{
    param
    (
        [Parameter(Mandatory=$true)]
            [String]$title,
        [Parameter(Mandatory=$true)]
            [String]$Log,
        [Parameter(Mandatory=$true)]
            $endpoint,
        [Parameter(Mandatory=$true)]
        [AllowNull()]
            $request,
        [Parameter(Mandatory=$true)]
            [String]$url,
        [Parameter(Mandatory=$true)]
            [Object]$Auth,
        [Parameter(Mandatory=$false)]
            [String]$Email,
        [Parameter(Mandatory=$false)]
            [String]$content,
        [Parameter(Mandatory=$false)]
            [String]$jobid,
        [Parameter(Mandatory=$false)]
            [String]$userid,
        [Parameter(Mandatory=$false)]
            [String]$phone

    )

    $command="curl"

    $en=$endpoint.Replace("/","#")
    $PSout="$RunDir\EndPoint#$en.log"

    del $PSout -ErrorAction SilentlyContinue

 
    (Get-date -format "dd.MM.yyyy_HH.mm.ss") | out-file $log -append
    
    "Endpoint: $endpoint" | out-file $log -append
    write-host $endpoint 

    $cp="" 
    if ($request -ne $null)
    {
        $request=$request.Replace("{url}",$url)
        $request=$request.Replace("{jobid}",$jobid)
        $request=$request.Replace("{endpoint}",$EP)
        $request=$request.Replace("{email}",$Email)
        $request=$request.Replace("{userid}",$userid)
        $request=$request.Replace("{phone}",$phone)

        $cp=$request.Replace("%AUTH%","*****") ; 
        $request=$request.Replace("%AUTH%",$Auth)

        if ( $request -match "/$endpoint" )
        {
            $cp = $cp.Replace("/$endpoint","$endpoint") 
            $request = $request.Replace("/$endpoint","$endpoint") 
        }
    }

    $logCmd=""

    if ($ShowToken -eq $true)
    {
        write-host $request
        "Call    : $command $request"  | out-file $log -append
        $logCmd="$command $request"
         
    }
    else
    {
        write-host $cp
        "Call    : $command $cp"  | out-file $log -append
         $logCmd="$command $cp"
    }


    $rc=""


    if ($request -ne $null)
    {
        $P = Start-Process -Filepath $command -NoNewWindow -Wait -RedirectStandardOutput $PSout -ArgumentList $request -PassThru
        $rc=(Get-Content $PSout) 
        
        
        if ($request -match "-i\s")
        {
            $rc1=[String]$rc
            #if ($rc1 -match '^(HTTP/1\.\d)\s(\d{1,4}).*(Content-Length:\s\d{1,2000000})')
            if ($rc1 -match '^(HTTP/1\.\d)\s(\d{1,4})')
            {
                $HttpHeader=$matches[1]
                $ResponseCode=$matches[2]

                $ResponseCode | out-file $log -append

                # ok Content-Lenght given ?
                if ($rc1 -match "(Content-Length:\s\d{1,2000000})")
                {
                    $cntLen=[int]($matches[1].Substring(16))
                    $len = [int]$rc1.Length 
                    $rc=$rc1.Substring($len-$cntLen,$cntlen)  
                }
                else
                {
                    # no, ok we need to search the first line, which is "", than all aller lines need to be add

                    $bFirstEmptyLine=$false
                    $rc1=""
                    foreach ($line in $rc)
                    {
                        if ($bFirstEmptyLine -eq $true)
                        {
                            $rc1="$rc1 $line"
                        }
                        if (($bFirstEmptyLine -eq $false) -and ($line.Trim() -eq ""))
                        {
                            $bFirstEmptyLine=$true 
                        }

                        if ($rc1.Length -gt 0)
                        {
                            $rc=$rc1.Substring(1)
                        }                    
                    }
                }
            }

        }

        "Returns ==> $rc" | out-file $log -append

   }
    else
    {
        "no command for $endpoint given, SKIP" | out-file $log -append
        $rc=""  
    }
    
    $rcgc=(Get-Content $PSout)

    del $PSout -ErrorAction SilentlyContinue
    
    "$logCmd" | out-file -FilePath $PSout -en utf8 -Append
    "$rcgc"   | out-file -FilePath $PSout -en utf8 -Append
 

    "-------------------------" | out-file $log -append

    return $rc

}



function NewJobId
{
    return (New-Guid).Guid
}


function Get-DWH-Token
{
    param
    (
        [Parameter(Mandatory=$true)]
            [String]$credfile
    )

    $out1="$RunDir\01#DWH.log"
    $err1="$RunDir\02#DWH.account.log"
    $out2="$RunDir\03#DWH.token.log"
    $err2="$RunDir\04#DWH.err.log"


    $cmd="gcloud"
    $args="auth activate-service-account --key-file $credfile" 

    $P = Start-Process -Filepath $cmd -NoNewWindow -Wait -RedirectStandardOutput $out1 -RedirectStandardError $err1 -ArgumentList $args -PassThru

    if (([System.IO.Fileinfo]$out1).Length -eq 0)
    {
       del $out1 -ErrorAction SilentlyContinue 
    }

    if (([System.IO.Fileinfo]$err1).Length -eq 0)
    {
       del $err1 -ErrorAction SilentlyContinue 
    }


    $cmd="gcloud"
    $args="auth print-identity-token"
     
    $P = Start-Process -Filepath $cmd -NoNewWindow -Wait -RedirectStandardOutput $out2  -RedirectStandardError $err2 -ArgumentList $args -PassThru

    if (([System.IO.Fileinfo]$out2).Length -eq 0)
    {
       del $out2 -ErrorAction SilentlyContinue 
    }

    if (([System.IO.Fileinfo]$err2).Length -eq 0)
    {
       del $err2 -ErrorAction SilentlyContinue 
    }

    return (get-content -path $out2)
}



<####################### MAIN ###########################>


$secure=$true

$XmlDocument = $null

$xmlConfig=$null
$xmlAuth=$null  


if ($host.Version.Major -gt 2)
{
    $RunDir=(get-item $PSCommandPath).DirectoryName
}
else
{
    $Mdir=([System.IO.FileInfo]($MyInvocation.MyCommand.Path)).Directory
    $RunDir=$Mdir.FullName
}

if (($RunDir.Length -eq 3) -and ($runDir[2] -eq "\"))
{
    $Rundir = $Rundir.Substring(0,2)
}


$xmlFileT="$Rundir\CheckEndpoint.xml"
$XmlConfig=[xml](Get-Content -Path $xmlfileT) 

if ($Secure -eq $true)
{
    
    $xmlFile="$Rundir\auth.exml"
    $XmlAuth=[xml](((Get-Content -Path $xmlfile) |  Unprotect-CmsMessage -to "cn=Reply.Spike"))
}
else
{
    $XmlFile="$Rundir\auth.xml"
    $XmlAuth=[xml](Get-Content -Path $xmlfile)
}



$TS = (Get-date -format "dd.MM.yyyy_HH.mm.ss")



<#
if (($name -eq $null) -or ($name.Trim() -eq ""))
{
    $name="COCKPIT.ACC.DPO_ByEMAIL";
}
#>

#$name="MENUKIT.ACC.DPO_EMAIL" ;
#$name="COCKPIT.ACC.DPO_EMAIL_AND_USER" 
#$name="DWH.MENUKIT.6"
#$name="MENUKIT.DEV.DPO_ByEMAIL" ;
#$name="COCKPIT.PROD.DPO_ByEMAIL";
#$name="DWH.DEV.ByEMAIL"
#$name="WEBSITEBUILDER.ACC.DPO_ByEMAIL"
#$name="SALESFORCE.ACC.DPO_ByEMAIL"

<# map to Environment #>
$xmlDocument=$xmlConfig
$title     = ReadXMLAttrib -attrib "title" -path "/Configs/Test[@name='$name']"
$content   = ReadXMLNode("/Configs/Content")
$urlid     = ReadXMLAttrib -attrib "urlid"  -path "/Configs/Test[@name='$name']"
$authid    = ReadXMLAttrib -attrib "authid" -path "/Configs/Test[@name='$name']"
$url       = ReadXMLAttrib -attrib "url"    -path "/Configs/Urls/Url[@id='$urlid']"


$xmlDocument=$xmlAuth
$auth      = ReadXMLNode("/Configs/Auths/Auth[@id='$authid']")
$authType  = ReadXMLAttrib -attrib "type"      -path "/Configs/Auths/Auth[@id='$authid']" 
$ShowToken = ReadXMLAttrib -attrib "showtoken" -path "/Configs/Auths/Auth[@id='$authid']"


$xmlDocument=$xmlConfig

<# command param will be overwritten, in case no value was given #>
<#
if (($email -eq $null)  -or ($email.Trim() -eq ""))
{
    $email = ReadXMLAttrib -attrib "email"  -path "/Configs/Test[@name='$name']"
}
#>
<# command param will be overwritten, in case no value was given #>
<#
if (($userid -eq $null) -or ($userid.Trim() -eq ""))
{
    $userid = ReadXMLAttrib -attrib "userid" -path "/Configs/Test[@name='$name']"
}
#>

<# command param will be overwritten, in case no value was given #>
<#
if (($phone -eq $null) -or ($phone.Trim() -eq ""))
{
    $phone = ReadXMLAttrib -attrib "phone" -path "/Configs/Test[@name='$name']"
}
#>

if ($email -eq $null) {$email = ""}
if ($userid -eq $null) {$userid = ""}
if ($phone -eq $null) {$phone = ""}


$Log="$RunDir\logs\$title.$TS.log"
del $log -ErrorAction SilentlyContinue

$ResultFile="$Rundir\logs\result.json"
del $log -ErrorAction SilentlyContinue

$result = New-Object PSObject -Property @{
        LogFile          = $log
        Start            = $TS
        End              = ""
        test             = $name
        UserId           = $userId
        Email            = $email
        Phone            = $phone
        Contact          =""
        url              =$url 
        urlid            =$urlid
        config           =$xmlFileT
        authid           =$authid
    }

$Result | ConvertTo-Json | out-file -FilePath $ResultFile 


if ($title -eq $null)
{
    $mes="$name is a not known test"
    write-host "$mes"
    $mes| out-file $log -append
    
    exit 
}


$answer="$RunDir\token.json"
del $answer -ErrorAction SilentlyContinue

"Test      : $name"   | out-file $log -append

if ($email -ne "")
{
    "Email     : $email"  | out-file $log -append
}

if ($userid -ne "")
{
    "UserId    : $userid" | out-file $log -append
}

if ($Phone -ne "")
{
   "Phone     : $phone"  | out-file $log -append
}

$ContactId=ReadXMLAttrib -attrib "id" -path ("/Configs/Test[@name='$name']/Contact") 
if ($contactID -ne $null)
{
    $Contact=ReadXMLAttrib -attrib "mail" -path ("/Configs/Recipients/Recipient[@id='$ContactId']") 
}
else
{
    $Contact=$null
}

if ($contact -ne "")
{
    "contact   : $Contact"  | out-file $log -append
}

""                    | out-file $log -append


#"#2" | out-file -FilePath $log -Append

$filepath="curl"

#handle "authType to get a token maybe"

$XmlDocument=$xmlAuth 
switch($authType.ToLower())
{
    "static" 
    {
        #nothing to do, because $auth contains the static key
    }

    "dynamic"
    {
        <## we need first catch the the auth via seperate call
        
        callid: contains the call, which must be execute to get the key
        
        after catching the callid, search the cmd and execue the request, the token/key will be stored in "token.json"
        ##>

    
        $authCallId  = ReadXMLAttrib -attrib "callid"    -path "/Configs/Auths/Auth[@id='$authid']" 
        $AuthRequest = ReadXMLAttrib -attrib "cmd"       -path "/Configs/Calls/Call[@id='$authcallid']"

        if ($ShowToken -eq $true)
        {
            "Call    : $filepath $AuthRequest"  | out-file $log -append 
        }

        $P = Start-Process -Filepath $filepath -NoNewWindow -Wait -RedirectStandardOutput $answer -ArgumentList $AuthRequest -PassThru

        if ($ShowToken -eq $true)
        {
            "Returns  ==>" + (Get-Content $answer) | out-file $log -append
        }
        else
        {
            "Returns  ==> *** "  | out-file $log -append
        }
        $rc = Get-Content -Raw -Path $answer | ConvertFrom-Json
        
        $auth=$null
        $Auth=$rc.access_token
        if ($auth -eq $null)
        {
            $Auth=$rc.accesstoken
        }
        

        <# ok, now we have the token #>
        <# need now to start the usual procedure #>
    }

    "special"
    {
        #we need to know the method and args 

        $AuthMethod=ReadXMLAttrib -attrib "method" -path "/Configs/Auths/Auth[@id='$authid']" 
        $AuthParams=ReadXMLAttrib -attrib "params" -path "/Configs/Auths/Auth[@id='$authid']"
        $AuthParams=$AuthParams.Replace("%RunDir%",$RunDir) 

        switch ($authMethod.ToUpper())
        {
            "get-dwh-token" 
            {
                $auth=Get-DWH-Token -credfile $AuthParams
            }

            default
            {
                write-host "$authMethod not defined" 
            }
        }

        <## ok, we ##>
    }
}

if (($ShowToken -ne $null) -and ($ShowToken.ToLower() -eq "true")) 
{
    $ShowToken = $true
    "Token=> $Auth" | out-file $log -append  
}
else
{
    $ShowToken = $false
}

$XmlDocument=$xmlConfig 


"ShowToken : $ShowToken " | out-file $log -append
""                        | out-file $log -append

 
$Endpoints=$XmlDocument.SelectNodes("/Configs/Test[@name='$name']/Endpoint")


foreach ($endpoint in $endpoints)
{

    $EP            = $endpoint.endpoint
    $callid        = $endpoint.callid 
    $NewJobId      = $endpoint.newjobid 
    $RF            = $endpoint.repeatiffalse
    

    if ($newJobId -ne $null) 
    {
        if (($NewJobId -eq "guid") -or ($newjobId -eq "true"))
        {
            $jobid=NewJobId
        }
        else
        {
            $jobid=Get-Random
            Write-host $jobid 
        }
    }

    $request       = ReadXMLAttrib -attrib "cmd" -path "/Configs/Calls/Call[@id='$callid']"

        
    $j=[int]0 

    if (($RF -eq $null) -or ($RF.Trim() -eq "")) 
    {
        $RF=0
    }

    if ($RF -lt 0)
    {
        $RF=0
    }

    if ($RF -gt 10)
    {
        $RF=10
    }

    $RF=[int]$RF

    if ($RF -gt 0)
    {
        write-host "RF:$RF"
    }


    if ($RF -gt 0)
    {
        "###################################### " |  out-file $log -append
    }


    while ($j -lt 10)
    {
        if ($RF -gt 0)
        {
            Write-host "j = $j"
        }

        $rc=CallEndPoint -Log $log -title $title -endpoint $EP -Email $email -Url $url -Auth $Auth -content $content -request $request -jobid $jobid -userid $userid -phone $phone


        if (($rc -eq "false") -and ($RF -gt $j))
        {
            "wait and repeat : $j" | out-file $log -append
            "start sleep" | out-file $log -append
            Start-Sleep -s 1
            "end sleep"   | out-file $log -append

            "LOOP: RC[$rc] j[$j] RF[$RF]" | out-file $log -append
        }
        else
        {
            $j=$j+10000000
            if ($RF -gt 0)
            {
                "END:  RC[$rc] j[$j] RF[$RF]" | out-file $log -append
            }
        }
        $j=$j+1  
    }

    
    $JsonResult="$RunDir\"+"ResponseBody"+$EP.Replace("/","#")
    del $JsonResult -ErrorAction SilentlyContinue
    $rc | out-file $jsonResult -append  

    # $JsonResult | out-file $log -Append
}



$End = (Get-date -format "dd.MM.yyyy_HH.mm.ss")

$result.End=$End
$result.Contact=$Contact

$Result | ConvertTo-Json | out-file -FilePath $ResultFile 

$ResultFile="$log.json"

