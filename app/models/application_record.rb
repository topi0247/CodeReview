# frozen_string_literal: true

# app/models/application_record.rb

# ApplicationRecord is the base class for all models in the application.
class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class
end
