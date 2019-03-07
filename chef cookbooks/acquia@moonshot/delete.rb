module Moonshot
  module Commands
    class Delete < Moonshot::Command
      include ShowAllEventsOption

      self.usage = 'delete [options]'
      self.description = 'Delete an existing environment'

      def execute
        controller.delete
      end
    end
  end
end
