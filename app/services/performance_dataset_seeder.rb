class PerformanceDatasetSeeder
  DEFAULTS = {
    accounts: 3,
    inventories_per_account: 1_000,
    purchases_per_account: 5_000,
    deliveries_per_account: 5_000,
    items_batch_size: 1_000
  }.freeze

  def initialize(accounts: DEFAULTS[:accounts], inventories_per_account: DEFAULTS[:inventories_per_account], purchases_per_account: DEFAULTS[:purchases_per_account], deliveries_per_account: DEFAULTS[:deliveries_per_account], items_batch_size: DEFAULTS[:items_batch_size])
    @accounts = accounts.to_i
    @inventories_per_account = inventories_per_account.to_i
    @purchases_per_account = purchases_per_account.to_i
    @deliveries_per_account = deliveries_per_account.to_i
    @items_batch_size = items_batch_size.to_i
  end

  def call
    require "factory_bot"

    puts "performance_seed: start"
    puts "accounts=#{accounts} inventories_per_account=#{inventories_per_account} purchases_per_account=#{purchases_per_account} deliveries_per_account=#{deliveries_per_account}"

    now = Time.current

    accounts.times do |account_idx|
      company = FactoryBot.create(:company, name: "PerfCompany#{account_idx + 1}")

      inventories = Array.new(inventories_per_account) do
        FactoryBot.attributes_for(:inventory, company_id: company.id).merge(created_at: now, updated_at: now)
      end
      Inventory.insert_all!(inventories)
      inventory_ids = company.inventories.order(:id).pluck(:id)

      purchases = Array.new(purchases_per_account) do |i|
        FactoryBot.attributes_for(:purchase, company_id: company.id, num: "P#{company.id}-#{i + 1}").merge(created_at: now, updated_at: now)
      end
      Purchase.insert_all!(purchases)
      purchase_ids = company.purchases.order(:id).pluck(:id)

      deliveries = Array.new(deliveries_per_account) do |i|
        FactoryBot.attributes_for(:delivery, company_id: company.id, num: "D#{company.id}-#{i + 1}").merge(created_at: now, updated_at: now)
      end
      Delivery.insert_all!(deliveries)
      delivery_ids = company.deliveries.order(:id).pluck(:id)

      build_and_insert_items(
        klass: PurchaseItem,
        factory_key: :purchase_item,
        company_id: company.id,
        parent_ids: purchase_ids,
        inventory_ids: inventory_ids,
        batch_size: items_batch_size,
        parent_key: :purchase_id,
        now: now
      )

      build_and_insert_items(
        klass: DeliveryItem,
        factory_key: :delivery_item,
        company_id: company.id,
        parent_ids: delivery_ids,
        inventory_ids: inventory_ids,
        batch_size: items_batch_size,
        parent_key: :delivery_id,
        now: now
      )

      puts "performance_seed: company=#{company.id} done"
    end

    puts "performance_seed: completed"
  end

  private

  attr_reader :accounts, :inventories_per_account, :purchases_per_account, :deliveries_per_account, :items_batch_size

  def build_and_insert_items(klass:, factory_key:, company_id:, parent_ids:, inventory_ids:, batch_size:, parent_key:, now:)
    buffer = []

    parent_ids.each do |parent_id|
      inventory_id = inventory_ids.sample
      attrs = FactoryBot.attributes_for(
        factory_key,
        company_id: company_id,
        inventory_id: inventory_id,
        parent_key => parent_id
      ).merge(created_at: now, updated_at: now)

      buffer << attrs

      if buffer.size >= batch_size
        klass.insert_all!(buffer)
        buffer.clear
      end
    end

    klass.insert_all!(buffer) if buffer.any?
  end
end
