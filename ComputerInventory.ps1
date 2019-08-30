$infoColl = @()
foreach ($s in Get-Content C:\servers.txt){
    $cpuinfo = Get-WmiObject -Class win32_processor -ComputerName $s |select *
    $os=Get-WmiObject -Class Win32_Operatingsystem -ComputerName $s -Property *
    $make=Get-WmiObject -ComputerName $s Win32_Computersystem
    $bb = get-wmiobject win32_operatingsystem
    $build = $bb.ConvertToDateTime($os.InstallDate) -f "MM/dd/yyyy"
    $Numcpu=(Get-WmiObject -ComputerName $s -Class Win32_ComputerSystem ).NumberOfProcessors
    $serial = (Get-WmiObject -ComputerName $s -Class Win32_bios).Serialnumber
    $lic = (Get-WmiObject SoftwareLicensingProduct -ComputerName $s | where PartialProductKey | select Pscomputername,Name,@{Name='LicenseStatus';Exp={ switch ($_.LicenseStatus) { 0 {'Unlicensed'} 1 {'licensed'} 2 {'00BGrace'} 3 {'00TGrace'} 4 {'NonGenuineGrace'} 5 {'Notificaton'} 6 {'ExtendedGrace'} Default {'Undetected'}}}}).LicenseStatus
    foreach($cup in $cpuinfo)
    {
    $infoObject = New-Object PSObject
   Add-Member -inputObject $infoObject -memberType NoteProperty -name "ServerName" -value $make.Name
   Add-Member -inputObject $infoObject -memberType NoteProperty -name "IP Address" -value $s
   Add-Member -inputObject $infoObject -memberType NoteProperty -name "OS_Name" -value $os.caption
   Add-Member -inputObject $infoObject -memberType NoteProperty -name "Service Pack" -value $os.CSDVersion
Add-Member -inputObject $infoObject -memberType NoteProperty -name "Version" -value $os.Version
   Add-Member -inputObject $infoObject -memberType NoteProperty -name "Vendor" -value $make.Manufacturer
   Add-Member -inputObject $infoObject -memberType NoteProperty -name "Model" -value $make.Model
   Add-Member -inputObject $infoObject -memberType NoteProperty -name "Serial Number" -value $serial
   Add-Member -inputObject $infoObject -memberType NoteProperty -name "Buid Date" -value $build
   Add-Member -inputObject $infoObject -memberType NoteProperty -name "OS License status" -value $lic
  $infoObject
  $infoColl += $infoObject
    }
    }
    #$infoColl |Out-GridView
    $infoColl | Export-Csv -path C:\Server_Inventory_$((Get-Date).ToString('MM-dd-yyyy')).csv -NoTypeInformation
 
