module RPATeachable
  class List
    ENDPOINT = '/lists'

    def self.all
      response = APIUtil.get(APIUtil::BASE_URL + ENDPOINT)
      response[:lists].map do |list|
        self.new(list)
      end
    end

    attr_accessor :name
    attr_reader :id, :src

    def initialize(name:, src: nil, id: nil)
      self.name = name
      self.src = src
      self.id = id
    end

    def items
      response = APIUtil.get(src)
      response[:items].map do |item|
        Item.new(item.merge(list: self))
      end
    end

    def save
      body = {
        list: {
          name: name
        }
      }
      if src
        response = APIUtil.patch(src, body)
      else
        response = APIUtil.post(APIUtil::BASE_URL + ENDPOINT, body)
        self.id = response[:id]
        self.src = response[:src]
      end

      true
    end

    def delete
      return true if src.nil?
      APIUtil.delete(src)
    end

    private

    attr_writer :id, :src

  end
end

require 'rpa_teachable/list/item'
