class PokemonGlobalMetadata
  attr_accessor :mainCharacters           # Stores all protagonists' data
  attr_accessor :commandCharacterSwitchOn # Enables character switching from menu
  attr_accessor :allowedCharacters        # Characters allowed for command switching
  
  alias new_initialize initialize
  def initialize
    new_initialize
    @mainCharacters = Array.new(MAX_CHARACTERS + 1)
    @commandCharacterSwitchOn = false
    @allowedCharacters = Array.new(MAX_CHARACTERS + 1, false)
    @allowedCharacters[1] = true
  end
end

# Enables sharing of resource between characters (i.e. Pokedex, bag, etc.).
# If it's a storage type of resource, it will merge the contents of all individual resources together.
def pbEnableSharingBetweenCharacters(key)
  MultipleProtagonistsCharacterDataHandler.enable_sharing(key)
end

# Disables sharing of resource between characters (i.e. Pokedex, bag, etc.).
# If it's a storage type of resource, it will duplicate the existing shared resource into a copy for each character.
# WARNING: See the warning listed in the main instructions on how this may cause duplication bugs if this command
# is used incorrectly.
def pbDisableSharingBetweenCharacters(key)
  MultipleProtagonistsCharacterDataHandler.disable_sharing(key)
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
  return if id < 1 || id == $player.character_ID
  meta = $PokemonGlobal.mainCharacters[id]
  oldid = $player.character_ID
  $PokemonGlobal.mainCharacters[oldid] = MultipleProtagonistsCharacterDataHandler.get_current_character_data_as_info_hash
  if meta.nil? # Set up trainer for the first time
    $player = Player.new("Unnamed", GameData::PlayerMetadata.get(id).trainer_type)
    $player.character_ID = id
    pbTrainerName(name, outfit)
    $player.id = pbGetForeignCharacterID
    # Create and store new character's meta
    newmeta = MultipleProtagonistsCharacterDataHandler.get_default_character_data_as_info_hash
    $PokemonGlobal.mainCharacters[id] = newmeta
    meta = $PokemonGlobal.mainCharacters[id]
    pbEnableCharacter(id)
    MultipleProtagonistsCharacterDataHandler.share_resources_with_new_character(meta)
  end
  if pbMapInterpreterRunning? # Must have been called through event command
    MultipleProtagonistsCharacterDataHandler.replace_keys_with_default_values_in_hash(meta, [
      :map_id, :x, :y, :direction, :bicycle, :surfing, :diving, :repel, :flash_used, :bridge, :escape_point
    ])
  end
  # Assumes that if called through event, then meta[:map_id]
  # was set to -1 earlier
  # Fades out to prepare for player map transfer
  if meta[:map_id] >= 0 && $PokemonGlobal.commandCharacterSwitchOn
    $game_screen.start_tone_change(Tone.new(-255, -255, -255, 0), 12)
    pbWait(1)
  end
  # Set to blank array so that dependent events of other character aren't
  # affected
  $PokemonGlobal.followers       = []
  $game_temp.followers.remove_all_followers
  # Assumes that if called through event, then meta[:map_id]
  # was set to -1 earlier
  # Performs map transfer on player
  if meta[:map_id] >= 0 && $PokemonGlobal.commandCharacterSwitchOn
    MultipleProtagonistsCharacterDataHandler.apply_character_data(meta, :map)
    $scene.transfer_player
  end
  # Set all game data to new character's data
  MultipleProtagonistsCharacterDataHandler.apply_character_data(meta, :standard)
  FollowingPkmn.refresh if hasFollowerScript?
  $game_player.refresh_charset
  pbUpdateVehicle
  # Assumes that if called through event, then meta[:map_id]
  # was set to -1 earlier
  # Fades in to new map after transferring player
  if meta[:map_id] >= 0 && $PokemonGlobal.commandCharacterSwitchOn
    $game_screen.start_tone_change(Tone.new(0, 0, 0, 0), 12)
    pbWait(1)
  end
end

class PokemonMapFactory
  attr_accessor :maps
end

# Saves data of Player A (id 1) at start of game
alias protag_pbTrainerName pbTrainerName
def pbTrainerName(name = nil,outfit = 0)
  protag_pbTrainerName(name, outfit)
  if $player.character_ID == 1
    $PokemonGlobal.mainCharacters[1] = MultipleProtagonistsCharacterDataHandler.get_current_character_data_as_info_hash
  end
end

# Sets the "last map" variables of character
def pbSetLastMap(id, map_id, x, y, dir)
  return if !characterIDValid?(id) || map_id < 0
  info = $PokemonGlobal.mainCharacters[id]
  info[:map_id] = map_id
  info[:x] = x
  info[:y] = y
  info[:direction] = dir
  MultipleProtagonistsCharacterDataHandler.replace_keys_with_default_values_in_hash(info, [
    :bicycle, :surfing, :diving, :repel, :flash_used, :bridge, :escape_point, :pokecenter_map_id, :pokecenter_x, :pokecenter_y, :pokecenter_direction
  ])
end

# Returns a trainer ID different from all other trainer IDs.
# Prevents two characters from accidentally having same trainer IDs on their
# trainer cards.
def pbGetForeignCharacterID
  characterIDs = []
  for i in 1..MAX_CHARACTERS
    if !$PokemonGlobal.mainCharacters[i].nil?
      characterIDs.push(getPlayerFromCharacter(i).id)
    end
  end
  id = $player.make_foreign_ID
  while characterIDs.include?(id)
    id = $player.make_foreign_ID
  end
  return id
end

# Substitutes \PN1-\PN8 with the appropriate trainer name
def gsubPN(name)
  global = $PokemonGlobal
  if global.nil? && SaveData.exists?
    save_data = SaveData.read_from_file(SaveData::FILE_PATH)
    global = save_data[:global_metadata]
  end
  return if global.nil?
  for i in 1..MAX_CHARACTERS
    if global.mainCharacters[i]
      name.gsub!(/\\[Pp][Nn]#{i}/, global.mainCharacters[i][:player].name)
    end
  end
end

# Creates NPCTrainer object from character
def pbCreateTrainerFromCharacter(character_ID)
  return if !characterIDValid?(character_ID)
  original = (character_ID == $player.character_ID) ? $player : getPlayerFromCharacter(character_ID)
  cloned = Marshal.load(Marshal.dump(original))
  cloned_trainer = NPCTrainer.new(cloned.name, cloned.trainer_type)
  cloned_trainer.id = cloned.id
  cloned_trainer.party = cloned.party
  return cloned_trainer
end

# Registers a player character as partner
def pbRegisterPartnerFromCharacter(character_ID)
  return if !characterIDValid?(character_ID)
  trainer = pbCreateTrainerFromCharacter(character_ID)
  EventHandlers.trigger(:on_trainer_load, trainer)
  for i in trainer.party
    i.owner = Pokemon::Owner.new_from_trainer(trainer)
    i.calc_stats
  end
  $PokemonGlobal.partner = [trainer.trainer_type, trainer.name, trainer.id, trainer.party]
end

# Gets $player object at specific character ID
def getPlayerFromCharacter(id)
  return nil if id < 1 || id > MAX_CHARACTERS
  if id == $player.character_ID
    return $player
  else
    meta = $PokemonGlobal.mainCharacters[id]
    return nil if !meta
    return meta[:player]
  end
end

# Returns true if id is within range 0..7 and meta exists
def characterIDValid?(id)
  return id >= 1 && id <= MAX_CHARACTERS && $PokemonGlobal.mainCharacters[id]
end

# Same as pbChoosePokemon but for another character (EXCLUDING the current character)
def pbChoosePokemonFromCharacter(id,variableNumber,nameVarNumber,ableProc=nil,allowIneligible=false)
  return if !characterIDValid?(id) || id == $player.character_ID
  ot = $player
  $player = getPlayerFromCharacter(id) # Partial switch to new character
  pbChoosePokemon(variableNumber,nameVarNumber,ableProc,allowIneligible)
  $player = ot # Restore original character
  FollowingPkmn.refresh if hasFollowerScript?
end

# Same as pbChooseTradablePokemon but for another character (EXCLUDING the current character)
def pbChooseTradablePokemonFromCharacter(id,variableNumber,nameVarNumber,ableProc=nil,allowIneligible=false)
  return if !characterIDValid?(id) || id == $player.character_ID
  ot = $player
  $player = getPlayerFromCharacter(id) # Partial switch to new character
  pbChooseTradablePokemon(variableNumber,nameVarNumber,ableProc,allowIneligible)
  $player = ot # Restore original character
  FollowingPkmn.refresh if hasFollowerScript?
end

# Trade with another character (just like NPC trade)
def pbTradeWithCharacter(id, firstPokemonIndex, secondPokemonIndex)
  return if !characterIDValid?(id) || id == $player.character_ID
  firsttrainer = $player
  firstpoke = firsttrainer.party[firstPokemonIndex]
  secondtrainer = getPlayerFromCharacter(id)
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
  FollowingPkmn.refresh if hasFollowerScript?
end

# Send Pokemon to another character
def pbSendToCharacter(id, pokemonIndex)
  return false if !characterIDValid?(id) || id == $player.character_ID
  if $player.party.length == 1
    pbMessage(_INTL("You can't send your last Pokemon away!"))
    return false
  end
  secondstorage = $PokemonGlobal.mainCharacters[id][:pokemon_storage]
  firsttrainer = $player
  secondtrainer = getPlayerFromCharacter(id)
  if secondtrainer.party_full? && secondstorage.full?
    pbMessage(_INTL("#{secondtrainer.name} has no space available!"))
    return false
  end
  pokemon = $player.party[pokemonIndex]
  pokemon.obtain_method = 2 # traded
  secondtrainer.pokedex.register(pokemon)
  secondtrainer.pokedex.set_owned(pokemon.species)
  if !secondtrainer.party_full?
    secondtrainer.party[secondtrainer.party.length] = pokemon
  else
    secondstorage.pbStoreCaught(pokemon)
  end
  $player.party.delete_at(pokemonIndex)
  FollowingPkmn.refresh if hasFollowerScript?
  return true
end

# Add pause menu switching
MenuHandlers.add(:pause_menu, :switch, {
  "name"      => _INTL("Switch"),
  "order"     => 55,
  "condition" => proc { next $PokemonGlobal.commandCharacterSwitchOn && !pbInSafari? && !pbInBugContest? && !pbBattleChallenge.pbInProgress? },
  "effect"    => proc { |menu|
    characters = []
    characterIDs = []
    for i in 1..MAX_CHARACTERS
      if $PokemonGlobal.allowedCharacters[i] && i != $player.character_ID
        characters.push(getPlayerFromCharacter(i).name)
        characterIDs.push(i)
      end
    end
    if characters.length <= 0
	    pbMessage(_INTL("You're the only character!"))
	    next false
    end
    characters.push("Cancel")
    command = pbShowCommands(nil, characters, characters.length)
    if command >= 0 && command < characters.length - 1
      menu.pbHideMenu
      pbSwitchCharacter(characterIDs[command])
      next true
    end
  }
})