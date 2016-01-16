require 'minitest/autorun'
class SamplesTest < Minitest::Test
  def assert_syntax(code)
    # http://stackoverflow.com/a/18749289/1058763
    stderr = $stderr
    $stderr.reopen(IO::NULL)
    RubyVM::InstructionSequence.compile(code)
    $stderr.reopen(stderr)
    assert true
  end

  def test_samples
    assert_syntax <<-RUBY
      class Person
        def hello
          puts 'hello'
        end
      end
    RUBY

    assert_syntax <<-RUBY
      class UserProfile
        # 引数や変数はスネークケース。phoneNumberのようなキャメルケースにはしない
        def initialize(name, phone_number)
          @name = name
          @phone_number = phone_number
        end

        # メソッド名はスネークケース。firstNameのようなキャメルケースにはしない
        def first_name
          @name.split(' ').first
        end
      end
    RUBY

    assert_syntax <<-RUBY
      # upcase() と書くことは少ない
      'hello'.upcase # => 'HELLO'

      # puts('hello') でも良いが、丸括弧は省略されることが多い
      puts 'hello'
    RUBY

    def fizz_buzz(n)
      if n % 5 == 0 && n % 3 == 0
        'Fizz Buzz'
      elsif n % 3 == 0
        'Fizz'
      elsif n % 5 == 0
        'Buzz'
      else
        n
      end
    end

    assert_equal 1, fizz_buzz(1)
    assert_equal 2, fizz_buzz(2)
    assert_equal 'Fizz', fizz_buzz(3)
    assert_equal 4, fizz_buzz(4)
    assert_equal 'Buzz', fizz_buzz(5)
    assert_equal 'Fizz Buzz', fizz_buzz(15)

    assert_syntax <<-RUBY
      def go_to_school(date)
        if date.saturday? || date.sunday?
          # 土曜日と日曜日は何もせずメソッドを抜ける
          return
        end

        self.get_up
        self.eat_breakfast
        # 処理が続く...
      end
    RUBY

    assert_syntax <<-RUBY
      # userが管理者でなければ通知を送る
      if !user.admin?
        send_notification_to(user)
      end

      # 上の条件分岐をunlessで置き換える
      unless user.admin?
        send_notification_to(user)
      end
    RUBY

    assert_syntax <<-RUBY
      puts 'お酒は20歳になってから！' if user.age < 20
    RUBY

    assert_syntax <<-RUBY
      # is_admin よりも admin? のように ? で終わらせる方がベター
      def admin?
        self.role == 'admin'
      end
    RUBY

    assert_output "実行されます\n" * 2 do
      if false
        puts '実行されません'
      end

      if nil
        puts '実行されません'
      end

      if true
        puts '実行されます'
      end

      if 0
        puts '実行されます'
      end
    end

    def hello(name)
      # "Hello, " + name + "!" ではなく、式展開を使う方がベター
      "Hello, #{name}!"
    end
    result = hello 'Alice'
    assert_equal 'Hello, Alice!', result

    assert_output "apple\nmelon\nbanana\n" * 2 do
      fruits = ['apple', 'melon', 'banana']

      # 繰り返し処理は each メソッドを使うのが一般的
      fruits.each do |fruit|
        puts fruit
      end

      # 単純な繰り返し処理で for ループが登場することはまずない
      for fruit in fruits
        puts fruit
      end
    end

    assert_output "8\n9\na\nb\nc\n" * 2 do
      numbers = [8, 9, 10, 11, 12]
      hex_numbers = []
      numbers.each do |n|
        hex_numbers << n.to_s(16)
      end
      puts hex_numbers # => ['8', '9', 'a', 'b', 'c']

      numbers = [8, 9, 10, 11, 12]
      hex_numbers = numbers.map do |n|
        n.to_s(16)
      end
      puts hex_numbers # => ['8', '9', 'a', 'b', 'c']
    end

    assert_output "1\n3\n5\n" * 2 do
      numbers = [1, 2, 3, 4, 5]
      odd_numbers = []
      numbers.each do |n|
        if n.odd?
          odd_numbers << n
        end
      end
      puts odd_numbers # => [1, 3, 5]

      numbers = [1, 2, 3, 4, 5]
      odd_numbers = numbers.select do |n|
        n.odd?
      end
      puts odd_numbers # => [1, 3, 5]

      odd_numbers = numbers.select do |n| n.odd? end
      odd_numbers = numbers.select { |n| n.odd? }
      odd_numbers = numbers.select(&:odd?)
    end

    assert_output "5\n3\n" * 2 do
      points = [
          [1, 4],
          [6, 8],
          [5, 3],
          [7, 3],
      ]
      target = nil
      points.each do |x, y|
        if x.odd? && y.odd?
          target = [x, y]
          break
        end
      end
      puts target # => [5, 3]

      points = [
          [1, 4],
          [6, 8],
          [5, 3],
          [7, 3],
      ]
      target = points.find { |x, y| x.odd? && y.odd? }
      puts target # => [5, 3]
    end

    assert_syntax <<-RUBY
      # userはnilの可能性があるのでチェックする
      unless user.nil?
        user.say 'Hello!'
      end

      # userがnilでも気にせずにsayメソッドを呼び出せる
      user&.say 'Hello!'
    RUBY

    items = {
        fruits: {
            apple: {
                price: 100
            },
            banana: {
                price: 50
            },
        }
    }
    assert_output "100\n50\n" do
      puts items[:fruits][:apple][:price] # => 100
      puts items[:fruits][:banana][:price] # => 50
    end
    assert_raises(NoMethodError) do
      puts items[:fruits][:melon][:price] # :melonというキーが無いので [:price] を呼ぶとエラー
    end
    assert_output "100\n50\n\n" do
      puts items.dig(:fruits, :apple, :price) # => 100
      puts items.dig(:fruits, :banana, :price) # => 50
      puts items.dig(:fruits, :melon, :price) # => nil
    end

    matrix = [
        [
            [1, 2, 3]
        ],
        [
            # 空
        ],
        [
            [100, 200, 300]
        ]
    ]
    # 添え字を使う場合
    assert_output "3\n300\n" do
      puts matrix[0][0][2] # => 3
      puts matrix[2][0][2] # => 300
    end
    assert_raises(NoMethodError) do
      puts matrix[1][0][2] # => matrix[1][0]が nil なので[2]を呼ぶとエラー
    end
    # digを使う場合
    assert_output "3\n\n300\n" do
      puts matrix.dig(0, 0, 2) # => 3
      puts matrix.dig(1, 0, 2) # => nil
      puts matrix.dig(2, 0, 2) # => 300
    end
  end
end