require 'spec_helper'
require 'MongoModel'

describe RedisDataSource do
  before :all do
    `php bin/parse.php `
    @data_source = RedisDataSource.new()
  end
  describe '#read' do
    context 'when there is no more data' do
      it 'returns a falsey value' do
        expect(@data_source.read).to be_false
      end
    end
    context 'when there is still some data' do
      it 'returns the data' do
        expect(@data_source.read).not_to be_false
      end
    end
  end
end
