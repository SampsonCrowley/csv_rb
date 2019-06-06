# encoding: utf-8

require'spec_helper'

describe 'csvrb renderer' do

  it "is registered" do
    ActionController::Renderers::RENDERERS.include?(:csv)
  end

  it "has mime type" do
    mime = mime_type
  	expect(mime).to be
  	expect(mime.to_sym).to eq(:csv)
  	expect(mime.to_s).to eq("text/csv")
  end

end
