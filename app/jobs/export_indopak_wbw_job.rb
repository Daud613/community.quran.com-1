class ExportIndopakWbwJob < ApplicationJob
  queue_as :default
  STORAGE_PATH = "public/exported_indopak"
  
  def perform(original_file_name='indopak_wbw')
    file_name = original_file_name.chomp('.db')
    file_path = "#{STORAGE_PATH}/#{Time.now.to_i}"
    require 'fileutils'
    FileUtils::mkdir_p file_path
    
    prepare_db("#{file_path}/#{file_name}.db")
    
    prepare_import_sql
    
    # zip the file
    `bzip2 #{file_path}/#{file_name}.db`
    
    # return the db file path
    "#{file_path}/#{file_name}.db.bz2"
  end
  
  def prepare_db(file_path)
    ExportRecord.establish_connection connection_config(file_path)
    ExportRecord.connection.execute("CREATE TABLE words(sura integer,ayah integer, word_position integer,
                                     text_uthmani text, text_indopak text, text_imlaei text, word_type text,
                                      primary key(sura, ayah, word_position))")
    ExportRecord.table_name = 'words'
  end
  
  def prepare_import_sql()
    hizb= WbwText.where(word_id: Word.where(char_type_name: 'rub-el-hizb').map(&:id))
    hizb.update_all(text_indopak: "۞", text_uthmani: "۞", text_imlaei: "۞")


    Word.find_each do |word|
      w_type         = ExportRecord.connection.quote(word.char_type_name)
      chapter, verse = word.verse_key.split(':')

      text_madani           = ExportRecord.connection.quote(word.text_uthmani)
      text_indopak           = ExportRecord.connection.quote(word.text_indopak)
      text_imlaei = ExportRecord.connection.quote(word.text_imlaei)

      values          = "(#{chapter}, #{verse}, #{word.position}, #{text_madani}, #{text_indopak}, #{text_imlaei}, #{w_type})"
      begin
        ExportRecord.connection.execute("INSERT INTO words (sura, ayah, word_position, text_uthmani, text_indopak, text_imlaei,
                                         word_type) VALUES #{values}")
      rescue Exception => e
        puts e.message
      end
    end
  end
  
  def connection_config(file_name)
    { adapter:  'sqlite3',
      database: file_name
    }
  end
  
  class ExportRecord < ActiveRecord::Base
  end
end




