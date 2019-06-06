# encoding: utf-8

class Encoder
    def initialize(str)
      @str = str
    end

    def to_utf8
      return @str if is_utf8?
      encoding = find_encoding
      @str.force_encoding(encoding).encode('utf-8', invalid: :replace, undef: :replace)
    end

    def find_encoding
      puts 'utf-8' if is_utf8?
      return 'utf-8' if is_utf8?
      puts 'iso-8859-1' if is_iso8859?
      return 'iso-8859-1' if is_iso8859?
      puts 'Windows-1252' if is_windows?
      return 'Windows-1252' if is_windows?
      raise ArgumentError.new "Invalid Encoding"
    end

    def is_utf8?
      is_encoding?(Encoding::UTF_8)
    end

    def is_iso8859?
      is_encoding?(Encoding::ISO_8859_1)
    end

    def is_windows?(str)
      is_encoding?(Encoding::Windows_1252)
    end

    def is_encoding?(encoding_check)
      case @str.encoding
      when encoding_check
        @str.valid_encoding?
      when Encoding::ASCII_8BIT, Encoding::US_ASCII
        @str.dup.force_encoding(encoding_check).valid_encoding?
      else
        false
      end
    end
  end

require 'spec_helper'
describe 'csv_rb request', :type => :request do

  after(:each) do
    if File.exists? '/tmp/csvrb_temp.csv'
      File.unlink '/tmp/csvrb_temp.csv'
    end
  end

  it "has a working dummy app" do
    @user1 = User.create name: 'Elmer', last_name: 'Fudd', address: '1234 Somewhere, Over NY 11111', email: 'elmer@fudd.com'
    visit '/'
    expect(page).to have_content("Hey, you")
  end

  it "downloads an csv file from default respond_to" do
    visit '/home.csv'
    expect(page.response_headers['Content-Type']).to eq(mime_type.to_s + "; charset=utf-8")
    File.open('/tmp/csvrb_temp.csv', 'w') {|f| f.write(page.source) }
    csv = nil
    expect{ csv = Roo::CSV.new('/tmp/csvrb_temp.csv') }.to_not raise_error
    expect(csv.cell(1,1)).to eq('Bad')
  end

  it "downloads an csv file from respond_to while specifying filename" do
    visit '/useheader.csv'

    expect(page.response_headers['Content-Type']).to eq(mime_type.to_s + "; charset=utf-8")
    expect(page.response_headers['Content-Disposition']).to include("filename=\"filename_test.csv\"")
  end

  it "downloads an csv file from respond_to while specifying filename in direct format" do
    visit '/useheader.csv?set_direct=true'

    expect(page.response_headers['Content-Type']).to eq(mime_type.to_s + "; charset=utf-8")
    expect(page.response_headers['Content-Disposition']).to include("filename=\"filename_test.csv\"")

    File.open('/tmp/csvrb_temp.csv', 'w') {|f| f.write(page.source) }
    csv = nil
    expect{ csv = Roo::CSV.new('/tmp/csvrb_temp.csv') }.to_not raise_error
    expect(csv.cell(1,1)).to eq('Bad')
  end

  it "downloads an csv file from render statement with filename" do
    visit '/another.csv'

    expect(page.response_headers['Content-Type']).to eq(mime_type.to_s + "; charset=utf-8")
    expect(page.response_headers['Content-Disposition']).to include("filename=\"filename_test.csv\"")
  end

  it "downloads an csv file from as_csv model" do
    User.destroy_all
    @user1 = User.create name: 'Elmer', last_name: 'Fudd', address: '1234 Somewhere, Over NY 11111', email: 'elmer@fudd.com'
    @user2 = User.create name: 'Bugs', last_name: 'Bunny', address: '1234 Left Turn, Albuquerque NM 22222', email: 'bugs@bunny.com'
    visit '/users.csv'
    expect(page.response_headers['Content-Type']).to eq(mime_type.to_s + "; charset=utf-8")
    File.open('/tmp/csvrb_temp.csv', 'w') {|f| f.write(page.source) }
    csv = nil
    expect{ csv = Roo::CSV.new('/tmp/csvrb_temp.csv') }.to_not raise_error
    expect(csv.cell(1,1)).to eq('Elmer')
    expect(csv.cell(2,1)).to eq('Bugs')
  end

  it "downloads an csv file with partial" do
    visit '/withpartial.csv'
    expect(page.response_headers['Content-Type']).to eq(mime_type.to_s + "; charset=utf-8")
    File.open('/tmp/csvrb_temp.csv', 'w') {|f| f.write(page.source) }
    csv = nil
    expect{ csv = Roo::CSV.new('/tmp/csvrb_temp.csv') }.to_not raise_error
    expect(csv.cell(1,1,csv.sheets[0])).to eq('Cover')
    expect(csv.cell(2,1,csv.sheets[1])).to eq("Bad")
  end

  it "handles nested resources" do
    User.destroy_all
    @user = User.create name: 'Bugs', last_name: 'Bunny', address: '1234 Left Turn, Albuquerque NM 22222', email: 'bugs@bunny.com'
    @user.likes.create(:name => 'Carrots')
    @user.likes.create(:name => 'Celery')
    visit "/users/#{@user.id}/likes.csv"
    expect(page.response_headers['Content-Type']).to eq(mime_type.to_s + "; charset=utf-8")
    File.open('/tmp/csvrb_temp.csv', 'w') {|f| f.write(page.source) }
    csv = nil
    expect{ csv = Roo::CSV.new('/tmp/csvrb_temp.csv') }.to_not raise_error
    expect(csv.cell(1,1)).to eq('Bugs')
    expect(csv.cell(2,1)).to eq('Carrots')
    expect(csv.cell(3,1)).to eq('Celery')
  end

  it "handles reference to absolute paths" do
    User.destroy_all
    @user = User.create name: 'Bugs', last_name: 'Bunny', address: '1234 Left Turn, Albuquerque NM 22222', email: 'bugs@bunny.com'
    visit "/users/#{@user.id}/render_elsewhere.csv"
    expect(page.response_headers['Content-Type']).to eq(mime_type.to_s + "; charset=utf-8")
    [[1,false],[3,true],[4,true],[5,false]].reverse.each do |s|
      visit "/home/render_elsewhere.csv?type=#{s[0]}"
      expect(page.response_headers['Content-Type']).to eq(mime_type.to_s + "; charset=utf-8")
    end
  end

  it "uses respond_with" do
    User.destroy_all
    @user = User.create name: 'Responder', last_name: 'Bunny', address: '1234 Right Turn, Albuquerque NM 22222', email: 'bugs@bunny.com'
    expect {
      visit "/users/#{@user.id}.csv"
    }.to_not raise_error
    File.open('/tmp/csvrb_temp.csv', 'w') {|f| f.write(page.source) }
    csv = nil
    expect{ csv = Roo::CSV.new('/tmp/csvrb_temp.csv') }.to_not raise_error
    expect(csv.cell(1,1)).to eq('Bad')
  end

  it "ignores layout" do
    User.destroy_all
    @user = User.create name: 'Responder', last_name: 'Bunny', address: '1234 Right Turn, Albuquerque NM 22222', email: 'bugs@bunny.com'
    expect {
      visit "/users/export/#{@user.id}.csv"
    }.to_not raise_error

    expect(page.response_headers['Content-Type']).to eq(mime_type.to_s + "; charset=utf-8")
    expect(page.response_headers['Content-Disposition']).to include("filename=\"export_#{@user.id}.csv\"")
  end

  it "handles missing format with render :csv" do
    visit '/another'

    expect(page.response_headers['Content-Type']).to eq(mime_type.to_s + "; charset=utf-8")
    expect(page.response_headers['Content-Disposition']).to include("filename=\"filename_test.csv\"")
    # csv.cell(2,1).should == 'Bad'
  end

  Capybara.register_driver :mime_all do |app|
    Capybara::RackTest::Driver.new(app, headers: { 'HTTP_ACCEPT' => '*/*' })
  end

  def puts_def_formats(title)
    puts "default formats #{title.ljust(30)}: #{ActionView::Base.default_formats}"
  end

  it "mime all with render :csv and then :html" do
    # puts_def_formats 'before'
    ActionView::Base.default_formats.delete :csv # see notes
    # puts_def_formats 'in my project'
    Capybara.current_driver = :mime_all
    visit '/another'
    # puts_def_formats 'after render csv with */*'
    expect{
      visit '/home/only_html'
    }.to_not raise_error
    ActionView::Base.default_formats.push :csv # see notes

    # Output:
    # default formats before                        : [:html, :text, :js, :css, :ics, :csv, :vcf, :png, :jpeg, :gif, :bmp, :tiff, :mpeg, :xml, :rss, :atom, :yaml, :multipart_form, :url_encoded_form, :json, :pdf, :zip, :csv]
    # default formats in my project                 : [:html, :text, :js, :css, :ics, :csv, :vcf, :png, :jpeg, :gif, :bmp, :tiff, :mpeg, :xml, :rss, :atom, :yaml, :multipart_form, :url_encoded_form, :json, :pdf, :zip]
    # default formats after render csv with */*    : [:csv, :text, :js, :css, :ics, :csv, :vcf, :png, :jpeg, :gif, :bmp, :tiff, :mpeg, :xml, :rss, :atom, :yaml, :multipart_form, :url_encoded_form, :json, :pdf, :zip]

    # Failure/Error: visit '/home/only_html'
    # ActionView::MissingTemplate:
    #   Missing template home/only_html, application/only_html with {:locale=>[:en], :formats=>[:csv, :text, :js, :css, :ics, :csv, :vcf, :png, :jpeg, :gif, :bmp, :tiff, :mpeg, :xml, :rss, :atom, :yaml, :multipart_form, :url_encoded_form, :json, :pdf, :zip], :variants=>[], :handlers=>[:erb, :builder, :raw, :ruby, :csvrb]}.
  end

  it "downloads an csv file when there is no action" do
    User.destroy_all
    @user1 = User.create name: 'Elmer', last_name: 'Fudd', address: '1234 Somewhere, Over NY 11111', email: 'elmer@fudd.com'
    @user2 = User.create name: 'Bugs', last_name: 'Bunny', address: '1234 Left Turn, Albuquerque NM 22222', email: 'bugs@bunny.com'
    visit '/users/noaction.csv'
    expect(page.response_headers['Content-Type']).to eq(mime_type.to_s + "; charset=utf-8")
    File.open('/tmp/csvrb_temp.csv', 'w') {|f| f.write(page.source) }
    csv = nil
    expect{ csv = Roo::CSV.new('/tmp/csvrb_temp.csv') }.to_not raise_error
    expect(csv.cell(1,1)).to eq('Elmer')
    expect(csv.cell(2,1)).to eq('Bugs')
  end
end
