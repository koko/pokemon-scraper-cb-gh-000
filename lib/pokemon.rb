#SAVE works fine, but no UPDATE
#FIND works beautifully, because simple
#back to trying to do BONUS stuff

class Pokemon

attr_accessor :id, :name, :type, :db, :all, :hp

  @@all = {}
  @@id  = 1

  def self.all
      @@all
  end

  def initialize(id:@@id, name:"Pikachu", type:"electric", db:"db",hp:60)
    #TODO: refactor by moving defaults to constants
    @id   = id
    if @id == @@id
      @@id += 1
    else
      @@id = @id + 1
    end
    @name = name
    @type = type
    @db   = db
    @hp   = hp
    @@all[name] = self
  end

  def to_s
    puts "pokemon id:#{@id} is: #{@name} #{@type} #{@db} #{@hp}"
  end

  def alter_hp(new_hp,db)
    #This will need to #save check to see if the Pokemon has been saved first.
    puts "altering hp from #{@hp} to #{new_hp}"
    @hp = new_hp
    print self.to_s and puts " is Pokemon after alteration"
    @@all[name] = self
    print @@all[name].to_s and puts " is saved Pokemon in local class"
    Pokemon.save(@name,@type,db,@hp)
  end

  def has_attributes(name,type,hp)
    name == @name and type == @type and hp == @hp
  end

  # def self.sql_update(name,type,db,hp)
  #   if hp == nil
  #     update_statement
  #   end
  # end

  #TODO: If you'd like, refactor insert and update later. sheesh
  def self.sql_insert(name,type,db,hp,needs_hp)
    if !needs_hp
      hp_field_name  = ""
      hp_value_stmt  = ""
    else
      hp_field_name = ",hp"
      hp_value_stmt = ",hp = #{hp}"
    end
    #If there is no such pokemon yet, let's make it!
    puts "we have a nil (new) pokemon? #{@@all[name].nil?}"
    if @@all[name].nil?
      pokemon = Pokemon.new(name:name,type:type,db:@db,hp:hp)
      @@all[name] = pokemon
    else
      pokemon = @@all[name]
    end
    puts "we have a nil (new) pokemon? #{@@all[name].nil?}"
    id = pokemon.id
    insert_statement = "INSERT INTO pokemon (id,name,type#{hp_field_name})
      VALUES(#{id},'#{name}','#{type}'#{hp_value_stmt})"
    puts insert_statement
    db.execute(insert_statement)[0]
    @@all[name]
  end

  def self.save(name,type,db,hp=60)
    #TODO: remove reference to default 60 HP.
    # Although Pokemon are given default HP values,
    # these aren't always saved here because the column may not exist.

    # TODO: make this only ALTER a pokemon if it's already there!
    #FIRST, We Need to check to see if there _should_ be an hp value in the db
    pokemon_table_create_stmt =
      db.execute("SELECT sql FROM sqlite_master WHERE name = 'pokemon'")[0][0]

    if pokemon_table_create_stmt.include?("hp")
      needs_hp = true
    else
      needs_hp = false
    end
    #This enables us to check the attributes only once.
    #First we check the class array to see if there's a pokemon with this name there.
    possible_pokemon = @@all[name]
    #If the pokemon we have in the class array matches all given attributes, no work needs done
    #This only applies when we are UPDATING!
    # if !(possible_pokemon.nil?) and possible_pokemon.has_attributes(name,type,hp)
    #   puts "no changes in pokemon"
    #   return possible_pokemon
    if !possible_pokemon.nil? and !possible_pokemon.has_attributes(name,type,hp)
      #If there IS a pokemon, but attributes don't all match
      #we have to update both the class array and the database.
      #These lines update the class array:
      new_pokemon      = possible_pokemon
      new_pokemon.name = name
      new_pokemon.type = type
      new_pokemon.hp   = hp
      @@all[name] = new_pokemon
      # if needs_hp == false
      #   hp = nil  # we won't save it in the database if there's no column for it
      # end
      self.sql_update(name,type,db,hp,needs_hp)
    else
      return self.sql_insert(name,type,db,hp,needs_hp)
    end
    # all the code below sucks. Let's make this simple.
    # puts "possible_pokemon? #{possible_pokemon.nil? ? "nil" : possible_pokemon.to_s}"
    # if possible_pokemon.nil?
    #   id = @@id
    #   @@id += 1
    #   possible_pokemon = Pokemon.new
    # else
    #   id = possible_pokemon.id
    # end
    # puts "the possible_pokemon is #{possible_pokemon.to_s}"
    # saved_pokemon = Pokemon.find(id,db)
    # if !(possible_pokemon.nil? or possible_pokemon.hp == 60) #TODO: constant hp to replace
    #   hp = possible_pokemon.hp
    #   hp_field_name  = ",hp"
    #   hp_value_stmt  = "hp = #{hp}"
    #   hp_update_stmt = "#{hp_field_name}=#{hp}"
    # elsif !(hp.nil? or hp == 60) #TODO: constant hp to replace
    #   hp_field_name  = ",hp"
    #   hp_value_stmt  = "hp = #{hp}"
    #   hp_update_stmt = "#{hp_field_name}=#{hp}"
    # else
    #   hp_field_name  = ""
    #   hp_value_stmt  = ""
    #   hp_update_stmt = ""
    # # TODO: Is this necessary?
    # # elsif pokemon.hp != 60 #TODO: constant to replace here
    # #   hp_field_name  = ",hp"
    # #   hp_value_stmt  = ",hp = #{hp}"
    # #   hp_update_stmt = ",#{hp_field_name}=#{hp}"
    # end
    # if saved_pokemon.nil?
    #   insert_statement = "INSERT INTO pokemon (id,name,type#{hp_field_name})
    #     VALUES(#{id},'#{name}','#{type}#{hp_value_stmt}')"
    #   puts insert_statement
    #   output  = db.execute(insert_statement)[0]
    #   pokemon = Pokemon.new(id:id,name:name,type:type,db:db)
    #   pokemon.hp = hp unless hp.nil?
    #   @@all[name] = pokemon
    # else
    #   puts "getting here to update in save method"
    #   pokemon_id = saved_pokemon.id
    #   update_statement = "UPDATE pokemon SET
    #     name='#{saved_pokemon.name}',type='#{saved_pokemon.type}'#{hp_update_stmt}
    #     WHERE id=#{saved_pokemon.id}"
    #   puts update_statement
    #   db.execute(update_statement)
    #   @@all[saved_pokemon.name] = saved_pokemon
    # end

  end

  def self.find(id,db)
    query  = "SELECT * FROM pokemon WHERE id=#{id}"
    output = db.execute(query)
    if output == []
      nil
    else
      output = output[0]
      puts output
      pokemon = Pokemon.new(id:output[0],name:output[1],type:output[2])
    end
  end

end
