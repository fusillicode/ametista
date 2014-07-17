require 'spec_helper'
require 'MongoModel'
require 'AFunctionBuilder'

describe 'MongoModel' do
  it 'can analyze a "simple" xml' do
    xml_file = File.open(__dir__+'/../test_codebase_xml/1.xml')
    mongo_daemon = MongoDaemon.new.start
    Mongoid.load!('./mongoid.yml', :test)
    Mongoid::Config.purge!
    model_builder = ModelBuilder.new(data_source: xml_file)
    model_builder.build
    # p AType.all.count
  end
end
