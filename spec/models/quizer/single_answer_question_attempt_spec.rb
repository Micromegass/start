# == Schema Information
#
# Table name: question_attempts
#
#  id              :integer          not null, primary key
#  quiz_attempt_id :integer
#  question_id     :integer
#  data            :json
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  type            :string
#  score           :decimal(, )
#
# Indexes
#
#  index_question_attempts_on_question_id      (question_id)
#  index_question_attempts_on_quiz_attempt_id  (quiz_attempt_id)
#

require 'rails_helper'

RSpec.describe Quizer::SingleAnswerQuestionAttempt, type: :model do

  context 'associations' do
    it { should belong_to(:quiz_attempt) }
    it { should belong_to(:question) }
  end

  it "has a valid factory" do
    question_attempt = build(:single_answer_question_attempt)
    expect(question_attempt).to be_valid
  end

  describe "validations" do
    it "validates data schema" do
      question_attempt = build(:single_answer_question_attempt)
      expect(question_attempt).to receive(:validate_data_schema)
      question_attempt.save
    end
  end

  it "calculates and assigns score before save" do
    question_attempt = build(:single_answer_question_attempt)
    expect(question_attempt).to receive(:calculate_score)
    question_attempt.save
  end

  it "assigns a score before_save" do
    question_attempt = build(:single_answer_question_attempt)
    question_attempt.save
    expect(question_attempt.reload.score).to_not be_nil
  end

  describe ".score" do
    it "is 1 if the answer is correct" do
      question_attempt = build(:single_answer_question_attempt)
      question_attempt.answer = SHA1.encode(question_attempt.question.answer)
      question_attempt.save
      expect(question_attempt.score).to eq(1)
    end

    it "is 0 if the answer is incorrect" do
      question_attempt = build(:single_answer_question_attempt)
      question_attempt.answer = SHA1.encode(question_attempt.question.wrong_answers.first)
      question_attempt.save
      expect(question_attempt.score).to eq(0)
    end
  end
end
