require "i18n"

class String
  NO_PROP_PREFIX_CHAR = 'N'.freeze
  RUS_TO_ENG_MAP = ["A", "B", "V", "G", "D", "E", "ZH", "Z", "I", "J", "K", "L",
                    "M", "N", "O", "P", "R", "S", "T", "U", "F", "H", "TS", "CH",
                    "SH", "SCH", "", "I", "", "E", "JU", "JA"].freeze

  def size_positive?; length > 0; end
  def ehtml; ::CGI::escapeHTML(self).html_safe; end
  def text_to_html; ::CGI::escapeHTML(self).gsub("\n", "<br />\n").html_safe; end
  def split_new_line; split("\n"); end
  def split_new_line_select_positive; split_new_line.map(&:strip).select(&:size_positive?); end
  def string_valid_2_levels_prop?; strip_prop.split('->').length.eql?(2) && calc_first_level_text_sum.positive? && calc_second_level_text_sum.positive?; end
  def split_to_props_arr; split_new_line_select_positive.select(&:string_valid_2_levels_prop?); end
  def scoma_i64; gsub(/[\[\]\" ]+/, '').split(',').map(&:strip).select(&:size_positive?).map { |x| x.to_i || 0 }.select(&:positive?); end
  def str_eq?(other); self == other; end
  def to_search_text; split(/\s+/).select(&:size_positive?).map(&:downcase).uniq.sort.join(' '); end
  def to_json_arr; size_positive? ? JSON.parse(strip) : []; end
  def to_json_h; size_positive? ? JSON.parse(strip) : {}; end

  def translit
    result = ""
    to_s.chars.each_with_index do |c, index|
      new_val = c.to_s
      if (c.ord >= 1040) && (c.ord < (1040 + RUS_TO_ENG_MAP.length))
        new_val = RUS_TO_ENG_MAP[c.ord - 1040].to_s
      elsif (c.ord >= 1072) && (c.ord < (1072 + RUS_TO_ENG_MAP.length))
        # new_val = RUS_TO_ENG_MAP[c.ord - 1072].not_nil!.downcase # this fix in php... maybe here must be too. Need check
        new_val = RUS_TO_ENG_MAP[c.ord - 1072 - RUS_TO_ENG_MAP.length].to_s.downcase
      end
      result += new_val
    end
    # result = result.gsub('.', "") unless keep_point
    result.gsub(/[^A-Za-z0-9\.\_\- ]/, "")
  end

  def each_str_chunk(chunk_size, &block)
    chunks = ((length - 1) / chunk_size).to_i
    (0..chunks).each do |chunk_num|
      chunk_start_id = (chunk_num * chunk_size)
      chunk_end_id = [((chunk_num + 1) * chunk_size) - 1, length].min
      chunk_arr = self[chunk_start_id..chunk_end_id]
      yield(chunk_arr, chunk_num)
    end
    true
  end

  def split_to_chunks(chunk_size)
    result = []
    each_str_chunk(chunk_size) { |str, chunk_num| result.push(str) }
    result
  end

  def clean_1251
    result = self
    { '⁰' => "dgr.", '°' => "dgr.", '˚' => "dgr." }.each { |c, v| result = result.gsub(c, v) }
    { '×' => 'x', ' ' => ' ', '²' => '2', '­' => '-', '­' => '-', '­' => '-', '–' => '-' , '″' => '"' }.each { |c, v| result = result.gsub(c, v) }
    result = result.gsub(/[^a-zA-ZА-Яа-я0-9\-\_\!\@\#\$\%\^\&\*\(\)\[\]\:\;\"\'\`\/\\\+\.\,\?\<\>\~\=\№ЪъЇїЄєЁёІі \n\t\r\|\{\}\«\»]/, '_')
    result
  end

  def try_normalize_utf8
    str = self
    { '⁰' => "dgr.", '°' => "dgr.", '˚' => "dgr." }.each { |c, v| str.gsub!(c, v) }
    { '×' => 'x', ' ' => ' ', '²' => '2', '­' => '-', '­' => '-', '­' => '-', '–' => '-' , '″' => '"' }.each { |c, v| str.gsub!(c, v) }
    n = str.downcase.strip.to_s
    n.gsub!(/[ÃÃ¡Ã¢Ã£Ã¤Ã¥ÄÄ]/u,       'a')
    n.gsub!(/Ã¦/u,                    'ae')
    n.gsub!(/[ÄÄ]/u,                  'd')
    n.gsub!(/[Ã§ÄÄÄÄ]/u,              'c')
    n.gsub!(/[Ã¨Ã©ÃªÃ«ÄÄÄÄÄ]/u,       'e')
    n.gsub!(/Æ/u,                     'f')
    n.gsub!(/[ÄÄÄ¡Ä£]/u,              'g')
    n.gsub!(/[Ä¥Ä§]/,                 'h')
    n.gsub!(/[Ã¬Ã¬Ã­Ã®Ã¯Ä«Ä©Ä­]/u,    'i')
    n.gsub!(/[Ä¯Ä±Ä³Äµ]/u,            'j')
    n.gsub!(/[Ä·Ä¸]/u,                'k')
    n.gsub!(/[ÅÄ¾ÄºÄ¼Å]/u,            'l')
    n.gsub!(/[Ã±ÅÅÅÅÅ]/u,             'n')
    n.gsub!(/[Ã²Ã³Ã´ÃµÃ¶Ã¸ÅÅÅÅ]/u,    'o')
    n.gsub!(/Å/u,                     'oe')
    n.gsub!(/Ä/u,                     'q')
    n.gsub!(/[ÅÅÅ]/u,                 'r')
    n.gsub!(/[ÅÅ¡ÅÅÈ]/u,              's')
    n.gsub!(/[Å¥Å£Å§È]/u,             't')
    n.gsub!(/[Ã¹ÃºÃ»Ã¼Å«Å¯Å±Å­Å©Å³]/u,'u')
    n.gsub!(/Åµ/u,                    'w')
    n.gsub!(/[Ã½Ã¿Å·]/u,              'y')
    n.gsub!(/[Å¾Å¼Åº]/u,              'z')
    n
  end

  def first_level_prop_text; strip_prop_prefix.split("->").first.to_s; end
  def calc_first_level_text_sum; first_level_prop_text.to_props_text_sum; end
  def calc_second_level_text_sum; second_level_prop_text.to_props_text_sum; end
  def second_level_prop_text; strip_prop_prefix.split("->").fetch(1) { |i| "" }; end

  def translit_for_prop(recursion = 2)
    result = ""
    unless recursion.positive?
      raise("ERROR 34432432423. word=[#{ strip }]")
      return result
    end
    strip.try_normalize_utf8.upcase.each_char_with_index2 do |c, index|
      new_val = c.to_s
      # puts "\n c[#{ new_val }]=[#{ c.ord }] \n"
      if c.ord.between?(65, 90)
        # already A-Z
      elsif c.ord.between?(1040, 1040 + RUS_TO_ENG_MAP.length - 1)
        new_val = RUS_TO_ENG_MAP[c.ord - 1040]
      elsif (".,\"\'\&\*\%\@\+\/\\\;\=\[\]\{\}\(\)\>\|".index(c))
        new_val = "x"
      elsif ("-!$^\#\<".index(c))
        new_val = "n"
      elsif (!("_0123456789".index(c)))
        str = I18n.transliterate(c)
        if str == new_val
          new_val = "_"
        else
          # puts "\n\n\n TMP 123312123. [#{ new_val }]!=[#{ str }] \n\n\n"
          new_val = str.translit_for_prop(recursion - 1)
        end
      end
      result += new_val if new_val.size_positive?
    end
    return result.gsub("__", '_')
    # result
  end

  def to_props_text_sum
    result = Integer(0)
    s_stripped_pref = strip_prop_prefix
    # you can add more symbols to the alphavit in the end only. Do not insert symbols into it! Only add.
    alphavit = "ABCDEFGHIJKLMNOPQRSTUVWXYZ._,0123456789"
    max_word_len_in_uint32_for_base36 = "ZZZZZZZZZZZ".length

    w = s_stripped_pref.gsub("->", "_").translit_for_prop
    return result if w.length > 180

    words_arr = []
    w.gsub("_", "PPP") unless w.length > (max_word_len_in_uint32_for_base36 * 2)

    last_str = ""
    w.split('_').each do |x|
      if x.length > 5
        words_arr.push(x)
      else
        if ((last_str.length + x.size) > max_word_len_in_uint32_for_base36)
          words_arr.push(last_str)
          last_str = ""
        end
        last_str += x
      end
    end
    words_arr.push(last_str) if last_str.size_positive?

    words_arr.each_with_index do |word, word_pos|
      next unless word.size.positive?
      prop_weight = Integer(0)
      word.split_to_chunks(max_word_len_in_uint32_for_base36).each do |word_part|
        word_part = "Z" + word_part unless word_part.length >= max_word_len_in_uint32_for_base36 # leading zero bug
        word_part_u64 = Integer(word_part.to_i(36))
        # puts "\n\n\n\n TMPDBG1 #{ word_pos }[#{ word }] word_part=[#{ word_part }] word_part_u64=[#{ word_part_u64 }] \n\n\n\n"
        # puts "\n\n\n\n TMPDBG2 prop_weight=[#{ "\xfe\xff\xfe\xff".unpack('Q') }] word_part_u64=[#{ word_part_u64.class }] \n\n\n\n"
        prop_weight = prop_weight ^ word_part_u64
        # prop_weight = RubyUint64Helper.ruby_xor_uint64(prop_weight, word_part_u64)
      end
      if (prop_weight > 0)
        result += Integer(prop_weight)
      end
    end
    result
  end

  def strip_prop(to_downcase = false)
    result = clean_1251.gsub(/[\t\n\r]/, " ").gsub(/ {2,}/, " ").split("->").map(&:strip).select(&:size_positive?).join("->")
    result = result[0..254] if result.length >= 255
    to_downcase ? result.downcase : result
  end

  def strip_prop_prefix; gsub(/^[a-zA-Z]\-\>/, ""); end
  def prop_prefix
    s = strip
    result = ((s.length > 2) && (s[1] == '-') && (s[2] == '>')) ? s[0].upcase : NO_PROP_PREFIX_CHAR
    return NO_PROP_PREFIX_CHAR unless result.ord.between?(65, 90)
    result
  end

  def each_char_with_index2(&block)
    num = 0
    each_char { |x| yield(x, num); num +=1; }
    true
  end
end
