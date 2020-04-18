# Scanline Hacks

This set of scripts lets you execute a single PowerShell script to rebind various keys, some of which do not exist as keys on physical keyboards. I personally find this useful as a Push-to-Talk key for software such as [Discord](https://discordapp.com/). As far as I know, Discord does not have the 'discard' capability of Teamspeak, hence this script. The necessary Scancode Map data has been floating on the internet for a while, but people always seem to have trouble interacting with the Registry Editor. I'm hoping these scripts make it easier for people who want an easier-to-access PTT key.

## Usage

First you need to allow PowerShell to execute scripts on your system if you haven't done so. To do this, you need a PowerShell prompt with elevated privileges. Type `powershell` into the Windows taskbar search, and **right click on it**, then select **Run as administrator**.

The UAC prompt will ask you for your consent. Accept and the PowerShell prompt will open.

By default, Windows PowerShell is configured to function in `Restricted`  mode. This means that PowerShell will not load configuration files or run any scripts. You cannot run this script while PowerShell is in *Restricted* mode.

To continue, configure your PowerShell into `Bypass` by typing in the following command:

```
Set-ExecutionPolicy Bypass
```

Now you can execute the scripts in your PowerShell. The script will prompt you for a permission to continue, but the user you run the script on **must have Administrative privileges enabled**. Before committing any changes, the script also offers to generate a System Restore Point for you.

Once you're done, reboot your computer. To restore your PowerShell execution policy back to a safe default, follow the earlier steps and type in the following command to the PowerShell prompt:

```
Set-ExecutionPolicy Restricted
```

## Selecting a Script to Run

 * `RebindCapslock-F13.ps1` Redefines the `[Caps Lock]` key to function as the key `[F13]`.
 * `RebindLeftWin-F13.ps1` Redefines the left `[Windows]` key to function as the key `[F13]`.
 * `RebindPopupKey-F13.ps1` Redefines the contextual popup key found on some keyboards to function as the key `[F13]`.
 * `RebindRightWin-F13.ps1` Redefines the right `[Windows]` key to function as the key `[F13]`.
 * `RemoveScancodeMappings.ps` Removes all current mappings.
