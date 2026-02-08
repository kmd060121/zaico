class MaxPerformanceDatasetSeeder
  MAX_CONFIG = {
    inventories: 200_000,
    purchases: 1_000_000,
    deliveries: 1_000_000,
    max_items_per_inventory: 1_000,
    batch_size: 10_000
  }.freeze

  def initialize
    @config = MAX_CONFIG
  end

  def call
    require "factory_bot"

    puts "=== 最大想定パフォーマンステストデータセット生成開始 ==="
    puts ""
    puts "【データ規模】"
    puts "  在庫数: #{config[:inventories].to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse}"
    puts "  入庫伝票: #{config[:purchases].to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse}"
    puts "  出庫伝票: #{config[:deliveries].to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse}"
    puts "  1在庫あたり最大明細数: #{config[:max_items_per_inventory]}"
    puts ""

    total_start_time = Time.current
    now = Time.current

    # Company作成
    puts "【1/5】Company作成中..."
    company = FactoryBot.create(:company, name: "MaxPerformanceCompany")
    puts "  Company ID: #{company.id} 完了"

    # Inventories作成
    puts "【2/5】Inventories作成中（#{config[:inventories]}件）..."
    create_inventories(company, now)
    inventory_ids = company.inventories.order(:id).pluck(:id)
    puts "  #{inventory_ids.size}件の在庫を作成完了"

    # Purchases作成
    puts "【3/5】Purchases作成中（#{config[:purchases]}件）..."
    create_purchases(company, now)
    purchase_ids = company.purchases.order(:id).pluck(:id)
    puts "  #{purchase_ids.size}件の入庫伝票を作成完了"

    # PurchaseItems作成（1在庫あたり最大1000件を意識）
    puts "【4/5】PurchaseItems作成中（1在庫最大#{config[:max_items_per_inventory]}件）..."
    create_purchase_items(company, purchase_ids, inventory_ids, now)

    # Deliveries作成
    puts "【5/5】Deliveries作成中（#{config[:deliveries]}件）..."
    create_deliveries(company, now)
    delivery_ids = company.deliveries.order(:id).pluck(:id)
    puts "  #{delivery_ids.size}件の出庫伝票を作成完了"

    # DeliveryItems作成（1在庫あたり最大1000件を意識）
    puts "【6/6】DeliveryItems作成中（1在庫最大#{config[:max_items_per_inventory]}件）..."
    create_delivery_items(company, delivery_ids, inventory_ids, now)

    total_elapsed = Time.current - total_start_time

    puts ""
    puts "=== データセット生成完了 ==="
    puts "総所要時間: #{total_elapsed.round(2)}秒"
    puts ""
    print_statistics
  end

  private

  attr_reader :config

  def create_inventories(company, now)
    batch_size = config[:batch_size]
    total = config[:inventories]
    batches = (total.to_f / batch_size).ceil

    batches.times do |batch_idx|
      start_idx = batch_idx * batch_size
      end_idx = [start_idx + batch_size, total].min
      count = end_idx - start_idx

      inventories = Array.new(count) do
        FactoryBot.attributes_for(:inventory, company_id: company.id).merge(created_at: now, updated_at: now)
      end
      Inventory.insert_all!(inventories)

      puts "  進捗: #{end_idx}/#{total} (#{((end_idx.to_f / total) * 100).round(1)}%)"
    end
  end

  def create_purchases(company, now)
    batch_size = config[:batch_size]
    total = config[:purchases]
    batches = (total.to_f / batch_size).ceil

    batches.times do |batch_idx|
      start_idx = batch_idx * batch_size
      end_idx = [start_idx + batch_size, total].min
      count = end_idx - start_idx

      purchases = Array.new(count) do |i|
        FactoryBot.attributes_for(:purchase, company_id: company.id, num: "P#{company.id}-#{start_idx + i + 1}").merge(created_at: now, updated_at: now)
      end
      Purchase.insert_all!(purchases)

      puts "  進捗: #{end_idx}/#{total} (#{((end_idx.to_f / total) * 100).round(1)}%)"
    end
  end

  def create_deliveries(company, now)
    batch_size = config[:batch_size]
    total = config[:deliveries]
    batches = (total.to_f / batch_size).ceil

    batches.times do |batch_idx|
      start_idx = batch_idx * batch_size
      end_idx = [start_idx + batch_size, total].min
      count = end_idx - start_idx

      deliveries = Array.new(count) do |i|
        FactoryBot.attributes_for(:delivery, company_id: company.id, num: "D#{company.id}-#{start_idx + i + 1}").merge(created_at: now, updated_at: now)
      end
      Delivery.insert_all!(deliveries)

      puts "  進捗: #{end_idx}/#{total} (#{((end_idx.to_f / total) * 100).round(1)}%)"
    end
  end

  def create_purchase_items(company, purchase_ids, inventory_ids, now)
    batch_size = config[:batch_size]
    buffer = []
    total_items = 0

    # 最大1000件の明細を持つ在庫を作成するため、在庫ごとにアイテム数を計算
    # 上位1000在庫には多くの明細を、残りには少なめに分散
    high_volume_inventory_count = 1000
    high_volume_items_per_inv = config[:max_items_per_inventory]

    # 高負荷在庫用の明細を作成
    high_volume_inventories = inventory_ids.sample(high_volume_inventory_count)

    puts "  高負荷在庫（#{high_volume_inventory_count}在庫 × 最大#{high_volume_items_per_inv}明細）を作成中..."

    high_volume_inventories.each_with_index do |inventory_id, idx|
      items_count = rand(500..high_volume_items_per_inv)

      items_count.times do
        purchase_id = purchase_ids.sample
        attrs = FactoryBot.attributes_for(
          :purchase_item,
          company_id: company.id,
          inventory_id: inventory_id,
          purchase_id: purchase_id
        ).merge(created_at: now, updated_at: now)

        buffer << attrs
        total_items += 1

        if buffer.size >= batch_size
          PurchaseItem.insert_all!(buffer)
          buffer.clear
        end
      end

      if (idx + 1) % 100 == 0
        puts "    高負荷在庫進捗: #{idx + 1}/#{high_volume_inventory_count} (#{total_items.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse}明細作成済み)"
      end
    end

    PurchaseItem.insert_all!(buffer) if buffer.any?
    buffer.clear

    puts "  残りの入庫明細を作成中..."

    # 残りのPurchaseに対して明細を作成（1伝票1〜5明細）
    remaining_purchases = purchase_ids.size - total_items
    processed = 0

    purchase_ids.each do |purchase_id|
      items_per_purchase = rand(1..5)

      items_per_purchase.times do
        inventory_id = inventory_ids.sample
        attrs = FactoryBot.attributes_for(
          :purchase_item,
          company_id: company.id,
          inventory_id: inventory_id,
          purchase_id: purchase_id
        ).merge(created_at: now, updated_at: now)

        buffer << attrs
        total_items += 1

        if buffer.size >= batch_size
          PurchaseItem.insert_all!(buffer)
          buffer.clear
          processed += batch_size
          puts "    進捗: #{total_items.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse}明細作成済み"
        end
      end
    end

    PurchaseItem.insert_all!(buffer) if buffer.any?
    puts "  合計#{total_items.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse}件のPurchaseItemを作成完了"
  end

  def create_delivery_items(company, delivery_ids, inventory_ids, now)
    batch_size = config[:batch_size]
    buffer = []
    total_items = 0

    # PurchaseItemsと同様の戦略
    high_volume_inventory_count = 1000
    high_volume_items_per_inv = config[:max_items_per_inventory]

    high_volume_inventories = inventory_ids.sample(high_volume_inventory_count)

    puts "  高負荷在庫（#{high_volume_inventory_count}在庫 × 最大#{high_volume_items_per_inv}明細）を作成中..."

    high_volume_inventories.each_with_index do |inventory_id, idx|
      items_count = rand(500..high_volume_items_per_inv)

      items_count.times do
        delivery_id = delivery_ids.sample
        attrs = FactoryBot.attributes_for(
          :delivery_item,
          company_id: company.id,
          inventory_id: inventory_id,
          delivery_id: delivery_id
        ).merge(created_at: now, updated_at: now)

        buffer << attrs
        total_items += 1

        if buffer.size >= batch_size
          DeliveryItem.insert_all!(buffer)
          buffer.clear
        end
      end

      if (idx + 1) % 100 == 0
        puts "    高負荷在庫進捗: #{idx + 1}/#{high_volume_inventory_count} (#{total_items.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse}明細作成済み)"
      end
    end

    DeliveryItem.insert_all!(buffer) if buffer.any?
    buffer.clear

    puts "  残りの出庫明細を作成中..."

    delivery_ids.each do |delivery_id|
      items_per_delivery = rand(1..5)

      items_per_delivery.times do
        inventory_id = inventory_ids.sample
        attrs = FactoryBot.attributes_for(
          :delivery_item,
          company_id: company.id,
          inventory_id: inventory_id,
          delivery_id: delivery_id
        ).merge(created_at: now, updated_at: now)

        buffer << attrs
        total_items += 1

        if buffer.size >= batch_size
          DeliveryItem.insert_all!(buffer)
          buffer.clear
          puts "    進捗: #{total_items.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse}明細作成済み"
        end
      end
    end

    DeliveryItem.insert_all!(buffer) if buffer.any?
    puts "  合計#{total_items.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse}件のDeliveryItemを作成完了"
  end

  def print_statistics
    puts "【最終データ統計】"
    puts "  Companies: 1"
    puts "  Inventories: #{Inventory.count.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse}"
    puts "  Purchases: #{Purchase.count.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse}"
    puts "  PurchaseItems: #{PurchaseItem.count.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse}"
    puts "  Deliveries: #{Delivery.count.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse}"
    puts "  DeliveryItems: #{DeliveryItem.count.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse}"

    total_records = Company.count + Inventory.count + Purchase.count + PurchaseItem.count + Delivery.count + DeliveryItem.count
    puts "  合計レコード数: #{total_records.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse}"

    # 最も明細が多い在庫を表示
    puts ""
    puts "【高負荷在庫トップ10】"
    top_inventories = Inventory.select('inventories.id, inventories.company_id, COUNT(purchase_items.id) + COUNT(delivery_items.id) as total_items')
      .joins('LEFT JOIN purchase_items ON purchase_items.inventory_id = inventories.id')
      .joins('LEFT JOIN delivery_items ON delivery_items.inventory_id = inventories.id')
      .group('inventories.id')
      .order('total_items DESC')
      .limit(10)

    top_inventories.each_with_index do |inv, idx|
      puts "  #{idx + 1}. 在庫ID #{inv.id}: #{inv.total_items}明細 (URL: http://localhost:3000/inventories/#{inv.id})"
    end
  end
end
