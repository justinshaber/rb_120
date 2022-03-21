class Pet
  def run
    'running!'
  end

  def jump
    'jumping!'
  end
end

class Dog < Pet
  def speak
    'bark!'
  end

  def fetch
    'fetching!'
  end

  def swim
    'swimming!'
  end
end

class BullDog < Dog
  def swim
    "Can't swim!"
  end
end

class Cat < Pet
  def speak
    'meow!'
  end
end

teddy = Dog.new
puts teddy.speak           # => "bark!"
puts teddy.swim           # => "swimming!"
chubby = BullDog.new
puts chubby.speak
puts chubby.swim

elle = Cat.new
puts elle.speak
puts elle.swim
puts elle.run
puts elle.fetch

