def fixture(file)
  File.read(File.expand_path(file))
end

RSpec.configure do |config|
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
