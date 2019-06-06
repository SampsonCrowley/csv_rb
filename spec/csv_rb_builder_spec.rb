# encoding: utf-8

require 'spec_helper'

describe 'csvrb template handler' do

  AB = ActionView::Template::Handlers::CSVRbBuilder
  VT = Struct.new(:source, :locals)

  let( :handler ) { AB.new }

  let( :template ) do
    src = <<-RUBY
      csv << ['TEST', 'STUFF']
    RUBY
    VT.new(src, [])
  end

  context "Rails #{Rails.version}" do
    # for testing if the author is set
    # before do
      # Rails.stub_chain(:application, :config, :csvrb_author).and_return( 'Elmer Fudd' )
    # end

    it "has csv format" do
      expect(handler.default_format).to eq(mime_type)
    end

    it "compiles to an csv spreadsheet" do
      csv = nil
      eval( AB.new.call template )
      expect{ csv = CSV.parse(csv) }.to_not raise_error
      expect(csv[0][0]).to eq('TEST')
    end

    #TODO:
    # Test if author field is set - does roo parse that?
  end
end
