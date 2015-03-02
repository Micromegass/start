# == Schema Information
#
# Table name: courses
#
#  id            :integer          not null, primary key
#  name          :string(50)
#  row           :integer
#  abstract      :text
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  time_estimate :string(50)
#  excerpt       :string
#  description   :string
#

class Course < ActiveRecord::Base
  include RankedModel
  ranks :row

  has_many :resources
  has_many :challenges
end
