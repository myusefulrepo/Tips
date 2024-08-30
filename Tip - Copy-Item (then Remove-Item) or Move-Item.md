# `Copy-Item` (then `Remove-Item`) or `Move-Item` directly ? 

## Introduction

I have always advised both my fellow admins and users to copy files (and then possibly delete them afterwards) rather than move them.

It doesn't matter whether the operation is done via GUI (copy, paste) or via Powershell (`copy-Item`, `Move-Item`)

This is to prevent any kind of problem. I will try to explain why.

## 1st assertion

**Any file created inherits the NTFS permissions of its parent.**

> [**Nota**] : Naturally, for NTFS permissions that can be propagated. A permission like "the Folder only" will not be propagated to a child file.

## 2nd Assertion

**When a file is moved, on a given volume, there is no file creation.**

Only the allocation table is modified (the file was in such a tree and is now in another tree). Therefore, the file retains its original NTFS permissions.

## 3rd assertion

**If a file is moved to another volume, a file is created on the destination volume.**

>[Nota] : Each volume has its own allocation table.

## And now you see the problems coming ?

A user notices that a file located in ***\\server\share1*** should be located in **\\server\share2**. He has access to both shares. He drags and drops it. However, his colleague, who only has access to the share ***share2***, cannot access the file.

The user cannot know if ***Share1*** and ***Share2*** are on the same volume.
Therefore, you must tell him to do a ***Copy/Paste*** (and then delete the file at the source), rather than doing a ***Cut/Paste***. A simple doc or video can do the trick.

## And for Admins ?

And there, you will tell me that for admins it is different, because they know, and above all, don't think that admins don't use the GUI too. 

Do you believe, really ? Some maybe, but not all of you know. **Do not believe, do not presume, be sure**.

>[Nota ] : Just think of your colleague who is affected by the **Dunning-Kruger effect** (see [English](https://en.wikipedia.org/wiki/Dunning%E2%80%93Kruger_effect) or [French](https://fr.wikipedia.org/wiki/Effet_Dunning-Kruger) ref.). :-)

But GUI or powershell, as I said in the introduction, that is not the problem. The same assertions apply.

Does this seem obvious to you ? Not so much actually. How many times have I seen Admins move files via the GUI or in powershell (using `Move-Item`) and thus do stupid things.

>[**Nota**] : While strangely, for large volumes to move they use **Robocopy** (so copy). Look for the error ! (Don't look, It's  [the Fucking Human Factor](https://www.francetvinfo.fr/culture/people/video-le-putain-de-facteur-humain-l-explication-d-hubert-reeves-sur-l-inaction-des-hommes-face-a-l-etat-de-la-terre_3231465.html), as [Hubert Reeves](https://en.wikipedia.org/wiki/Hubert_Reeves) would say).

## Wrap up

So be very careful in your use of `Move-Item` (***Cut/Paste*** in GUI), always keep in mind what is happening under the hood.

If you must create a script, **use `Copy-Item` rather `than Move-Item`**. If no errors occured, then delete (Using **`Remove-Item`**) the files at the source.


I hope this helps some.




