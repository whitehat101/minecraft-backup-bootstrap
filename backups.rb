#!/usr/bin/env ruby
require 'bundler/setup'
require 'erb'
require 'filesize'
require 'rb-inotify'

Dir.chdir File.dirname(__FILE__)

stores = Dir['backups/*/backupstore.txt']

rebuild_index = proc do
  puts "Rebuilding index..."
  start = Time.now

  backups = []
  backup_chart = []
  total_bytes = 0

  stores.each do |backupstore|
    IO.readlines(backupstore).reverse.each do |backup|
      parts = backup.chomp!.split '='

      file = "backups/#{parts[0..3].join '/'}/Backup-#{parts[0..3].join '-'}--#{parts[4..5].join '-'}.zip"
      bytes = File.size file

      backups << {
        name: "#{parts[0]} #{Time.new *parts[1..5]}",
        url: "/#{file}",
        size: Filesize.from("#{bytes} B").to_s('MiB'),
      }

      backup_chart.unshift ["#{Time.new *parts[1..5]}", bytes]

      total_bytes += bytes
    end
  end
  backup_chart.unshift %w(Date Bytes)
  backup_chart = JSON.generate backup_chart
  total_bytes = Filesize.from("#{total_bytes} B").to_s('MiB')

  template = ERB.new File.read("index.html.erb")
  File.write 'index.html', template.result(binding)
  puts Time.now - start
end


notifier = INotify::Notifier.new
stores.each do |store|
  notifier.watch store, :modify, &rebuild_index
end
rebuild_index.call
notifier.run
