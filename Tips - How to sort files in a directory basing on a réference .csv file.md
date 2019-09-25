# THE CASE
We have thousands images in a folder.
Each image is classified into a specific type (diagnosis, named dx in the input file) and classified in the Excel file. This specific type defined the name of the file.

## The goal is :

How to sort these images in the folder in groups so that each group of images have the same specific Type.

## This question was originally posted on :

https://superuser.com/questions/1485722/how-do-i-find-images-based-on-their-numbers-in-the-excel-file/1485788#1485788

# THE APPROACH FOR THIS CASE
I proposed the following approach, and perhaps it could be useful for someone else, then i post this as a tips


````powershell
# Define some variables
$BasedImages = "\\path\to\ImagesDirectory"
$Csvfile = "\\path\to\InputCsvFile.csv"

# Gather all sub-folders in the Images Directory (only first level) and put the name of these folder in a var. The only property useful for later use is the Directory name. Useless to gather all properties
$ExistingSubDir = Get-ChildItem -Path $BasedImages -Directory | Select-Object -Property name

# Gather unique diagnosis in the input file and put in a var. The only useful property in the dx property for a later use. Useless to collect more info.
$UniqueDiagnosis = Import-Csv -Path $Csvfile | Select-Object -property dx -Unique

# gather all images files FullName in the Images Directory and put in a var. it seems that only  Name,DirectoryName, FullName properties will be useful for later use
$AllImagesFiles = Get-ChildItem -Path $BasedImages -File | Select-Object -Property Name, DirectoryName FullName

#region First Step : build a Tree with sub-folders named by the unique Diagnosis name.
foreach ($Diagnosis in $UniqueDiagnosis)
    {
    # search if a diagnosis dir name (dx field in the input .csv file) exist in the ImageDirectory and put the result in a var
    if ($ExistingSubDir -contains $Diagnosis)
        {
        Write-Host "$ExistingSubDir is still existing, no action at this step" -ForegroundColor Green
        }
    else
        {
        New-Item -Path $BasedImages -Name $Diagnosis -ItemType Directory
        Write-Host "a sub-directory named $Diagnosis has been created in the folder $BasedImages" -ForegroundColor Yellow
        }
    }
#endregion

# At this step, you'll have some sub directories named with the name of all diagnosis (fied dx in the input file)
#region Step 2 : Time to move the files in the root folder
foreach ($image in $AllImagesFiles)
    {
    $TargetSubDir = Get-Item -Path $($image.fullName)
    Move-Item -Path $($Image.FullName) -Destination ( Join-Path -Path (Split-Path -Path $($Image.DirectoryName) -Parent) -ChildPath $TargetSubDir)
    Write-Host "the image named $($image.name) has been moved to the sud directory $TargetSubDir" -ForegroundColor Green
    }
#endregion
````
