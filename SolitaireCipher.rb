class SolitaireCipher

  def initialize
    @key = (1..54).to_a
  end

  def sanitize(text)
    text = text.gsub(/[^a-z]/i, '').upcase
    string_to_number(pad_last_group(text))
  end

  def pad_last_group(text)
    block_count = (text.length / 5.0).ceil
    missing_chars = (block_count * 5) - text.length
    missing_chars.times do 
      text += "X"
    end
    text
  end

  def encrypt(message)
    crypt(message){|entry, key_entry|(entry+key_entry).modulo(26)}
  end

  def crypt(message, &processor)
    message = sanitize(message)
    result = []
    message.each do |entry|
      key_entry = prepare_key
      v = processor.call(entry, key_entry)
      v = (v+64).chr("UTF-8")
      result << v
    end
    result
  end

  def decrypt(message)
    crypt(message){|message_number,key_number|
    if key_number >= message_number
      message_number+=26
    end
    message_number-key_number}
  end

  def prepare_key
    joker_down(53,1)
    joker_down(54,2)
    triple_cut
    count_cut

    if @key[0] == 54 #jokers always 53
      index = 53
    else
      index = @key[0]
    end

    first_card = @key[index]

    if first_card > 52
      return prepare_key
    else
      first_card.modulo(26)
    end
  end

  def joker_down(joker,steps)
    joker_position = @key.index(joker)
    target_card_position = (joker_position+steps+1).modulo(54) #insert always before, task requires after

    target_card = @key[target_card_position]
    @key.delete_at(joker_position)

    target = @key.index(target_card)

    if target == 0
      @key << joker
    else
      @key = @key.insert(target, joker)
    end

  end

  def triple_cut
    top_joker_position = @key.index(53)
    bottom_joker_position = @key.index(54)
    top_joker_position, bottom_joker_position = bottom_joker_position, top_joker_position if top_joker_position > bottom_joker_position
    distance = bottom_joker_position - top_joker_position

    before_top_joker = @key[0,top_joker_position]
    after_bottom_joker = @key[bottom_joker_position+1,@key.length]
    between_jokers = @key[top_joker_position,distance+1]

    @key.replace([after_bottom_joker,between_jokers,before_top_joker].flatten)
  end

  def count_cut
    card_value = @key[53]
    cut = @key[0,card_value]
    @key = @key[card_value, 53]
    @key = @key.insert(53-card_value, cut).flatten
  end

  def string_to_number(string)
    result = []
    string.split("").each do |char|
      result << char.ord-64
    end
    result
  end

end

sc = SolitaireCipher.new
puts sc.decrypt("GLNCQMJAFFFVOMBJIYCB")
