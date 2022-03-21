class Person
  attr_accessor :first_name, :last_name

  def initialize(name)
    parse_full_name(name)
  end

  def name
    "#{first_name} #{last_name}".strip
  end

  def name=(name)
    parse_full_name(name)
  end

  def has_same_name?(other_name)
    name == other_name.name
  end

  def to_s
    name
  end

  private

  def parse_full_name(name)
    @first_name, @last_name = name.split
  end
end

# bob = Person.new('Robert')
# puts bob.name                  # => 'Robert'
# p bob.first_name            # => 'Robert'
# puts bob.last_name             # => ''
# bob.last_name = 'Smith'
# puts bob.name                  # => 'Robert Smith'

# bob.name = "John Adams"
# puts bob.first_name            # => 'John'
# puts bob.last_name             # => 'Adams'

bob = Person.new('Robert Smith')
rob = Person.new('Robert Smith')
puts bob.has_same_name?(rob)
puts bob.name == rob.name
puts "The person's name is: #{bob}"
puts "The person's name is: " + bob.name