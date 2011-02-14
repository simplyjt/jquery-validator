module ActionView
  module Helpers
    class FormBuilder
      def jquery_validators(options = {})
          selected_fields = options.delete(:only)
          
          @object.class.validators.each do |v|
              if validator = JqueryValidator.factory(v, self, selected_fields) #check if matching validator exists
                options.deep_merge!(validator.validate_attributes) 
              end
          end
                    
          # determines form name; copied from rails source: FormHelper::apply_form_for_options!
          action = (@object.respond_to?(:persisted?) && @object.persisted?) ? :edit : :new
          dom_id = @options[:as] ? "#{@options[:as]}_#{action}" : ActionController::RecordIdentifier.dom_id(@object, action)
          
          js = options.to_json
          js.gsub!(/"\s*(function\(.*\})\s*\"/, '\1')
          code = %Q[
            <script>
            $(document).ready(function() {                                        
              $("##{dom_id}").validate(#{js});
            });
            </script>
          ]
          code.html_safe
      end
    end
  end
end
