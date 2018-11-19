module RPATeachable
  class List
    class Item
      CREATE_ENDPOINT = '/items'
      FINISH_ENDPOINT = '/finish'
      attr_reader :list, :finished_at, :name, :src, :id

      def initialize(list:, name:, src: nil, id: nil, finished_at: nil)
        self.list = list
        self.name = name
        self.src = src
        self.id = id
        self.finished_at = parse_time(finished_at)
      end

      def save
        return true unless src.nil?
        list.save if list.src.nil?
        body = {
          item: {
            name: name
          }
        }
        response = APIUtil.post(list.src + CREATE_ENDPOINT, body)

        self.src = response[:src]
        self.id = response[:id]
        true
      end

      def finish
        save if src.nil?
        APIUtil.put(src + FINISH_ENDPOINT)
        assign_finished_at
        true
      end

      def delete
        return true if src.nil?
        APIUtil.delete(src)
      end

      private

      def assign_finished_at
        self.finished_at = list.items.select { |l| l.id == id }[0].finished_at
      end

      def parse_time(time)
        return nil if time.nil?
        Time.strptime(time, '%Y-%m-%dT%T.%LZ')
      end

      attr_writer :list, :name, :finished_at, :src, :id
    end
  end
end
