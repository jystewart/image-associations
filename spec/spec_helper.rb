begin
  require 'rubygems'
  require 'spec'
rescue LoadError
  puts "Please install rspec to run the tests."
  exit 1
end

begin
  require 'rubygems'
  require 'activerecord'
rescue LoadError
  puts "Please install rubygems and activerecord to run the tests"
  exit 1
end

require File.join(File.dirname(__FILE__), *%w[../lib/image_associations])

class ActiveRecordStub
  class << self
    def has_many(name, *args); end
    def belongs_to(name, *args); end
  end
  
  def write_attribute(name, value); end
end

class FakeImageStub
  class << self
    def create!(*args); end
  end
end