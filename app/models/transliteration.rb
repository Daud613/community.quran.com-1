class Transliteration < QuranApiRecord
  has_paper_trail on: :update, ignore: [:created_at, :updated_at]

  belongs_to :resource, polymorphic: true
  belongs_to :language
  belongs_to :resource_content
end
