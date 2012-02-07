require 'rubygems'
require 'bundler/setup'

require 'active_record_calculator'


RSpec.configure do |config|
  # some (optional) config here
end

ActiveRecord::Base.establish_connection(
:adapter => "mysql",
:database => "active_record_calculator_test"
)

ActiveRecord::Migration.create_table :purchases, :force => true do |t|
  t.integer :store_id, :null => false
  t.integer :amount_in_cents, :null => false, :default => 0
  t.boolean :used_coupon, :null => false, :default => false
  t.datetime :purchase_date, :null => false
end

ActiveRecord::Migration.create_table :stat_summaries, :force => true do |t|
  t.integer :store_id, :null => false
  t.integer :total_purchases, :null => false, :default => 0
  t.decimal :cost_per_purchase, :precision => 14, :scale => 2, :default => 0.0,   :null => false
  t.integer :total_sales, :null => false, :default => 0
  t.integer :purchases_with_coupon, :null => false, :default => 0
end

ActiveRecord::Migration.create_table :stores, :force => true do |t|
  t.string :name
end

class Purchase < ActiveRecord::Base
  belongs_to :store
end

class Store < ActiveRecord::Base
  has_many :purchases
  has_one :stat_summary
end

class StatSummary < ActiveRecord::Base
  belongs_to :store
end

store_ids = 1.upto(5).collect do |n|
  store = Store.create(:name => "Store_#{n}")
  StatSummary.create(:store_id => store.id)
  store.id
end
 
1.upto(1000).each do |n|
  Purchase.create(
    :store_id => store_ids.shuffle.first,
    :used_coupon => rand(2) == 1,
    :amount_in_cents => rand(2)*100 + rand(100),
    :purchase_date => (rand(365) + 1).days.ago
  )
end


