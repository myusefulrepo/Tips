# Extract Metadata from .mp3 Files and export in a File

## Foreword
You have thousands, or even tens of thousands, of .mp3 files, and you've noticed that some are missing the metadata you care about.

First, you need to identify these files. A long task, very long indeed. And that's what the script I'm proposing here is supposed to do: collect the metadata of the files you're interested in and export everything to a file (currently .csv) so that you can identify at a glance the files whose metadata needs to be updated.

## how it works ?

- Collect the list of files in a directory and its subdirectories
- Retrieve the metadata for each file
- Export to a file

However, these metadata are not directly visible in the file properties. For this, I use the TagLibSharp library (link in the script).

## Example of recoverable metadata

````powershell
$TagFile.Tag | Get-Member -MemberType Property


   TypeName : TagLib.NonContainer.Tag

Name                       MemberType Definition
----                       ---------- ----------
Album                      Property   string Album {get;set;}
AlbumArtists               Property   string[] AlbumArtists {get;set;}
AlbumArtistsSort           Property   string[] AlbumArtistsSort {get;set;}
AlbumSort                  Property   string AlbumSort {get;set;}
AmazonId                   Property   string AmazonId {get;set;}
Artists                    Property   string[] Artists {get;set;}
BeatsPerMinute             Property   uint32 BeatsPerMinute {get;set;}
Comment                    Property   string Comment {get;set;}
Composers                  Property   string[] Composers {get;set;}
ComposersSort              Property   string[] ComposersSort {get;set;}
Conductor                  Property   string Conductor {get;set;}
Copyright                  Property   string Copyright {get;set;}
DateTagged                 Property   System.Nullable[datetime] DateTagged {get;set;}
Description                Property   string Description {get;set;}
Disc                       Property   uint32 Disc {get;set;}
DiscCount                  Property   uint32 DiscCount {get;set;}
EndTag                     Property   TagLib.NonContainer.EndTag EndTag {get;}
FirstAlbumArtist           Property   string FirstAlbumArtist {get;}
FirstAlbumArtistSort       Property   string FirstAlbumArtistSort {get;}
FirstArtist                Property   string FirstArtist {get;}
FirstComposer              Property   string FirstComposer {get;}
FirstComposerSort          Property   string FirstComposerSort {get;}
FirstGenre                 Property   string FirstGenre {get;}
FirstPerformer             Property   string FirstPerformer {get;}
FirstPerformerSort         Property   string FirstPerformerSort {get;}
Genres                     Property   string[] Genres {get;set;}
Grouping                   Property   string Grouping {get;set;}
InitialKey                 Property   string InitialKey {get;set;}
IsEmpty                    Property   bool IsEmpty {get;}
ISRC                       Property   string ISRC {get;set;}
JoinedAlbumArtists         Property   string JoinedAlbumArtists {get;}
JoinedArtists              Property   string JoinedArtists {get;}
JoinedComposers            Property   string JoinedComposers {get;}
JoinedGenres               Property   string JoinedGenres {get;}
JoinedPerformers           Property   string JoinedPerformers {get;}
JoinedPerformersSort       Property   string JoinedPerformersSort {get;}
Length                     Property   string Length {get;set;}
Lyrics                     Property   string Lyrics {get;set;}
MusicBrainzArtistId        Property   string MusicBrainzArtistId {get;set;}
MusicBrainzDiscId          Property   string MusicBrainzDiscId {get;set;}
MusicBrainzReleaseArtistId Property   string MusicBrainzReleaseArtistId {get;set;}
MusicBrainzReleaseCountry  Property   string MusicBrainzReleaseCountry {get;set;}
MusicBrainzReleaseGroupId  Property   string MusicBrainzReleaseGroupId {get;set;}
MusicBrainzReleaseId       Property   string MusicBrainzReleaseId {get;set;}
MusicBrainzReleaseStatus   Property   string MusicBrainzReleaseStatus {get;set;}
MusicBrainzReleaseType     Property   string MusicBrainzReleaseType {get;set;}
MusicBrainzTrackId         Property   string MusicBrainzTrackId {get;set;}
MusicIpId                  Property   string MusicIpId {get;set;}
Performers                 Property   string[] Performers {get;set;}
PerformersRole             Property   string[] PerformersRole {get;set;}
PerformersSort             Property   string[] PerformersSort {get;set;}
Pictures                   Property   TagLib.IPicture[] Pictures {get;set;}
Publisher                  Property   string Publisher {get;set;}
RemixedBy                  Property   string RemixedBy {get;set;}
ReplayGainAlbumGain        Property   double ReplayGainAlbumGain {get;set;}
ReplayGainAlbumPeak        Property   double ReplayGainAlbumPeak {get;set;}
ReplayGainTrackGain        Property   double ReplayGainTrackGain {get;set;}
ReplayGainTrackPeak        Property   double ReplayGainTrackPeak {get;set;}
StartTag                   Property   TagLib.NonContainer.StartTag StartTag {get;}
Subtitle                   Property   string Subtitle {get;set;}
Tags                       Property   TagLib.Tag[] Tags {get;}
TagTypes                   Property   TagLib.TagTypes TagTypes {get;}
Title                      Property   string Title {get;set;}
TitleSort                  Property   string TitleSort {get;set;}
Track                      Property   uint32 Track {get;set;}
TrackCount                 Property   uint32 TrackCount {get;set;}
Year                       Property   uint32 Year {get;set;}
````
That's quite a number.

That's why in the script below, I have only chosen a few of them. But feel free to modify the code to suit your needs.

````powershell
$Metadata = [PSCustomObject]@{
            FileName    = $File.Name
            Title       = $tagFile.Tag.Title
            Album       = $tagFile.Tag.Album
            Artists     = $tagFile.Tag.Artists -join ', '
            Genre       = $tagFile.Tag.FirstGenre
            TrackNumber = $tagFile.Tag.Track
            TotalTracks = $tagFile.Tag.TrackCount
            DiscNumber  = $tagFile.Tag.Disc
            Year        = $tagFile.Tag.Year
            Duration    = $tagFile.Properties.Duration.ToString()
        }
````


## The script

```powershell
<#
.SYNOPSIS
    Extrait les métadonnées des fichiers MP3 d'un dossier spécifié et les exporte dans un fichier CSV.

.DESCRIPTION
    Ce script utilise la bibliothèque TagLibSharp pour lire les métadonnées des fichiers MP3.
    Il vérifie d'abord si TagLibSharp est installé, l'installe si nécessaire, puis extrait
    les métadonnées suivantes pour chaque fichier MP3 :
    - Nom du fichier
    - Titre
    - Album
    - Artistes
    - Genre
    - Année
    - Durée

.PARAMETER FolderPath
    Chemin du dossier contenant les fichiers MP3 à analyser.
    Ce paramètre est obligatoire.
    Il peut être spécifié sous forme de chemin absolu ou relatif.
    Exemple : 'D:\Musique\Rock' ou 'C:\Users\Utilisateur\Documents\MP3'
    Si le chemin spécifié n'existe pas, le script renverra une erreur.
    valeur par défaut : 'D:\MP3\'

.PARAMETER OutputFile
    Chemin du fichier CSV de sortie où seront stockées les métadonnées.
    Valeur par défaut : 'C:\Temp\Metadata.csv'
    Si le dossier de sortie n'existe pas, il sera créé automatiquement.

.PARAMETER TagLibSharpPath
    Chemin d'installation de la bibliothèque TagLibSharp.
    Valeur par défaut : 'C:\Program Files (x86)\TagLibSharp'

.PARAMETER NuGetPath
    Chemin d'installation de NuGet.
    Valeur par défaut : 'C:\Program Files (x86)\NuGet'

.PARAMETER TagLibSharpVersion
    Version de TagLibSharp à installer.
    Valeur par défaut : '2.3.0'
    Si la version spécifiée n'est pas disponible, le script renverra une erreur.

.EXAMPLE
    .\MP3_folder_path.ps1 -FolderPath "D:\MP3\ACDC"
    Extrait les métadonnées des fichiers MP3 du dossier "D:\MP3\ACDC" et les exporte dans le fichier "C:\Temp\Metadata.csv". (valeur par défaut)

.EXAMPLE
    .\MP3_folder_path.ps1 -FolderPath "D:\Musique\Rock" -OutputFile "C:\Temp\Metadata_Rock.csv"
    Extrait les métadonnées des fichiers MP3 du dossier "D:\Musique\Rock" et les exporte dans le fichier "C:\Temp\Metadata_Rock.csv".

.EXAMPLE
    .\MP3_folder_path.ps1 -FolderPath "D:\MP3\ACDC" 
    Extrait les métadonnées des fichiers MP3 du dossier "D:\MP3\ACDC" et les exporte dans le fichier "C:\Temp\Metadata_ACDC.csv".

.EXAMPLE
    Get-Help .\MP3_folder_path.ps1 -ShowWindow
    Affiche la documentation du script dans une fenêtre d'aide.

.NOTES
    Auteur: O. FERRIERE
    Date de création: 2025/04/28
    Version: 1.0
    Prérequis: Windows PowerShell 5.1 ou ultérieur
    Bibliothèque TagLibSharp (installée automatiquement si nécessaire)
    NuGet (installé automatiquement si nécessaire)
    Ce script est fourni tel quel, sans garantie d'aucune sorte.
    L'utilisation de ce script est à vos propres risques.
    Veuillez tester dans un environnement de développement avant de l'utiliser en production.
    Changements : V1.0 - 2025/04/28 - Création du script

    // TODO 
         : Ajouter la possibilité de choisir les propriétés à exporter
         : Ajouter la possibilité de choisir le format d'export (CSV, JSON, XML)

#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true,
        Position = 0,
        ValueFromPipeline = $true,
        ValueFromPipelineByPropertyName = $true,
        HelpMessage = 'Chemin du dossier contenant les fichiers MP3')]
    [ValidateScript({
            if (Test-Path $_)
            {
                if ((Get-Item $_).PSIsContainer)
                {
                    return $true 
                }
                throw 'Le chemin doit pointer vers un dossier.'
            }
            throw "Le chemin n'existe pas."
        })]
    [string]$FolderPath = 'D:\MP3\',

    [Parameter(Mandatory = $false,
        Position = 1,
        HelpMessage = 'Chemin du fichier CSV de sortie')]
    [string]$OutputFile = 'c:\temp\MP3_Metadata.csv',

    [Parameter(Mandatory = $false)]
    [string]$TagLibSharpPath = 'C:\Program Files (x86)\TagLibSharp',

    [Parameter(Mandatory = $false)]
    [string]$NuGetPath = 'C:\Program Files (x86)\NuGet',

    [Parameter(Mandatory = $false)]
    [string]$TagLibSharpVersion = '2.3.0'
)

# Création du dossier de sortie si nécessaire
$OutputDirectory = Split-Path -Parent $OutputFile
if (-not (Test-Path $OutputDirectory))
{
    New-Item -ItemType Directory -Path $OutputDirectory -Force | Out-Null
}

# Collecter la liste des fichiers mp3
$Files = Get-ChildItem -Path $FolderPath -Filter *.mp3 -Recurse

# Vérification et installation de TagLibSharp si nécessaire
if (-not (Test-Path "$TagLibSharpPath\TagLibSharp.dll"))
{
    Write-Verbose 'TagLibSharp library not found. Starting installation...'
    
    # Installation de NuGet si nécessaire
    $nugetExePath = Join-Path $NuGetPath 'NuGet.exe'
    if (-not (Test-Path $nugetExePath))
    {
        Write-Verbose "NuGet n'est pas installé. Téléchargement et installation."
        New-Item -ItemType Directory -Path $NuGetPath -Force | Out-Null
        $nugetUrl = 'https://dist.nuget.org/win-x86-commandline/latest/nuget.exe'
        Invoke-WebRequest -Uri $nugetUrl -OutFile $nugetExePath
    }

    # Installation de TagLibSharp
    New-Item -ItemType Directory -Path $TagLibSharpPath -Force | Out-Null
    $url = "https://www.nuget.org/api/v2/package/TagLibSharp/$TagLibSharpVersion"
    $outputPath = "$TagLibSharpPath\TagLibSharp.$TagLibSharpVersion.nupkg"
    
    try
    {
        Invoke-WebRequest -Uri $url -OutFile $outputPath
        Expand-Archive -Path $outputPath -DestinationPath $TagLibSharpPath -Force
        Copy-Item -Path "$TagLibSharpPath\lib\net462\TagLibSharp.dll" -Destination "$TagLibSharpPath\TagLibSharp.dll" -Force
    }
    catch
    {
        Write-Error "Erreur lors de l'installation de TagLibSharp: $_"
        return
    }
}

# Chargement de la DLL TagLibSharp
try
{
    Add-Type -Path "$TagLibSharpPath\TagLibSharp.dll"
}
catch
{
    Write-Error "Impossible de charger TagLibSharp: $_"
    return
}

# Traitement des fichiers MP3
$MetadataList = @()
foreach ($File in $Files)
{
    try
    {
        $tagFile = [TagLib.File]::Create($File.FullName)
        <#
        $TagFile.Tag | Get-Member -MemberType Property


   TypeName : TagLib.NonContainer.Tag

Name                       MemberType Definition
----                       ---------- ----------
Album                      Property   string Album {get;set;}
AlbumArtists               Property   string[] AlbumArtists {get;set;}
AlbumArtistsSort           Property   string[] AlbumArtistsSort {get;set;}
AlbumSort                  Property   string AlbumSort {get;set;}
AmazonId                   Property   string AmazonId {get;set;}
Artists                    Property   string[] Artists {get;set;}
BeatsPerMinute             Property   uint32 BeatsPerMinute {get;set;}
Comment                    Property   string Comment {get;set;}
Composers                  Property   string[] Composers {get;set;}
ComposersSort              Property   string[] ComposersSort {get;set;}
Conductor                  Property   string Conductor {get;set;}
Copyright                  Property   string Copyright {get;set;}
DateTagged                 Property   System.Nullable[datetime] DateTagged {get;set;}
Description                Property   string Description {get;set;}
Disc                       Property   uint32 Disc {get;set;}
DiscCount                  Property   uint32 DiscCount {get;set;}
EndTag                     Property   TagLib.NonContainer.EndTag EndTag {get;}
FirstAlbumArtist           Property   string FirstAlbumArtist {get;}
FirstAlbumArtistSort       Property   string FirstAlbumArtistSort {get;}
FirstArtist                Property   string FirstArtist {get;}
FirstComposer              Property   string FirstComposer {get;}
FirstComposerSort          Property   string FirstComposerSort {get;}
FirstGenre                 Property   string FirstGenre {get;}
FirstPerformer             Property   string FirstPerformer {get;}
FirstPerformerSort         Property   string FirstPerformerSort {get;}
Genres                     Property   string[] Genres {get;set;}
Grouping                   Property   string Grouping {get;set;}
InitialKey                 Property   string InitialKey {get;set;}
IsEmpty                    Property   bool IsEmpty {get;}
ISRC                       Property   string ISRC {get;set;}
JoinedAlbumArtists         Property   string JoinedAlbumArtists {get;}
JoinedArtists              Property   string JoinedArtists {get;}
JoinedComposers            Property   string JoinedComposers {get;}
JoinedGenres               Property   string JoinedGenres {get;}
JoinedPerformers           Property   string JoinedPerformers {get;}
JoinedPerformersSort       Property   string JoinedPerformersSort {get;}
Length                     Property   string Length {get;set;}
Lyrics                     Property   string Lyrics {get;set;}
MusicBrainzArtistId        Property   string MusicBrainzArtistId {get;set;}
MusicBrainzDiscId          Property   string MusicBrainzDiscId {get;set;}
MusicBrainzReleaseArtistId Property   string MusicBrainzReleaseArtistId {get;set;}
MusicBrainzReleaseCountry  Property   string MusicBrainzReleaseCountry {get;set;}
MusicBrainzReleaseGroupId  Property   string MusicBrainzReleaseGroupId {get;set;}
MusicBrainzReleaseId       Property   string MusicBrainzReleaseId {get;set;}
MusicBrainzReleaseStatus   Property   string MusicBrainzReleaseStatus {get;set;}
MusicBrainzReleaseType     Property   string MusicBrainzReleaseType {get;set;}
MusicBrainzTrackId         Property   string MusicBrainzTrackId {get;set;}
MusicIpId                  Property   string MusicIpId {get;set;}
Performers                 Property   string[] Performers {get;set;}
PerformersRole             Property   string[] PerformersRole {get;set;}
PerformersSort             Property   string[] PerformersSort {get;set;}
Pictures                   Property   TagLib.IPicture[] Pictures {get;set;}
Publisher                  Property   string Publisher {get;set;}
RemixedBy                  Property   string RemixedBy {get;set;}
ReplayGainAlbumGain        Property   double ReplayGainAlbumGain {get;set;}
ReplayGainAlbumPeak        Property   double ReplayGainAlbumPeak {get;set;}
ReplayGainTrackGain        Property   double ReplayGainTrackGain {get;set;}
ReplayGainTrackPeak        Property   double ReplayGainTrackPeak {get;set;}
StartTag                   Property   TagLib.NonContainer.StartTag StartTag {get;}
Subtitle                   Property   string Subtitle {get;set;}
Tags                       Property   TagLib.Tag[] Tags {get;}
TagTypes                   Property   TagLib.TagTypes TagTypes {get;}
Title                      Property   string Title {get;set;}
TitleSort                  Property   string TitleSort {get;set;}
Track                      Property   uint32 Track {get;set;}
TrackCount                 Property   uint32 TrackCount {get;set;}
Year                       Property   uint32 Year {get;set;}

Ci-dessus, vous pouvez voir les propriétés disponibles dans l'objet Tag.
        # Pour plus d'informations sur les propriétés, consultez la documentation de TagLibSharp.

Ceci est fourni a titre d'exemple afin d'aider à déterminer les propriétés qui vous intéressent. Vous pouvez ce propriétés ci-après 
#>

        $Metadata = [PSCustomObject]@{
            FileName    = $File.Name
            Title       = $tagFile.Tag.Title
            Album       = $tagFile.Tag.Album
            Artists     = $tagFile.Tag.Artists -join ', '
            Genre       = $tagFile.Tag.FirstGenre
            TrackNumber = $tagFile.Tag.Track
            TotalTracks = $tagFile.Tag.TrackCount
            DiscNumber  = $tagFile.Tag.Disc
            Year        = $tagFile.Tag.Year
            Duration    = $tagFile.Properties.Duration.ToString()
        }
        
        $MetadataList += $Metadata
        ## Libération des ressources
        $tagFile.Dispose()
    }
    catch
    {
        Write-Warning "Erreur lors du traitement du fichier $($File.Name): $_"
        continue
    }
}

# Export des métadonnées
try
{
    $MetadataList | Export-Csv -Path $OutputFile -NoTypeInformation -Encoding UTF8
    Write-Host "Métadonnées exportées avec succès dans $OutputFile"
}
catch
{
    Write-Error "Erreur lors de l'export du fichier CSV: $_"
}
````

## Conclusion

This script allows you to easily extract metadata from your .mp3 files and export it to a .csv file. You can then use this file to identify files whose metadata needs to be updated.

Feel free to adapt the script to your needs and add other properties as needed. If you have any questions or suggestions, please share them.

The script is self-documented, so you can use the `Get-Help` command to get more information about its usage and parameters. Sorry, for the french comments, but I think you can understand them. If you need a translation, please let me know.


