<# 
*****************************************************
*               Generate-StrikeForce                *
*****************************************************
Created By: Gunslap
Date Created:  March 12rd, 2019
Purpose:
The main function in this script (Generate-StrikeForce) will create and return a randomized Strike Force Team Name 
Requirements:
The associated word list files
#>


#region Helper Functions
#Helper function to load up the word files
function Populate-WordLists()
{
    #Try loading the word lists in from the same relative path as the script:
    if(!$GLOBAL:nouns){$GLOBAL:nouns = Get-Content -Path "$PSScriptRoot\nouns.txt" -ErrorAction SilentlyContinue}
    if(!$GLOBAL:adjectives){$GLOBAL:adjectives= Get-Content -Path "$PSScriptRoot\adjectives.txt" -ErrorAction SilentlyContinue}
    if(!$GLOBAL:verbs){$GLOBAL:verbs =  Get-Content -Path "$PSScriptRoot\verbs.txt" -ErrorAction SilentlyContinue}

    #If they still don't exist, read them in from host:
    if(!$GLOBAL:nouns){
        $wordPath = Read-Host -Prompt "Path to word lists?"
        $GLOBAL:nouns = Get-Content -Path "$wordPath\nouns.txt" -ErrorAction SilentlyContinue
        if(!$GLOBAL:adjectives){$GLOBAL:adjectives= Get-Content -Path "$wordPath\adjectives.txt" -ErrorAction SilentlyContinue}
        if(!$GLOBAL:verbs){$GLOBAL:verbs =  Get-Content -Path "$wordPath\verbs.txt" -ErrorAction SilentlyContinue}
    }
    #If they STILL don't exist, throw an error
    if(!$GLOBAL:nouns){Throw "ERROR: Word lists were not found at: $wordPath"}
}

#This helper function will return a noun with 0, 1, or 2 adjectives in front of it
function Generate-Noun()
{
    #Get a noun
    $noun = $GLOBAL:nouns[$(Get-Random -Minimum 0 -Maximum ($GLOBAL:nouns.Length -1))]

    #decide if we're going to get 0,1, or 2 adjectives
    $num_adjectives = $(Get-Random -Minimum 0 -Maximum 8)

    #0-3 = one adjective - 37.5% chance
    if($num_adjectives -le 3)
    {
        #get one adjective
        $adjective_1 = $GLOBAL:adjectives[$(Get-Random -Minimum 0 -Maximum ($GLOBAL:adjectives.Length -1))]
        #add it before the noun
        $noun = $adjective_1 + " " + $noun
    }
    #3 = two adjectives - 12.5% chance
    elseif($num_adjectives -eq 4)
    {
        #get two adjectives
        $adjective_1 = $GLOBAL:adjectives[$(Get-Random -Minimum 0 -Maximum ($GLOBAL:adjectives.Length -1))]
        $adjective_2 = $GLOBAL:adjectives[$(Get-Random -Minimum 0 -Maximum ($GLOBAL:adjectives.Length -1))]
        #add them before the noun
        $noun = $adjective_1 + " " + $adjective_2 + " " + $noun
    }
    # any other case (5 or above) is no adjectives - 50%
    #so do nothing to the noun

    #return the noun + adjectives string
    return $noun
}
#endregion

#script will generate a new randomized game title to display

#Title Style Randomizer
function Generate-StrikeForce()
{
<#
.SYNOPSIS
This function will generate a Strike Force name
.DESCRIPTION
This function will read in some word lists and randomly generate and return a Strike Force name
.EXAMPLE
"Generate-StrikeForce"
Strike Force Unusual Scuba Diving
#>


    #Make sure the word lists are populated
    Populate-WordLists

    $title = ""

    $title_style = $(Get-Random -Minimum 0 -Maximum 7)
    switch ($title_style){
        #Single Noun
        0 {
            $noun_1 = Generate-Noun
            $title += $noun_1
        break
        }
        #Single Noun
        1 {
            $noun_1 = Generate-Noun
            $title += $noun_1
        break
        }
        #Noun Verb Noun
        2 {
            $noun_1 = Generate-Noun
            $verb_1 = $GLOBAL:verbs[$(Get-Random -Minimum 0 -Maximum ($GLOBAL:verbs.Length -1))]
            $noun_2 = Generate-Noun
        
            while($($noun_1 + $verb_1 + $noun_2).length -ge 40)
            {
                $noun_1 = Generate-Noun
                $noun_2 = Generate-Noun
            }
            $title += $noun_1 + " " + $verb_1 + " " + $noun_2
            break
        }
        #Verb Noun
        3 {
            $verb_1 = $GLOBAL:verbs[$(Get-Random -Minimum 0 -Maximum ($GLOBAL:verbs.Length -1))]
            $noun_1 = Generate-Noun
        
            while($($noun_1 + $verb_1).length -ge 40)
            {
                $noun_1 = Generate-Noun
            }
            $title +=  $verb_1 + " " +  $noun_1
            break
        }
        #Default will be "Noun Noun"
        default {
            $noun_1 = Generate-Noun
            #We don't want the second noun to have any adjectives
            #as those are weird looking on this type so we'll pull one directly from the array:
            $noun_2 = $GLOBAL:nouns[$(Get-Random -Minimum 0 -Maximum ($GLOBAL:nouns.Length -1))]
            #noun_2 = Generate-Noun
            #if it's over 40 characters, it's pretty freaking long, try some new nouns!
            while($($noun_1 + " in" + $noun_2).length -ge 40)
            {
                $noun_1 = Generate-Noun
                $noun_2 = $GLOBAL:nouns[$(Get-Random -Minimum 0 -Maximum ($GLOBAL:nouns.Length -1))]
            }
            #Save the title to the global title variable
            $title += $noun_1 + " " + $noun_2
        }
    }

    #Now that we've got our general title structure
    #we will check it's lenth, if it's too long
    #skip even thinking of adding a suffix

    $skip_suffix = $false
    #if it's already over 30, skip
    if($title.length -ge 30)
    {
        $skip_suffix = $true
    }
    #Ending Modifier
    if($skip_suffix -eq $false)
    {
        $ending_modify = Get-Random -Minimum 0 -Maximum 50
        $ending_addition = ""
        switch ($ending_modify)
        {
            #sequels
            0 {
                $ending_addition = " " + $(Get-Random -Minimum 2 -Maximum 10)
                break
            }
            #Year
            6 {
                $ending_addition = " " + $(Get-Random -Minimum 1000 -Maximum 3000)
                break
            }
            #"Zero"
            8 {
                $ending_addition = " Zero"
                break
            }
            #"Unleashed"
            9 { 
                $ending_addition = " Unleashed"
                break
            }
            #"Vengance!"
            16 {
                $ending_addition = " Vengance"
                break
            }
            # otherwise, do nothing
        }
        if($ending_addition -ne "")
        {
            $title = $title + $ending_addition
        }
    }
    #Add "Strike Force" to the front
    $title = "Strike Force " + $title
    #return the completed Title
    return $title
}