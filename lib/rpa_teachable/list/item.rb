module RPATeachable
  class List
    class Item
      CREATE_ENDPOINT = '/items'
      FINISH_ENDPOINT = '/finish'
      attr_reader :list, :finished_at, :name, :src, :id

      def initialize(list:, name:, src: nil, id: nil)
        self.list = list
        self.name = name
        self.src = src
        self.id = id
      end

      def save
        return true unless src.nil?
        list.save if list.src.nil?
        response = APIUtil.post(
          list.src + CREATE_ENDPOINT,
          body: {
            name: name
          }
        )

        self.src = response[:src]
        self.id = response[:id]
        true
      end

      def finish
        save if src.nil?
        response = APIUtil.put(src + '/finish')
        self.finished_at = response[:finished_at]
        true
      end

      def delete
        return true if src.nil?
        APIUtil.delete(src)
      end

      private

      attr_writer :list, :name, :finished_at, :src, :id
    end
  end
end
