ActiveAdmin.register Word do
  menu parent: "Quran", priority: 3

  filter :verse_key
  filter :char_type
  filter :page_number
  filter :text_madani
  filter :code_hex

  permit_params do
    [:text_indopak]
  end

  show do
    attributes_table do
      row :id
      row :verse
      row :verse_key
      row :verse_index
      row :position
      row :text_madani
      row :text_clean
      row :text_simple
      row :page_number do |resource|
        link_to resource.page_number, "/admin/page?page#{resource.page_number}"
      end

      row :font do |resource|
        (span class: "v2p#{resource.page_number} char-#{resource.char_type_name.to_s.downcase}" do
          resource.code.html_safe
        end)
      end

      row :font_v3 do |resource|
        (span class: "v3p#{resource.page_number} char-#{resource.char_type_name.to_s.downcase}" do
          resource.code_v3.html_safe
        end)
      end

      row :text_font do |resource|
        (span class: "pt#{resource.page_number} char-#{resource.char_type_name.to_s.downcase}" do
          resource.code_v3.html_safe
        end)
      end

      row :image do |resource|
        image_tag resource.image_url
      end

      row :image_blob
      row :word_corpus
      row :word_lemmas do |resource|
        resource.word_lemmas.map do |w|
          link_to w, [:admin, w]
        end
      end
    end
  end

  index do
    column :id do |resource|
      link_to resource.id, admin_word_path(resource)
    end

    column :verse do |resource|
      link_to resource.verse_id, admin_verse_path(resource.verse_id)
    end

    column :char_type do |resource|
      resource.char_type_name
    end
    column :position

    column :pause_name do |resource|
      if resource.char_type_id == 4
        if resource.pause_marks.present?
          resource.pause_marks.pluck(:mark).join ', '
        else
          div do
            (link_to("Jeem", admin_pause_marks_path(word_id: resource.id, mark: 'jeem'), class: 'mark-btn', data: {method: :post, remote: true, disable_with: 'Wait'}) +
                (link_to "Sad lam ya", admin_pause_marks_path(word_id: resource.id, mark: 'Sad lam ya'), class: 'mark-btn', data: {method: :post, remote: true, disable_with: 'Wait'})+
                (link_to "Three dots", admin_pause_marks_path(word_id: resource.id, mark: 'Three dots'), class: 'mark-btn', data: {method: :post, remote: true, disable_with: 'Wait'})+
                (link_to "Qaf lam ya", admin_pause_marks_path(word_id: resource.id, mark: 'qaf lam ya'), class: 'mark-btn', data: {method: :post, remote: true, disable_with: 'Wait'})+
                (link_to "Lam Alif", admin_pause_marks_path(word_id: resource.id, mark: 'lam alif'), class: 'mark-btn', data: {method: :post, remote: true, disable_with: 'Wait'})+
                (link_to "Meem", admin_pause_marks_path(word_id: resource.id, mark: 'Meem'), class: 'mark-btn', data: {method: :post, remote: true, disable_with: 'Wait'})+
                (link_to "Seen", admin_pause_marks_path(word_id: resource.id, mark: 'Seen'), class: 'mark-btn', data: {method: :post, remote: true, disable_with: 'Wait'})
            ).html_safe
          end
        end
      end
    end

    column :font do |resource|
      (span class: "v2p#{resource.page_number} char-#{resource.char_type.name.to_s.downcase}" do
        resource.code.html_safe
      end)
    end

    column :fontv3 do |resource|
      (span class: "v3p#{resource.page_number} char-#{resource.char_type.name.to_s.downcase}" do
        resource.code_v3.html_safe
      end)
    end

    column :font_v3 do |resource|
      (span class: "v3p#{resource.page_number} char-#{resource.char_type_name.to_s.downcase}" do
        resource.code_v3.html_safe
      end)
    end

    column :code_hex
    column :code_hex_v3
    column :text_madani
    column :text_simple

    actions
  end

  def scoped_collection
    super.includes :verse, :char_type # prevents N+1 queries to your database
  end

  sidebar "Audio", only: :show do
    table do
      thead do
        td :id
        td :language
        td :play
      end

      tbody do
        word.audio_files.each do |audio|
          tr do
            td link_to(audio.id, [:admin, audio])
          end
        end
      end
    end
  end

  sidebar "Transliterations", only: :show do
    table do
      thead do
        td :id
        td :language
        td :text
      end

      tbody do
        word.transliterations.each do |trans|
          tr do
            td link_to(trans.id, [:admin, trans])
            td link_to(trans.language_name, admin_language_path(trans.language_id)) if trans.language_id
            td trans.text
          end
        end
      end
    end
  end

  sidebar "Translations", only: :show do
    table do
      thead do
        td :id
        td :language
        td :text
      end

      tbody do
        word.translations.each do |trans|
          tr do
            td link_to(trans.id, [:admin, trans])
            td link_to(trans.language_name, admin_language_path(trans.language_id)) if trans.language_id
            td trans.text
          end
        end
      end
    end
  end
end
