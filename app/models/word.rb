class Word < QuranApiRecord
  belongs_to :verse
  belongs_to :char_type
  belongs_to :topic
  belongs_to :token

  has_many :translations, as: :resource
  has_many :transliterations, as: :resource
  
  has_one :word_lemma
  has_one :lemma, through: :word_lemma
  has_one :word_stem
  has_one :stem, through: :word_stem
  has_one :word_root
  has_one :root, through: :word_root
  has_one :pause_mark
  has_one  :audio_file, as: :resource
  
  # Used for export translation
  ['en', 'id', 'bn', 'ur'].each do |lang|
    has_one "#{lang}_translation".to_sym, -> { where(language: Language.find_by_iso_code(lang)) }, class_name: 'Translation', as: :resource
  end

  has_one :word_corpus
  has_one :arabic_transliteration

  has_paper_trail on: [:update, :destroy, :create], ignore: [:created_at, :updated_at]

  def code
    "&#x#{code_hex};"
  end

  def code_v3
    "&#x#{code_hex_v3};"
  end

  def audio
    "//audio.recitequran.com/wbw/arabic/wisam_sharieff/#{audio_url}"
  end
end
