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

<#
if ($Secure -eq $true)
{
    $xmlFile="$Rundir\CheckEndpoint.exml"
    $xmlTests=[xml](((Get-Content -Path $xmlfile) |  Unprotect-CmsMessage -to "cn=Reply.Spike"))
}
else
{
#>
    $XmlFile="$Rundir\CheckEndpoint.xml"
    $xmlTests=[xml](Get-Content -Path $xmlfile)
<#
}
#>
$path=$RunDir


$Form = New-Object system.Windows.Forms.Form
$Form.Text = "GuiDrivenTest : CheckEndpoint.ps1 test"
$Form.TopMost = $true
$Form.Width = 900
$Form.Height = 650

$LeftX=10 
$LeftH=10

$font= New-Object System.Drawing.Font("Lucidia Sans",11,[System.Drawing.FontStyle]::Regular)
#$font= New-Object System.Drawing.Font("Courier New",12,[System.Drawing.FontStyle]::Regular)

$lblUser = New-Object System.Windows.Forms.Label
$lblUser.Font = $font 
$lblUser.Location = New-Object System.Drawing.Point(10,10) 
$lblUser.Size = New-Object System.Drawing.Size(70,20)
$lblUser.Text = "User  :"
$lblUser.TabIndex = 1
$Form.Controls.Add($lblUser)

$txtUser = New-Object System.Windows.Forms.TextBox
$txtUser.font = $font 
$txtUser.Location = New-Object System.Drawing.Point(80,10) 
$txtUser.Size = New-Object System.Drawing.Size(340,20)
$txtUser.Text = ""
$txtUser.TabIndex = 2
$Form.Controls.Add($txtUser)

$lblEmail = New-Object System.Windows.Forms.Label
$lblEmail.Font = $font 
$lblEmail.Location = New-Object System.Drawing.Point(10,40) 
$lblEmail.Size = New-Object System.Drawing.Size(70,20)
$lblEmail.Text = "Email :"
$lblEmail.TabIndex = 3
$Form.Controls.Add($lblEmail)

$txtEmail = New-Object System.Windows.Forms.TextBox
$txtEmail.font = $font
$txtEmail.Location = New-Object System.Drawing.point(80,40) 
$txtEmail.Size = New-Object System.Drawing.Size(340,20)
$txtEmail.Text = ""
$txtEmail.TabIndex = 4
$Form.Controls.Add($txtEmail)


$lblPhone = New-Object System.Windows.Forms.Label
$lblPhone.Font = $font 
$lblPhone.Location = New-Object System.Drawing.Point(10,70) 
$lblPhone.Size = New-Object System.Drawing.Size(70,20)
$lblPhone.Text = "Phone :"
$lblPhone.TabIndex = 5
$Form.Controls.Add($lblPhone)

$txtPhone = New-Object System.Windows.Forms.TextBox
$txtPhone.font = $font
$txtPhone.Location = New-Object System.Drawing.point(80,70) 
$txtPhone.Size = New-Object System.Drawing.Size(340,20)
$txtPhone.Text = ""
$txtPhone.TabIndex = 6
$Form.Controls.Add($txtPhone)


$btnReplace = New-Object System.Windows.Forms.Button
$btnReplace.Font =$font  
$btnReplace.Location = New-Object System.Drawing.Point(440,10) 
$btnReplace.Size = New-Object System.Drawing.Size(230,84)
$btnReplace.Text = "< use dialog values"
$btnReplace.TabIndex = 8
$btnReplace.Tag="xml"
$Form.Controls.Add($btnReplace)


$chkToken = New-Object System.Windows.Forms.CheckBox
$chkToken.Font =$font  
$chkToken.Location = New-Object System.Drawing.Point(700,10) 
$chkToken.Size = New-Object System.Drawing.Size(230,34)
$chkToken.Text = "show token in log"
$chkToken.TabIndex = 12
$chkToken.Enabled=$false
$Form.Controls.Add($chkToken)


$lblTests = New-Object System.Windows.Forms.Label
$lblTests.Font=$font 
$lblTests.Location = New-Object System.Drawing.Point(10,100) 
$lblTests.Size = New-Object System.Drawing.Size(70,20)
$lblTests.Text = "Tests :"
$lblTests.TabIndex = 7
$Form.Controls.Add($lblTests)

$liBoTest          = new-object System.Windows.Forms.ListBox
$liBotest.Font     = $font
$liBoTest.Location = New-Object System.Drawing.Point(80,100) 
$liBoTest.Size     = New-Object System.Drawing.Size(340,150)
$liBoTest.Text     = ""
$liBoTest.TabIndex = 9
$Form.Controls.Add($liBoTest)

$rtb          = New-Object System.Windows.Forms.RichTextBox
$rtb.Font     = $font
$rtb.Location = New-Object System.Drawing.Point(440,100) 
$rtb.Size     = New-Object System.Drawing.Size(430,140)
$rtb.Text     = ""
$rtb.Multiline = $true 
$rtb.TabIndex = 13
$rtb.Enabled=$false 
$Form.Controls.Add($rtb)


# create ContextMenu
$cntMenu=New-object System.Windows.Forms.ContextMenu 
$cntMenu.MenuItems.Clear()
$mnItem1=New-Object System.Windows.Forms.MenuItem ("&Execute Test")

#$form.Control.Add($cntMenu)
$cntMenu.MenuItems.Add($mnItem1)
$liBoTest.ContextMenu=$cntMenu


$livTestDetail = New-Object system.windows.Forms.ListView
$livTestDetail.Font = $font 
$livTestDetail.location = new-object system.drawing.Point(10,260)
$livTestDetail.Width = $Form.Width - 38
$livTestDetail.Height = $Form.height - $txtUser.Height -$txtEmail.Height - $txtPhone.Height - $liBoTest.Height - 90
$livTestDetail.View='Details'
$livTestDetail.ShowItemToolTips=$true
$livTestDetail.TabIndex=10 
$livTestDetail.Visible=$true  
$Form.controls.Add($livTestDetail)


$txtResult = New-Object System.Windows.Forms.TextBox
$txtResult.Location = New-Object System.Drawing.Point(10,260) 
$txtResult.Width=$livTestDetail.Width
$txtResult.Height=$livTestDetail.Height
$txtResult.Text = ""
$txtResult.TabIndex =11
$txtResult.Visible=$false 
$txtResult.Multiline=$true 
$txtResult.WordWrap=$true 
$txtResult.ScrollBars="Vertical" 

$Form.controls.Add($txtResult)

$Form.Add_Resize({
    if ($this.Width -lt 800) { $this.Width = 800}
    if ($this.Height -lt 500) { $this.Height = 500 }

    <#
    $lblTests.Location=New-Object system.drawing.point(10,10)
    $lblTests.Width=80
    $lblTests.Height=20
    #>

    $liBoTest.Location = New-Object System.Drawing.Point(80,100) 
    $liBoTest.Width = 340
    $liBoTest.Height = 148 

    $rtb.Location = New-Object System.Drawing.Point(440,100)
    $w= $this.Width - $liBoTest.Width -10 - 10 -110
    $h=$liBoTest.Height
    $rtb.Size = New-Object System.Drawing.Size ($w,$h)


    $livTestDetail.location = new-object system.drawing.point(10,260)
    $livTestDetail.Width = $Form.Width - 38
    $livTestDetail.Height = $Form.height - $txtUser.Height -$txtEmail.Height - $txtPhone.Height - $liBoTest.Height - 90 -10

    $txtResult.Width = $livTestDetail.Width
    $txtResult.Height = $livTestDetail.Height


    if ($livTestDetail.Columns.Count > 0)
    {
        $livTestDetail.Columns[0].Width=140
        
        $livTestDetail.Columns[1].Width=$livTestDetail.Width - $livTestDetail.Columns[0].Width

        #write-host $livTestDetail.Columns[1].Width
    }
})



function FillTests
{
    MyIp

    $livTestDetail.Items.Clear()
    $liBoTest.Items.Clear()

    foreach ($xmlNode in $xmlTests.Configs.Test)
    {
        if ($xmlNode.LocalName -eq "Test")
        {

            $liBotest.Items.Add($xmlNode.Name)
        }
    }
}



function FillTestView{

    param
    (
        [Parameter(Mandatory=$true)]
            [string]$Test,
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
    $rtb.Text = "" 


    $Form.Text = "MyIp: " + $Form.Tag.ToString() + " GuiDrivenTest : CheckEndpoint.ps1"
    $Form.Text = " GuiDrivenTest : CheckEndpoint.ps1"

    foreach ($xmlNode in $xmlTests.Configs.Test)
    {

        if (($xmlNode.LocalName -eq "Test") -and ($xmlNode.active -eq "false"))
        {
           continue 
        }

        if (($xmlNode.LocalName -eq "Test") -and ($xmlNode.Name -eq $Test))
        {
            
            $Urlid=$xmlNode.urlId
            $xmlUrlNode=$xmlTests.SelectSingleNode("/Configs/Urls/Url[@id='"+$urlId+"']")
            #write-host $urlId
            #write-host $xmlUrlNode.url

            $lg=new-object System.Windows.Forms.ListViewGroup ($xmlNode.Name + " # " + $xmlUrlNode.url + " # " +$xmlNode.Email + " # " + $xmlNode.userid + "#" +$xmlNode.phone)
            $livTestDetail.Groups.Add($lg) ;


            <# catch showtoken #>
            $xTest = $xmlNode.authid 
            write-host $xTest
            
            $xmlAuthNode=$xmlTests.SelectSingleNode("/Configs/Auths/Auth[@id='"+$xtest+"']")
            write-host $xmlAuthNode.showtoken
            
            $chkToken.Checked = ($xmlAuthNode.showtoken -eq "true") 

            foreach ($endpoint in $xmlNode.Childnodes)
            {
                
                if ($endpoint.LocalName -eq "Contact")
                {

                    $ContactId=$endpoint.id

                    if ($contactID -ne $null)
                    {
                        $Contact = $xmlTests.SelectSingleNode("/Configs/Recipients/Recipient[@id='"+$ContactID+"']").mail 
                    }
                    else
                    {
                        $Contact=""
                    }

                    if($contact -ne "")
                    {
                        $Form.Text = $Form.Text + " / contact : $Contact"  
                    }

                }

                
                if ($endpoint.LocalName -eq "Remark")
                {
                    $rtb.text = $endpoint.Innertext 
                }
               
 
                if ($endpoint.LocalName -eq "Endpoint")
                {               
                
                    $ep=$endpoint.endpoint.ToString()
                    #write-host $ep 
                    $li=New-Object System.Windows.Forms.ListViewItem ($ep) ;
               
                    $cmd=$xmlTests.SelectSingleNode("/Configs/Calls/Call[@id='" + $endpoint.callid +"']").cmd 
                 
                    $cmd=$cmd.Replace("{url}",$xmlUrlNode.url) 
                    $cmd=$cmd.Replace("{endpoint}",$ep)
                
                    <#
                    if($cmd.Substring(30) -match "//")
                    {
                        $pre=$cmd.Substring(0,29)
                        $post=$cmd.substring(30, $cmd.Length -30) 
                        $post = $post.Replace("//","/") 

                        $cmd=$pre + $post 
                    }
                    #>
                    $li.Tag = $cmd
                
                    if ($select -ne "xml")
                    {
                        $cmd=$cmd.Replace("{userid}",$txtuser.Text) ;
                        $cmd=$cmd.Replace("{email}",$txtEmail.Text) ;
                        $cmd=$cmd.Replace("{phone}","'"+$txtPhone.Text+"'") ;
                    }
                    else
                    {
                        $txtUser.text = $xmlNode.userid
                        $txtEmail.text = $xmlNode.email
                        $txtPhone.text = $xmlNode.phone
                
                        $cmd=$cmd.Replace("{userid}",$xmlNode.userid) ;
                        $cmd=$cmd.Replace("{email}",$xmlNode.email) ;
                        $cmd=$cmd.Replace("{phone}","'"+$xmlNode.phone+"'") ;
                    }

                    $li.SubItems.Add($cmd)
                    $li.Group=$lg

                    $livTestDetail.Items.Add($li)
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



$btnReplace.Add_Click({


    $i=$liBoTest.SelectedIndex
    write "btnReplace $i"

    $Test=$liBoTest.Items[$i]

    if ($btnReplace.Tag -eq "xml")
    {
        $btnReplace.Tag ="nxml" 
        $btnReplace.Text = " | use xml given values" 
    }
    else
    {
        $btnReplace.Tag ="xml" 
        $btnReplace.Text = " < use dialog values" 
    }
    FillTestView -test $Test -select $btnReplace.Tag.ToString() 

})



$liBoTest.Add_Click({

   $Test=$this.Items[$this.SelectedIndex]

   FillTestView -test $Test -select $btnReplace.Tag.ToString() 
   
})



$mnItem1.Add_Click({

    write-host "mnuItem"

    <#
    foreach ($xmlNode in $xmlTests.Configs.Test)
    {

        if (($xmlNode.LocalName -eq "Test") -and ($xmlNode.active -eq "false"))
        {
           return  
        }
   }
   #>      

    

    $jsonfile="$Path\logs\result.json"
    del $jsonfile -ErrorAction SilentlyContinue 
    
    $pCmd="powershell.exe"
        
    $email=$txtEmail.Text 
    $userid=$txtUser.Text
    $phone=$txtPhone.Text 
    $name=$liBoTest.Items[$liBoTest.SelectedIndex] 

    

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


    $livTestDetail.Visible=$false
    $txtResult.Visible=$true
    $txtResult.Text ="" 
    $txtResult.font = $font 

    if ((test-path -Path $jsonfile) -eq $true)
    {
        $js=(Get-content -path $jsonfile)  | Out-String | ConvertFrom-Json

        $js.LogFile
    
        if ((test-path -path $js.LogFile) -eq $true)
        {
            $re=Get-Content -path $js.LogFile
    
            foreach ($line in $re)
            { 
                $txtResult.Text = $txtResult.Text + $line + [Environment]::NewLine
            }
        }
    }

})



FillTests


[System.Windows.Forms.Application]::EnableVisualStyles()

[void]$Form.ShowDialog()
$Form.Dispose()