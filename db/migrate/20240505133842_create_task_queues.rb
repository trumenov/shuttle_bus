class CreateTaskQueues < ActiveRecord::Migration[6.0]
  def change
    create_table :task_queues, { id: :unsigned_integer, options: "ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci" } do |t|
      t.string :name, null: false, default: "", limit: 240
      t.integer :user_id, limit: 8, null: false, default: 0, :unsigned => true
      t.string :pub_password
      t.timestamps null: false
      t.index [:user_id], name: "index_task_queues_on_user_id"
    end

    create_table :ceparser_tasks, { id: :unsigned_integer, options: "ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci" } do |t|
      t.integer :task_queue_id, limit: 8, null: false, default: 0, :unsigned => true
      t.integer :prio, limit: 4, null: false, default: 0, :unsigned => true
      t.text :task_options_json, size: :long
      t.integer :take_await_seconds, limit: 8, null: false, default: 0, :unsigned => true
      t.integer :take_max_seconds, limit: 8, null: false, default: 0, :unsigned => true
      t.integer :failed_cnt, limit: 4, null: false, default: 0, :unsigned => true
      t.string :taked_by
      t.datetime :taked_at
      t.datetime :last_ping_at
      t.timestamps null: false
      t.index [:task_queue_id, :prio], name: "index_ceparser_task_on_queue_prio"
    end
  end
end
