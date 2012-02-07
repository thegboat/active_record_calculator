# active\_record\_calculator

__Known Issues:__

* not compatible with activerecord 3.0.0 or higher

__Usage:__

Use active record calculator to subgroup SQL calculations.  active record calculator is best used when:

* whenever more than a third of the table rows need to be examined
* when a group by returns many rows
* when the alternative requires many queries whose conditions can not be totally indexed

You should run benchmarks to determine when to use active record calculator. As a rule active record calculator queries are as slow as the slowest single query.

__Example:__

    calculator = Purchase.calculator(:conditions => ["created_at > ?", 1.year.ago], group => "store_id") do |c|
      c.count(:id, :total_purchases)
      c.cnt(:id, :expensive_purchases, "amount_in_cents > 100")
      c.average(:amount_in_cents, :cost_per_purchase)
      c.avg(:amount_in_cents, :cost_per_expensive_purchase, "amount_in_cents > 100")
      c.sum(:amount_in_cents, :total_sales)
      c.sum(:amount_in_cents, :total_expensive_sales, "amount_in_cents > 100")
      c.min(:amount_in_cents, :least_over_100, "amount_in_cents > 100")
      c.max(:amount_in_cents, :most_less_100, "amount_in_cents <= 100")
    end
    calculator.calculate

__Will yield the same data as__

    Purchase.count(:id, :conditions => ["created_at > ?", 1.year.ago], :group => "store_id")
    Purchase.count(:id, :conditions => ["amount_in_cents > 100 and created_at > ?", 1.year.ago], :group => "store_id" )
    Purchase.average(:amount_in_cents, :conditions => ["created_at > ?", 1.year.ago], :group => "store_id" )
    Purchase.sum(:amount_in_cents, :conditions => ["created_at > ?", 1.year.ago])
    Purchase.sum(:amount_in_cents, :conditions => ["amount_in_cents > 100 and created_at > ?", 1.year.ago])
    Purchase.minimum(:amount_in_cents, :conditions => ["amount_in_cents > 100 and created_at > ?", 1.year.ago])
    Purchase.maximum(:amount_in_cents, :conditions => ["amount_in_cents <= 100 and created_at > ?", 1.year.ago])

When adding operations, the calculator expects the format

 method(column, alias, sub\_group\_condition)
 
The calculate method returns an array of hashes with the aliases as keys and results as values
Group columns are automatically included

__Example:__

    >> calc = Transaction.calculator(:conditions => "transactions.user_id = 55555", :group => "transactions.user_id, bonus") do |c|
    ?>   c.count :id, "transactions_count"
    >>   c.count :id, "approved_bonus_count", "status = 'approved' and bonus = true"
    >>   c.count :id, "approved_offers_count", "status = 'approved' and bonus = false"
    >> end
    ...
    >> calc.calculate
    => [{"approved_bonus_count"=>0, "group_column_1"=>"55555", "group_column_2"=>"0", "transactions_count"=>34, "approved_offers_count"=>0}, {"approved_bonus_count"=>17, "group_column_1"=>"55555", "group_column_2"=>"1", "transactions_count"=>18, "approved_offers_count"=>17}]

You can use statement method to see the sql created.

The updater can be used for fast direct sql updates.  An updater needs to be created where all the operations have aliases that have a respective column name in the update table.  The first two arguments are the update table and the key to join.  The key is joined with the first group column which is also required.

    updater = Purchases.updater(:purchase_history, :user_id, :conditions => "created_at > '2011-07-01'", :group => "user_id")
    updater.count :id, "total_purchases"
    updater.cnt :id, "expensive_purchases", "price > 100"
    updater.sum :price, "cheap_spending", "price < 100"
    updater.avg :price, "cheap_average", "price < 100"
    updater.min :price, "least_purchase"
    updater.max :price, "most_purchase"
  
Update should work with all ActiveRecord supported databases except sqlite
