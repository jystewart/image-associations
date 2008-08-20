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
            return if value.blank?
            association = self.class.reflect_on_association(association_id)
            if value.is_a?(StringIO) or (defined?(ActionController) and value.is_a?(ActionController::UploadedTempfile))
              image_class = association.class_name.constantize
              value = image_class.create!(:uploaded_data => value)
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
          
          def define_has_one_method(association_id)
            define_method("#{association_id}=") do |data|
              return unless valid_file?(data)
              association = self.class.reflect_on_association(association_id)
              self.send("build_#{association_id}", :uploaded_data => data)
            end
          end
          
          def define_has_many_method(association_id)
            define_method("#{association_id}=") do |data|
              return if data.empty? or data[0].blank?
              association = self.class.reflect_on_association(association_id)
              data.each do |value|
                if valid_file?(value)
                  self.send(association_id).build(:uploaded_data => value)
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