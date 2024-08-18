# Tip - How to get the installed Font Famillies

Just a quick tip. 

First load the assembly
````powershell
[System.Reflection.Assembly]::LoadWithPartialName("System.Drawing")

GAC    Version        Location
---    -------        --------
True   v4.0.30319     C:\WINDOWS\Microsoft.Net\assembly\GAC_MSIL\System.Drawing\v4.0_4.0.0.0__b03f5f7f11d50a3a\System.Drawing.dll
````
After this stap there are 3 ways to get the Installed Font Families

## Powershell Way
````powershell
(New-Object System.Drawing.Text.InstalledFontCollection).Families
Name
----
Agency FB
Algerian
AniMe Matrix - MB_EN
Arial
Arial Black
Arial Narrow
Arial Rounded MT Bold
Arial Unicode MS
Bahnschrift
Bahnschrift Condensed
Bahnschrift Light
Bahnschrift Light Condensed
Bahnschrift Light SemiCondensed
Bahnschrift SemiBold
Bahnschrift SemiBold Condensed
Bahnschrift SemiBold SemiConden
Bahnschrift SemiCondensed
Bahnschrift SemiLight
Bahnschrift SemiLight Condensed
Bahnschrift SemiLight SemiConde
Baskerville Old Face
Bauhaus 93
Bell MT
Berlin Sans FB
Berlin Sans FB Demi
Bernard MT Condensed
Blackadder ITC
Bodoni MT
Bodoni MT Black
Bodoni MT Condensed
Bodoni MT Poster Compressed
Book Antiqua
Bookman Old Style
Bookshelf Symbol 7
Bradley Hand ITC
Britannic Bold
Broadway
Brush Script MT
Calibri
Calibri Light
Californian FB
Calisto MT
Cambria
Cambria Math
Candara
Candara Light
Cascadia Code
Cascadia Code ExtraLight
Cascadia Code Light
Cascadia Code SemiBold
Cascadia Code SemiLight
Cascadia Mono
Cascadia Mono ExtraLight
Cascadia Mono Light
Cascadia Mono SemiBold
Cascadia Mono SemiLight
Castellar
Centaur
Century
Century Gothic
Century Schoolbook
Chiller
Colonna MT
Comic Sans MS
Consolas
Constantia
Cooper Black
Copperplate Gothic Bold
Copperplate Gothic Light
Corbel
Corbel Light
Courier New
Curlz MT
Dubai
Dubai Light
Dubai Medium
Ebrima
Edwardian Script ITC
Elephant
Engravers MT
Eras Bold ITC
Eras Demi ITC
Eras Light ITC
Eras Medium ITC
Felix Titling
Footlight MT Light
Forte
Franklin Gothic Book
Franklin Gothic Demi
Franklin Gothic Demi Cond
Franklin Gothic Heavy
Franklin Gothic Medium
Franklin Gothic Medium Cond
Freestyle Script
French Script MT
Gabriola
Gadugi
Garamond
Georgia
Gigi
Gill Sans MT
Gill Sans MT Condensed
Gill Sans MT Ext Condensed Bold
Gill Sans Ultra Bold
Gill Sans Ultra Bold Condensed
Gloucester MT Extra Condensed
Goudy Old Style
Goudy Stout
Haettenschweiler
Harlow Solid Italic
Harrington
High Tower Text
HoloLens MDL2 Assets
Impact
Imprint MT Shadow
Informal Roman
Ink Free
Javanese Text
Jokerman
Juice ITC
Kristen ITC
Kunstler Script
Leelawadee UI
Leelawadee UI Semilight
Lucida Bright
Lucida Calligraphy
Lucida Console
Lucida Fax
Lucida Handwriting
Lucida Sans
Lucida Sans Typewriter
Lucida Sans Unicode
Magneto
Maiandra GD
Malgun Gothic
Malgun Gothic Semilight
Marlett
Matura MT Script Capitals
Microsoft Himalaya
Microsoft JhengHei
Microsoft JhengHei Light
Microsoft JhengHei UI
Microsoft JhengHei UI Light
Microsoft New Tai Lue
Microsoft PhagsPa
Microsoft Sans Serif
Microsoft Tai Le
Microsoft YaHei
Microsoft YaHei Light
Microsoft YaHei UI
Microsoft YaHei UI Light
Microsoft Yi Baiti
MingLiU-ExtB
MingLiU_HKSCS-ExtB
Mistral
Modern No. 20
Mongolian Baiti
Monotype Corsiva
MS Gothic
MS Outlook
MS PGothic
MS Reference Sans Serif
MS Reference Specialty
MS UI Gothic
MT Extra
MV Boli
Myanmar Text
Niagara Engraved
Niagara Solid
Nirmala UI
Nirmala UI Semilight
NSimSun
OCR A Extended
Old English Text MT
Onyx
Palace Script MT
Palatino Linotype
Papyrus
Parchment
Perpetua
Perpetua Titling MT
Playbill
PMingLiU-ExtB
Poor Richard
Pristina
Rage Italic
Ravie
Rockwell
Rockwell Condensed
Rockwell Extra Bold
ROG Fonts
Sans Serif Collection
Script MT Bold
Segoe Fluent Icons
Segoe MDL2 Assets
Segoe Print
Segoe Script
Segoe UI
Segoe UI Black
Segoe UI Emoji
Segoe UI Historic
Segoe UI Light
Segoe UI Semibold
Segoe UI Semilight
Segoe UI Symbol
Segoe UI Variable Display
Segoe UI Variable Display Light
Segoe UI Variable Display Semib
Segoe UI Variable Display Semil
Segoe UI Variable Small
Segoe UI Variable Small Light
Segoe UI Variable Small Semibol
Segoe UI Variable Small Semilig
Segoe UI Variable Text
Segoe UI Variable Text Light
Segoe UI Variable Text Semibold
Segoe UI Variable Text Semiligh
Showcard Gothic
SimSun
SimSun-ExtB
Sitka Banner
Sitka Banner Semibold
Sitka Display
Sitka Display Semibold
Sitka Heading
Sitka Heading Semibold
Sitka Small
Sitka Small Semibold
Sitka Subheading
Sitka Subheading Semibold
Sitka Text
Sitka Text Semibold
Snap ITC
Stencil
Sylfaen
Symbol
Tahoma
Tempus Sans ITC
Times New Roman
Trebuchet MS
Tw Cen MT
Tw Cen MT Condensed
Tw Cen MT Condensed Extra Bold
Verdana
Viner Hand ITC
Vivaldi
Vladimir Script
Webdings
Wide Latin
Wingdings
Wingdings 2
Wingdings 3
Yu Gothic
Yu Gothic Light
Yu Gothic Medium
Yu Gothic UI
Yu Gothic UI Light
Yu Gothic UI Semibold
Yu Gothic UI Semilight

(New-Object System.Drawing.Text.InstalledFontCollection).Families.count
259
````

## .NET Way

````Powershell
([System.Drawing.Text.InstalledFontCollection]::new() ).Families
````

## And alternatives ways using the pipeline, `Select-object` cmdlet and the `ExpandProperty` property

````Powershell
[System.Drawing.Text.InstalledFontCollection]::new() | Select-Object -ExpandProperty Families
# or
New-Object System.Drawing.Text.InstalledFontCollection | Select-Object -ExpandProperty Families
````

## And what about the performance ?

````powershell
Measure-MyScript -Name "Powershell method with pipeline" -Unit ms -Repeat 100 -ScriptBlock {
New-Object System.Drawing.Text.InstalledFontCollection | Select-Object -ExpandProperty Families
}

Measure-MyScript -Name ".NET method with pipeline" -Unit ms -Repeat 100 -ScriptBlock {
[System.Drawing.Text.InstalledFontCollection]::new() | Select-Object -ExpandProperty Families
}
Measure-MyScript -Name ".NET method" -Unit ms -Repeat 100 -ScriptBlock {
([System.Drawing.Text.InstalledFontCollection]::new() ).Families
}

Measure-MyScript -Name "Powershell method" -Unit ms -Repeat 100 -ScriptBlock {
(New-Object System.Drawing.Text.InstalledFontCollection).Families
}

name                            Avg                 Min                 Max                 
----                            ---                 ---                 ---                 
Powershell method with pipeline 0,6252 Milliseconds 0,307 Milliseconds  19,3635 Milliseconds
.NET method with pipeline       0,4361 Milliseconds 0,2634 Milliseconds 10,0761 Milliseconds
.NET method                     0,1564 Milliseconds 0,0555 Milliseconds 8,1997 Milliseconds 
Powershell method               0,4902 Milliseconds 0,2111 Milliseconds 13,9108 Milliseconds
````

>[Nota] : For the performance test, I'm using a function called [Measure-MyScrypt](https://gist.github.com/Rapidhands/e80c921baa08c5506d832e6fed73391b).

Using the pipeline is time consuming, regardless of the method used. The .NET way is fastest (30%).

