module RubyUint64Helper

  # a - Int, b - Int, result - Int
  def self.ruby_xor_uint64(a, b)
    astr = int_to_binary_u64_string(a)
    bstr = int_to_binary_u64_string(b)
    result = ''
    64.times do |i|
      result[i] = astr[i] == bstr[i] ? '0' : '1'
    end
    result.to_i(2)
  end

  def self.int_to_binary_u64_string(a)
    str = a.abs.to_s(2)
    64.times { |x| str = "0#{ str }" unless (str.length > x) }
    str
  end

end
