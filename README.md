# Wine Builder

These scripts may be useful for someone.  

Use a Docker image to build and patch Wine.

```
make wine
```

When this script has run successfully you will have a wine directory which contains everything wine needs to run.

## Extract League of Legends Installer .exe to a local directory

```
Local installer :

make league exe="LeagueOfLegendsInstaller.exe"

Download over http :

make league exe="http://l3cdn.riotgames.com/releases/live/installer/League%20of%20Legends%20installer%20EUW.exe"
```

When this script has run successfully you will have a LoL_installed directory.


