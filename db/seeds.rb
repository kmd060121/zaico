PerformanceDatasetSeeder.new(
  accounts: ENV.fetch("ACCOUNTS", PerformanceDatasetSeeder::DEFAULTS[:accounts]),
  inventories_per_account: ENV.fetch("INVENTORIES_PER_ACCOUNT", PerformanceDatasetSeeder::DEFAULTS[:inventories_per_account]),
  purchases_per_account: ENV.fetch("PURCHASES_PER_ACCOUNT", PerformanceDatasetSeeder::DEFAULTS[:purchases_per_account]),
  deliveries_per_account: ENV.fetch("DELIVERIES_PER_ACCOUNT", PerformanceDatasetSeeder::DEFAULTS[:deliveries_per_account]),
  items_batch_size: ENV.fetch("ITEMS_BATCH_SIZE", PerformanceDatasetSeeder::DEFAULTS[:items_batch_size])
).call
