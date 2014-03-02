Given(/^the System is$/) do |source|
  @system ||= Qrb::DEFAULT_SYSTEM.parse(source)
end

### dressing

Given(/^I dress the following JSON document:$/) do |str|
  doc = MultiJson.load(str)
  @result = @system.dress(doc) rescue $!
end

Given(/^I dress the following JSON document with (.*?):$/) do |type, json|
  type = @system.fetch(type)
  json = ::MultiJson.load(json)
  @result = type.dress(json) rescue $!
end

### result

Then(/^it should be a success$/) do
  @result.should_not be_a(Exception)
end

Then(/^it should be a TypeError as:$/) do |table|
  @result.should be_a(Qrb::TypeError)
  expected = table.hashes.first
  expected.each_pair do |k,v|
    @result.send(k.to_sym).should eq(v)
  end
end

Then(/^the result should equal (\d+)$/) do |expected|
  @result.should eq(Integer(expected))
end

### representation

Then(/^the result should be a Nil representation$/) do
  @result.should be_nil
end

Then(/^the result should be a Tuple representation$/) do
  @result.should be_a(Hash)
end

Then(/^its '(.*?)' attribute should be a Date representation$/) do |attr|
  @result[attr.to_sym].should be_a(Date)
end

Then(/^the result should be a representation for (.*?)$/) do |type|
  type = @system.fetch(type)
  case type
  when Qrb::TupleType
    @result.should be_a(Hash)
    @result.keys.all?{|k| k.should be_a(Symbol) }
  when Qrb::RelationType
    @result.should be_a(Set)
    @result.all?{|t|
      t.should be_a(Hash)
      t.keys.all?{|k| k.should be_a(Symbol) }
    }
  else
    raise "Unexpected type `#{type}`"
  end
end
