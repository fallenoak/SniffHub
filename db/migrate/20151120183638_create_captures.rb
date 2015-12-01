class CreateCaptures < ActiveRecord::Migration
  def change
    create_table :captures do |t|
      t.integer     :upload_id,           null: false
      t.integer     :user_id,             null: false

      t.string      :original_file_name,  null: false
      t.string      :file_name,           null: false
      t.string      :file_type,           null: false
      t.string      :file_path,           null: false
      t.integer     :file_size,           null: false
      t.string      :file_digest,         null: false

      t.string      :client_build,        null: true
      t.string      :client_locale,       null: true
      t.string      :format_version,      null: true

      t.timestamp   :captured_at,         null: true
      t.timestamp   :uploaded_at,         null: true

      t.timestamps null: false
    end
  end
end
