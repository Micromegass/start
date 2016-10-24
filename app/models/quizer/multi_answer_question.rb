# == Schema Information
#
# Table name: questions
#
#  id          :integer          not null, primary key
#  quiz_id     :integer
#  type        :string
#  data        :json
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  published   :boolean
#  explanation :text
#
# Indexes
#
#  index_questions_on_quiz_id  (quiz_id)
#

class Quizer::MultiAnswerQuestion < Quizer::Question

  after_initialize :defaults

  def mixed_answers
    (data["correct_answers"] + data["wrong_answers"]).shuffle
  end

  def correct_answers=(correct_answers)
    data["correct_answers"] = correct_answers
  end

  def correct_answers
    data["correct_answers"]
  end

  def wrong_answers=(wrong_answers)
    data["wrong_answers"] = wrong_answers
  end

  def wrong_answers
    data["wrong_answers"]
  end

  def text=(text)
    data["text"] = text
  end

  def text
    data["text"]
  end

  protected
    def defaults
      super
      self.data ||= {
        "text" => "",
        "wrong_answers" => [],
        "correct_answers" => []
      }
    end

    def data_schema
      {
        "type" => "object",
        "required" => ["text"],
        "properties" => {
          "text" => { "type" => "string" },
          "wrong_answers" => {
            "type" => "array",
            "default" => [],
            "items" => { "type" => "string" }
          },
          "correct_answers" => {
            "type" => "array",
            "default" => [],
            "items" => { "type" => "string" }
          }
        }
      }
    end
end
