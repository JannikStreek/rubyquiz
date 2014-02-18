class SecretSantas
  require 'net/smtp'

	def initialize(file)
    @santas = Hat.new(read_input(file)).sort
	end

  def read_input(file)
    santas = []
    file = File.new(file, "r")
    while (line = file.gets)
      data = line.split(" ")
      santa = Santa.new(data[0], data[1], data[2])
      santas << santa
    end
    return santas
  end

  def start_drawing
    (0..@santas.length-1).each do |i|
      if i >= @santas.length-1
        inform_santa(@santas[i], @santas[0])
      else
        inform_santa(@santas[i], @santas[i+1])
      end
    end
  end

  def inform_santa(santa,victim)
    to = santa.email[1..-1]
    opts = {:to => to,
            :body => "Hi #{santa.firstname} #{santa.lastname}, your victims name is: #{victim.firstname} #{victim.lastname}"}
    send_mail(opts)
  end

  def send_mail(opts={})
    opts[:from]        ||= 'theshowcanbegin@gmail.com'
    opts[:from_alias]  ||= 'rubyquiz'
    opts[:subject]     ||= "SecretSantas Victim"
    opts[:body]        ||= ""
    opts[:to]          ||= "theshowcanbegin@gmail.com"
    opts[:login]       ||= "theshowcanbegin"
    opts[:password]    ||= "XXXX"

msg = <<END_OF_MESSAGE
From: #{opts[:from_alias]} <#{opts[:from]}>
To: <#{opts[:to]}>
Subject: #{opts[:subject]}

#{opts[:body]}
END_OF_MESSAGE

    smtp = Net::SMTP.new 'smtp.gmail.com', 587
    smtp.enable_starttls

    smtp.start(Socket.gethostname, opts[:login], opts[:password], :login) do |smtp|
      smtp.send_message msg, opts[:from], opts[:to]
    end
  end
end

class Santa
  attr_reader :firstname, :lastname, :email
  def initialize(firstname, lastname, email)
    @firstname = firstname
    @lastname = lastname
    @email = email
  end
end

class Hat
  def initialize(santas)
    @santas = santas
    @ranking = create_ranking(santas)
    @result = []
  end

  def sort
    @santas.length.times do
      lastname = get_first_in_ranking
      santa = search_santa(lastname)
      @result << santa
    end
    return @result
  end

  def search_santa(lastname)
    @santas.each do |santa|
      if santa.lastname == lastname
        @santas.delete(santa)
        return santa
      end
    end
  end

  def get_first_in_ranking
    lastname = @ranking[0][1]
    if @result.last != nil and lastname == @result.last.lastname
      lastname = @ranking[1][1]
    end
    remove_santa(lastname)
    return lastname
  end

  def create_ranking(santas)
    ranking = Hash.new(0)
    santas.each do |santa|
      ranking[santa.lastname] += 1
    end
    ranking.collect{|k,v| [v,k] }.sort{|a,b| b<=>a}
  end

  def remove_santa(lastname)
    index = (0..@ranking.size-1).select{|i| i if @ranking[i][1] == lastname}[0]
    @ranking[index][0] -= 1
    while index+1 < @ranking.size and @ranking[index][0] < @ranking[index+1][0] do #bubble swap down
      @ranking[index], @ranking[index+1] = @ranking[index+1], @ranking[index]
      index+=1
    end
  end
end

ss = SecretSantas.new(ARGV[0])
ss.start_drawing