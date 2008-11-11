# ImageAssociations
module Ketlai
  module Image
    module Associations
      def self.included(base)
        base.extend(ClassMethods)
      end
      
      def valid_file?(data)
        data.is_a?(StringIO) or (defined?(ActionController) and data.is_a?(ActionController::UploadedTempfile))
      end
      
      module ClassMethods
        def belongs_to_image(association_id, options = {})
          belongs_to association_id, options
          define_method("#{association_id}=") do |value|
            this_file = file_value(value)
            return if this_file.blank?
            association = self.class.reflect_on_association(association_id)
            if this_file.is_a?(StringIO) or (defined?(ActionController) and this_file.is_a?(ActionController::UploadedTempfile))
              image_class = association.class_name.constantize
              value = image_class.create!(:uploaded_data => this_file)
            end
            write_attribute association.association_foreign_key, value.id
          end
        end
        
        def has_one_image(association_id, options = {})
          has_one association_id, options
          define_has_one_method(association_id)
        end
        
        def has_many_images(association_id, options = {})
          has_many association_id, options
          define_has_many_method(association_id)
        end
        
        protected
          
          def file_value(data)
            data.is_a?(Hash) ? data['uploaded_data'] : data
          end
          
          def define_has_one_method(association_id)
            define_method("#{association_id}=") do |data|
              this_file = file_value(data)
              return unless valid_file?(this_file)
              association = self.class.reflect_on_association(association_id)
              self.send("build_#{association_id}", :uploaded_data => this_file)
            end
          end
          
          def define_has_many_method(association_id)
            define_method("#{association_id}=") do |data|
              return if data.empty? or (data[0].respond_to?(:blank?) and data[0].blank?) or (data[0].is_a?(Hash) and data[0]['uploaded_data'].blank?)
              association = self.class.reflect_on_association(association_id)
              data.each do |value|
                this_file = file_value(value)
                
                if valid_file?(this_file)
                  self.send(association_id).build(:uploaded_data => this_file)
                end
              end
            end
          end
      end
    end
  end
end

ActiveRecord::Base.class_eval do
  include Ketlai::Image::Associations
end