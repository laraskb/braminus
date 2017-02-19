require 'benchmark'

LIMIT = 0.2 # Braminus needs to respond within 200 milliseconds

def within_limit(endpoint_call)
  t = Benchmark.realtime do
    endpoint_call
  end
  expect(t).to be < LIMIT
end

def fixture(file)
  File.read(File.expand_path(file))
end

RSpec.configure do |config|
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
