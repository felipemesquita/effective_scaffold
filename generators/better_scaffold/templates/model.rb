class <%= class_name %> < ActiveRecord::Base
  cattr_reader :per_page
  @@per_page = 3

end
