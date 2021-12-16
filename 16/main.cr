packet = PacketReader.read("input.txt")

# Part one
puts packet.version_sum

# Part two
puts packet.value

class PacketReader
  @reader : Char::Reader

  def self.read(filename : String) : Packet
    return self.new(filename).read_packet
  end

  private def initialize(@filename : String)
    data = File.read(@filename).each_char.map { |c| "%04d" % c.to_i(16).digits(2).reverse.join }.join
    @reader = Char::Reader.new(data)
  end

  def read_bytes_str(num)
    @reader.first(num).join
  end

  def read_bytes_i32(num)
    read_bytes_str(num).to_i(2)
  end

  def read_packet : Packet
    version = read_bytes_i32(3)
    type_id = read_bytes_i32(3)

    children = [] of Packet
    value : Int64 = 0

    case type_id
    when 4
      value_bits = ""
      while true
        final = read_bytes_str(1) == "0"
        value_bits += read_bytes_str(4)
        break if final
      end

      value = value_bits.to_i64(2)
    else
      length_type_id = read_bytes_i32(1)
      case length_type_id
      when 0
        length_bits = read_bytes_i32(15)
        i2 = @reader.pos + length_bits

        while @reader.pos < i2
          child = self.read_packet
          if child
            children.push child
          end
        end
      when 1
        child_count = read_bytes_i32(11)
        (0..child_count - 1).each do |_|
          child = self.read_packet
          if child
            children.push child
          end
        end
      end
    end

    return Packet.new(version, type_id, children, value)
  end
end

class Packet
  @children = [] of Packet
  @value : Int64

  def initialize(@version : Int32, @type_id : Int32, @children, @value : Int64)
  end

  def version
    @version
  end

  def children
    @children
  end

  def version_sum
    sum = @version

    @children.each do |child|
      sum += child.version_sum
    end

    return sum
  end

  def value : Int64
    value : Int64 = 0
    child_values = @children.map { |child| child.value }
    case @type_id
    when 0
      value = child_values.sum.to_i64
    when 1
      value = child_values.product.to_i64
    when 2
      value = child_values.min.to_i64
    when 3
      value = child_values.max.to_i64
    when 4
      value = @value
    else
      first_value = @children[0].value
      second_value = @children[1].value
      case @type_id
      when 5
        value = first_value > second_value ? 1_i64 : 0_i64
      when 6
        value = first_value < second_value ? 1_i64 : 0_i64
      when 7
        value = first_value == second_value ? 1_i64 : 0_i64
      end
    end

    return value
  end
end
