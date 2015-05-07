# == Schema Information
#
# Table name: projects
#
#  id                    :integer          not null, primary key
#  course_id             :integer
#  name                  :string
#  explanation_text      :text
#  explanation_video_url :string
#  published             :boolean
#  row                   :integer
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#

class Project < ActiveRecord::Base
  include RankedModel
  ranks :row, with_same: :course_id

  validates :name, presence: true
  validates :explanation_text, presence: true
  validates :course, presence: true

  belongs_to :course
  has_many :comments, as: :commentable

  scope :for, -> user { published unless user.is_admin? }
  scope :published, -> { where(published: true) }
  
end
