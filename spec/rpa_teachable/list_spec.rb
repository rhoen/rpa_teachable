describe RPATeachable::List do
  let(:name) { 'my list' }
  it 'can be instantiated with a name' do
    list = RPATeachable::List.new(name: name)
    expect(list.name).to eq(name)
  end

  describe '#save' do
    it ''
  end
end
