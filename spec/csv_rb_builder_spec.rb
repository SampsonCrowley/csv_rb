# encoding: utf-8

require 'spec_helper'

describe 'csvrb template handler' do

  AB = ActionView::Template::Handlers::CSVRbBuilder
  VT = Struct.new(:source, :locals)

  let( :handler ) { AB.new }

  let( :template_src ) do
    <<-RUBY
      csv << ['TEST', 'STUFF']
    RUBY
  end

  let( :template ) do
    VT.new(template_src, [])
  end

  let( :set_template_src ) do
    <<-RUBY
      csv.set CSV.generate_line(['TEST', 'STUFF'], encoding: 'utf-8', force_quotes: true)
    RUBY
  end

  let( :set_template ) do
    VT.new(set_template_src, [])
  end

  context "Rails #{Rails.version}" do
    # for testing if the author is set
    # before do
      # Rails.stub_chain(:application, :config, :csvrb_author).and_return( 'Elmer Fudd' )
    # end

    it "has csv format" do
      expect(handler.default_format).to eq(mime_type)
    end

    context "compiles to an csv spreadsheet" do
      it "rails 5 single arity call format" do
        csv = nil
        eval( AB.new.call template )
        expect{ csv = CSV.parse(csv) }.to_not raise_error
        expect(csv[0][0]).to eq('TEST')
      end

      it "rails 6 dual arity call format" do
        csv = nil
        eval( AB.new.call template, template_src )
        expect{ csv = CSV.parse(csv) }.to_not raise_error
        expect(csv[0][0]).to eq('TEST')
      end
    end

    context "accepts a full CSV string" do
      it "rails 5 single arity call format" do
        csv = nil
        eval( AB.new.call set_template )
        expect{ csv = CSV.parse(csv) }.to_not raise_error
        expect(csv[0][0]).to eq('TEST')
      end

      it "rails 6 dual arity call format" do
        csv = nil
        eval( AB.new.call set_template, set_template_src )
        expect{ csv = CSV.parse(csv) }.to_not raise_error
        expect(csv[0][0]).to eq('TEST')
      end
    end

  end
end
