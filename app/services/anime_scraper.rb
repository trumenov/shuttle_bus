require 'httparty'
require 'nokogiri'
require 'csv'

class AnimeScraper
  ANIME_TITLES_CSV = Rails.root.join('public/anime_titles.csv').freeze

  class << self
    def detect_new_animes
      current_animes = load_fresh_anime_list
      puts "\n\n current_animes=[#{current_animes.count}] \n\n"

      # Если файла нет, возвращаем все текущие аниме как новые
      return current_animes unless File.exist?(ANIME_TITLES_CSV)

      existing_animes = []
      # Читаем существующие записи из CSV
      CSV.foreach(ANIME_TITLES_CSV, headers: true) do |row|
        existing_animes << [row['ID'], row['Title'], row['Url']]
      end

      puts "\n\n existing_animes=[#{existing_animes.count}] \n\n"
      # Используем Set для эффективного сравнения
      current_set = Set.new(current_animes)
      existing_set = Set.new(existing_animes)

      (current_set - existing_set).to_a
    end

    def load_fresh_anime_list
      url = 'https://www.wcostream.tv/dubbed-anime-list'

      response = HTTParty.get(
        url,
        headers: {
          "User-Agent" => "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36"
        }
      )

      raise "Ошибка при загрузке страницы: #{response.code}" unless response.success?

      File.write(Rails.root.join('public/anime_titles.html'), response.body)
      doc = Nokogiri::HTML(response.body)

      anime_list = doc.css('div.ddmcc ul.tooltip > li').map do |li|
        id = li.attr('data-id')
        a_tag = li.at_css('a')
        title = a_tag.text.strip
        href = a_tag['href'].strip
        [id, title, href]
      end

      anime_list
    end

    def save_anime_titles_to_csv
      anime_list = load_fresh_anime_list

      CSV.open(ANIME_TITLES_CSV, 'w') do |csv|
        csv << ['ID', 'Title', 'Url']
        anime_list.each { |row| csv << row }
      end

      puts "Сохранено #{anime_list.size} названий в public/anime_titles.csv"
    end
  end
end
