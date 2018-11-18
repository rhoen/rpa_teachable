describe RPATeachable::List do
  let(:name) { 'my list' }
  let(:src) { 'some_link' }
  let(:id) { 'somd_id' }
  let(:item_name) { 'item name' }
  let(:item_src) { 'item src' }
  subject { RPATeachable::List.new(name: name) }
  let(:list_create_response) do
    {
      name: name,
      src: src,
      id: id
    }
  end
  let(:list_show_response) do
    {
      name: name,
      items: [
        name: item_name,
        src: item_src
      ]
    }
  end
  let(:all_response_body) do
    {
      lists: [
        list_create_response
      ]
    }
  end
  before do
    allow(RPATeachable::APIUtil).to receive(:post)
      .and_return(list_create_response)
    allow(RPATeachable::APIUtil).to receive(:patch)
      .and_return(list_create_response)
    allow(RPATeachable::APIUtil).to receive(:delete).and_return(true)
    allow(RPATeachable::APIUtil).to receive(:get)
      .with(RPATeachable::APIUtil::BASE_URL + RPATeachable::List::ENDPOINT)
      .and_return(all_response_body)
    allow(RPATeachable::APIUtil).to receive(:get).with(src)
      .and_return(list_show_response)
  end

  it 'can be instantiated with a name' do
    expect(subject.name).to eq(name)
  end

  describe '.all' do
    it 'uses APIUtil to get' do
      described_class.all
      expect(RPATeachable::APIUtil).to have_received(:get).with(
        RPATeachable::APIUtil::BASE_URL + RPATeachable::List::ENDPOINT
      )
    end

    it 'returns an array of lists' do
      expect(described_class.all).to be_a(Array)
      expect(described_class.all[0]).to be_a(RPATeachable::List)
    end
  end

  describe '#items' do
    subject { RPATeachable::List.new(name: name, src: src) }
    it 'users APIUtil to get the list' do
      subject.items
      expect(RPATeachable::APIUtil).to have_received(:get).with(src)
    end

    it 'returns an array of Items' do
      expect(subject.items).to be_a(Array)
      expect(subject.items[0]).to be_a(RPATeachable::List::Item)
    end
  end

  describe '#delete' do
    context 'src is set' do
      subject { RPATeachable::List.new(name: name, src: src) }
      it 'uses APIUtil to delete' do
        subject.delete
        expect(RPATeachable::APIUtil).to have_received(:delete).with(src)
      end
    end

    context 'src is not set' do
      it 'does not use APIUtil to delete' do
        subject.delete
        expect(RPATeachable::APIUtil).not_to have_received(:delete)
      end
    end
  end

  describe '#add_item' do
    before do
      allow(RPATeachable::List::Item).to receive(:new).and_call_original
    end
    
    it 'instantiates an item and calls save' do
      name = 'item'
      subject.add_item(name: name)
      expect(RPATeachable::List::Item).to have_received(:new).with(
        list: subject,
        name: name
      )
    end
  end

  describe '#save' do
    context 'src is not set' do
      it 'uses the APIUtil to post' do
        subject.save
        expect(RPATeachable::APIUtil).to have_received(:post).with(
          RPATeachable::APIUtil::BASE_URL + RPATeachable::List::ENDPOINT,
          list: {name: name}
        )
      end

      it 'sets the src' do
        subject.save
        expect(subject.src).to eq(src)
      end

      it 'sets the id' do
        subject.save
        expect(subject.id).to eq(id)
      end
    end

    context 'src is set' do
      subject { RPATeachable::List.new(name: name, src: src) }
      it 'users APIUtil to patch' do
        subject.save
        expect(RPATeachable::APIUtil).to have_received(:patch).with(
          src,
          list: { name: name }
        )
      end
    end
  end
end
