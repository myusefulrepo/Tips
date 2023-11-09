# Display Month, Days in Culture
- [Display Month, Days in Culture](#display-month-days-in-culture)
  - [Preface](#preface)
  - [1. Display month names in the current Culture](#1-display-month-names-in-the-current-culture)
  - [2. Display abbreviated month names in the current Culture](#2-display-abbreviated-month-names-in-the-current-culture)
  - [3. Display day names in the current Culture](#3-display-day-names-in-the-current-culture)
  - [4. Display abbreviated day names in the current Culture](#4-display-abbreviated-day-names-in-the-current-culture)
  - [5. Display 1st letter of days in the current culture](#5-display-1st-letter-of-days-in-the-current-culture)
  - [6. Display month names in another Culture](#6-display-month-names-in-another-culture)
  - [7. Display abbreviated month names in another Culture](#7-display-abbreviated-month-names-in-another-culture)
  - [8. Display abbreviated day names in another Culture](#8-display-abbreviated-day-names-in-another-culture)
  - [9. Display abbreviated day names in another culture](#9-display-abbreviated-day-names-in-another-culture)
  - [10. Display first letter of day in another culture](#10-display-first-letter-of-day-in-another-culture)
  - [11. Get the current culture info](#11-get-the-current-culture-info)
  - [12. Change the Culture](#12-change-the-culture)
  - [13. List all available cultures](#13-list-all-available-cultures)
  - [Last words](#last-words)


## Preface
Month and Day names are in a `[Enum]`. You could enumerate them. 


## 1. Display month names in the current Culture

````powershell
1..12 | ForEach-Object -process {(Get-Culture).DateTimeFormat.GetMonthName($_)}
````

````output
janvier
février
mars
avril
mai
juin
juillet
août
septembre
octobre
novembre
décembre
````

**Explanations** : We use the property `DateTimeFormat` of `Get-Culture` cmdlet and then we use a method called `GetMonthName()`.


## 2. Display abbreviated month names in the current Culture

````powershell
1..12 | ForEach-Object -process {(Get-Culture).DateTimeFormat.GetAbbreviatedMonthName($_)}
````

````output
janv.
févr.
mars
avr.
mai
juin
juil.
août
sept.
oct.
nov.
déc.
````

## 3. Display day names in the current Culture

````Powershell
0..6 | ForEach-Object -process {(Get-Culture).DateTimeFormat.GetdayName($_)}
````

````output
dimanche
lundi
mardi
mercredi
jeudi
vendredi
samedi
````

>[**Keep in Mind**] A week starts on Sunday.

## 4. Display abbreviated day names in the current Culture

````powershell
0..6 | ForEach-Object -process {(Get-Culture).DateTimeFormat.GetAbbreviatedDayName($_)}
````

````Output
dim.
lun.
mar.
mer.
jeu.
ven.
sam.
````

## 5. Display 1st letter of days in the current culture

````powershell
0..6 | ForEach-Object -process {(Get-Culture).DateTimeFormat.GetshortestdayName($_)}
````

````output
di
lu
ma
me
je
ve
sa
````

## 6. Display month names in another Culture

````powershell
$Culture = 'en-us' # here, I choose 'En-US' culture
1..12 | ForEach-Object -process {[cultureinfo]::GetCultureInfo($Culture).DateTimeFormat.GetMonthName($_)}
````
````output
January
February
March
April
May
June
July
August
September
October
November
December
````
>[Nota] The current culture is not changed, only the display.

````Powershell
# eg of use
$Culture = 'en-us' # here, I choose 'En-US' culture
# Gathering Month Names in this specific culture and put the result in a var
$MonthNames = 1..12 | ForEach-Object -process {[cultureinfo]::GetCultureInfo($Culture).DateTimeFormat.GetMonthName($_)}
# Gathering a specific month name. Here, "March". This is the 3rd member of the array. Remember that an array begins by 0.
$MonthNames[2]
March
````

## 7. Display abbreviated month names in another Culture

````powershell
1..12 | ForEach-Object -process {[cultureinfo]::GetCultureInfo($Culture).DateTimeFormat.GetAbbreviatedMonthName($_)}
````

````ouput
Jan
Feb
Mar
Apr
May
Jun
Jul
Aug
Sep
Oct
Nov
Dec
````

## 8. Display abbreviated day names in another Culture
````powershell
0..6 | ForEach-Object -process {[cultureinfo]::GetCultureInfo($Culture).DateTimeFormat.GetdayName($_)}
````

````Output
Sunday
Monday
Tuesday
Wednesday
Thursday
Friday
Saturday
````

## 9. Display abbreviated day names in another culture

````Powershell
$Culture = 'en-us' # here, I choose 'En-US' culture
0..6 | ForEach-Object -process {[cultureinfo]::GetCultureInfo($Culture).DateTimeFormat.GetAbbreviatedDayName($_)}
````

````output
Sun
Mon
Tue
Wed
Thu
Fri
Sat
````

## 10. Display first letter of day in another culture
````powershell
$Culture = 'en-us' # here, I choose 'En-US' culture
0..6 | ForEach-Object -process {[cultureinfo]::GetCultureInfo($Culture).DateTimeFormat.GetshortestdayName($_)}
````

````output
Su
Mo
Tu
We
Th
Fr
Sa
````

## 11. Get the current culture info

````Powershell
[cultureinfo]::CurrentCulture
# Or
Get-Culture

LCID             Name             DisplayName
----             ----             -----------
1036             fr-FR            Français (France)
````

## 12. Change the Culture
````powershell
[cultureinfo]::CurrentCulture = 'en-us'
# or (work with Windows Powershell 5.1 and Powershell 7.x)
Set-Culture

# and show the culture in use
[cultureinfo]::CurrentCulture # Get-Culture

LCID             Name             DisplayName
----             ----             -----------
1033             en-US            anglais (États-Unis)
````

>[**Important**] `Set-Culture` persistently changes the current user's culture system-wide. But, this only takes effect in future PowerShell sessions (processes), so you'll have to open a new PowerShell console window, for instance, for the change to take effect.
See [this link](https://stackoverflow.com/questions/60266401/powershell-how-to-set-culture) for more info.


## 13. List all available cultures

````Powershell
[System.Globalization.CultureInfo]::GetCultures([System.Globalization.CultureTypes]::AllCultures)

# or a shorter way (with the same output) using the accelerator [CultureInfo]
[cultureinfo]::GetCultures('SpecificCultures')

# or with PS 7.x only
Get-Culture -ListAvailable
````

````output
LCID             Name             DisplayName
----             ----             -----------
127                               Langue indifférente (Pays indifférent)
4096             aa               Afar
4096             aa-DJ            Afar (Djibouti)
4096             aa-ER            Afar (Érythrée)
4096             aa-ET            Afar (Éthiopie)
54               af               Afrikaans
4096             af-NA            Afrikaans (Namibie)
1078             af-ZA            Afrikaans (Afrique du Sud)
4096             agq              Aghem
4096             agq-CM           Aghem (Cameroun)
4096             ak               Akan
4096             ak-GH            Akan (Ghana)
94               am               Amharique
1118             am-ET            Amharique (Éthiopie)
1                ar               Arabe
4096             ar-001           Arabe (International)
14337            ar-AE            Arabe (E.A.U.)
15361            ar-BH            Arabe (Bahreïn)
4096             ar-DJ            Arabe (Djibouti)
5121             ar-DZ            Arabe (Algérie)
3073             ar-EG            Arabe (Égypte)
4096             ar-ER            Arabe (Érythrée)
4096             ar-IL            Arabe (Israël)
2049             ar-IQ            Arabe (Irak)
11265            ar-JO            Arabe (Jordanie)
4096             ar-KM            Arabe (Comores)
13313            ar-KW            Arabe (Koweït)
12289            ar-LB            Arabe (Liban)
4097             ar-LY            Arabe (Libye)
6145             ar-MA            Arabe (Maroc)
4096             ar-MR            Arabe (Mauritanie)
8193             ar-OM            Arabe (Oman)
4096             ar-PS            Arabe (Autorité palestinienne)
16385            ar-QA            Arabe (Qatar)
1025             ar-SA            Arabe (Arabie saoudite)
4096             ar-SD            Arabe (Soudan)
4096             ar-SO            Arabe (Somalie)
4096             ar-SS            Arabe (Soudan du Sud)
10241            ar-SY            Arabe (Syrie)
4096             ar-TD            Arabe (Tchad)
7169             ar-TN            Arabe (Tunisie)
9217             ar-YE            Arabe (Yémen)
122              arn              Mapuche
1146             arn-CL           Mapuche (Chili)
77               as               Assamais
1101             as-IN            Assamais (Inde)
4096             asa              Asu
4096             asa-TZ           Asu (Tanzanie)
4096             ast              Asturien
4096             ast-ES           Asturien (Espagne)
44               az               Azerbaïdjanais
29740            az-Cyrl          Azerbaïdjanais (cyrillique)
2092             az-Cyrl-AZ       Azerbaïdjanais (cyrillique, Azerbaïdjan)
30764            az-Latn          Azerbaïdjanais (latin)
1068             az-Latn-AZ       Azerbaïdjanais (latin, Azerbaïdjan)
109              ba               Bachkir
1133             ba-RU            Bachkir (Russie)
4096             bas              Basaa
4096             bas-CM           Basaa (Cameroun)
35               be               Biélorusse
1059             be-BY            Biélorusse (Bélarus)
4096             bem              Bemba
4096             bem-ZM           Bemba (Zambie)
4096             bez              Bena
4096             bez-TZ           Bena (Tanzanie)
2                bg               Bulgare
1026             bg-BG            Bulgare (Bulgarie)
102              bin              Édo
1126             bin-NG           Édo (Nigeria)
4096             bm               Bambara
4096             bm-Latn          Bambara (Latin)
4096             bm-Latn-ML       Bambara (Latin, Mali)
69               bn               Bengali
2117             bn-BD            Bengali (Bangladesh)
1093             bn-IN            Bengali (Inde)
81               bo               Tibétain
1105             bo-CN            Tibétain (RPC)
4096             bo-IN            Tibétain (Inde)
126              br               Breton
1150             br-FR            Breton (France)
4096             brx              Bodo
4096             brx-IN           Bodo (Inde)
30746            bs               Bosniaque
25626            bs-Cyrl          Bosniaque (cyrillique)
8218             bs-Cyrl-BA       Bosniaque (cyrillique, Bosnie-Herzégovine)
26650            bs-Latn          Bosniaque (latin)
5146             bs-Latn-BA       Bosniaque (latin, Bosnie-Herzégovine)
4096             byn              Blin
4096             byn-ER           Blin (Érythrée)
3                ca               Catalan
4096             ca-AD            Catalan (Andorre)
1027             ca-ES            catalan (catalan)
2051             ca-ES-valencia   Valencien (Espagne)
4096             ca-FR            Catalan (France)
4096             ca-IT            Catalan (Italie)
4096             ccp              Chakma
4096             ccp-Cakm         Chakma (Chakma)
4096             ccp-Cakm-BD      Chakma (Chakma, Bangladesh)
4096             ccp-Cakm-IN      Chakma (Chakma, Inde)
4096             ce               Tchétchène
4096             ce-RU            Tchétchène (Russie)
4096             ceb              Cebuano
4096             ceb-Latn         Cebuano (latin)
4096             ceb-Latn-PH      Cebuano (latin, Philippines)
4096             cgg              Chiga
4096             cgg-UG           Chiga (Ouganda)
92               chr              Cherokee
31836            chr-Cher         Cherokee (Cherokee)
1116             chr-Cher-US      Cherokee (Cherokee)
131              co               Corse
1155             co-FR            Corse (France)
5                cs               Tchèque
1029             cs-CZ            Tchèque (République tchèque)
4096             cu               Slave
4096             cu-RU            Slave (Russie)
82               cy               Gallois
1106             cy-GB            Gallois (Royaume-Uni)
6                da               Danois
1030             da-DK            Danois (Danemark)
4096             da-GL            Danois (Groenland)
4096             dav              Taita
4096             dav-KE           Taita (Kenya)
7                de               Allemand
3079             de-AT            Allemand (Autriche)
4096             de-BE            Allemand (Belgique)
2055             de-CH            Allemand (Suisse)
1031             de-DE            Allemand (Allemagne)
4096             de-IT            Allemand (Italie)
5127             de-LI            Allemand (Liechtenstein)
4103             de-LU            Allemand (Luxembourg)
4096             dje              Zarma
4096             dje-NE           Zarma (Niger)
4096             doi              Dogri
4096             doi-Deva         Dogri (Devanagari)
4096             doi-Deva-IN      Dogri (Devanagari, Inde)
31790            dsb              Bas sorabe
2094             dsb-DE           Bas sorabe (Allemagne)
4096             dua              Duala
4096             dua-CM           Duala (Cameroun)
101              dv               Maldivien
1125             dv-MV            Maldivien (Maldives)
4096             dyo              Jola-Fonyi
4096             dyo-SN           Jola-Fonyi (Sénégal)
4096             dz               Dzongkha
3153             dz-BT            Dzongkha (Bhoutan)
4096             ebu              Embu
4096             ebu-KE           Embu (Kenya)
4096             ee               Ewe
4096             ee-GH            Ewe (Ghana)
4096             ee-TG            Ewe (Togo)
8                el               Grec
4096             el-CY            Grec (Chypre)
1032             el-GR            Grec (Grèce)
9                en               Anglais
4096             en-001           Anglais (International)
9225             en-029           Anglais (Caraïbes)
4096             en-150           Anglais (Europe)
19465            en-AE            Anglais (Émirats Arabes Unis)
4096             en-AG            Anglais (Antigua-et-Barbuda)
4096             en-AI            Anglais (Anguilla)
4096             en-AS            Anglais (Samoa américaines)
4096             en-AT            Anglais (Autriche)
3081             en-AU            Anglais (Australie)
4096             en-BB            Anglais (Barbade)
4096             en-BE            Anglais (Belgique)
4096             en-BI            Anglais (Burundi)
4096             en-BM            Anglais (Bermudes)
4096             en-BS            Anglais (Bahamas)
4096             en-BW            Anglais (Botswana)
10249            en-BZ            Anglais (Belize)
4105             en-CA            Anglais (Canada)
4096             en-CC            Anglais (Îles Cocos [Keeling])
4096             en-CH            Anglais (Suisse)
4096             en-CK            Anglais (Îles Cook)
4096             en-CM            Anglais (Cameroun)
4096             en-CX            Anglais (Île Christmas)
4096             en-CY            Anglais (Chypre)
4096             en-DE            Anglais (Allemagne)
4096             en-DK            Anglais (Danemark)
4096             en-DM            Anglais (Dominique)
4096             en-ER            Anglais (Érythrée)
4096             en-FI            Anglais (Finlande)
4096             en-FJ            Anglais (Fidji)
4096             en-FK            Anglais (Îles Malouines)
4096             en-FM            Anglais (Micronésie)
2057             en-GB            Anglais (Royaume-Uni)
4096             en-GD            Anglais (Grenade)
4096             en-GG            Anglais (Guernesey)
4096             en-GH            Anglais (Ghana)
4096             en-GI            Anglais (Gibraltar)
4096             en-GM            Anglais (Gambie)
4096             en-GU            Anglais (Guam)
4096             en-GY            Anglais (Guyane)
15369            en-HK            Anglais (RAS de Hong Kong)
14345            en-ID            Anglais (Indonésie)
6153             en-IE            Anglais (Irlande)
4096             en-IL            Anglais (Israël)
4096             en-IM            Anglais (Île de Man)
16393            en-IN            Anglais (Inde)
4096             en-IO            Anglais (Territoire britannique de l'océan Indien)
4096             en-JE            Anglais (Jersey)
8201             en-JM            Anglais (Jamaïque)
4096             en-KE            Anglais (Kenya)
4096             en-KI            Anglais (Kiribati)
4096             en-KN            Anglais (Saint-Christophe-et-Niévès)
4096             en-KY            Anglais (Îles Cayman)
4096             en-LC            Anglais (Sainte-Lucie)
4096             en-LR            Anglais (Libéria)
4096             en-LS            Anglais (Lesotho)
4096             en-MG            Anglais (Madagascar)
4096             en-MH            Anglais (Îles Marshall)
4096             en-MO            Anglais (RAS de Macao)
4096             en-MP            Anglais (Îles Mariannes du Nord)
4096             en-MS            Anglais (Montserrat)
4096             en-MT            Anglais (Malte)
4096             en-MU            Anglais (Île Maurice)
4096             en-MW            Anglais (Malawi)
17417            en-MY            Anglais (Malaisie)
4096             en-NA            Anglais (Namibie)
4096             en-NF            Anglais (Île Norfolk)
4096             en-NG            Anglais (Nigéria)
4096             en-NL            Anglais (Pays-Bas)
4096             en-NR            Anglais (Nauru)
4096             en-NU            Anglais (Niue)
5129             en-NZ            Anglais (Nouvelle-Zélande)
4096             en-PG            Anglais (Papouasie-Nouvelle-Guinée)
13321            en-PH            Anglais (Philippines)
4096             en-PK            Anglais (Pakistan)
4096             en-PN            Anglais (Îles Pitcairn)
4096             en-PR            Anglais (Porto Rico)
4096             en-PW            Anglais (Palaos)
4096             en-RW            Anglais (Rwanda)
4096             en-SB            Anglais (Îles Salomon)
4096             en-SC            Anglais (Seychelles)
4096             en-SD            Anglais (Soudan)
4096             en-SE            Anglais (Suède)
18441            en-SG            Anglais (Singapour)
4096             en-SH            Anglais (Sainte-Hélène, Ascension et Tristan da Cunha)
4096             en-SI            Anglais (Slovénie)
4096             en-SL            Anglais (Sierra Leone)
4096             en-SS            Anglais (Soudan du Sud)
4096             en-SX            Anglais (Saint-Martin)
4096             en-SZ            Anglais (Swaziland)
4096             en-TC            Anglais (Îles Turks et Caicos)
4096             en-TK            Anglais (Tokelau)
4096             en-TO            Anglais (Tonga)
11273            en-TT            Anglais (Trinité-et-Tobago)
4096             en-TV            Anglais (Tuvalu)
4096             en-TZ            Anglais (Tanzanie)
4096             en-UG            Anglais (Ouganda)
4096             en-UM            Anglais (Dépendances américaines du Pacifique)
1033             en-US            Anglais (États-Unis)
4096             en-VC            Anglais (Saint-Vincent-et-les-Grenadines)
4096             en-VG            Anglais (Îles Vierges britanniques)
4096             en-VI            Anglais (Îles Vierges des États-Unis)
4096             en-VU            Anglais (Vanuatu)
4096             en-WS            Anglais (Samoa)
7177             en-ZA            Anglais (Afrique du Sud)
4096             en-ZM            Anglais (Zambie)
12297            en-ZW            Anglais (Zimbabwe)
4096             eo               Espéranto
4096             eo-001           Espéranto (International)
10               es               Espagnol
22538            es-419           Espagnol (Amérique du Sud)
11274            es-AR            Espagnol (Argentine)
16394            es-BO            Espagnol (Bolivie)
4096             es-BR            Espagnol (Brésil)
4096             es-BZ            Espagnol (Belize)
13322            es-CL            Espagnol (Chili)
9226             es-CO            Espagnol (Colombie)
5130             es-CR            Espagnol (Costa Rica)
23562            es-CU            Espagnol (Cuba)
7178             es-DO            Espagnol (République dominicaine)
12298            es-EC            Espagnol (Équateur)
3082             es-ES            Espagnol (Espagne)
4096             es-GQ            Espagnol (Guinée équatoriale)
4106             es-GT            Espagnol (Guatemala)
18442            es-HN            Espagnol (Honduras)
2058             es-MX            Espagnol (Mexique)
19466            es-NI            Espagnol (Nicaragua)
6154             es-PA            Espagnol (Panama)
10250            es-PE            Espagnol (Pérou)
4096             es-PH            Espagnol (Philippines)
20490            es-PR            Espagnol (Porto Rico)
15370            es-PY            Espagnol (Paraguay)
17418            es-SV            Espagnol (Salvador)
21514            es-US            Espagnol (États-Unis)
14346            es-UY            Espagnol (Uruguay)
8202             es-VE            Espagnol (République bolivarienne du Venezuela)
37               et               Estonien
1061             et-EE            Estonien (Estonie)
45               eu               Basque
1069             eu-ES            Basque (Basque)
4096             ewo              Ewondo
4096             ewo-CM           Ewondo (Cameroun)
41               fa               Persan
1164             fa-AF            Persan (Afghanistan)
1065             fa-IR            Persan (Iran)
103              ff               Fula
4096             ff-Adlm          Peul (ADLaM)
4096             ff-Adlm-BF       Peul (ADLaM, Burkina Faso)
4096             ff-Adlm-CM       Peul (ADLaM, Cameroun)
4096             ff-Adlm-GH       Peul (ADLaM, Ghana)
4096             ff-Adlm-GM       Peul (ADLaM, Gambie)
4096             ff-Adlm-GN       Peul (ADLaM, Guinée)
4096             ff-Adlm-GW       Peul (ADLaM, Guinée-Bissau)
4096             ff-Adlm-LR       Peul (ADLaM, Libéria)
4096             ff-Adlm-MR       Peul (ADLaM, Mauritanie)
4096             ff-Adlm-NE       Peul (ADLaM, Niger)
4096             ff-Adlm-NG       Peul (ADLaM, Nigéria)
4096             ff-Adlm-SL       Peul (ADLaM, Sierra Leone)
4096             ff-Adlm-SN       Peul (ADLaM, Sénégal)
31847            ff-Latn          Fula (Latin)
4096             ff-Latn-BF       Peul (latin, Burkina Faso)
4096             ff-Latn-CM       Peul (latin, Cameroun)
4096             ff-Latn-GH       Peul (latin, Ghana)
4096             ff-Latn-GM       Peul (latin, Gambie)
4096             ff-Latn-GN       Peul (latin, Guinée)
4096             ff-Latn-GW       Peul (latin, Guinée-Bissau)
4096             ff-Latn-LR       Peul (latin, Liberia)
4096             ff-Latn-MR       Peul (latin, Mauritanie)
4096             ff-Latn-NE       Peul (latin, Niger)
1127             ff-Latn-NG       Peul (latin, Nigeria)
4096             ff-Latn-SL       Peul (latin, Sierra Leone)
2151             ff-Latn-SN       Fula (Latin, Sénégal)
11               fi               Finnois
1035             fi-FI            Finnois (Finlande)
100              fil              Filipino
1124             fil-PH           Filipino (Philippines)
56               fo               Féroïen
4096             fo-DK            Féroïen (Danemark)
1080             fo-FO            Féroïen (Îles Féroé)
12               fr               Français
7180             fr-029           Français (Caraïbes)
2060             fr-BE            Français (Belgique)
4096             fr-BF            Français (Burkina Faso)
4096             fr-BI            Français (Burundi)
4096             fr-BJ            Français (Bénin)
4096             fr-BL            Français (Saint-Barthélemy)
3084             fr-CA            Français (Canada)
9228             fr-CD            Français (République démocratique du Congo)
4096             fr-CF            Français (République centrafricaine)
4096             fr-CG            Français (Congo)
4108             fr-CH            Français (Suisse)
12300            fr-CI            Français (Côte d'Ivoire)
11276            fr-CM            Français (Cameroun)
4096             fr-DJ            Français (Djibouti)
4096             fr-DZ            Français (Algérie)
1036             fr-FR            Français (France)
4096             fr-GA            Français (Gabon)
4096             fr-GF            Français (Guyane française)
4096             fr-GN            Français (Guinée)
4096             fr-GP            Français (Guadeloupe)
4096             fr-GQ            Français (Guinée équatoriale)
15372            fr-HT            Français (Haïti)
4096             fr-KM            Français (Comores)
5132             fr-LU            Français (Luxembourg)
14348            fr-MA            Français (Maroc)
6156             fr-MC            Français (Monaco)
4096             fr-MF            Français (Saint-Martin)
4096             fr-MG            Français (Madagascar)
13324            fr-ML            Français (Mali)
4096             fr-MQ            Français (Martinique)
4096             fr-MR            Français (Mauritanie)
4096             fr-MU            Français (Maurice)
4096             fr-NC            Français (Nouvelle-Calédonie)
4096             fr-NE            Français (Niger)
4096             fr-PF            Français (Polynésie française)
4096             fr-PM            Français (Saint-Pierre-et-Miquelon)
8204             fr-RE            Français (La Réunion)
4096             fr-RW            Français (Rwanda)
4096             fr-SC            Français (Seychelles)
10252            fr-SN            Français (Sénégal)
4096             fr-SY            Français (Syrie)
4096             fr-TD            Français (Tchad)
4096             fr-TG            Français (Togo)
4096             fr-TN            Français (Tunisie)
4096             fr-VU            Français (Vanuatu)
4096             fr-WF            Français (Wallis et Futuna)
4096             fr-YT            Français (Mayotte)
4096             fur              Frioulan
4096             fur-IT           Frioulan (Italie)
98               fy               Frison
1122             fy-NL            Frison (Pays-Bas)
60               ga               Irlandais
4096             ga-GB            Irlandais (Royaume-Uni)
2108             ga-IE            Irlandais (Irlande)
145              gd               Gaélique écossais
1169             gd-GB            Gaélique écossais (Royaume-Uni)
86               gl               Galicien
1110             gl-ES            Galicien (Galicien)
116              gn               Guarani
1140             gn-PY            Guarani (Paraguay)
132              gsw              Alsacien
4096             gsw-CH           Alsacien (Suisse)
1156             gsw-FR           Alsacien (France)
4096             gsw-LI           Alsacien (Liechtenstein)
71               gu               Goudjrati
1095             gu-IN            Goudjrati (Inde)
4096             guz              Gusii
4096             guz-KE           Gusii (Kenya)
4096             gv               Manx
4096             gv-IM            Manx (Île de Man)
104              ha               Haoussa
31848            ha-Latn          Haoussa (latin)
4096             ha-Latn-GH       Hausa (Latin, Ghana)
4096             ha-Latn-NE       Hausa (Latin, Niger)
1128             ha-Latn-NG       Haoussa (latin, Nigeria)
117              haw              Hawaïen
1141             haw-US           Hawaïen (États-Unis)
13               he               Hébreu
1037             he-IL            Hébreu (Israël)
57               hi               Hindi
1081             hi-IN            Hindi (Inde)
26               hr               Croate
4122             hr-BA            Croate (latin, Bosnie-Herzégovine)
1050             hr-HR            Croate (Croatie)
46               hsb              Haut sorabe
1070             hsb-DE           Haut sorabe (Allemagne)
14               hu               Hongrois
1038             hu-HU            Hongrois (Hongrie)
43               hy               Arménien
1067             hy-AM            Arménien (Arménie)
4096             ia               Interlingua
4096             ia-001           Interlingua (International)
105              ibb              Ibibio
1129             ibb-NG           Ibibio (Nigeria)
33               id               Indonésien
1057             id-ID            Indonésien (Indonésie)
112              ig               Igbo
1136             ig-NG            Igbo (Nigeria)
120              ii               Yi
1144             ii-CN            Yi (RPC)
15               is               Islandais
1039             is-IS            Islandais (Islande)
16               it               Italien
2064             it-CH            Italien (Suisse)
1040             it-IT            Italien (Italie)
4096             it-SM            Italien (Saint-Marin)
4096             it-VA            Italien (État de la Cité du Vatican)
93               iu               Inuktitut
30813            iu-Cans          Inuktitut (syllabaire)
1117             iu-Cans-CA       Inuktitut (syllabaire, Canada)
31837            iu-Latn          Inuktitut (latin)
2141             iu-Latn-CA       Inuktitut (latin, Canada)
17               ja               Japonais
1041             ja-JP            Japonais (Japon)
4096             jgo              Ngomba
4096             jgo-CM           Ngomba (Cameroun)
4096             jmc              Machame
4096             jmc-TZ           Machame (Tanzanie)
4096             jv               Javanais
4096             jv-Java          Javanais (Javanais)
4096             jv-Java-ID       Javanais (Javanais, Indonésie)
4096             jv-Latn          Javanais
4096             jv-Latn-ID       Javanais (Indonésie)
55               ka               Géorgien
1079             ka-GE            Géorgien (Géorgie)
4096             kab              Kabyle
4096             kab-DZ           Kabyle (Algérie)
4096             kam              Kamba
4096             kam-KE           Kamba (Kenya)
4096             kde              Makonde
4096             kde-TZ           Makonde (Tanzanie)
4096             kea              Capverdien
4096             kea-CV           Capverdien (Cabo Verde)
4096             khq              Koyra Chiini
4096             khq-ML           Koyra Chiini (Mali)
4096             ki               Kikuyu
4096             ki-KE            Kikuyu (Kenya)
63               kk               Kazakh
1087             kk-KZ            Kazakh (Kazakhstan)
4096             kkj              Kako
4096             kkj-CM           Kako (Cameroun)
111              kl               Groenlandais
1135             kl-GL            Groenlandais (Groenland)
4096             kln              Kalenjin
4096             kln-KE           Kalenjin (Kenya)
83               km               Khmer
1107             km-KH            Khmer (Cambodge)
75               kn               Kannada
1099             kn-IN            Kannada (Inde)
18               ko               Coréen
4096             ko-KP            Coréen (Corée du Nord)
1042             ko-KR            Coréen (Corée)
87               kok              Konkani
1111             kok-IN           Konkani (Inde)
113              kr               Kanouri
4096             kr-Latn          Kanuri (latin)
1137             kr-Latn-NG       Kanuri (latin, Nigéria)
96               ks               Kashmiri
1120             ks-Arab          Kashmiri (Perso-arabe)
4096             ks-Arab-IN       Kashmiri (Perso-arabe)
4096             ks-Deva          Kashmiri (Dévanâgarî)
2144             ks-Deva-IN       Kashmiri (Dévanâgarî, Inde)
4096             ksb              Shambala
4096             ksb-TZ           Shambala (Tanzanie)
4096             ksf              Bafia
4096             ksf-CM           Bafia (Cameroun)
4096             ksh              Francique colonais
4096             ksh-DE           Francique ripuaire (Allemagne)
146              ku               Sorani
31890            ku-Arab          Sorani (Arabe)
1170             ku-Arab-IQ       Sorani (Iraq)
4096             ku-Arab-IR       Kurde (arabe, Iran)
4096             kw               Cornique
4096             kw-GB            Cornique (Royaume-Uni)
64               ky               Kirghize
1088             ky-KG            Kirghize (Kirghizistan)
118              la               Latin
1142             la-VA            Latin (cité du Vatican)
4096             lag              Langi
4096             lag-TZ           Langi (Tanzanie)
110              lb               Luxembourgeois
1134             lb-LU            Luxembourgeois (Luxembourg)
4096             lg               Ganda
4096             lg-UG            Ganda (Ouganda)
4096             lkt              Lakota
4096             lkt-US           Lakota (États-Unis)
4096             ln               Lingala
4096             ln-AO            Lingala (Angola)
4096             ln-CD            Lingala (République démocratique du Congo)
4096             ln-CF            Français (République centrafricaine)
4096             ln-CG            Lingala (Congo)
84               lo               Lao
1108             lo-LA            Lao (RDP Lao)
4096             lrc              Luri du nord
4096             lrc-IQ           Luri du nord (Irak)
4096             lrc-IR           Luri du nord (Iran)
39               lt               Lituanien
1063             lt-LT            Lituanien (Lituanie)
4096             lu               Luba-Katanga
4096             lu-CD            Luba-Katanga (République démocratique du Congo)
4096             luo              Luo
4096             luo-KE           Luo (Kenya)
4096             luy              Luyia
4096             luy-KE           Luyia (Kenya)
38               lv               Letton
1062             lv-LV            Letton (Lettonie)
4096             mai              Maïthili
4096             mai-IN           Maïthili (Inde)
4096             mas              Maasaï
4096             mas-KE           Maasaï (Kenya)
4096             mas-TZ           Maasaï (Tanzanie)
4096             mer              Meru
4096             mer-KE           Meru (Kenya)
4096             mfe              Mauricien
4096             mfe-MU           Mauricien (Maurice)
4096             mg               Malgache
4096             mg-MG            Malgache (Madagascar)
4096             mgh              Makhuwa-Meetto
4096             mgh-MZ           Makhuwa-Meetto (Mozambique)
4096             mgo              Meta'
4096             mgo-CM           Meta' (Cameroun)
129              mi               Maori
1153             mi-NZ            Maori (Nouvelle-Zélande)
47               mk               Macédonien
1071             mk-MK            Macédonien (Macédoine du Nord)
76               ml               Malayalam
1100             ml-IN            Malayalam (Inde)
80               mn               Mongol
30800            mn-Cyrl          Mongol (cyrillique)
1104             mn-MN            Mongol (Cyrillique, Mongolie)
31824            mn-Mong          Mongol (mongol traditionnel)
2128             mn-Mong-CN       Mongol (mongol traditionnel, RPC)
3152             mn-Mong-MN       Mongol (Mongol traditionnel, Mongolie)
88               mni              Manipuri
4096             mni-Beng         Manipuri (Bangla)
1112             mni-IN           Manipuri (Inde)
124              moh              Mohawk
1148             moh-CA           Mohawk (Mohawk)
78               mr               Marathe
1102             mr-IN            Marathe (Inde)
62               ms               Malais
2110             ms-BN            Malais (Brunei Darussalam)
4096             ms-ID            Malais (Indonésie)
1086             ms-MY            Malais (Malaisie)
4096             ms-SG            Malais (Latin, Singapour)
58               mt               Maltais
1082             mt-MT            Maltais (Malte)
4096             mua              Mundang
4096             mua-CM           Mundang (Cameroun)
85               my               Birman
1109             my-MM            Birman (Myanmar)
4096             mzn              Mazandarani
4096             mzn-IR           Mazandarani (Iran)
4096             naq              Nama
4096             naq-NA           Nama (Namibie)
31764            nb               Norvégien (Bokmål)
1044             nb-NO            Norvégien, Bokmål (Norvège)
4096             nb-SJ            Norvégien, Bokmål l (Svalbard et Jan Mayen)
4096             nd               Ndébélé du Nord
4096             nd-ZW            Ndébélé du Nord (Zimbabwe)
4096             nds              Bas allemand
4096             nds-DE           Bas allemand (Allemagne)
4096             nds-NL           Bas allemand (Pays-Bas)
97               ne               Népalais
2145             ne-IN            Népalais (Inde)
1121             ne-NP            Népalais (Népal)
19               nl               Néerlandais
4096             nl-AW            Néerlandais (Aruba)
2067             nl-BE            Néerlandais (Belgique)
4096             nl-BQ            Néerlandais (Bonaire, Saint-Eustache et Saba)
4096             nl-CW            Néerlandais (Curaçao)
1043             nl-NL            Néerlandais (Pays-Bas)
4096             nl-SR            Néerlandais (Suriname)
4096             nl-SX            Néerlandais (Saint-Martin)
4096             nmg              Kwasio
4096             nmg-CM           Kwasio (Cameroun)
30740            nn               Norvégien (Nynorsk)
2068             nn-NO            Norvégien, Nynorsk (Norvège)
4096             nnh              Ngiemboon
4096             nnh-CM           Ngiemboon (Cameroun)
20               no               Norvégien
4096             nqo              N'ko
4096             nqo-GN           N'ko (Guinée)
4096             nr               Ndébélé du Sud
4096             nr-ZA            Ndébélé du Sud (Afrique du Sud)
108              nso              Sesotho sa Leboa
1132             nso-ZA           Sesotho sa Leboa (Afrique du Sud)
4096             nus              Nuer
4096             nus-SS           Nuer (Soudan du Sud)
4096             nyn              Nyankole
4096             nyn-UG           Nyankole (Ouganda)
130              oc               Occitan
1154             oc-FR            Occitan (France)
114              om               Oromo
1138             om-ET            Oromo (Éthiopie)
4096             om-KE            Oromo (Kenya)
72               or               Odia
1096             or-IN            Odia (Inde)
4096             os               Ossète
4096             os-GE            Ossète (Cyrillique, Géorgie)
4096             os-RU            Ossète (Cyrillique, Russie)
70               pa               Pendjabi
31814            pa-Arab          Pendjabi (Arabe)
2118             pa-Arab-PK       Pendjabi (République islamique du Pakistan)
4096             pa-Guru          Pendjabi
1094             pa-IN            Pendjabi (Inde)
121              pap              Papiamento
1145             pap-029          Papiamento (Caraïbes)
4096             pcm              Pidgin nigérian
4096             pcm-Latn         Pidgin nigérian (latin)
4096             pcm-Latn-NG      Pidgin nigérian (latin, Nigéria)
21               pl               Polonais
1045             pl-PL            Polonais (Pologne)
4096             prg              Prussien
4096             prg-001          Prussien (international)
99               ps               Pachtou
1123             ps-AF            Pachtou (Afghanistan)
4096             ps-PK            Pachtou (Pakistan)
22               pt               Portugais
4096             pt-AO            Portugais (Angola)
1046             pt-BR            Portugais (Brésil)
4096             pt-CH            Portugais (Suisse)
4096             pt-CV            Portugais (Cabo Verde)
4096             pt-GQ            Portugais (Guinée équatoriale)
4096             pt-GW            Portugais (Guinée-Bissau)
4096             pt-LU            Portugais (Luxembourg)
4096             pt-MO            Portugais (RAS de Macao)
4096             pt-MZ            Portugais (Mozambique)
2070             pt-PT            Portugais (Portugal)
4096             pt-ST            Portugais (Sao Tomé-et-Principe)
4096             pt-TL            Portugais (Timor-Leste)
134              quc              K'iche'
31878            quc-Latn         K'iche'
1158             quc-Latn-GT      K'iche' (Guatemala)
107              quz              Quechua
1131             quz-BO           Quechua (Bolivie)
2155             quz-EC           Quechua (Équateur)
3179             quz-PE           Quechua (Pérou)
23               rm               Romanche
1047             rm-CH            Romanche (Suisse)
4096             rn               Rundi
4096             rn-BI            Rundi (Burundi)
24               ro               Roumain
2072             ro-MD            Roumain (Moldavie)
1048             ro-RO            Roumain (Roumanie)
4096             rof              Rombo
4096             rof-TZ           Rombo (Tanzanie)
25               ru               Russe
4096             ru-BY            Russe (Bélarus)
4096             ru-KG            Russe (Kirghizistan)
4096             ru-KZ            Russe (Kazakhstan)
2073             ru-MD            Russe (Moldavie)
1049             ru-RU            Russe (Russe)
4096             ru-UA            Russe (Ukraine)
135              rw               Kinyarwanda
1159             rw-RW            Kinyarwanda (Rwanda)
4096             rwk              Rwa
4096             rwk-TZ           Rwa (Tanzanie)
79               sa               Sanscrit
1103             sa-IN            Sanscrit (Inde)
133              sah              Sakha
1157             sah-RU           Sakha (Russie)
4096             saq              Samburu
4096             saq-KE           Samburu (Kenya)
4096             sat              Santali
4096             sat-Olck         Santali (ol tchiki)
4096             sat-Olck-IN      Santali (ol tchiki, Inde)
4096             sbp              Sangu
4096             sbp-TZ           Sangu (Tanzanie)
89               sd               Sindhi
31833            sd-Arab          Sindhi (Arabe)
2137             sd-Arab-PK       Sindhi (République islamique du Pakistan)
4096             sd-Deva          Sindhi (Devanâgarî)
1113             sd-Deva-IN       Sindhi (Devanâgarî, Inde)
59               se               Sami (du Nord)
3131             se-FI            Sami du Nord (Finlande)
1083             se-NO            Sami du Nord (Norvège)
2107             se-SE            Sami du Nord (Suède)
4096             seh              Sena
4096             seh-MZ           Sena (Mozambique)
4096             ses              Koyraboro Senni
4096             ses-ML           Koyraboro Senni (Mali)
4096             sg               Sango
4096             sg-CF            Sango (République centrafricaine)
4096             shi              Tachelhite
4096             shi-Latn         Tachelhite (Latin)
4096             shi-Latn-MA      Tachelhite (Latin, Maroc)
4096             shi-Tfng         Tachelhite (Tifinagh)
4096             shi-Tfng-MA      Tachelhite (Tifinagh, Maroc)
91               si               Sinhala
1115             si-LK            Sinhala (Sri Lanka)
27               sk               Slovaque
1051             sk-SK            Slovaque (Slovaquie)
36               sl               Slovène
1060             sl-SI            Slovène (Slovénie)
30779            sma              Sami (du Sud)
6203             sma-NO           Sami du Sud (Norvège)
7227             sma-SE           Sami du Sud (Suède)
31803            smj              Sami (Lule)
4155             smj-NO           Sami de Lule (Norvège)
5179             smj-SE           Sami de Lule (Suède)
28731            smn              Sami (Inari)
9275             smn-FI           Sami d'Inari (Finlande)
29755            sms              Sami (Skolt)
8251             sms-FI           Sami de Skolt (Finlande)
4096             sn               Shona
4096             sn-Latn          Shona (Latin)
4096             sn-Latn-ZW       Shona (Latin, Zimbabwe)
119              so               Somali
4096             so-DJ            Somali (Djibouti)
4096             so-ET            Somali (Éthiopie)
4096             so-KE            Somali (Kenya)
1143             so-SO            Somali (Somalie)
28               sq               Albanais
1052             sq-AL            Albanais (Albanie)
4096             sq-MK            Albanien (Macédoine du Nord)
4096             sq-XK            Albanais (Kosovo)
31770            sr               Serbe
27674            sr-Cyrl          Serbe (cyrillique)
7194             sr-Cyrl-BA       Serbe (cyrillique, Bosnie-Herzégovine)
12314            sr-Cyrl-ME       Serbe (cyrillique, Monténégro)
10266            sr-Cyrl-RS       Serbe (cyrillique, Serbie)
4096             sr-Cyrl-XK       Serbe (Cyrillique, Kosovo)
28698            sr-Latn          Serbe (latin)
6170             sr-Latn-BA       Serbe (latin, Bosnie-Herzégovine)
11290            sr-Latn-ME       Serbe (latin, Monténégro)
9242             sr-Latn-RS       Serbe (latin, Serbie)
4096             sr-Latn-XK       Serbe (Latin, Kosovo)
4096             ss               Swati
4096             ss-SZ            Swati (Swaziland)
4096             ss-ZA            Swati (Afrique du Sud)
4096             ssy              Saho
4096             ssy-ER           Saho (Érythrée)
48               st               Sotho du Sud
4096             st-LS            Sotho du Sud (Lesotho)
1072             st-ZA            Sotho du Nord (Afrique du Sud)
4096             su               Sundanais
4096             su-Latn          Sundanais (latin)
4096             su-Latn-ID       Sundanais (latin, Indonésie)
29               sv               Suédois
4096             sv-AX            Suédois (Åland)
2077             sv-FI            Suédois (Finlande)
1053             sv-SE            Suédois (Suède)
65               sw               Swahili
4096             sw-CD            Swahili (Congo RDC)
1089             sw-KE            Swahili (Kenya)
4096             sw-TZ            Swahili (Tanzanie)
4096             sw-UG            Swahili (Ouganda)
90               syr              Syriaque
1114             syr-SY           Syriaque (Syrie)
73               ta               Tamoul
1097             ta-IN            Tamoul (Inde)
2121             ta-LK            Tamoul (Sri Lanka)
4096             ta-MY            Tamoul (Malaisie)
4096             ta-SG            Tamoul (Singapour)
74               te               Télougou
1098             te-IN            Télougou (Inde)
4096             teo              Teso
4096             teo-KE           Teso (Kenya)
4096             teo-UG           Teso (Ouganda)
40               tg               Tadjik
31784            tg-Cyrl          Tadjik (cyrillique)
1064             tg-Cyrl-TJ       Tadjik (cyrillique, Tadjikistan)
30               th               Thaï
1054             th-TH            Thaï (Thaïlande)
115              ti               Tigrinya
2163             ti-ER            Tigrinya (Érythrée)
1139             ti-ET            Tigrinya (Éthiopie)
4096             tig              Tigré
4096             tig-ER           Tigré (Érythrée)
66               tk               Turkmène
1090             tk-TM            Turkmène (Turkménistan)
50               tn               Setswana
2098             tn-BW            Setswana (Botswana)
1074             tn-ZA            Setswana (Afrique du Sud)
4096             to               Tongien
4096             to-TO            Tongien (Tonga)
31               tr               Turc
4096             tr-CY            Turc (Chypre)
1055             tr-TR            Turc (Turquie)
49               ts               Tsonga
1073             ts-ZA            Tsonga (Afrique du Sud)
68               tt               Tatar
1092             tt-RU            Tatar (Russie)
4096             twq              Tasawaq
4096             twq-NE           Tasawaq (Niger)
95               tzm              Tamazight
4096             tzm-Arab         Amazighe de l'Atlas central (Arabe)
1119             tzm-Arab-MA      Amazighe de l'Atlas central (Arabe, Maroc)
31839            tzm-Latn         Tamazight (latin)
2143             tzm-Latn-DZ      Tamazight (latin, Algérie)
4096             tzm-Latn-MA      Tamazight du Maroc central (Latin, Maroc)
30815            tzm-Tfng         Tamazight (Tifinagh)
4191             tzm-Tfng-MA      Tamazight de l'Atlas central (Tifinagh, Maroc)
128              ug               Ouïghour
1152             ug-CN            Ouïghour (RPC)
34               uk               Ukrainien
1058             uk-UA            Ukrainien (Ukraine)
32               ur               Ourdou
2080             ur-IN            Ourdou (Inde)
1056             ur-PK            Ourdou (Pakistan)
67               uz               Ouzbek
4096             uz-Arab          Ouzbek (Perso-arabe)
4096             uz-Arab-AF       Ouzbek (Perso-arabe, Afghanistan)
30787            uz-Cyrl          Ouzbek (cyrillique)
2115             uz-Cyrl-UZ       Ouzbek (Cyrillique, Ouzbékistan)
31811            uz-Latn          Ouzbek (latin)
1091             uz-Latn-UZ       Ouzbek (Latin, Ouzbékistan)
4096             vai              Vaï
4096             vai-Latn         Vaï (Latin)
4096             vai-Latn-LR      Vaï (Latin, Libéria)
4096             vai-Vaii         Vaï (Vaï)
4096             vai-Vaii-LR      Vaï (Vaï, Libéria)
51               ve               Venda
1075             ve-ZA            Venda (Afrique du Sud)
42               vi               Vietnamien
1066             vi-VN            Vietnamien (Vietnam)
4096             vo               Volapük
4096             vo-001           Volapük (International)
4096             vun              Vunjo
4096             vun-TZ           Vunjo (Tanzanie)
4096             wae              Walser
4096             wae-CH           Walser (Suisse)
4096             wal              Wolaytta
4096             wal-ET           Wolaytta (Éthiopie)
136              wo               Wolof
1160             wo-SN            Wolof (Sénégal)
52               xh               Xhosa
1076             xh-ZA            Xhosa (Afrique du Sud)
4096             xog              Soga
4096             xog-UG           Soga (Ouganda)
4096             yav              Yangben
4096             yav-CM           Yangben (Cameroun)
61               yi               Yiddish
1085             yi-001           Yiddish (International)
106              yo               Yoruba
4096             yo-BJ            Yoruba (Bénin)
1130             yo-NG            Yoruba (Nigeria)
4096             zgh              Tamazight marocain standard
4096             zgh-Tfng         Tamazight marocain standard (Tifinagh)
4096             zgh-Tfng-MA      Tamazight marocain standard (Tifinagh, Maroc)
30724            zh               Chinois
2052             zh-CN            Chinois (Simplifié, RPC)
4                zh-Hans          Chinois (Simplifié)
4096             zh-Hans-HK       Chinois simplifié (Hong Kong (R.A.S.))
4096             zh-Hans-MO       Chinois simplifié (Macao (R.A.S.))
31748            zh-Hant          Chinois (Traditionnel)
3076             zh-HK            Chinois (Traditionnel, Hong Kong R.A.S.)
5124             zh-MO            Chinois (Traditionnel, Macao R.A.S.)
4100             zh-SG            Chinois (Simplifié, Singapour)
1028             zh-TW            Chinois (Traditionnel, Taïwan)
53               zu               Zoulou
1077             zu-ZA            Zoulou (Afrique du Sud)
4                zh-CHS           Chinois (Simplifié) - Hérité
31748            zh-CHT           Chinois (Traditionnel) - Hérité
````

## Last words

Gathering information about the names of months and days in common culture is not as simple as it seems, but it is important to keep in mind that these are `[Enum]`.

Additionally, if there is a need to change the culture, this will only apply globally in any new instance of powershell.

As a last point, I would add the `Get-Culture` cmdlet with an additional parameter (`-ListAvailable`) with PS 7.x that doesn't exist with Windows Powershell.
