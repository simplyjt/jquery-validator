module JqueryValidator
  class Base
    def initialize(builder, validator, selected_fields = nil)
      @builder, @validator = builder, validator
      @attributes = if selected_fields == nil
        @validator.attributes
      else
        if selected_fields.is_a?(Symbol)
          @validator.attributes.select { |attribute| selected_fields == attribute}
        else        
          @validator.attributes.select { |attribute| selected_fields.include? attribute }
        end
      end
    end

    def validate_attributes
      options = {}

      conditional = @validator.options[:if] || @validator.options[:unless]

      if conditional.is_a?(Symbol)
        result = @builder.object.send(conditional)
      elsif conditional.is_a?(Proc)
        result = conditional.call
      end

      result = !result if @validator.options[:unless]

      if result == false
        return options
      end

      @attributes.each do |attribute|
        field_name = "#{@builder.object_name}[#{attribute}]"
        options.deep_merge!( validate_attribute(field_name) )
        if @validator.options.key? :message
          options.deep_merge!( {:messages => { field_name => @validator.options[:message] }})
        end        
      end

      options
    end

  end
  
  def self.factory(v, builder, selected_fields)
    klass = v.class.to_s.split("::").last
    klass = "JqueryValidator::#{klass}"
    klass.constantize.new(builder, v, selected_fields)
  rescue =>e
    # No matching validator exists.  
    #Rails.logger.debug e.message
    nil
  end
  
  class PresenceValidator < JqueryValidator::Base
    def validate_attribute(field_name)
      {:rules => {field_name =>  {'required' => true}}}
    end
  end
  
  class AcceptanceValidator < JqueryValidator::Base
    def validate_attribute(field_name)
      { :rules => { field_name =>  {:accepts => true}} }
    end
  end

  class ConfirmationValidator < JqueryValidator::Base
    def validate_attribute(field_name)
      { :rules => { field_name.gsub(/]/, '_confirmation]') =>  {:equalTo => '#' + field_name.slice(0..field_name.length-2).gsub(/\[/, '_')}} }
    end
  end
  
  #note: this currentty doesn't create valid jquery -- should use :range instead for some cases, and something custom for includes/excludes
  # http://docs.jquery.com/Plugins/Validation/Methods/range
  class ExclusionValidator < JqueryValidator::Base
    def validate_attribute(field_name)
      { :rules => { field_name =>  {:excludes => @validator.options[:in] }}}
    end
  end  

  #note: this currentty doesn't create valid jquery -- should use :range instead for some cases, and something custom for includes/excludes
  class InclusionValidator < JqueryValidator::Base
    def validate_attribute(field_name)
      { :rules => { field_name =>  {:includes => @validator.options[:in] }}}
    end
  end
  
  class LengthValidator < JqueryValidator::Base
    def validate_attribute(field_name)
      args = {:rules => {field_name => {}}}
      args[:rules][field_name][:minlength] = @validator.options[:minimum] if @validator.options[:minimum]
      args[:rules][field_name][:maxlength] = @validator.options[:maximum] if @validator.options[:maximum]
      args
    end
  end

  class NumericalityValidator < JqueryValidator::Base
    def validate_attribute(field_name)
      args = {:rules => {field_name => {:number => true}}}
      args[:rules][field_name][:min] = @validator.options[:greater_than_or_equal_to] if @validator.options[:greater_than_or_equal_to]
      args[:rules][field_name][:max] = @validator.options[:less_than_or_equal_to] if @validator.options[:less_than_or_equal_to]
      args[:rules][field_name][:digits] = true if @validator.options[:only_integer]
      args 
    end
  end
  
  class FormatValidator < JqueryValidator::Base
    def validate_attribute(field_name)
      args = {:rules => {field_name => {}}}
      args[:rules][field_name][:matches] = @validator.options[:with].source if @validator.options[:with]
      args[:rules][field_name][:nomatches] = @validator.options[:without].source if @validator.options[:without]
      args
    end
  end

  
end
