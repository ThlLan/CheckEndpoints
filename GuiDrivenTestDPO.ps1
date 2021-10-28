# version 1.00 cleartext xml file
# version 1.01 encrypted xml file
# version 1.02 cleartext xml file, because auths are removed to auths.xml

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing


[System.Windows.Forms.Application]::EnableVisualStyles()


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

$XmlFile="$Rundir\CheckEndpoint.xml"
$xmlTests=[xml](Get-Content -Path $xmlfile)

$Path=$RunDir


$Form = New-Object system.Windows.Forms.Form
$Form.Text = "GuiDrivenTestDPO : CheckEndpoint.ps1 test"
$Form.TopMost = $true
$Form.Width = 1000
$Form.Height = 660

$LeftX=10 
$LeftH=10

$font= New-Object System.Drawing.Font("Lucidia Sans",11,[System.Drawing.FontStyle]::Regular)
#$font= New-Object System.Drawing.Font("Courier New",12,[System.Drawing.FontStyle]::Regular)

$btnTests = New-Object System.Windows.Forms.Button
$btnTests.Font=$font 
$btnTests.Location = New-Object System.Drawing.Point(10,10) 
$btnTests.Size = New-Object System.Drawing.Size(70,24)
$btnTests.Text = "Run >"
$btnTests.TabIndex = 1
$Form.Controls.Add($btnTests)

$liBoTestCollections = new-object System.Windows.Forms.ListBox
$liBotestCollections.Font      = $font
$liBoTestCollections.Location  = New-Object System.Drawing.Point(90,10) 
$liBoTestCollections.Size      = New-Object System.Drawing.Size(340,150)
$liBoTestCollections.Text      = ""
$liBoTestCollections.TabIndex  = 2
$Form.Controls.Add($liBoTestCollections)


$lblUser = New-Object System.Windows.Forms.Label
$lblUser.Font = $font 
$lblUser.Location = New-Object System.Drawing.Point(440,10) 
$lblUser.Size = New-Object System.Drawing.Size(70,20)
$lblUser.Text = "User"
$lblUser.TabIndex = 3
$Form.Controls.Add($lblUser)

$txtUser = New-Object System.Windows.Forms.TextBox
$txtUser.font = $font 
$txtUser.Location = New-Object System.Drawing.Point(510,10) 
$txtUser.Size = New-Object System.Drawing.Size(360,20)
$txtUser.Text = ""
$txtUser.TabIndex = 4
$Form.Controls.Add($txtUser)

$lblEmail = New-Object System.Windows.Forms.Label
$lblEmail.Font = $font 
$lblEmail.Location = New-Object System.Drawing.Point(440,40) 
$lblEmail.Size = New-Object System.Drawing.Size(70,20)
$lblEmail.Text = "Email"
$lblEmail.TabIndex = 5
$Form.Controls.Add($lblEmail)

$txtEmail = New-Object System.Windows.Forms.TextBox
$txtEmail.font = $font
$txtEmail.Location = New-Object System.Drawing.point(510,40) 
$txtEmail.Size = New-Object System.Drawing.Size(360,20)
$txtEmail.Text = ""
$txtEmail.TabIndex = 6
$Form.Controls.Add($txtEmail)

$lblPhone = New-Object System.Windows.Forms.Label
$lblPhone.Font = $font 
$lblPhone.Location = New-Object System.Drawing.Point(440,70) 
$lblPhone.Size = New-Object System.Drawing.Size(70,20)
$lblPhone.Text = "Phone"
$lblPhone.TabIndex = 7
$Form.Controls.Add($lblPhone)

$txtPhone = New-Object System.Windows.Forms.TextBox
$txtPhone.font = $font
$txtPhone.Location = New-Object System.Drawing.point(510,70) 
$txtPhone.Size = New-Object System.Drawing.Size(360,20)
$txtPhone.Text = ""
$txtPhone.TabIndex = 8
$Form.Controls.Add($txtPhone)

$livTestDetail = New-Object system.windows.Forms.ListView
$livTestDetail.Font = $font 
$livTestDetail.location = new-object system.drawing.Point(10,166)
$livTestDetail.Width = $Form.Width - 38
$livTestDetail.Height = $Form.height - $txtUser.Height -$txtEmail.Height - $txtPhone.Height - $liBoTestCollections.Height
$livTestDetail.View='Details'
$livTestDetail.ShowItemToolTips=$true
$livTestDetail.TabIndex=10 
$livTestDetail.Visible=$true  
$Form.controls.Add($livTestDetail)


$txtResult = New-Object System.Windows.Forms.TextBox
$txtResult.Location = New-Object System.Drawing.Point(10,166) 
$txtResult.Width=$livTestDetail.Width
$txtResult.Height=$livTestDetail.Height
$txtResult.Text = ""
$txtResult.TabIndex =11
$txtResult.Visible=$false 
$txtResult.Multiline=$true 
$txtResult.WordWrap=$true 
$txtResult.ScrollBars="Vertical" 

$Form.controls.Add($txtResult)


<## Resize Form 
##>
$Form.Add_Resize({
    if ($this.Width -lt 900) { $this.Width = 900}
    if ($this.Height -lt 600) { $this.Height = 600 }

    $liBoTestCollections.Location = New-Object System.Drawing.Point(90,10) 
    $liBoTestCollections.Width = 340
    $liBoTestCollections.Height = 150
 
    $livTestDetail.Location = new-object system.drawing.point(10,166)
    $livTestDetail.Width = $this.Width - 38
    $livTestDetail.Height = $this.height - $txtUser.Height -$txtEmail.Height - $txtPhone.Height - $liBoTestCollections.Height 

    $txtResult.Width = $livTestDetail.Width
    $txtResult.Height = $livTestDetail.Height

    if ($livTestDetail.Columns.Count > 0)
    {
        $livTestDetail.Columns[0].Width=140
        $livTestDetail.Columns[1].Width=$livTestDetail.Width - $livTestDetail.Columns[0].Width
    }

})



<#
 Fill the Test-Collections
#>

function FillTestCollections
{
    MyIp

    #clear existing Tests
    $livTestDetail.Items.Clear()
    $liBoTestCollections.Items.Clear()

    foreach ($xmlNode in $xmlTests.Configs.Collections.Collection)
    {
        <#if ($xmlNode.LocalName -eq "Test")
        {#>

            $liBoTestCollections.Items.Add($xmlNode.Name)
        <#}#>
    }
}



function FillTestCollectionView{

    param
    (
        [Parameter(Mandatory=$true)]
            [string]$TestCollection,
        [Parameter(Mandatory=$true)]
            [string]$select
    ) 


    $livTestDetail.Visible=$true
    $txtResult.Visible=$false

    $livTestDetail.Items.Clear()

    $livTestDetail.Columns.Clear()
    $livTestDetail.Columns.Add("endpoint")
    $livTestDetail.Columns.Add("cmd")
    $livTestDetail.Columns[0].Width=140

    $livTestDetail.Columns[1].Width=$livTestDetail.Width - $livTestDetail.Columns[0].Width
               
    $livTestDetail.ShowGroups=$true
    #$rtb.Text = "" 

    $Form.Text = "MyIp: " + $Form.Tag.ToString() + " GuiDrivenTest : CheckEndpoint.ps1"
    $Form.Text = " GuiDrivenTestDPO : CheckEndpoint.ps1"

    <# search the given test Collection name #>
    
    $sPath="/Configs/Collections/Collection[@name='$TestCollection']"
    $xmlCollection=$xmlTests.SelectSingleNode("/Configs/Collections/Collection[@name='$TestCollection']")

    if ($xmlCollection -eq $null)
    {
      return 
    }

    <# bitte den Testuser im Dialog einstellen #>
    $txtEmail.Text  = $xmlCollection.Email
    $txtUser.text   = $xmlCollection.userid
    $txtPhone.text  = $xmlCollection.phone

    foreach ($xmlChNode in $xmlCollection.ChildNodes)
    {

        if (($xmlChNode.LocalName -eq "Test") -and ($xmlChNode.active -eq "false"))
        {
           continue 
        }

        if (($xmlChNode.LocalName -eq "Test") -and ($xmlChNode.ref -ne $null))
        {
            
            $sPath="/Configs/Test[@name='"+$xmlChNode.ref+"']"
            $xmlThisTestNode=$xmlTests.SelectSingleNode($sPath)

            $ToCollectRB=$xmlChNode.collect

            foreach ($xmlNode in $xmlThisTestNode)
            {
                $Urlid=$xmlNode.urlId
                $xmlUrlNode=$xmlTests.SelectSingleNode("/Configs/Urls/Url[@id='"+$urlId+"']")
                #write-host $urlId
                #write-host $xmlUrlNode.url

                $lg=new-object System.Windows.Forms.ListViewGroup ($xmlChNode.app + " # " + $xmlNode.Name + " # " + $xmlUrlNode.url + " # " +$txtEmail.Text + " # " + $txtuser.Text + "#" +$TxtPhone.Text)
                $livTestDetail.Groups.Add($lg) ;


                <# catch showtoken #>
                $xTest = $xmlNode.authid 
                write-host $xTest
            
                #$xmlAuthNode=$xmlTests.SelectSingleNode("/Configs/Auths/Auth[@id='"+$xtest+"']")
                #write-host $xmlAuthNode.showtoken
            
                ##$chkToken.Checked = ($xmlAuthNode.showtoken -eq "true") 

                foreach ($endpoint in $xmlNode.Childnodes)
                {
                
                    if ($endpoint.LocalName -eq "Remark")
                    {
                        $rtb.text = $endpoint.Innertext 
                    }
               
 
                    if ($endpoint.LocalName -eq "Endpoint")
                    {               
                        
                        $ep=$endpoint.endpoint.ToString()
                        #write-host $ep
                         
                        $li=New-Object System.Windows.Forms.ListViewItem ($ep) ;

                        if (($ToCollectRB -split(',')) -contains $ep)
                        {
                            $li.SubItems[0].BackColor=[System.Drawing.Color]::YellowGreen
                        }
                        
               
                        $cmd=$xmlTests.SelectSingleNode("/Configs/Calls/Call[@id='" + $endpoint.callid +"']").cmd 
                 
                        $cmd=$cmd.Replace("{url}",$xmlUrlNode.url) 
                        $cmd=$cmd.Replace("{endpoint}",$ep)
                
                        $li.Tag = $cmd
                
                        $cmd=$cmd.Replace("{userid}",$txtuser.Text) ;
                        $cmd=$cmd.Replace("{email}",$txtEmail.Text) ;
                        $cmd=$cmd.Replace("{phone}","'"+$txtPhone.Text+"'") ;

                        $li.SubItems.Add($cmd)
                        $li.Group=$lg
                       
                        $lg.Name = $xmlNode.Name
                        $lg.Tag  = $ToCollectRB
                        
                        $livTestDetail.Items.Add($li)
                    }
                }
            }
        }
    }
}


Function MyIp
{
    <#
    $request="https://api.myip.com"
    $PsOut="$RunDir\myip.log"

    $P = Start-Process -Filepath "curl.exe" -NoNewWindow -Wait -RedirectStandardOutput $PSout -ArgumentList $request -PassThru

    $body = (get-content -raw -path $PsOut) | ConvertFrom-Json 
    $Form.Tag = $body.ip.ToString() 
    #>
    $Form.Tag=""
}



$liBoTestCollections.Add_Click({

   $Test=$this.Items[$this.SelectedIndex]

   FillTestCollectionView -test $Test -select "xml" #$btnReplace.Tag.ToString() 
   
})



$BtnTests.Add_Click({
#$mnItem1.Add_Click({


    <#
    foreach ($xmlNode in $xmlTests.Configs.Test)
    {

        if (($xmlNode.LocalName -eq "Test") -and ($xmlNode.active -eq "false"))
        {
           return  
        }
   }
   #>      


    $i=$liBoTestCollections.SelectedIndex
    $CentralName=$liBoTestCollections.Items[$i]
    

    $jsonfile="$Path\logs\result.json"
    del $jsonfile -ErrorAction SilentlyContinue 
    
    $pCmd="powershell.exe"
        
    $email=$txtEmail.Text 
    $userid=$txtUser.Text
    $phone=$txtPhone.Text 


    <# we need to create a central logfile #>
    <# we need to create a central collectionfile #>
    
    $TS=Get-date -format "dd.MM.yyyy_HH.mm.ss"


    $CentralLogFile="$Path\logs\$CentralName.$TS.log"
    del $CentralLogFile -ErrorAction SilentlyContinue 
    $CentralJsonFile="$Path\logs\$CentralName.$TS.json"
    del $CentralJsonFile -ErrorAction SilentlyContinue 

    $CollectedJson=""


    $Form.Cursor = [System.Windows.Forms.Cursors]::WaitCursor

    <# der name muss replaced werden aus dem lv Gruppen Element #>
    foreach ($gruppe in $livTestDetail.Groups)
    {
        $name=$liBoTestCollections.Items[$liBoTestCollections.SelectedIndex] 
        $name=$gruppe.Name
    

        $pCall = "-ExecutionPolicy Bypass -Command ""$Path\CheckEndpoint.ps1 -name $name -email $email -userid $userid -phone '$phone'""".Trim() 
    #    write-host "446: $pCall $path"


        if (($email -eq $null) -or ($email -eq ""))
        {
            $pcall = $pcall.Replace("-email","") 
        }

        if (($userid -eq $null) -or ($userid -eq ""))
        {
            $pcall = $pcall.Replace("-userid","") 
        }

        if (($phone -eq $null) -or ($phone -eq ""))
        {
            $pcall = $pcall.Replace("-phone","") 
        }

        $pcall = $pcall.Replace("''","") 
    

        $pCall=$pcall.TrimEnd() 

        write-host "PCall: $pcall"

        $PR = Start-Process -Filepath $pcmd -NoNewWindow -ArgumentList $pcall -RedirectStandardError "$Rundir\GuiTest.txt" -Wait 


        <#
        $livTestDetail.Visible=$false
        $txtResult.Visible=$true
        $txtResult.Text ="" 
        $txtResult.font = $font 
        #>
        

        foreach ($ep in ($gruppe.Tag.ToString() -split(",")))
        {
            $contentRBFile="$Rundir\ResponseBody"+$ep.Replace("/","#")
            $contentRB=(get-content -Path $contentRBFile) 
 
            $apps=($gruppe.Header -split(" # "))[0] 

            if ($ep -eq "/export")
            {
                $EPD=""
            }
            else
            {
               $EPD=$ep.Replace("/","_")
            }

 
            $AppJson="{ ""$apps$EPD"" : $contentRB }"
            
            #"[{ $apps : $contentRB }]" | out-File -FilePath $CentralJsonFile -Append  



            if ($CollectedJson -eq "")
            {
                $CollectedJson = "[$AppJson]"
            }
            else
            {
                $CollectedJson = $CollectedJson +",[$appJson]"
            }

        }
 

        if ((test-path -Path $jsonfile) -eq $true)
        {
            $js=(Get-content -path $jsonfile)  | Out-String | ConvertFrom-Json

            $js.LogFile

    
            if ((test-path -path $js.LogFile) -eq $true)
            {
                $re=Get-Content -path $js.LogFile

    
                foreach ($line in $re)
                { 
                    #$txtResult.Text = $txtResult.Text + $line + [Environment]::NewLine
                    $line | out-file -FilePath $CentralLogFile -Append
                }
            }
        }
    }

    $livTestDetail.Visible=$false
    $txtResult.Visible=$true
    $txtResult.Text ="" 
    $txtResult.font = $font 

    if ((Test-Path -path $CentralLogFile) -eq $true)
    {
        $re=Get-Content -path $CentralLogFile

    
        foreach ($line in $re)
        { 
            $txtResult.Text = $txtResult.Text + $line + [Environment]::NewLine
        }
    }

    "[$CollectedJson]" | out-File -FilePath $CentralJsonFile -Append  

    $Form.Cursor = [System.Windows.Forms.Cursors]::Default


})



FillTestCollections


[System.Windows.Forms.Application]::EnableVisualStyles()

[void]$Form.ShowDialog()
$Form.Dispose()