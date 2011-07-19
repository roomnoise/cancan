module CanCan
  module ModelAdapters
    class MongoMapperAdapter < AbstractAdapter
      def self.for_class?(model_class)
        model_class <= MongoMapper::Document
      end

      def database_records
        if @rules.size == 0
          @model_class.where(:_id => {'$exists' => false, '$type' => 7})
        elsif @rules.size == 1 && @rules[0].conditions.is_a?(Hash)
          @model_class.where(@rules[0].conditions)
        else
          # we only need to process can rules if
          # there are no rules with empty conditions
          rules = @rules.reject { |rule| rule.conditions.empty? }
          process_can_rules = @rules.count == rules.count
          rules.inject(@model_class.all) do |records, rule|
            if process_can_rules && rule.base_behavior
              records.select{|r| r.find(rule.conditions)} #.or rule.conditions
            elsif !rule.base_behavior
              records.excludes rule.conditions
            else
              records
            end
          end
        end
      end
      
    end # class MongoMapperAdapter
  end # module ModelAdapters
end # module CanCan

module MongoMapper::Document::ClassMethods
  include CanCan::ModelAdditions::ClassMethods
end