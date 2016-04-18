module QMA
  module Tryable
    def try(*a, &b)
      try!(*a, &b) if a.empty? || respond_to?(a.first)
    end

    def try!(*a, &b)
      if a.empty? && block_given?
        if b.arity.zero?
          instance_eval(&b)
        else
          yield self
        end
      else
        public_send(*a, &b)
      end
    end
  end
end

class Object
  include QMA::Tryable
end