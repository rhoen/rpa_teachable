describe RPATeachable::List::Item do
  let(:name) { 'my item' }
  let(:src) { 'some_link' }
  let(:list_src) { 'some_list_link' }
  let(:id) { 'somd_id' }
  let(:list) { double('list', name: 'my list', src: list_src) }
  let(:finished_at) { '2018-11-19T00:18:04.333Z' }
  subject { RPATeachable::List::Item.new(name: name, list: list) }
  let(:post_response_body) do
    {
      name: name,
      src: src,
      id: id,
      finished_at: nil
    }
  end
  let(:put_response_body) do
    "Unexpected 's'"
  end
  before do
    allow(RPATeachable::APIUtil).to receive(:post).and_return(post_response_body)
    allow(RPATeachable::APIUtil).to receive(:put).and_return(put_response_body)
    allow(RPATeachable::APIUtil).to receive(:delete).and_return(true)
  end

  it 'can be instantiated with a list and a name' do
    expect(subject.name).to eq(name)
    expect(subject.list).to eq(list)
  end

  it 'can be instantiated with a finished_at string' do
    item = described_class.new(name: name, list: list, finished_at: finished_at)
    expect(item.finished_at).to be_a(Time)
  end

  describe '#finish' do
    let(:finish_time) { Time.now }
    before do
      item = double('item', id: id, finished_at: finish_time )
      allow(list).to receive(:items) { [item] }
    end
    it 'uses APIUtil to put' do
      subject.finish
      expect(RPATeachable::APIUtil).to have_received(:put)
        .with(src + RPATeachable::List::Item::FINISH_ENDPOINT)
    end

    it 'assigns the finished_at from the item in the list' do
      subject.finish
      expect(subject.finished_at).to eq(finish_time)
    end
  end

  describe '#delete' do
    context 'src present' do
      subject { RPATeachable::List::Item.new(name: name, list: list, src: src) }
      it 'calls APIUtil delete' do
        subject.delete
        expect(RPATeachable::APIUtil).to have_received(:delete).with(src)
      end
    end

    context 'src present' do
      it 'does not call APIUtil delete' do
        subject.delete
        expect(RPATeachable::APIUtil).not_to have_received(:delete)
      end
    end
  end

  describe '#save' do
    context 'src not present' do
      before { subject.save }

      it 'uses APIUtil to post' do
        expect(RPATeachable::APIUtil).to have_received(:post).with(
          list.src + RPATeachable::List::Item::CREATE_ENDPOINT,
          { item: { name: name } }
        )
      end

      it 'saves the src' do
        expect(subject.src).to eq(src)
      end

      context 'list not present' do
        it 'raises error' do
          expect { RPATeachable::List::Item.new(name: name) }.to raise_error(
            ArgumentError
          )
        end
      end
    end

    context 'src present' do
      subject { RPATeachable::List::Item.new(name: name, list: list, src: src) }
      it 'returns true' do
        expect(subject.save).to be true
      end

      it 'does not make an API call' do
        subject.save
        expect(RPATeachable::APIUtil).not_to have_received(:post)
      end
    end

    context 'list src not present' do
      let(:list) { double('list', name: 'my list') }
      before { allow(list).to receive(:src).and_return(nil, list_src) }
      it 'calls save on the list' do
        expect(list).to receive(:save).and_return(true)
        subject.save
      end
    end
  end
end
