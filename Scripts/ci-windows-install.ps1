Write-Host "$(date) Start build script"-ForegroundColor green

#Invoke-WebRequest "http://beta.unity3d.com/download/a122f5dc316d/Windows64EditorInstaller/UnitySetup64-2018.2.21f1.exe" -OutFile .\UnitySetup64.exe
#Start-Process -FilePath ".\UnitySetup64.exe" -Wait -ArgumentList ('/S', '/Q')

git clone git@github.com:microsoft/unitysetup.powershell.git
cd unitysetup.powershell

# See https://github.com/microsoft/unitysetup.powershell
Install-Module UnitySetup -Scope CurrentUser

# Based on https://github.com/microsoft/unitysetup.powershell/blob/develop/UnitySetup/Examples/Sample_xUnity_Install.ps1
Configuration Sample_xUnity_Install {

    param(
        [PSCredential]$UnityCredential,
        [PSCredential]$UnitySerial
    )

    Import-DscResource -ModuleName UnitySetup

    Node 'localhost' {

        xUnitySetupInstance Unity {
            Versions   = '2018.2.21f1'
            Components = 'Windows', 'Mac', 'Linux', 'UWP', 'iOS', 'Android'
            Ensure     = 'Present'
        }

        xUnityLicense UnityLicense {
            Name = 'UL01'
            Credential = $UnityCredential
            Serial = $UnitySerial
            Ensure = 'Present'
            UnityVersion = '2018.2.21f1'
            DependsOn = '[xUnitySetupInstance]Unity'   
        }
    }
}

$username = $env:UNITY_USERNAME
$password = $env:UNITY_PASSWORD

# Create non-interactive credential object as explained here: https://blogs.msdn.microsoft.com/koteshb/2010/02/12/powershell-how-to-create-a-pscredential-object/
$secure_password = ConvertTo-SecureString $password -AsPlainText -Force
$credentials = New-Object System.Management.Automation.PSCredential ($username, $secure_password)

$serial = $env:UNITY_SERIAL

Sample_xUnity_Install -UnityCredential $username $password -UnitySerial $serial

Write-Host "$(date) Unity Installed"-ForegroundColor green
