class CreateUploads < ActiveRecord::Migration
  def change
    create_table :uploads do |t|
      t.integer     :user_id,             null: false

      t.string      :original_file_name,  null: false
      t.string      :file_name,           null: false
      t.string      :file_type,           null: false
      t.string      :file_path,           null: false
      t.integer     :file_size,           null: false
      t.string      :file_digest,         null: false

      t.boolean     :archive,             default: false, null: false
      t.boolean     :unsupported,         default: false, null: false
      t.boolean     :deleted,             default: false, null: false
      t.boolean     :processed,           default: false, null: false

      t.timestamp   :uploaded_at,         null: true

      t.timestamps null: false
    end
  end
end
