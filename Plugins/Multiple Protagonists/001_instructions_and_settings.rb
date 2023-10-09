################################################################################
# Multiple Protagonists v5.0.0
# by NettoHikari
# 
# October 8, 2023
# 
# This script allows the player to have multiple main characters, each
# with their own Pokemon parties, PC and Item storages, Trainer data, etc. It is
# intended for use in games where the story is split between at least two
# playable protagonists (e.g. half the story from the main character's
# perspective, the other half from the perspective of the rival).
# 
# Credits MUST BE GIVEN to NettoHikari
# You should also credit the authors of Pokemon Essentials itself.
# 
#-------------------------------------------------------------------------------
# INSTALLATION
#-------------------------------------------------------------------------------
# Copy this plugin's folder (named "Multiple Protagonists") into your project's
# Plugins folder. In addition, make sure to define all of your playable
# characters in the Global Metadata (found under "PBS/metadata.txt" in your game
# folder), starting with section [1].
# 
# Before using this script, make sure to start a new save file when testing.
# Since it adds new stored data, the script will probably throw errors when used
# with saves where the script wasn't present before.
# 
# You'll need to allow the use of \PN1, \PN2, etc. for map names and Show Text
# boxes, exactly like how \PN works. To do this, follow the instructions below.

=begin
  1. In section Messages, around line 265:
  
     gsubPN(name) # Add this above
     name.gsub!(/\\PN/, $player.name) if $player # Find this
  
  2. In section Messages, around line 448:
  
     gsubPN(text) if defined?(gsubPN) # Add this above
     text.gsub!(/\\pn/i,  $player.name) if $player # Find this
  
  3. In section Battle_StartAndEnd, around line 419:
  
     gsubPN(msg) # Add this above
     pbDisplayPaused(msg.gsub(/\\[Pp][Nn]/, pbPlayer.name)) # Find this
  
  4. In section Battle_StartAndEnd, around line 456:
  
     gsubPN(msg) # Add this above
     pbDisplayPaused(msg.gsub(/\\[Pp][Nn]/, pbPlayer.name)) # Find this

  5. In section MapMetadata, around line 124:

     gsubPN(ret) if defined?(gsubPN) # Add this above
     ret.gsub!(/\\PN/, $player.name) if $player # Find this
     
  6. For any third-party script you install, if you see a line with any variant
     of "\PN" or "\[Pp][Nn]", then you will need to add a line above it like
     "gsubPN(text)", where "text" needs to be replaced with whatever variable
     name is being used. For example, if you are using Mr. Gela's Name Windows
     script:
     
     gsubPN(text) if defined?(gsubPN) # Add this above
     text.gsub!(/\\[Pp][Nn]/,$Trainer.name) if $Trainer # Find this

=end

#-------------------------------------------------------------------------------
# SCRIPT USAGE
#-------------------------------------------------------------------------------
# 
#-------------------------------------------------------------------------------
# INITIALIZING AND SWITCHING BETWEEN CHARACTERS
#-------------------------------------------------------------------------------
# To switch to another character at any point in the story, simply call
# "pbSwitchCharacter(id)", where the id corresponds to the definition in the
# Global Metadata (starting with character 1). If you're switching to a
# character for the first time, you can pass in the same parameters as you would
# for "pbTrainerName", though it's not necessary.
# 
# At the start of the game, the character id is initially 1. Use
# pbTrainerName to set the character up instead of pbSwitchCharacter, unless
# you want the starting character to NOT be character 1.
# 
# Ex. Starting out as character 1:
# 
# pbTrainerName # Notice that this is the same as in base Essentials
# 
# Ex. If you want to switch to character 3 and let the player choose their name:
# 
# pbSwitchCharacter(3)
# 
# Ex. If you then want to switch to character 2 with the name "Leaf" and outfit 3:
# 
# pbSwitchCharacter(2, "Leaf", 3)
# 
# All global switches/variables and event self-switches DO NOT get saved in
# the character's data, so if you have an event that you want each character to
# be able to use once, make sure to handle that by having the event keep track of
# which characters have already used it.
# 
#-------------------------------------------------------------------------------
# PAUSE MENU SWITCHING
#-------------------------------------------------------------------------------
# You can enable and disable the "Switch" command in the pause menu with one of
# the following scripts:
# 
# pbEnableCharacterCommandSwitching
# pbDisableCharacterCommandSwitching
# 
# When switching from the pause menu, it will automatically fade out of the
# current map, transfer the player, and fade in to the new map. However, if the
# "pbSwitchCharacter" function is called through an event, you will need to use
# the "Transfer Player" command to transfer the player on your own.
# 
# You can enable and disable certain characters from the Switch command with
# "pbEnableCharacter(id)" and "pbDisableCharacter(id)", where "id" is the
# character id.
# 
# Ex. You have enabled character switching from the pause menu, but want to
# exclude character 3 from the list of characters to switch to:
# 
# pbDisableCharacter(3)
# 
# The "pbSetLastMap(id, map_id, x, y, dir)" function lets you set the spawn
# point of the character id to the specified location the next time that
# character is switched to from the pause menu (not from an event).
# 
# Ex. You're currently playing as character 2, and want to make sure that the
# next time you switch to character 1 from the pause menu, they end up at map
# ID 3, coordinates (5, 7), and facing up:
# 
# pbSetLastMap(1, 3, 5, 7, 8)
# 
#-------------------------------------------------------------------------------
# BATTLES BETWEEN CHARACTERS
#-------------------------------------------------------------------------------
# You can register or battle against other characters (even yourself!) by
# setting the trainer id as the character id and the trainer name as
# "PROTAG". The general format is "pbRegisterPartnerFromCharacter(character_id)"
# and "TrainerBattle.start(pbCreateTrainerFromCharacter(character_id))".
# 
# Ex, If you want to fight against character 2, you can use this script:
# 
# TrainerBattle.start(pbCreateTrainerFromCharacter(2))
# 
# Ex. If you want to fight alongside character 2 against character 3 and Camper
# Liam, the following two lines can be used:
# 
# pbRegisterPartnerFromCharacter(2)
# TrainerBattle.start(pbCreateTrainerFromCharacter(3), :CAMPER, "Liam")
# 
# Ex. If a character wants to fight against themselves, use this script:
# 
# TrainerBattle.start(pbCreateTrainerFromCharacter($player.character_ID))
# 
#-------------------------------------------------------------------------------
# TRADING BETWEEN CHARACTERS
#-------------------------------------------------------------------------------
# You can trade between characters in a manner similar to how you would trade
# with an NPC. You can choose a Pokemon from another character using one of
# these functions:
# 
# pbChoosePokemonFromCharacter(id,variableNumber,nameVarNumber,ableProc=nil,allowIneligible=false)
# pbChooseTradablePokemonFromCharacter(id,variableNumber,nameVarNumber,ableProc=nil,allowIneligible=false)
# 
# Where "id" is the character ID, and the next four parameters are the same as
# the base Essentials functions of "pbChoosePokemon" and
# "pbChooseTradablePokemon".
# 
# You can then initiate the trade using:
# 
# pbTradeWithCharacter(id, firstPokemonIndex, secondPokemonIndex)
# 
# Where "id" is the other character's ID, "firstPokemonIndex" is the index of
# the current player's chosen Pokemon, and "secondPokemonIndex" is the index of
# the other character's chosen Pokemon.
# 
# Ex. Assume character 1 is the current character and wants to trade with
# character 2.
# 
# First choose a Pokemon from the current character:
# pbChoosePokemon(1, 2) # "pbGet(1)" is firstPokemonIndex
# 
# If pbGet(1) is not -1, choose a Pokemon from character 2:
# pbChoosePokemonFromCharacter(2, 3, 4) # "pbGet(3)" is secondPokemonIndex
# # The first "2" means character ID of 2
# 
# If pbGet(3) is not -1, perform the trade:
# pbTradeWithCharacter(2, pbGet(1), pbGet(3))
# # The first "2" means character ID of 2
# 
# You can put whatever messages and other commands you want for your trade
# event. Visit the "Trading Pokemon" section on the Essentials wiki to see an
# example of a default trade event.
# 
# You can also have the current character send a Pokemon to another character
# using this function: "pbSendToCharacter(id, pokemonIndex)". The current
# character cannot send their last remaining Pokemon away, and the recipient
# must have space in either their party or storage to receive the Pokemon.
# 
# Ex. The current character wants to send a Pokemon to character 2.
# 
# First choose a Pokemon from the current character:
# pbChoosePokemon(1, 2)
# 
# If pbGet(1) is not -1, send to character 2:
# pbSendToCharacter(2, pbGet(1))
# 
#-------------------------------------------------------------------------------
# SHARING RESOURCES BETWEEN CHARACTERS
#-------------------------------------------------------------------------------
# You can currently share the following resources between all characters:
# - :pokedex
# - :bag
# - :pokemon_storage
# - :pc_item_storage
# 
# You can enable sharing at any time using the following command:
# 
# pbEnableSharingBetweenCharacters(key)
# 
# where "key" is any of the resources listed above. This will make it so that
# all existing characters and any new characters that are initialized will
# access the same resource
# 
# You can disable sharing at any time using the following command:
# 
# pbDisableSharingBetweenCharacters(key)
# 
# WARNING: If it's a storage type of resource, it does NOT split the contents
# into the individual resources, instead it will just copy all of the contents
# to each individual resource. If you allow players to enable/disable sharing at
# will, it would be possible for them to use the system to duplicate items or
# Pokemon.
# 
# Ex. If you want to enable sharing Pokedex data between all characters:
# 
# pbEnableSharingBetweenCharacters(:pokedex)
# 
#-------------------------------------------------------------------------------
# MISC.
#-------------------------------------------------------------------------------
# You can use this variable to get the ID of the character currently being
# played as: $player.character_ID
# 
# You can use \PN1, \PN2, etc. to refer to each of the protagonists' names (\PN1
# is character 1, \PN2 is character 2, and so on) in map names exactly like the
# way you use \PN to refer to the name of the current character.
# 
# Refer to "Script Compatibility" to add more data that you want to track
# for each character.
# 
#-------------------------------------------------------------------------------
# POTENTIAL BUGS
#-------------------------------------------------------------------------------
# Any maps that have \PN in the name (a placeholder for the player's name) have
# a minor bug of not updating the map's name correctly. For example, if a player
# named Red steps into a house named "\PN's House", the name would show as
# "Red's House", and if later another character named Blue comes in, the name
# would still show "Red's House", UNTIL you save, close and open the game again,
# in which case it will then turn into "Blue's House". If you have any maps with
# \PN in it, this can be fixed by replacing the following:
# 
# name.gsub!(/\\PN/, $player.name) if $player # Find this
# 
# with:
# 
# name = name.gsub(/\\PN/, $player.name) if $player # Replace it with this
# 
# Solution added by Tustin2121
# 
#-------------------------------------------------------------------------------
# SCRIPT COMPATIBILITY
#-------------------------------------------------------------------------------
# This script works just fine in base Essentials (and Golisopod User's Following
# Pokemon EX script if you use that), but if you add any new data for your
# character outside of data that is already saved by this script, you will need
# to add that into this script manually. For example, if you add a new variable
# in class Player, you DO NOT need to do anything as the entire Player object is
# saved for each character. However, you MAY need to add it below if you add a
# new variable in class PokemonGlobalMetadata or elsewhere. Below is a guide on
# how to add such data to this script (I use the value of Game Switch 005 as an
# example, but you can apply this to whatever you actually need to add).
# 
# Define a data handler similar to the following:
# 
# MultipleProtagonistsCharacterDataHandler.add(:game_switch_five, {
#   :set_data_value => proc { |value|
#     $game_switches[5] = value
#   },
#   :get_data_value => proc { $game_switches[5] },
#   :get_default_value => proc { false },
#   :data_classification => :standard
# })
# 
# :set_data_value is the function that gets called to set the attribute of the
# new character when pbSwitchCharacter is called.
# :get_data_value is the function that gets called to store the attribute of the
# old character when pbSwitchCharacter is called.
# :get_default_value is the function that gets called to initialize the
# attribute of the new character when pbSwitchCharacter is called.
# :data_classification determines the grouping of data attributes together. For
# example, map-related data (map ID, x, y, direction) are set before all other
# attributes in pbSwitchCharacter to make map transfer possible.
# 
# Once you've added the data you needed, make sure to start a new save in order
# to test those changes.
# 
#-------------------------------------------------------------------------------
# I would like to acknowledge Tustin2121 for making a tutorial for Multiple
# Protagonists on the old wiki, before the wiki was shut down. His tutorial
# essentially laid the basis for how I designed my script.
# 
# I hope you enjoy it!
# - NettoHikari
################################################################################

def hasFollowerScript?
  return defined?(FollowingPkmn)
end

MAX_CHARACTERS = 8
