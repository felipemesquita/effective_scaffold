class <%= class_name %> < ActiveRecord::Base
  def self.all
    find(:all)
  end
end
