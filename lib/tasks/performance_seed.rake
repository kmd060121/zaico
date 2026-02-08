namespace :performance_seed do
  desc "Seed test dataset (18 accounts with varied scales)"
  task test: :environment do
    puts "=== テストデータセット投入開始 ==="
    puts ""
    puts "【データ分布】"
    puts "  小規模アカウント: 10 (在庫10-100、入出庫50-500)"
    puts "  中規模アカウント: 5 (在庫1k-10k、入出庫5k-50k)"
    puts "  大規模アカウント: 2 (在庫50k-100k、入出庫250k-500k)"
    puts "  最大規模アカウント: 1 (在庫200k、入出庫1M)"
    puts ""
    puts "【推定データサイズ】"
    puts "  合計アカウント数: 18"
    puts "  合計レコード数: 約3,000,000"
    puts "  ディスク使用量: 1-2GB"
    puts ""
    print "続行しますか？ (yes/no): "
    confirmation = STDIN.gets.chomp

    if confirmation.downcase == "yes"
      PerformanceDatasetSeeder.new(mode: :test).call
    else
      puts "キャンセルしました。"
    end
  end

  desc "Seed realistic dataset (1000 accounts with varied scales)"
  task realistic: :environment do
    puts "=== 現実的なデータセット投入開始 ==="
    puts ""
    puts "【データ分布】"
    puts "  小規模アカウント: 700 (在庫10-100、入出庫50-500)"
    puts "  中規模アカウント: 250 (在庫1k-10k、入出庫5k-50k)"
    puts "  大規模アカウント: 40 (在庫50k-100k、入出庫250k-500k)"
    puts "  最大規模アカウント: 10 (在庫200k、入出庫1M)"
    puts ""
    puts "【推定データサイズ】"
    puts "  合計レコード数: 約135,000,000"
    puts "  ディスク使用量: 30-40GB"
    puts ""
    print "続行しますか？ (yes/no): "
    confirmation = STDIN.gets.chomp

    if confirmation.downcase == "yes"
      PerformanceDatasetSeeder.new(mode: :realistic).call
    else
      puts "キャンセルしました。"
    end
  end

  desc "Clear all performance test data"
  task clear: :environment do
    puts "=== パフォーマンステストデータの削除 ==="

    counts_before = {
      companies: Company.count,
      inventories: Inventory.count,
      deliveries: Delivery.count,
      delivery_items: DeliveryItem.count,
      purchases: Purchase.count,
      purchase_items: PurchaseItem.count
    }

    puts "削除前のデータ数:"
    counts_before.each { |k, v| puts "  #{k}: #{v.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse}" }
    puts ""

    print "すべてのデータを削除しますか？ (yes/no): "
    confirmation = STDIN.gets.chomp

    if confirmation.downcase == "yes"
      puts ""
      puts "削除中..."

      PurchaseItem.delete_all
      DeliveryItem.delete_all
      Purchase.delete_all
      Delivery.delete_all
      Inventory.delete_all
      Company.delete_all

      puts ""
      puts "すべてのデータを削除しました。"
      puts ""
      puts "削除後のデータ数:"
      puts "  companies: #{Company.count}"
      puts "  inventories: #{Inventory.count}"
      puts "  deliveries: #{Delivery.count}"
      puts "  delivery_items: #{DeliveryItem.count}"
      puts "  purchases: #{Purchase.count}"
      puts "  purchase_items: #{PurchaseItem.count}"
    else
      puts "キャンセルしました。"
    end
  end

  desc "Seed maximum performance test dataset (1 account, 200k inventories, 1M purchases/deliveries)"
  task max: :environment do
    puts "=== 最大想定パフォーマンステストデータセット投入開始 ==="
    puts ""
    puts "【データ規模】"
    puts "  アカウント数: 1"
    puts "  在庫数: 200,000"
    puts "  入庫伝票: 1,000,000"
    puts "  出庫伝票: 1,000,000"
    puts "  1在庫あたり最大明細数: 1,000"
    puts ""
    puts "【推定データサイズ】"
    puts "  合計レコード数: 約5,000,000-6,000,000"
    puts "  ディスク使用量: 3-5GB"
    puts ""
    puts "【データ投入戦略】"
    puts "  - 1,000在庫: 500-1,000明細（高負荷検証用）"
    puts "  - 残り199,000在庫: 1-5明細（通常データ）"
    puts ""
    print "続行しますか？ (yes/no): "
    confirmation = STDIN.gets.chomp

    if confirmation.downcase == "yes"
      require_relative "../../app/services/max_performance_dataset_seeder"
      MaxPerformanceDatasetSeeder.new.call
    else
      puts "キャンセルしました。"
    end
  end

  desc "Show dataset information"
  task info: :environment do
    puts "=== 現在のデータ統計 ==="
    puts ""
    puts "【レコード数】"
    puts "  Companies: #{Company.count.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse}"
    puts "  Inventories: #{Inventory.count.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse}"
    puts "  Purchases: #{Purchase.count.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse}"
    puts "  PurchaseItems: #{PurchaseItem.count.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse}"
    puts "  Deliveries: #{Delivery.count.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse}"
    puts "  DeliveryItems: #{DeliveryItem.count.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse}"
    puts ""

    total_records = Company.count + Inventory.count + Purchase.count + PurchaseItem.count + Delivery.count + DeliveryItem.count
    puts "  合計レコード数: #{total_records.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse}"
    puts ""

    if Company.any?
      puts "【アカウント規模分布】"

      small_count = Company.joins(:inventories).group('companies.id').having('COUNT(inventories.id) < 1000').count.size
      medium_count = Company.joins(:inventories).group('companies.id').having('COUNT(inventories.id) >= 1000 AND COUNT(inventories.id) < 50000').count.size
      large_count = Company.joins(:inventories).group('companies.id').having('COUNT(inventories.id) >= 50000 AND COUNT(inventories.id) < 200000').count.size
      max_count = Company.joins(:inventories).group('companies.id').having('COUNT(inventories.id) >= 200000').count.size

      puts "  小規模 (在庫<1,000): #{small_count}アカウント"
      puts "  中規模 (在庫1,000-50,000): #{medium_count}アカウント"
      puts "  大規模 (在庫50,000-200,000): #{large_count}アカウント"
      puts "  最大規模 (在庫≥200,000): #{max_count}アカウント"
    end

    puts ""
    puts "【利用可能なタスク】"
    puts "  rails performance_seed:test       # テスト用データセット投入 (18アカウント)"
    puts "  rails performance_seed:realistic  # 本番規模データセット投入 (1000アカウント)"
    puts "  rails performance_seed:max        # 最大想定データセット投入 (1アカウント、200k在庫)"
    puts "  rails performance_seed:clear      # 全データ削除"
    puts "  rails performance_seed:info       # データ統計表示"
  end
end
