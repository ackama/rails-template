##
# Create an event class similar to the one below for every auditable event in
# your system.
#
class Auditor
  class Event
    class Example < Event
      def description
        "The example event happened"
      end
    end
  end
end
