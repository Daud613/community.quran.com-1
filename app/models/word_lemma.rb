# == Schema Information
#
# Table name: word_lemmas
#
#  id         :integer          not null, primary key
#  word_id    :integer
#  lemma_id   :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class WordLemma < QuranApiRecord
  belongs_to :word
  belongs_to :lemma

  def to_s
    lemma&.text_madani
  end
end
