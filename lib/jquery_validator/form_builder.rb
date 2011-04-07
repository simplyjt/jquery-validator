module ActionView
  module Helpers
    class FormBuilder
      def jquery_validators(options = {})
        fields = options.delete(:only)
        v_arr = @object.class.validators.map do |v|
          if v.attributes.size > 1
            v.attributes.map do |a|
              new_v = v.clone
              new_v.instance_variable_set "@attributes", [a]
              new_v
            end
          else
            v
          end
        end
        v_arr.flatten.each do |v|
          if !fields || fields.include?(v.attributes.first)
            if validator = JqueryValidator.factory(v, self)
              options.deep_merge!(JqueryValidator.factory(v, self).validate_arguments)
            end
          end
        end
        js = options.to_json
        js.gsub!(/"\s*(function\(.*\})\s*\"/, '\1')
        code = %Q[
            <script>
            $(document).ready(function() {
              $("##{ActionController::RecordIdentifier.dom_id(@object, @object.new_record? ? :new : :edit)}").validate(#{js});
            });
            </script>
          ]
        code.html_safe
      end
    end
  end
end
