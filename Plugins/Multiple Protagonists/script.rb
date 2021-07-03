################################################################################
# Multiple Protagonists v4.0.2
# by NettoHikari
# 
# July 2, 2021
# 
# This script allows the player to have up to 8 main characters, each with their
# own Pokemon parties, PC and Item storages, Trainer data, etc. It is intended
# for use in games where the story is split between at least two playable
# protagonists (e.g. half the story from the main character's perspective,
# the other half from the perspective of the rival).
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
# folder), starting with PlayerA (and up to PlayerH).
# 
# Before using this script, make sure to start a new save file when testing.
# Since it adds new stored data, the script will probably throw errors when used
# with saves where the script wasn't present before.
# 
# To install the "Switch" character command in the pause menu, follow the
# instructions below.
# 
# You will need to paste the following code into the section "UI_PauseMenu"
# at the appropriate lines (all of which are under "def pbStartPokemonMenu").
# If you've already made your own edits to the script before, then ignore the
# suggested line numbers below and just find each line with CTRL + Shift + F.

=begin
  1. You'll need to start by defining a variable for the command. Place the
     following line AFTER the line "cmdEndGame  = -1" (around line 115):
  
     cmdEndGame  = -1 # Find this
     cmdSwitch   = -1 # Add this below
  
  2. Now you need to add it to the list of pause menu commands. Place these 4
     lines AFTER the line "commands[cmdTrainer = commands.length]  = $Trainer.name"
     (around line 123):
  
     commands[cmdTrainer = commands.length]  = $Trainer.name # Find this
     # Add following lines below
     if $PokemonGlobal.commandCharacterSwitchOn && !pbInSafari? &&
           !pbInBugContest? && !pbBattleChallenge.pbInProgress?
       commands[cmdSwitch = commands.length] = _INTL("Switch")
     end
  
  3. Finally, you need to add the code for what actually happens when the player
     selects the command. Add the following code BEFORE the line
     "elsif cmdOption>=0 && command==cmdOption" (around line 256):
  
     elsif cmdSwitch>=0 && command==cmdSwitch
       characters = []
       characterIDs = []
       for i in 0...8
         if $PokemonGlobal.allowedCharacters[i] && i != $Trainer.character_ID
           characters.push(getTrainerFromCharacter(i).name)
           characterIDs.push(i)
         end
       end
       if characters.length <= 0
         pbMessage(_INTL("You're the only character!"))
         next
       end
       characters.push("Cancel")
       command = pbShowCommands(nil, characters, characters.length)
       if command >= 0 && command < characters.length - 1
         @scene.pbHideMenu
         pbSwitchCharacter(characterIDs[command])
         break
       end
     # Add lines above this line
     elsif cmdOption>=0 && command==cmdOption # Find this
  
  4. That's it! When you enable character switching through the menu, this
     should now show up and let the player switch between characters.
=end

# In addition, you'll need to allow the use of \PN0 - \PN7 for map names and
# Show Text boxes, exactly like how \PN works. To do this, follow the
# instructions below.

=begin
  1. In section Game_Map, around line 101:
  
     gsubPN(ret) # Add this above
     ret.gsub!(/\\PN/,$Trainer.name) if $Trainer # Find this
  
  2. In section Messages, around line 355:
  
     gsubPN(map) # Add this above
     map.gsub!(/\\PN/,$Trainer.name) if $Trainer # Find this
  
  3. In section Messages, around line 546:
  
     gsubPN(text) if defined?(gsubPN) # Add this above
     text.gsub!(/\\pn/i,$Trainer.name) if $Trainer # Find this
  
  4. In section Battle_StartAndEnd, around line 411:
  
     gsubPN(msg) # Add this above
     pbDisplayPaused(msg.gsub(/\\[Pp][Nn]/,pbPlayer.name)) # Find this
  
  5. In section Battle_StartAndEnd, around line 446:
  
     gsubPN(msg) # Add this above
     pbDisplayPaused(msg.gsub(/\\[Pp][Nn]/,pbPlayer.name)) # Find this
     
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
# Global Metadata (PlayerA is 0, PlayerB is 1, etc). If you're switching to a
# character for the first time, you can pass in the same parameters as you would
# for "pbTrainerName", though it's not necessary.
# 
# At the start of the game, the character id is initially 0 (PlayerA). Use
# pbTrainerName to set the character up instead of pbSwitchCharacter, unless
# you want the starting character to NOT be PlayerA.
# 
# Ex. Starting out as Player A:
# 
# pbTrainerName # Notice that this is the same as in base Essentials
# 
# Ex. If you want to switch to Player C and let the player choose their name:
# 
# pbSwitchCharacter(2)
# 
# Ex. If you then want to switch to Player B with the name "Leaf" and outfit 3:
# 
# pbSwitchCharacter(1, "Leaf", 3)
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
# exclude Player C from the list of characters to switch to:
# 
# pbDisableCharacter(2)
# 
# The "pbSetLastMap(id, map_id, x, y, dir)" function lets you set the spawn
# point of the character id to the specified location the next time that
# character is switched to from the pause menu (not from an event).
# 
# Ex. You're currently playing as Player B, and want to make sure that the next
# time you switch to Player A from the pause menu, they end up at map ID 3,
# coordinates (5, 7), and facing up:
# 
# pbSetLastMap(0, 3, 5, 7, 8)
# 
#-------------------------------------------------------------------------------
# BATTLES BETWEEN CHARACTERS
#-------------------------------------------------------------------------------
# You can register or battle against other characters (even yourself!) by
# setting the trainer id as the character id and the trainer name as
# "PROTAG". The general format is "pbRegisterPartner(character_id, "PROTAG")"
# and "pbTrainerBattle(character_id, "PROTAG")" (and similar for one or more)
# characters in pbDoubleTrainerBattle).
# 
# Ex, If you want to fight against Player B, you can use this script:
# 
# pbTrainerBattle(1, "PROTAG")
# 
# Ex. If you want to fight alongside Player B against Player C and Camper
# Liam, the following two lines can be used:
# 
# pbRegisterPartner(1, "PROTAG")
# pbDoubleTrainerBattle(2, "PROTAG", 0, nil, :CAMPER, "Liam")
# 
# Ex. If a character wants to fight against themselves, use this script:
# 
# pbTrainerBattle($Trainer.character_ID, "PROTAG")
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
# Ex. Assume Player A (the current character) wants to trade with Player B.
# 
# First choose a Pokemon from the current character:
# pbChoosePokemon(1, 2) # "pbGet(1)" is firstPokemonIndex
# 
# If pbGet(1) is not -1, choose a Pokemon from Player B:
# pbChoosePokemonFromCharacter(1, 3, 4) # "pbGet(3)" is secondPokemonIndex
# # The first "1" means character ID of 1 = Player B
# 
# If pbGet(3) is not -1, perform the trade:
# pbTradeWithCharacter(1, pbGet(1), pbGet(3))
# # The first "1" means character ID of 1 = Player B
# 
# You can put whatever messages and other commands you want for your trade
# event. Visit the "Trading Pokemon" section on the Essentials wiki to see an
# example of a default trade event.
# 
# You can also have the current character send a Pokemon to another character
# using this function: "pbSendToCharacter(id, pokemonIndex)". The current
# player cannot send their last remaining Pokemon away, and the recipient
# must have space in either their party or storage to receive the Pokemon.
# 
# Ex. Player A wants to send a Pokemon to Player B.
# 
# First choose a Pokemon from the current character:
# pbChoosePokemon(1, 2)
# 
# If pbGet(1) is not -1, send to Player B:
# pbSendToCharacter(1, pbGet(1))
# 
#-------------------------------------------------------------------------------
# MISC.
#-------------------------------------------------------------------------------
# You can use this variable to get the ID of the character currently being
# played as: $Trainer.character_ID
# 
# You can use \PN0 - \PN7 to refer to each of the protagonists' names (\PN0 is
# PlayerA, \PN1 is Player B, and so on) in map names exactly like the way you
# use \PN to refer to the name of the current player.
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
# ret.gsub!(/\\PN/,$Trainer.name) if $Trainer # Find this
# 
# with:
# 
# ret=ret.gsub(/\\PN/,$Trainer.name) if $Trainer # Replace it with this
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
# how to add such data to this script (I use switch ID 5 as an example, but you
# can apply this to whatever you actually need to add).
# 
# 1. Add a constant for the data to the bottom of module PBCharacterData:
# 
#     CurrentDiving       = 44 # Find these two lines
#    end
#    Example              = XX # Add this (name can be whatever makes sense)
#    # The next number (XX) should be one more than the previous number.
#    # If you haven't added data using this tutorial yet, XX would be 45.
# 
# 2. In def pbSwitchCharacter:
# 
#    $PokemonGlobal.mapTrail              = meta[PBCharacterData::MapTrail] # Find this
#    $game_switches[5]                    = meta[PBCharacterData::Example]  # Add this
# 
# 3. In def pbCharacterInfoArray:
# 
#    info[PBCharacterData::MapTrail]              = $PokemonGlobal.mapTrail # Find this
#    info[PBCharacterData::Example]               = $game_switches[5]       # Add this
# 
# 4. In def pbDefaultCharacterInfoArray:
# 
#    info[PBCharacterData::MapTrail]              = []    # Find this
#    info[PBCharacterData::Example]               = false # Add this
# 
# 5. Once you've added the data you needed, make sure to start a new save in
#    order to test those changes.
# 
#-------------------------------------------------------------------------------
# I would like to acknowledge Tustin2121 for making a tutorial for Multiple
# Protagonists on the old wiki, before the wiki was shut down. His tutorial
# essentially laid the basis for how I would design my script.
# 
# I hope you enjoy it!
# - NettoHikari
################################################################################

def hasFollowerScript?
  return defined?(FollowerSettings)
end

# List of objects stored for each character
# 0. Trainer Object
# 1. Item Bag
# 2. Pokemon Storage
# 3. Mailbox
# 4. Item Storage
# 5. Happiness Steps
# 6. Pokerus Time
# 7. Daycare Pokemon
# 8. Daycare Egg
# 9. Daycare Egg Steps
# 10. Current Pokedex
# 11. Last Viewed Pokemon in each Dex
# 12. Pokedex Search Mode
# 13. Visited Maps
# 14. Partner Trainer
# 15. Phone Numbers
# 16. Phone Time
# 17. Dependent Events
# 18. Pokeradar Battery
# 19. Purify Chamber
# 20. Triad Collection
# 21. Last Map
# 22. Last X
# 23. Last Y
# 24. Last Direction
# 25. Bicycle Active
# 26. Surfing Active
# 27. Diving Active
# 28. Repel Steps Remaining
# 29. Flash Active
# 30. Bridge Tile Passage
# 31. Last Healing Spot
# 32. Cave Escape Point
# 33. Last Pokecenter Map ID
# 34. Last Pokecenter X
# 35. Last Pokecenter Y
# 36. Last Pokecenter Direction
# 37. Last Battle (Battle Tower)
# 38. Map Trail
# 
# If Following Pokemon EX script is installed:
# 39. Following Active
# 40. Call Refresh
# 41. Time Taken (related to Happiness)
# 42. Follower Hold Item (picked up from following)
# 43. Currently Surfing
# 44. Currently Diving

module PBCharacterData
  Trainer               = 0
  PokemonBag            = 1
  PokemonStorage        = 2
  Mailbox               = 3
  PCItemStorage         = 4
  HappinessSteps        = 5
  PokerusTime           = 6
  Daycare               = 7
  DaycareEgg            = 8
  DaycareEggSteps       = 9
  PokedexDex            = 10
  PokedexIndex          = 11
  PokedexMode           = 12
  VisitedMaps           = 13
  Partner               = 14
  PhoneNumbers          = 15
  PhoneTime             = 16
  DependentEvents       = 17
  PokeradarBattery      = 18
  PurifyChamber         = 19
  Triads                = 20
  MapID                 = 21
  X                     = 22
  Y                     = 23
  Direction             = 24
  Bicycle               = 25
  Surfing               = 26
  Diving                = 27
  Repel                 = 28
  FlashUsed             = 29
  Bridge                = 30
  HealingSpot           = 31
  EscapePoint           = 32
  PokecenterMapID       = 33
  PokecenterX           = 34
  PokecenterY           = 35
  PokecenterDirection   = 36
  LastBattle            = 37
  MapTrail              = 38
  if hasFollowerScript?
    FollowerToggled     = 39
    CallRefresh         = 40
    TimeTaken           = 41
    FollowerHoldItem    = 42
    CurrentSurfing      = 43
    CurrentDiving       = 44
  end
end

class PokemonGlobalMetadata
  attr_accessor :mainCharacters           # Stores all protagonists' data
  attr_accessor :commandCharacterSwitchOn # Enables character switching from menu
  attr_accessor :allowedCharacters        # Characters allowed for command switching
  
  alias new_initialize initialize
  def initialize
    new_initialize
    @mainCharacters = Array.new(8)
    @commandCharacterSwitchOn = false
    @allowedCharacters = Array.new(8, false)
    @allowedCharacters[0] = true
  end
end

# Enables character switching through pause menu
def pbEnableCharacterCommandSwitching
  $PokemonGlobal.commandCharacterSwitchOn = true
end

# Disables character switching through pause menu
def pbDisableCharacterCommandSwitching
  $PokemonGlobal.commandCharacterSwitchOn = false
end

# Enables specific character in command switching
def pbEnableCharacter(id)
  return if !characterIDValid?(id)
  $PokemonGlobal.allowedCharacters[id] = true
end

# Disables specific character in command switching
def pbDisableCharacter(id)
  return if !characterIDValid?(id)
  $PokemonGlobal.allowedCharacters[id] = false
end

# Main function to switch between characters
def pbSwitchCharacter(id, name = nil, outfit = 0)
  return if id<0 || id>=8 || id == $Trainer.character_ID
  meta = $PokemonGlobal.mainCharacters[id]
  oldid = $Trainer.character_ID
  $PokemonGlobal.mainCharacters[oldid] = pbCharacterInfoArray
  if meta.nil? # Set up trainer for the first time
    $Trainer = Player.new("Unnamed", GameData::Metadata.get_player(id)[0])
    $Trainer.character_ID = id
    pbTrainerName(name, outfit)
    $Trainer.id = pbGetForeignCharacterID
    $PokemonTemp.begunNewGame = false
    # Create and store new character's meta
    newmeta = pbDefaultCharacterInfoArray
    newmeta[PBCharacterData::Trainer] = $Trainer
    $PokemonGlobal.mainCharacters[id] = newmeta
    meta = $PokemonGlobal.mainCharacters[id]
    pbEnableCharacter(id)
  end
  if pbMapInterpreterRunning? # Must have been called through event command
    meta[PBCharacterData::MapID]                 = -1
    meta[PBCharacterData::X]                     = -1
    meta[PBCharacterData::Y]                     = -1
    meta[PBCharacterData::Direction]             = -1
    meta[PBCharacterData::Bicycle]               = false
    meta[PBCharacterData::Surfing]               = false
    meta[PBCharacterData::Diving]                = false
    meta[PBCharacterData::Repel]                 = 0
    meta[PBCharacterData::FlashUsed]             = false
    meta[PBCharacterData::Bridge]                = 0
    meta[PBCharacterData::EscapePoint]           = []
  end
  # Assumes that if called through event, then meta[PBCharacterData::MapID]
  # was set to -1 earlier
  # Fades out to prepare for player map transfer
  if meta[PBCharacterData::MapID] >= 0 && $PokemonGlobal.commandCharacterSwitchOn
    $game_screen.start_tone_change(Tone.new(-255, -255, -255, 0), 12)
    pbWait(16)
  end
  # Set to blank array so that dependent events of other character aren't
  # affected
  $PokemonGlobal.dependentEvents       = []
  $PokemonTemp.dependentEvents.removeAllEvents()
  # Assumes that if called through event, then meta[PBCharacterData::MapID]
  # was set to -1 earlier
  # Performs map transfer on player
  if meta[PBCharacterData::MapID] >= 0 && $PokemonGlobal.commandCharacterSwitchOn
    $game_temp.player_new_map_id       = meta[PBCharacterData::MapID]
    $game_temp.player_new_x            = meta[PBCharacterData::X]
    $game_temp.player_new_y            = meta[PBCharacterData::Y]
    $game_temp.player_new_direction    = meta[PBCharacterData::Direction]
    $scene.transfer_player
  end
  # Set all game data to new character's data
  $Trainer                             = meta[PBCharacterData::Trainer]
  $PokemonBag                          = meta[PBCharacterData::PokemonBag]
  $PokemonStorage                      = meta[PBCharacterData::PokemonStorage]
  $PokemonGlobal.mailbox               = meta[PBCharacterData::Mailbox]
  $PokemonGlobal.pcItemStorage         = meta[PBCharacterData::PCItemStorage]
  $PokemonGlobal.happinessSteps        = meta[PBCharacterData::HappinessSteps]
  $PokemonGlobal.pokerusTime           = meta[PBCharacterData::PokerusTime]
  $PokemonGlobal.daycare               = meta[PBCharacterData::Daycare]
  $PokemonGlobal.daycareEgg            = meta[PBCharacterData::DaycareEgg]
  $PokemonGlobal.daycareEggSteps       = meta[PBCharacterData::DaycareEggSteps]
  $PokemonGlobal.pokedexDex            = meta[PBCharacterData::PokedexDex]
  $PokemonGlobal.pokedexIndex          = meta[PBCharacterData::PokedexIndex]
  $PokemonGlobal.pokedexMode           = meta[PBCharacterData::PokedexMode]
  $PokemonGlobal.visitedMaps           = meta[PBCharacterData::VisitedMaps]
  $PokemonGlobal.partner               = meta[PBCharacterData::Partner]
  $PokemonGlobal.phoneNumbers          = meta[PBCharacterData::PhoneNumbers]
  $PokemonGlobal.phoneTime             = meta[PBCharacterData::PhoneTime]
  $PokemonGlobal.dependentEvents       = meta[PBCharacterData::DependentEvents]
  # Resetting the dependent events causes new unwanted maps to be added to
  # the map factory, so delete them before the scene can be updated
  oldmaps = []
  $MapFactory.maps.each {|map| oldmaps.push(map.map_id)}
  $PokemonTemp.dependentEvents = DependentEvents.new
  $MapFactory.maps.delete_if {|map| !oldmaps.include?(map.map_id)}
  $PokemonTemp.dependentEvents.updateDependentEvents
  $PokemonGlobal.pokeradarBattery      = meta[PBCharacterData::PokeradarBattery]
  $PokemonGlobal.purifyChamber         = meta[PBCharacterData::PurifyChamber]
  $PokemonGlobal.triads                = meta[PBCharacterData::Triads]
  $PokemonGlobal.bicycle               = meta[PBCharacterData::Bicycle]
  $PokemonGlobal.surfing               = meta[PBCharacterData::Surfing]
  $PokemonGlobal.diving                = meta[PBCharacterData::Diving]
  $PokemonGlobal.repel                 = meta[PBCharacterData::Repel]
  $PokemonGlobal.flashUsed             = meta[PBCharacterData::FlashUsed]
  $PokemonGlobal.bridge                = meta[PBCharacterData::Bridge]
  $PokemonGlobal.healingSpot           = meta[PBCharacterData::HealingSpot]
  $PokemonGlobal.escapePoint           = meta[PBCharacterData::EscapePoint]
  $PokemonGlobal.pokecenterMapId       = meta[PBCharacterData::PokecenterMapID]
  $PokemonGlobal.pokecenterX           = meta[PBCharacterData::PokecenterX]
  $PokemonGlobal.pokecenterY           = meta[PBCharacterData::PokecenterY]
  $PokemonGlobal.pokecenterDirection   = meta[PBCharacterData::PokecenterDirection]
  $PokemonGlobal.lastbattle            = meta[PBCharacterData::LastBattle]
  $PokemonGlobal.mapTrail              = meta[PBCharacterData::MapTrail]
  if hasFollowerScript?
    $PokemonGlobal.follower_toggled    = meta[PBCharacterData::FollowerToggled]
    $PokemonGlobal.call_refresh        = meta[PBCharacterData::CallRefresh]
    $PokemonGlobal.time_taken          = meta[PBCharacterData::TimeTaken]
    $PokemonGlobal.follower_hold_item  = meta[PBCharacterData::FollowerHoldItem]
    $PokemonGlobal.current_surfing     = meta[PBCharacterData::CurrentSurfing]
    $PokemonGlobal.current_diving      = meta[PBCharacterData::CurrentDiving]
    $PokemonTemp.dependentEvents.refresh_sprite
  end
  $game_player.charsetData = nil
  pbUpdateVehicle
  # Assumes that if called through event, then meta[PBCharacterData::MapID]
  # was set to -1 earlier
  # Fades in to new map after transferring player
  if meta[PBCharacterData::MapID] >= 0 && $PokemonGlobal.commandCharacterSwitchOn
    $game_screen.start_tone_change(Tone.new(0, 0, 0, 0), 12)
    pbWait(16)
  end
end

class PokemonMapFactory
  attr_accessor :maps
end

# Saves data of Player A (id 0) at start of game
alias protag_pbTrainerName pbTrainerName
def pbTrainerName(name=nil,outfit=0)
  protag_pbTrainerName(name, outfit)
  if $Trainer.character_ID == 0
    $PokemonGlobal.mainCharacters[0] = pbCharacterInfoArray
  end
end

# Sets the "last map" variables of character
def pbSetLastMap(id, map_id, x, y, dir)
  return if !characterIDValid?(id) || map_id < 0
  info = $PokemonGlobal.mainCharacters[id]
  info[PBCharacterData::MapID]                 = map_id
  info[PBCharacterData::X]                     = x
  info[PBCharacterData::Y]                     = y
  info[PBCharacterData::Direction]             = dir
  info[PBCharacterData::Bicycle]               = false
  info[PBCharacterData::Surfing]               = false
  info[PBCharacterData::Diving]                = false
  info[PBCharacterData::Repel]                 = 0
  info[PBCharacterData::FlashUsed]             = false
  info[PBCharacterData::Bridge]                = 0
  info[PBCharacterData::HealingSpot]           = nil
  info[PBCharacterData::EscapePoint]           = []
  info[PBCharacterData::PokecenterMapID]       = -1
  info[PBCharacterData::PokecenterX]           = -1
  info[PBCharacterData::PokecenterY]           = -1
  info[PBCharacterData::PokecenterDirection]   = -1
end

def pbCharacterInfoArray
  info = []
  info[PBCharacterData::Trainer]               = $Trainer
  info[PBCharacterData::PokemonBag]            = $PokemonBag
  info[PBCharacterData::PokemonStorage]        = $PokemonStorage
  info[PBCharacterData::Mailbox]               = $PokemonGlobal.mailbox
  info[PBCharacterData::PCItemStorage]         = $PokemonGlobal.pcItemStorage
  info[PBCharacterData::HappinessSteps]        = $PokemonGlobal.happinessSteps
  info[PBCharacterData::PokerusTime]           = $PokemonGlobal.pokerusTime
  info[PBCharacterData::Daycare]               = $PokemonGlobal.daycare
  info[PBCharacterData::DaycareEgg]            = $PokemonGlobal.daycareEgg
  info[PBCharacterData::DaycareEggSteps]       = $PokemonGlobal.daycareEggSteps
  info[PBCharacterData::PokedexDex]            = $PokemonGlobal.pokedexDex
  info[PBCharacterData::PokedexIndex]          = $PokemonGlobal.pokedexIndex
  info[PBCharacterData::PokedexMode]           = $PokemonGlobal.pokedexMode
  info[PBCharacterData::VisitedMaps]           = $PokemonGlobal.visitedMaps
  info[PBCharacterData::Partner]               = $PokemonGlobal.partner
  info[PBCharacterData::PhoneNumbers]          = $PokemonGlobal.phoneNumbers
  info[PBCharacterData::PhoneTime]             = $PokemonGlobal.phoneTime
  info[PBCharacterData::DependentEvents]       = $PokemonGlobal.dependentEvents
  info[PBCharacterData::PokeradarBattery]      = $PokemonGlobal.pokeradarBattery
  info[PBCharacterData::PurifyChamber]         = $PokemonGlobal.purifyChamber
  info[PBCharacterData::Triads]                = $PokemonGlobal.triads
  info[PBCharacterData::MapID]                 = $game_map.map_id
  info[PBCharacterData::X]                     = $game_player.x
  info[PBCharacterData::Y]                     = $game_player.y
  info[PBCharacterData::Direction]             = $game_player.direction
  info[PBCharacterData::Bicycle]               = $PokemonGlobal.bicycle
  info[PBCharacterData::Surfing]               = $PokemonGlobal.surfing
  info[PBCharacterData::Diving]                = $PokemonGlobal.diving
  info[PBCharacterData::Repel]                 = $PokemonGlobal.repel
  info[PBCharacterData::FlashUsed]             = $PokemonGlobal.flashUsed
  info[PBCharacterData::Bridge]                = $PokemonGlobal.bridge
  info[PBCharacterData::HealingSpot]           = $PokemonGlobal.healingSpot
  info[PBCharacterData::EscapePoint]           = $PokemonGlobal.escapePoint
  info[PBCharacterData::PokecenterMapID]       = $PokemonGlobal.pokecenterMapId
  info[PBCharacterData::PokecenterX]           = $PokemonGlobal.pokecenterX
  info[PBCharacterData::PokecenterY]           = $PokemonGlobal.pokecenterY
  info[PBCharacterData::PokecenterDirection]   = $PokemonGlobal.pokecenterDirection
  info[PBCharacterData::LastBattle]            = $PokemonGlobal.lastbattle
  info[PBCharacterData::MapTrail]              = $PokemonGlobal.mapTrail
  if hasFollowerScript?
    info[PBCharacterData::FollowerToggled]     = $PokemonGlobal.follower_toggled
    info[PBCharacterData::CallRefresh]         = $PokemonGlobal.call_refresh
    info[PBCharacterData::TimeTaken]           = $PokemonGlobal.time_taken
    info[PBCharacterData::FollowerHoldItem]    = $PokemonGlobal.follower_hold_item
    info[PBCharacterData::CurrentSurfing]      = $PokemonGlobal.current_surfing
    info[PBCharacterData::CurrentDiving]       = $PokemonGlobal.current_diving
  end
  return info
end

def pbDefaultCharacterInfoArray
  info = []
  info[PBCharacterData::Trainer]               = nil
  info[PBCharacterData::PokemonBag]            = PokemonBag.new
  info[PBCharacterData::PokemonStorage]        = PokemonStorage.new
  info[PBCharacterData::Mailbox]               = nil
  info[PBCharacterData::PCItemStorage]         = nil
  info[PBCharacterData::HappinessSteps]        = 0
  info[PBCharacterData::PokerusTime]           = nil
  info[PBCharacterData::Daycare]               = [[nil,0],[nil,0]]
  info[PBCharacterData::DaycareEgg]            = false
  info[PBCharacterData::DaycareEggSteps]       = 0
  numRegions = pbLoadRegionalDexes.length
  info[PBCharacterData::PokedexDex]            = (numRegions==0) ? -1 : 0
  info[PBCharacterData::PokedexIndex]          = []
  for i in 0...numRegions+1     # National Dex isn't a region, but is included
    info[PBCharacterData::PokedexIndex][i]    = 0
  end
  info[PBCharacterData::PokedexMode]           = 0
  info[PBCharacterData::VisitedMaps]           = []
  info[PBCharacterData::Partner]               = nil
  info[PBCharacterData::PhoneNumbers]          = []
  info[PBCharacterData::PhoneTime]             = 0
  info[PBCharacterData::DependentEvents]       = nil
  info[PBCharacterData::PokeradarBattery]      = 0
  info[PBCharacterData::PurifyChamber]         = nil
  info[PBCharacterData::Triads]                = nil
  info[PBCharacterData::MapID]                 = -1
  info[PBCharacterData::X]                     = -1
  info[PBCharacterData::Y]                     = -1
  info[PBCharacterData::Direction]             = -1
  info[PBCharacterData::Bicycle]               = false
  info[PBCharacterData::Surfing]               = false
  info[PBCharacterData::Diving]                = false
  info[PBCharacterData::Repel]                 = 0
  info[PBCharacterData::FlashUsed]             = false
  info[PBCharacterData::Bridge]                = 0
  info[PBCharacterData::HealingSpot]           = nil
  info[PBCharacterData::EscapePoint]           = []
  info[PBCharacterData::PokecenterMapID]       = -1
  info[PBCharacterData::PokecenterX]           = -1
  info[PBCharacterData::PokecenterY]           = -1
  info[PBCharacterData::PokecenterDirection]   = -1
  info[PBCharacterData::LastBattle]            = nil
  info[PBCharacterData::MapTrail]              = []
  if hasFollowerScript?
    info[PBCharacterData::FollowerToggled]     = false
    info[PBCharacterData::CallRefresh]         = [false, false]
    info[PBCharacterData::TimeTaken]           = 0
    info[PBCharacterData::FollowerHoldItem]    = false
    info[PBCharacterData::CurrentSurfing]      = nil
    info[PBCharacterData::CurrentDiving]       = nil
  end
  return info
end

# Returns a trainer ID different from all other trainer IDs.
# Prevents two characters from accidentally having same trainer IDs on their
# trainer cards.
def pbGetForeignCharacterID
  characterIDs = []
  for i in 0...$PokemonGlobal.mainCharacters.length
    if $PokemonGlobal.mainCharacters[i] != nil
      characterIDs.push(getTrainerFromCharacter(i).id)
    end
  end
  id = $Trainer.make_foreign_ID
  while characterIDs.include?(id)
    id = $Trainer.make_foreign_ID
  end
  return id
end

# Substitutes \PN0-\PN7 with the appropriate trainer name
def gsubPN(name)
  global = $PokemonGlobal
  if global.nil? && SaveData.exists?
    save_data = SaveData.read_from_file(SaveData::FILE_PATH)
    global = save_data[:global_metadata]
  end
  return if global.nil?
  for i in 0..7
    if global.mainCharacters[i]
      name.gsub!(/\\[Pp][Nn]#{i}/, global.mainCharacters[i][PBCharacterData::Trainer].name)
    end
  end
end

# Clones and returns character trainer and party if given character id and
# "PROTAG" as trainer name, otherwise loads trainer data normally
alias reg_pbLoadTrainer pbLoadTrainer
def pbLoadTrainer(tr_type, tr_name, tr_version = 0)
  if tr_name == "PROTAG" && characterIDValid?(tr_type)
    original = (tr_type == $Trainer.character_ID) ? $Trainer : getTrainerFromCharacter(tr_type)
    cloned = Marshal.load(Marshal.dump(original))
    cloned_trainer = NPCTrainer.new(cloned.name, cloned.trainer_type)
    cloned_trainer.id = cloned.id
    cloned_trainer.party = cloned.party
    return cloned_trainer
  else
    return reg_pbLoadTrainer(tr_type, tr_name, tr_version)
  end
end

# Registeres a main character as partner if given character id and
# "PROTAG" as trainer name, otherwise registers partner normally
alias multiple_protag_pbRegisterPartner pbRegisterPartner
def pbRegisterPartner(tr_type, tr_name, tr_id = 0)
  if tr_name == "PROTAG" && characterIDValid?(tr_type)
    trainer = pbLoadTrainer(tr_type, tr_name, tr_id)
    Events.onTrainerPartyLoad.trigger(nil, trainer)
    for i in trainer.party
      i.owner = Pokemon::Owner.new_from_trainer(trainer)
      i.calc_stats
    end
    $PokemonGlobal.partner = [tr_type, tr_name, trainer.id, trainer.party]
  else
    multiple_protag_pbRegisterPartner(tr_type, tr_name, tr_id)
  end
end

# Gets $Trainer object at specific character ID
def getTrainerFromCharacter(id)
  return nil if id < 0 || id >= 8
  if id == $Trainer.character_ID
    return $Trainer
  else
    meta = $PokemonGlobal.mainCharacters[id]
    return nil if !meta
    return meta[PBCharacterData::Trainer]
  end
end

# Returns true if id is within range 0..7 and meta exists
def characterIDValid?(id)
  return id >= 0 && id < 8 && $PokemonGlobal.mainCharacters[id]
end

# Same as pbChoosePokemon but for another character (EXCLUDING the current character)
def pbChoosePokemonFromCharacter(id,variableNumber,nameVarNumber,ableProc=nil,allowIneligible=false)
  return if !characterIDValid?(id) || id == $Trainer.character_ID
  ot = $Trainer
  $Trainer = getTrainerFromCharacter(id) # Partial switch to new character
  pbChoosePokemon(variableNumber,nameVarNumber,ableProc,allowIneligible)
  $Trainer = ot # Restore original character
  $PokemonTemp.dependentEvents.refresh_sprite if hasFollowerScript?
end

# Same as pbChooseTradablePokemon but for another character (EXCLUDING the current character)
def pbChooseTradablePokemonFromCharacter(id,variableNumber,nameVarNumber,ableProc=nil,allowIneligible=false)
  return if !characterIDValid?(id) || id == $Trainer.character_ID
  ot = $Trainer
  $Trainer = getTrainerFromCharacter(id) # Partial switch to new character
  pbChooseTradablePokemon(variableNumber,nameVarNumber,ableProc,allowIneligible)
  $Trainer = ot # Restore original character
  $PokemonTemp.dependentEvents.refresh_sprite if hasFollowerScript?
end

# Trade with another character (just like NPC trade)
def pbTradeWithCharacter(id, firstPokemonIndex, secondPokemonIndex)
  return if !characterIDValid?(id) || id == $Trainer.character_ID
  firsttrainer = $Trainer
  firstpoke = firsttrainer.party[firstPokemonIndex]
  secondtrainer = getTrainerFromCharacter(id)
  secondpoke = secondtrainer.party[secondPokemonIndex]
  # secondtrainer will have firstpoke
  firstpoke.obtain_method = 2 # traded
  secondtrainer.pokedex.register(firstpoke)
  secondtrainer.pokedex.set_owned(firstpoke.species)
  # firsttrainer will have secondpoke
  secondpoke.obtain_method = 2 # traded
  firsttrainer.pokedex.register(secondpoke)
  firsttrainer.pokedex.set_owned(secondpoke.species)
  # Start trade animation
  pbFadeOutInWithMusic(99999){
    evo=PokemonTrade_Scene.new
    evo.pbStartScreen(firstpoke,secondpoke,firsttrainer.name,secondtrainer.name)
    evo.pbTrade
    evo.pbEndScreen
    newspecies = firstpoke.check_evolution_on_trade(secondpoke)
    if newspecies
      evo=PokemonEvolutionScene.new
      evo.pbStartScreen(firstpoke,newspecies)
      evo.pbEvolution(false)
      evo.pbEndScreen
    end
  }
  # Swap Pokemon
  firsttrainer.party[firstPokemonIndex] = secondpoke
  secondtrainer.party[secondPokemonIndex] = firstpoke
  $PokemonTemp.dependentEvents.refresh_sprite if hasFollowerScript?
end

# Send Pokemon to another character
def pbSendToCharacter(id, pokemonIndex)
  return false if !characterIDValid?(id) || id == $Trainer.character_ID
  if $Trainer.party.length == 1
    pbMessage(_INTL("You can't send your last Pokemon away!"))
    return false
  end
  secondstorage = $PokemonGlobal.mainCharacters[id][PBCharacterData::PokemonStorage]
  firsttrainer = $Trainer
  secondtrainer = getTrainerFromCharacter(id)
  if secondtrainer.party_full? && secondstorage.full?
    pbMessage(_INTL("#{secondtrainer.name} has no space available!"))
    return false
  end
  pokemon = $Trainer.party[pokemonIndex]
  pokemon.obtain_method = 2 # traded
  secondtrainer.pokedex.register(pokemon)
  secondtrainer.pokedex.set_owned(pokemon.species)
  if !secondtrainer.party_full?
    secondtrainer.party[secondtrainer.party.length] = pokemon
  else
    secondstorage.pbStoreCaught(pokemon)
  end
  $Trainer.party.delete_at(pokemonIndex)
  $PokemonTemp.dependentEvents.refresh_sprite if hasFollowerScript?
  return true
end