module Gmail
  module Base
    module Trash
      def trash(_opts = {})
        response = Gmail.request(self.class.base_method.send('trash'), id: id)
        Util.convert_to_gmail_object(response, self.class.class_name.downcase)
      end

      def untrash(_opts = {})
        response = Gmail.request(self.class.base_method.send('untrash'), id: id)
        Util.convert_to_gmail_object(response, self.class.class_name.downcase)
      end

      module ClassMethods
        def trash(id, _opts = {})
          response = Gmail.request(base_method.send('trash'), id: id)
          Util.convert_to_gmail_object(response, class_name.downcase)
        end

        def untrash(id, _opts = {})
          response = Gmail.request(base_method.send('untrash'), id: id)
          Util.convert_to_gmail_object(response, class_name.downcase)
        end
      end

      def self.included(base)
        base.extend(ClassMethods)
      end
    end
  end
end
