<# 
*****************************************************
*                  Generate-Title                   *
*****************************************************
Created By: Gunslap
Date Created:  March 3rd, 2019
Purpose:
The main function in this script (Generate-Title) will create and return a randomized Video Game title 
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

#This function will return a noun with 0, 1, or 2 adjectives in front of it
function Generate-Noun()
{
    #Get a noun
    $noun = $GLOBAL:nouns[$(Get-Random -Minimum 0 -Maximum ($GLOBAL:nouns.Length -1))]

    #decide if we're going to get 0,1, or 2 adjectives
    $num_adjectives = $(Get-Random -Minimum 0 -Maximum 9)

    #0-3 = one adjective - 40% chance
    if($num_adjectives -le 3)
    {
        #get one adjective
        $adjective_1 = $GLOBAL:adjectives[$(Get-Random -Minimum 0 -Maximum ($GLOBAL:adjectives.Length -1))]
        #add it before the noun
        $noun = $adjective_1 + " " + $noun
    }
    #3 = two adjectives - 10% chance
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


# Main Title Generator Function
function Generate-Title()
{
<#
.SYNOPSIS
This function will generate a video game title
.DESCRIPTION
This function will read in some word lists and randomly generate and return a video game title
.EXAMPLE
"Generate-Title"
Super Cobra Vehicle Simulator 5
#>


    #Populate word lists
    Populate-WordLists

    $title = ""
    $title_style = $(Get-Random -Minimum 0 -Maximum 7)
    switch ($title_style){
        #Single Noun
        0 {
            $noun_1 = Generate-Noun
            $title = $noun_1
        break
        }
        #Noun preposition Noun
        1 {
            $noun_1 = Generate-Noun
            $noun_2 = Generate-Noun
            #if it's over 40 characters, it's pretty freaking long, find shorter nouns!
            while($($noun_1 + " in" + $noun_2).length -ge 40)
            {
                $noun_1 = Generate-Noun
                $noun_2 = Generate-Noun
            }
            $joiner = $(Get-Random -Minimum 0 -Maximum 6)
            switch($joiner){
                #Of
                0 {
                    $title = $noun_1 + " of " + $noun_2
                    break
                }
                #"In"
                1 {
                    $title = $noun_1 + " in " + $noun_2
                    break
                }
                #"After"
                2 {
                     $title = $noun_1 + " After " + $noun_2
                    break
                }
                #"Before"
                3 {
                     $title = $noun_1 + " Before " + $noun_2
                    break
                }
                #"With"
                4 {
                     $title = $noun_1 + " with " + $noun_2
                    break
                }
                #"Vs."
                5 {
                     $title = $noun_1 + " Vs. " + $noun_2
                    break
                }
                #"Featuring"
                6 {
                     $title = $noun_1 + " Featuring " + $noun_2
                    break
                }
            }
        break
        }
        #I'M NOT A FAN OF THIS ONE YET. IT NEEDS SOME WORK FOR SURE
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
            $title = $noun_1 + " " + $verb_1 + " " + $noun_2
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
            $title =  $verb_1 + " " +  $noun_1
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
            $title = $noun_1 + " " + $noun_2
        }
    }

    #Now that we've got our general title structure
    #we'll check it for lenth, if it's too long
    #skip even thinking of adding either a prefix or a suffix
    #(and if it's already SUPER long we'll skip both)

    $skip_prefix = $false
    $skip_suffix = $false
    #if it's already over 30, skip both
    if($title.length -ge 30)
    {
        $skip_prefix = $true
        $skip_suffix = $true
    }
    #if it's over 20, skip 1 at random
    elseif($title.length -ge 20)
    {
        $skipper = Get-Random -Minimum 0 -Maximum 1
        switch ($skipper)
        {
            0 {
                $skip_prefix = $true
                break
            }
            1 {
                $skip_suffix = $true
                break
            }
        }
    }

    #Skip if too long
    if($skip_prefix -eq $false)
    {
        $prefix_modify = Get-Random -Minimum 0 -Maximum 100
        $prefix_addition = ""

        #7 choices, even odds would be 14/100 each
    
        #Some of these make sense with a "The" in front of them
        #and others with a "The" after them. We will set a flag
        #to determine which "The" is appropriate
        $the_before  = $true
    
        #"Super" - 10%
        if($prefix_modify -le 10)
        {
            $prefix_addition = "Super "
        }
        #"Ultimate" - 10%
        elseif($prefix_modify -ge 10 -AND $prefix_modify -le 20)
        {
            $prefix_addition = "Ultimate "
        }
        #"Extreme" - 7%
        elseif($prefix_modify -ge 21 -AND $prefix_modify -le 28)
        {
            $prefix_addition = "Extreme "
        }
        #"Legend of" - 8%
        elseif($prefix_modify -ge 29 -AND $prefix_modify -le 37)
        {
            $prefix_addition = "Legend of "
        }
        #"Age of" - 6%
        elseif($prefix_modify -ge 38 -AND $prefix_modify -le 44)
        {
            $prefix_addition = "Age of "
        }
        #"Imagine" - 5%
        elseif($prefix_modify -ge 45 -AND $prefix_modify -le 50)
        {
            $prefix_addition = "Imagine "
            $the_before  = $false
        }
        #"Revenge of" - 4%
        elseif($prefix_modify -ge 51 -AND $prefix_modify -le 55)
        {
            $prefix_addition = "Revenge of "
            $the_before  = $false
        }
        #44% chance - no prefix!
    
        #if a prefix was selected, add it in!
        if($prefix_addition -ne "")
        {
            #Determine if we want a "The" in here and add the prefix
            if($(Get-Random -Minimum 0 -Maximum 5) -eq 0 -AND $title.length -le 35)
            {
                #Can the "The" go before the prefix?
                if($the_before  -eq $true)
                {
                    $title = "The " + $prefix_addition + $title
                }
                else
                {
                    $title = $prefix_addition + "The " + $title
                }
            }
            #No "The", just add the prefix
            else
            {
                $title = $prefix_addition + $title
            }
        }
        #No prefix, maybe we still want a "The"?
        elseif($(Get-Random -Minimum 0 -Maximum 5) -eq 0 -AND $title.Length -le 35)
        {
            $title = "The " + $title
        }
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
            #"The Game"
            1 {
                $ending_addition = ": The Game"
                break
            }
            #"Simulator"
            2 {
                $ending_addition = " Simulator"
                break
            }
            #"GOTY Edition"
            3 {
                $ending_addition = " GOTY Edition"
                break
            }
            #"Remastered"
            4 {
                $ending_addition = " Remastered"
                break
            }
            #"HD"
            5 {
                $ending_addition = " HD"
                break
            }
            #Year
            6 {
                $ending_addition = " " + $(Get-Random -Minimum 1000 -Maximum 3000)
                break
            }
            #"Cronicles"
            7 {
                $ending_addition = " Cronicles"
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
            #"Origins"
            10 {
                $ending_addition = " Origins"
                break
            }
            #"Mania!"
            11 {
                $ending_addition = " Mania!"
                break
            }
            #"XD"
            12 {
                $ending_addition = " XD"
                break
            }
            #"Online"
            13 {
                $ending_addition = " Online"
                break
            }
            #"For Kids!"
            15 {
                $ending_addition = " for Kids!"
                break
            }
            #"Vengance"
            16 {
                $ending_addition = " Vengance"
                break
            }
             #"Deluxe"
            17 {
                $ending_addition = " Deluxe"
                break
            }
            # otherwise, do nothing
        }
        if($ending_addition -ne "")
        {
            $title = $title + $ending_addition
        }
    }
    #return the completed Title
    return $title
}