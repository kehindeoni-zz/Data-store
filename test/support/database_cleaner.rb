require "database_cleaner"
DatabaseCleaner.strategy = :truncation

module AroundEachTest
  def before_setup
    super
    DatabaseCleaner.start
  end

  def after_teardown
    super
    DatabaseCleaner.clean
  end
end

class Minitest::Test
  include AroundEachTest
end
