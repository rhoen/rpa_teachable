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
    deleted = !RPATeachable::List.all.any? do |l|
      l.id == list.id
    end
    expect(deleted).to be true
  end

  it 'creates and finishes an item' do
    name = 'New List' + Time.now.to_s
    list = RPATeachable::List.new(name: name)
    list.save
    item = list.add_item(name: 'my item' + Time.now.to_s)
    expect(item).to be_a(RPATeachable::List::Item)
    item.finish
    expect(item.finished_at).to be_a(Time)
    list.delete
  end

  it 'can update the name of a list' do
    name = 'New List' + Time.now.to_s
    list = RPATeachable::List.new(name: name)
    new_name = 'New List Name' + Time.now.to_s
    list.name = new_name
    list.save
    fetched_list = RPATeachable::List.all.select{|l| l.id == list.id}[0]
    expect(fetched_list.name).to eq(new_name)
    fetched_list.delete
  end
end
