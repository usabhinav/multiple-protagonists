module MultipleProtagonistsCharacterDataHandler
  @@handlers = HandlerHash.new
  @@sharing_handlers = HandlerHash.new
  @@active_shared_items = []

  def self.add(key, hash)
    @@handlers.add(key, hash)
  end

  def self.add_sharing_handler(key, hash)
    @@sharing_handlers.add(key, hash)
  end

  def self.apply_character_data(meta, data_classification)
    @@handlers.each do |key, hash|
      hash[:set_data_value].call(meta[key]) if hash[:data_classification] == data_classification
    end
  end

  def self.get_current_character_data_as_info_hash
    info = {}
    @@handlers.each do |key, hash|
      info[key] = hash[:get_data_value].call
    end
    return info
  end

  def self.get_default_character_data_as_info_hash
    info = {}
    @@handlers.each do |key, hash|
      info[key] = hash[:get_default_value].call
    end
    return info
  end

  def self.replace_keys_with_default_values_in_hash(meta, keys)
    keys.each do |key|
      hash = @@handlers[key]
      meta[key] = hash[:get_default_value].call
    end
  end

  def self.enable_sharing(key)
    return if @@active_shared_items.include?(key)
    @@sharing_handlers[key][:enable_sharing].call
    @@active_shared_items.push(key)
  end

  def self.disable_sharing(key)
    return if !@@active_shared_items.include?(key)
    @@sharing_handlers[key][:disable_sharing].call
    @@active_shared_items.delete(key)
  end

  def self.share_resources_with_new_character(meta)
    @@active_shared_items.each do |key|
      @@sharing_handlers[key][:share_resource_with_new_character].call(meta)
    end
  end
end

# Character data configurations for all fields

MultipleProtagonistsCharacterDataHandler.add(:player, {
  :set_data_value => proc { |value|
    $player = value
  },
  :get_data_value => proc { $player },
  :get_default_value => proc { $player },
  :data_classification => :standard
})

MultipleProtagonistsCharacterDataHandler.add(:bag, {
  :set_data_value => proc { |value|
    $bag = value
  },
  :get_data_value => proc { $bag },
  :get_default_value => proc { PokemonBag.new },
  :data_classification => :standard
})

MultipleProtagonistsCharacterDataHandler.add(:pokemon_storage, {
  :set_data_value => proc { |value|
    $PokemonStorage = value
  },
  :get_data_value => proc { $PokemonStorage },
  :get_default_value => proc { PokemonStorage.new },
  :data_classification => :standard
})

MultipleProtagonistsCharacterDataHandler.add(:mailbox, {
  :set_data_value => proc { |value|
    $PokemonGlobal.mailbox = value
  },
  :get_data_value => proc { $PokemonGlobal.mailbox },
  :get_default_value => proc { nil },
  :data_classification => :standard
})

MultipleProtagonistsCharacterDataHandler.add(:pc_item_storage, {
  :set_data_value => proc { |value|
    $PokemonGlobal.pcItemStorage = value
  },
  :get_data_value => proc { $PokemonGlobal.pcItemStorage },
  :get_default_value => proc { nil },
  :data_classification => :standard
})

MultipleProtagonistsCharacterDataHandler.add(:happiness_steps, {
  :set_data_value => proc { |value|
    $PokemonGlobal.happinessSteps = value
  },
  :get_data_value => proc { $PokemonGlobal.happinessSteps },
  :get_default_value => proc { 0 },
  :data_classification => :standard
})

MultipleProtagonistsCharacterDataHandler.add(:pokerus_time, {
  :set_data_value => proc { |value|
    $PokemonGlobal.pokerusTime = value
  },
  :get_data_value => proc { $PokemonGlobal.pokerusTime },
  :get_default_value => proc { nil },
  :data_classification => :standard
})

MultipleProtagonistsCharacterDataHandler.add(:daycare, {
  :set_data_value => proc { |value|
    $PokemonGlobal.day_care = value
  },
  :get_data_value => proc { $PokemonGlobal.day_care },
  :get_default_value => proc { DayCare.new },
  :data_classification => :standard
})

MultipleProtagonistsCharacterDataHandler.add(:last_battle, {
  :set_data_value => proc { |value|
    $PokemonGlobal.lastbattle = value
  },
  :get_data_value => proc { $PokemonGlobal.lastbattle },
  :get_default_value => proc { nil },
  :data_classification => :standard
})

MultipleProtagonistsCharacterDataHandler.add(:map_trail, {
  :set_data_value => proc { |value|
    $PokemonGlobal.mapTrail = value
  },
  :get_data_value => proc { $PokemonGlobal.mapTrail },
  :get_default_value => proc { [] },
  :data_classification => :standard
})

MultipleProtagonistsCharacterDataHandler.add(:pokedex_dex, {
  :set_data_value => proc { |value|
    $PokemonGlobal.pokedexDex = value
  },
  :get_data_value => proc { $PokemonGlobal.pokedexDex },
  :get_default_value => proc { (pbLoadRegionalDexes.length == 0) ? -1 : 0 },
  :data_classification => :standard
})

MultipleProtagonistsCharacterDataHandler.add(:pokedex_index, {
  :set_data_value => proc { |value|
    $PokemonGlobal.pokedexIndex = value
  },
  :get_data_value => proc { $PokemonGlobal.pokedexIndex },
  :get_default_value => proc { Array.new(pbLoadRegionalDexes.length + 1, 0) },
  :data_classification => :standard
})

MultipleProtagonistsCharacterDataHandler.add(:pokedex_mode, {
  :set_data_value => proc { |value|
    $PokemonGlobal.pokedexMode = value
  },
  :get_data_value => proc { $PokemonGlobal.pokedexMode },
  :get_default_value => proc { 0 },
  :data_classification => :standard
})

MultipleProtagonistsCharacterDataHandler.add(:visited_maps, {
  :set_data_value => proc { |value|
    $PokemonGlobal.visitedMaps = value
  },
  :get_data_value => proc { $PokemonGlobal.visitedMaps },
  :get_default_value => proc { [] },
  :data_classification => :standard
})

MultipleProtagonistsCharacterDataHandler.add(:partner, {
  :set_data_value => proc { |value|
    $PokemonGlobal.partner = value
  },
  :get_data_value => proc { $PokemonGlobal.partner },
  :get_default_value => proc { nil },
  :data_classification => :standard
})

MultipleProtagonistsCharacterDataHandler.add(:phone, {
  :set_data_value => proc { |value|
    $PokemonGlobal.phone = value
  },
  :get_data_value => proc { $PokemonGlobal.phone },
  :get_default_value => proc { Phone.new },
  :data_classification => :standard
})

MultipleProtagonistsCharacterDataHandler.add(:followers, {
  :set_data_value => proc { |value|
    $PokemonGlobal.followers = value
    # Resetting the dependent events causes new unwanted maps to be added to
    # the map factory, so delete them before the scene can be updated
    oldmaps = []
    $map_factory.maps.each {|map| oldmaps.push(map.map_id)}
    $game_temp.followers = Game_FollowerFactory.new
    $map_factory.maps.delete_if {|map| !oldmaps.include?(map.map_id)}
    $game_temp.followers.update
  },
  :get_data_value => proc { $PokemonGlobal.followers },
  :get_default_value => proc { [] },
  :data_classification => :standard
})

MultipleProtagonistsCharacterDataHandler.add(:pokeradar_battery, {
  :set_data_value => proc { |value|
    $PokemonGlobal.pokeradarBattery = value
  },
  :get_data_value => proc { $PokemonGlobal.pokeradarBattery },
  :get_default_value => proc { 0 },
  :data_classification => :standard
})

MultipleProtagonistsCharacterDataHandler.add(:purify_chamber, {
  :set_data_value => proc { |value|
    $PokemonGlobal.purifyChamber = value
  },
  :get_data_value => proc { $PokemonGlobal.purifyChamber },
  :get_default_value => proc { nil },
  :data_classification => :standard
})

MultipleProtagonistsCharacterDataHandler.add(:triads, {
  :set_data_value => proc { |value|
    $PokemonGlobal.triads = value
  },
  :get_data_value => proc { $PokemonGlobal.triads },
  :get_default_value => proc { nil },
  :data_classification => :standard
})

MultipleProtagonistsCharacterDataHandler.add(:map_id, {
  :set_data_value => proc { |value|
    $game_temp.player_new_map_id = value
  },
  :get_data_value => proc { $game_map.map_id },
  :get_default_value => proc { -1 },
  :data_classification => :map
})

MultipleProtagonistsCharacterDataHandler.add(:x, {
  :set_data_value => proc { |value|
    $game_temp.player_new_x = value
  },
  :get_data_value => proc { $game_player.x },
  :get_default_value => proc { -1 },
  :data_classification => :map
})

MultipleProtagonistsCharacterDataHandler.add(:y, {
  :set_data_value => proc { |value|
    $game_temp.player_new_y = value
  },
  :get_data_value => proc { $game_player.y },
  :get_default_value => proc { -1 },
  :data_classification => :map
})

MultipleProtagonistsCharacterDataHandler.add(:direction, {
  :set_data_value => proc { |value|
    $game_temp.player_new_direction = value
  },
  :get_data_value => proc { $game_player.direction },
  :get_default_value => proc { -1 },
  :data_classification => :map
})

MultipleProtagonistsCharacterDataHandler.add(:bicycle, {
  :set_data_value => proc { |value|
    $PokemonGlobal.bicycle = value
  },
  :get_data_value => proc { $PokemonGlobal.bicycle },
  :get_default_value => proc { false },
  :data_classification => :standard
})

MultipleProtagonistsCharacterDataHandler.add(:surfing, {
  :set_data_value => proc { |value|
    $PokemonGlobal.surfing = value
  },
  :get_data_value => proc { $PokemonGlobal.surfing },
  :get_default_value => proc { false },
  :data_classification => :standard
})

MultipleProtagonistsCharacterDataHandler.add(:diving, {
  :set_data_value => proc { |value|
    $PokemonGlobal.diving = value
  },
  :get_data_value => proc { $PokemonGlobal.diving },
  :get_default_value => proc { false },
  :data_classification => :standard
})

MultipleProtagonistsCharacterDataHandler.add(:repel, {
  :set_data_value => proc { |value|
    $PokemonGlobal.repel = value
  },
  :get_data_value => proc { $PokemonGlobal.repel },
  :get_default_value => proc { 0 },
  :data_classification => :standard
})

MultipleProtagonistsCharacterDataHandler.add(:flash_used, {
  :set_data_value => proc { |value|
    $PokemonGlobal.flashUsed = value
  },
  :get_data_value => proc { $PokemonGlobal.flashUsed },
  :get_default_value => proc { false },
  :data_classification => :standard
})

MultipleProtagonistsCharacterDataHandler.add(:bridge, {
  :set_data_value => proc { |value|
    $PokemonGlobal.bridge = value
  },
  :get_data_value => proc { $PokemonGlobal.bridge },
  :get_default_value => proc { 0 },
  :data_classification => :standard
})

MultipleProtagonistsCharacterDataHandler.add(:healing_spot, {
  :set_data_value => proc { |value|
    $PokemonGlobal.healingSpot = value
  },
  :get_data_value => proc { $PokemonGlobal.healingSpot },
  :get_default_value => proc { nil },
  :data_classification => :standard
})

MultipleProtagonistsCharacterDataHandler.add(:escape_point, {
  :set_data_value => proc { |value|
    $PokemonGlobal.escapePoint = value
  },
  :get_data_value => proc { $PokemonGlobal.escapePoint },
  :get_default_value => proc { [] },
  :data_classification => :standard
})

MultipleProtagonistsCharacterDataHandler.add(:pokecenter_map_id, {
  :set_data_value => proc { |value|
    $PokemonGlobal.pokecenterMapId = value
  },
  :get_data_value => proc { $PokemonGlobal.pokecenterMapId },
  :get_default_value => proc { -1 },
  :data_classification => :standard
})

MultipleProtagonistsCharacterDataHandler.add(:pokecenter_x, {
  :set_data_value => proc { |value|
    $PokemonGlobal.pokecenterX = value
  },
  :get_data_value => proc { $PokemonGlobal.pokecenterX },
  :get_default_value => proc { -1 },
  :data_classification => :standard
})

MultipleProtagonistsCharacterDataHandler.add(:pokecenter_y, {
  :set_data_value => proc { |value|
    $PokemonGlobal.pokecenterY = value
  },
  :get_data_value => proc { $PokemonGlobal.pokecenterY },
  :get_default_value => proc { -1 },
  :data_classification => :standard
})

MultipleProtagonistsCharacterDataHandler.add(:pokecenter_direction, {
  :set_data_value => proc { |value|
    $PokemonGlobal.pokecenterDirection = value
  },
  :get_data_value => proc { $PokemonGlobal.pokecenterDirection },
  :get_default_value => proc { -1 },
  :data_classification => :standard
})

if hasFollowerScript?
  MultipleProtagonistsCharacterDataHandler.add(:follower_toggled, {
    :set_data_value => proc { |value|
      $PokemonGlobal.follower_toggled = value
    },
    :get_data_value => proc { $PokemonGlobal.follower_toggled },
    :get_default_value => proc { false },
    :data_classification => :standard
  })

  MultipleProtagonistsCharacterDataHandler.add(:call_refresh, {
    :set_data_value => proc { |value|
      $PokemonGlobal.call_refresh = value
    },
    :get_data_value => proc { $PokemonGlobal.call_refresh },
    :get_default_value => proc { [false, false] },
    :data_classification => :standard
  })

  MultipleProtagonistsCharacterDataHandler.add(:time_taken, {
    :set_data_value => proc { |value|
      $PokemonGlobal.time_taken = value
    },
    :get_data_value => proc { $PokemonGlobal.time_taken },
    :get_default_value => proc { 0 },
    :data_classification => :standard
  })

  MultipleProtagonistsCharacterDataHandler.add(:follower_hold_item, {
    :set_data_value => proc { |value|
      $PokemonGlobal.follower_hold_item = value
    },
    :get_data_value => proc { $PokemonGlobal.follower_hold_item },
    :get_default_value => proc { false },
    :data_classification => :standard
  })

  MultipleProtagonistsCharacterDataHandler.add(:current_surfing, {
    :set_data_value => proc { |value|
      $PokemonGlobal.current_surfing = value
    },
    :get_data_value => proc { $PokemonGlobal.current_surfing },
    :get_default_value => proc { nil },
    :data_classification => :standard
  })
  
  MultipleProtagonistsCharacterDataHandler.add(:current_diving, {
    :set_data_value => proc { |value|
      $PokemonGlobal.current_diving = value
    },
    :get_data_value => proc { $PokemonGlobal.current_diving },
    :get_default_value => proc { nil },
    :data_classification => :standard
  })
end

# Resource sharing handlers

class Player < Trainer
  attr_accessor :pokedex

  class Pokedex
    def register_caught_by_amount(species, amount)
      species_id = GameData::Species.try_get(species)&.species
      return if species_id.nil?
      @caught_counts[species_id] = 0 if @caught_counts[species_id].nil?
      @caught_counts[species_id] += amount
    end

    def register_defeated_by_amount(species, amount)
      species_id = GameData::Species.try_get(species)&.species
      return if species_id.nil?
      @defeated_counts[species_id] = 0 if @defeated_counts[species_id].nil?
      @defeated_counts[species_id] += amount
    end
  end
end

MultipleProtagonistsCharacterDataHandler.add_sharing_handler(:pokedex, {
  :enable_sharing => proc {
    pokedex_list = []
    for i in 1..MAX_CHARACTERS
      pokedex_list.push($PokemonGlobal.mainCharacters[i][:player].pokedex) if !$PokemonGlobal.mainCharacters[i].nil?
    end
    new_pokedex = Player::Pokedex.new
    GameData::Species.each do |species|
      # Seen
      new_pokedex.set_seen(species) if (pokedex_list.map { |dex| dex.seen?(species) }).include?(true)
      # Owned
      new_pokedex.set_owned(species) if (pokedex_list.map { |dex| dex.owned?(species) }).include?(true)
      # Seen form
      for gender in 0..1
        [true, false].each do |shiny|
          if (pokedex_list.map { |dex| dex.seen_form?(species.species, gender, species.form, shiny) }).include?(true)
            new_pokedex.register(species.species, gender, species.form, shiny)
          end
        end
      end
      # Seen egg
      new_pokedex.set_seen_egg(species) if (pokedex_list.map { |dex| dex.seen_egg?(species) }).include?(true)
      # Owned shadow
      new_pokedex.set_shadow_pokemon_owned(species) if (pokedex_list.map { |dex| dex.owned_shadow_pokemon?(species) }).include?(true)
      if species.form == 0
        # Caught counts
        new_pokedex.register_caught_by_amount(species, pokedex_list.sum { |dex| dex.caught_count(species) })
        # Defeated counts
        new_pokedex.register_defeated_by_amount(species, pokedex_list.sum { |dex| dex.defeated_count(species) })
      end
    end
    0.upto(pbLoadRegionalDexes.length) do |i|
      new_pokedex.unlock(i) if (pokedex_list.map { |dex| dex.unlocked?(i) }).include?(true)
    end
    for i in 1..MAX_CHARACTERS
      $PokemonGlobal.mainCharacters[i][:player].pokedex = new_pokedex if !$PokemonGlobal.mainCharacters[i].nil?
    end
    $player.pokedex = new_pokedex
  },
  :disable_sharing => proc {
    for i in 1..MAX_CHARACTERS
      if !$PokemonGlobal.mainCharacters[i].nil?
        $PokemonGlobal.mainCharacters[i][:player].pokedex = Marshal.load(Marshal.dump($PokemonGlobal.mainCharacters[i][:player].pokedex))
      end
    end
    $player.pokedex = Marshal.load(Marshal.dump($player.pokedex))
  },
  :share_resource_with_new_character => proc { |meta|
    meta[:player].pokedex = $PokemonGlobal.mainCharacters[1][:player].pokedex
  }
})

MultipleProtagonistsCharacterDataHandler.add_sharing_handler(:bag, {
  :enable_sharing => proc {
    bag_list = []
    for i in 1..MAX_CHARACTERS
      bag_list.push($PokemonGlobal.mainCharacters[i][:bag]) if !$PokemonGlobal.mainCharacters[i].nil?
    end
    new_bag = PokemonBag.new
    GameData::Item.each do |item|
      quantity = bag_list.sum { |bag| bag.quantity(item) }
      new_bag.add(item, quantity) if quantity > 0
    end
    for i in 1..MAX_CHARACTERS
      $PokemonGlobal.mainCharacters[i][:bag] = new_bag if !$PokemonGlobal.mainCharacters[i].nil?
    end
    $bag = new_bag
  },
  :disable_sharing => proc {
    for i in 1..MAX_CHARACTERS
      if !$PokemonGlobal.mainCharacters[i].nil?
        $PokemonGlobal.mainCharacters[i][:bag] = Marshal.load(Marshal.dump($PokemonGlobal.mainCharacters[i][:bag]))
      end
    end
    $bag = Marshal.load(Marshal.dump($bag))
  },
  :share_resource_with_new_character => proc { |meta|
    meta[:bag] = $PokemonGlobal.mainCharacters[1][:bag]
  }
})

MultipleProtagonistsCharacterDataHandler.add_sharing_handler(:pokemon_storage, {
  :enable_sharing => proc {
    pokemon_storage_list = []
    for i in 1..MAX_CHARACTERS
      pokemon_storage_list.push($PokemonGlobal.mainCharacters[i][:pokemon_storage]) if !$PokemonGlobal.mainCharacters[i].nil?
    end
    new_pokemon_storage = PokemonStorage.new
    pokemon_storage_list.each do |pokemon_storage|
      pokemon_storage.boxes.each do |box|
        box.pokemon.each do |pokemon|
          new_pokemon_storage.pbStoreCaught(pokemon)
        end
      end
    end
    for i in 1..MAX_CHARACTERS
      $PokemonGlobal.mainCharacters[i][:pokemon_storage] = new_pokemon_storage if !$PokemonGlobal.mainCharacters[i].nil?
    end
    $PokemonStorage = new_pokemon_storage
  },
  :disable_sharing => proc {
    for i in 1..MAX_CHARACTERS
      if !$PokemonGlobal.mainCharacters[i].nil?
        $PokemonGlobal.mainCharacters[i][:pokemon_storage] = Marshal.load(Marshal.dump($PokemonGlobal.mainCharacters[i][:pokemon_storage]))
      end
    end
    $PokemonStorage = Marshal.load(Marshal.dump($PokemonStorage))
  },
  :share_resource_with_new_character => proc { |meta|
    meta[:pokemon_storage] = $PokemonGlobal.mainCharacters[1][:pokemon_storage]
  }
})

MultipleProtagonistsCharacterDataHandler.add_sharing_handler(:pc_item_storage, {
  :enable_sharing => proc {
    pc_item_storage_list = []
    for i in 1..MAX_CHARACTERS
      pc_item_storage_list.push($PokemonGlobal.mainCharacters[i][:pc_item_storage]) if !$PokemonGlobal.mainCharacters[i].nil?
    end
    new_pc_item_storage = PCItemStorage.new
    new_pc_item_storage.clear
    GameData::Item.each do |item|
      quantity = pc_item_storage_list.sum { |pc_item_storage| pc_item_storage.nil? ? 0 : pc_item_storage.quantity(item) }
      new_pc_item_storage.add(item, quantity) if quantity > 0
    end
    for i in 1..MAX_CHARACTERS
      $PokemonGlobal.mainCharacters[i][:pc_item_storage] = new_pc_item_storage if !$PokemonGlobal.mainCharacters[i].nil?
    end
    $PokemonGlobal.pcItemStorage = new_pc_item_storage
  },
  :disable_sharing => proc {
    for i in 1..MAX_CHARACTERS
      if !$PokemonGlobal.mainCharacters[i].nil?
        $PokemonGlobal.mainCharacters[i][:pc_item_storage] = Marshal.load(Marshal.dump($PokemonGlobal.mainCharacters[i][:pc_item_storage]))
      end
    end
    $PokemonGlobal.pcItemStorage = Marshal.load(Marshal.dump($PokemonGlobal.pcItemStorage))
  },
  :share_resource_with_new_character => proc { |meta|
    meta[:pc_item_storage] = $PokemonGlobal.mainCharacters[1][:pc_item_storage]
  }
})
