
require 'rufus-scheduler'

scheduler = Rufus::Scheduler.singleton

unless defined?(Rails::Console) || File.split($0).last == 'rake'
  # only schedule when not running from the Ruby on Rails console
  # or from a rake task

  scheduler.every '3m' do
    if Rails.env.development?
      # puts "\n #{ Time.now.client_stamp_str } Run run_fill_payments \n"
      # TicketsPayment.run_fill_payments
      # puts "\n #{ Time.now.client_stamp_str } End run_fill_payments \n"
    else
      TicketsPayment.run_fill_payments
    end
    true
  end

  # scheduler.cron '52 19 * * *' do
  #     puts 'Hello World'
  # end
end

