RPATeachable.user_name = nil
RPATeachable.password = nil

describe RPATeachable do
  it 'creates and deletes a list' do
    name = 'New List' + Time.now.to_s
    list = RPATeachable::List.new(name: name)
    list.save
    expect(list).to be_a(RPATeachable::List)
    list.delete
    lists = RPATeachable::List.all
    still_present = lists.any? { |list| list.name == name }
    expect(still_present).to be false
  end

  end
end
