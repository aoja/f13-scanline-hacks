# MIT License

# Copyright (c) 2018-2020 Antti J. Oja <a.oja@outlook.com>

# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.


# Get the ID and security principal of the current user account
$myWindowsID = [System.Security.Principal.WindowsIdentity]::GetCurrent();
$myWindowsPrincipal = New-Object System.Security.Principal.WindowsPrincipal($myWindowsID);

# Get the security principal for the administrator role
$adminRole = [System.Security.Principal.WindowsBuiltInRole]::Administrator;

# Check to see if we are currently running as an administrator
if ($myWindowsPrincipal.IsInRole($adminRole))
{
    # We are running as an administrator, so change the title and background colour to indicate this
    $Host.UI.RawUI.WindowTitle = $myInvocation.MyCommand.Definition + "(Elevated)";
    $Host.UI.RawUI.BackgroundColor = "DarkBlue";
    Clear-Host;
}
else
{
    # We are not running as an administrator, so relaunch as administrator

    # Create a new process object that starts PowerShell
    $newProcess = New-Object System.Diagnostics.ProcessStartInfo "PowerShell";

    # Specify the current script path and name as a parameter with added scope and support for scripts with spaces in it's path
    $newProcess.Arguments = "& '" + $script:MyInvocation.MyCommand.Path + "'"

    # Indicate that the process should be elevated
    $newProcess.Verb = "runas";

    # Start the new process
    [System.Diagnostics.Process]::Start($newProcess);

    # Exit from the current, unelevated, process
    Exit;
}

# Set up the message labels
$message = "IMPORTANT"
$question = "Would you like a system restore point generated before proceeding?"

# Set up the choice for generating a System Restore point before continuing
$choices = New-Object Collections.ObjectModel.Collection[Management.Automation.Host.ChoiceDescription]
$choices.Add((New-Object Management.Automation.Host.ChoiceDescription -ArgumentList "&Yes", "Generates a system restore point before proceeding."))
$choices.Add((New-Object Management.Automation.Host.ChoiceDescription -ArgumentList "&No", "Proceeds without generating a system restore point."))

# Present the choice
$decision = $Host.UI.PromptForChoice($message, $question, $choices, 0)

if ($decision -eq 0)
{
    # The user selected 'yes'

    # Generate the restore point with the selected tags
    Checkpoint-Computer -Description "Rebind Caps Lock to F13" -RestorePointType MODIFY_SETTINGS
}

# Registry path, key name and the data to write
$registryPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Keyboard Layout"
$keyName = "Scancode Map"
$valueString = "00,00,00,00,00,00,00,00,02,00,00,00,64,00,3a,00,00,00,00,00"

# Prepend all the values in $value with '0x'
$keyData = $valueString.Split(',') | % { "0x$_" }

if (!(Test-Path $registryPath))
{
    # Key was not discovered. Something is seriously wrong with the registry
    Write-Host $registryPath "was not found in the registry. Something is wrong with the Windows installation. Aborting..."
}
else
{
    # Key was discovered. Now probe for the property "Scancode Map"

    if (Get-ItemProperty -Path $registryPath -Name $keyName -ErrorAction 'silentlycontinue')
    {
        # "Scancode Map" already exists

        # Set up the message labels
        $message = "IMPORTANT"
        $question = "Scancode Map already has a value assigned to it. This means that there are potential mappings in place. Would you like to overwrite?"

        # Set up the choices
        $choices = New-Object Collections.ObjectModel.Collection[Management.Automation.Host.ChoiceDescription]
        $choices.Add((New-Object Management.Automation.Host.ChoiceDescription -ArgumentList "&Overwrite", "Overwrites the current Scancode mapping."))
        $choices.Add((New-Object Management.Automation.Host.ChoiceDescription -ArgumentList "&Cancel", "No changes will be written to the registry."))

        # Present the choice
        $decision = $Host.UI.PromptForChoice($message, $question, $choices, 0)

        if ($decision -eq 0)
        {
            # The user selected 'overwrite'
            Set-ItemProperty -Path $registryPath -Name $keyName -Value ([byte[]] $keyData)

            # Write the instructionary closing message
            Write-Host "Changes done! Please reboot your computer for the changes to take effect."
        }
    }
    else
    {
        # "Scancode Map" doesn't exist
        New-ItemProperty -Path $registryPath -Name $keyName -PropertyType Binary -Value ([byte[]] $keyData)

        # Write the instructionary closing message
        Write-Host "Changes done! Please reboot your computer for the changes to take effect."
    }
}

# Wait for any key to be pressed at the end so the shell won't just vanish
Write-Host "Press any key to continue...";
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown");
