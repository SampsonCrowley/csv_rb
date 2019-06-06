csvrb-Rails &mdash; Spreadsheet templates for Rails
===================================================

[![Build Status](https://secure.travis-ci.org/straydogstudio/csv_rb.svg?branch=master)](http://travis-ci.org/straydogstudio/csv_rb)
[![Gem
Version](https://badge.fury.io/rb/csv_rb.svg)](http://badge.fury.io/rb/csv_rb)
[![Dependency Status](https://gemnasium.com/straydogstudio/csv_rb.svg?branch=master)](https://gemnasium.com/straydogstudio/csv_rb)
[![Coverage
Status](https://coveralls.io/repos/straydogstudio/csv_rb/badge.svg)](https://coveralls.io/r/straydogstudio/csv_rb)

![Total downloads](http://ruby-gem-downloads-badge.herokuapp.com/csv_rb?type=total)
![Downloads for 0.4.0](http://ruby-gem-downloads-badge.herokuapp.com/csv_rb/0.4.0?label=0.4.0)
![Downloads for 0.5.0](http://ruby-gem-downloads-badge.herokuapp.com/csv_rb/0.5.0?label=0.5.0)
![Downloads for latest release](http://ruby-gem-downloads-badge.herokuapp.com/csv_rb/0.5.1?label=0.5.1)

## Installation

In your Gemfile:

```ruby
gem 'rubyzip', '>= 1.2.1'
gem 'csvrb', git: 'https://github.com/randym/csvrb.git', ref: 'c8ac844'
gem 'csv_rb'
```

**NOTE:** csvrb has been pending release for a long time. You must specify the master on github to support Rubyzip 1.2.1.

If `rubyzip 1.0.0` is needed:

```ruby
gem 'rubyzip', '= 1.0.0'
gem 'csvrb', '= 2.0.1'
gem 'csv_rb'
```

If `rubyzip >= 1.1.0` is needed:

```ruby
gem 'rubyzip', '~> 1.1.0'
gem 'csvrb', '2.1.0.pre'
gem 'csv_rb'
```

## Requirements

* Rails 4.2, 5.0 or 5.1 (tested)
* For Rails 3.1 or 3.2 use version 3.0
* **As of 0.5.0 requires csvrb 2.0.1, but strongly suggests 2.1.0.pre, which requires rubyzip 1.1.0**
* As of Rails 4.1 you must use `render_to_string` to render a mail attachment.

## FYI

* This gem depends on [csvrb](https://github.com/randym/csvrb). See [the blog](http://csvrb.blog.randym.net/) or the [examples page](https://github.com/randym/csvrb/blob/master/examples/example.rb) for usage.
* Check out [csvrb_styler](https://github.com/sakovias/csvrb_styler) by [sakovias](https://github.com/sakovias) for easier styles and borders!

## Usage

csvrb-Rails provides a renderer and a template handler. It adds the `:csv` format and parses `.csv.csvrb` templates. This lets you take all the [csvrb](https://github.com/randym/csvrb) code out of your controller or model and place it inside the template, where view code belongs! **See [this blog post](http://csvrb.blog.randym.net/2012/08/excel-on-rails-like-pro-with-CSVRb.html) for a more complete walkthrough.**

### Controller

To use csvrb-Rails set your instance variables in your controller and configure the response if needed:

```ruby
class ButtonController < ApplicationController
  def action_name
    @buttons = Button.all
    respond_to do |format|
      format.csv
    end
  end
end
```

### Template

Create the template with the `.csv.csvrb` extension (`action_name.csv.csvrb` for example.) [**Watch out for typos!**](#troubleshooting) In the template, use csv_package variable to create your spreadsheet:

```ruby
wb = csv_package.workbook
wb.add_worksheet(name: "Buttons") do |sheet|
  @buttons.each do |button|
    sheet.add_row [button.name, button.category, button.price]
  end
end
```

This is where you place all your [csvrb](https://github.com/randym/csvrb) specific markup. Add worksheets, fill content, merge cells, add styles. See the [csvrb examples](https://github.com/randym/csvrb/tree/master/examples/example.rb) page to see what you can do.

Remember, like in `erb` templates, view helpers are available to use the `.csv.csvrb` template.

That's it. Call your action and your spreadsheet will be delivered.

### Rendering Options

You can call render in any of the following ways:

```ruby
# rendered, no disposition/filename header
render 'buttons'
# rendered from another controller, no disposition/filename header
render 'featured/latest'
# template and filename of 'buttons'
render csv: 'buttons'
# template from another controller, filename of 'latest_buttons'
render csv: 'latest_buttons', template: 'featured/latest'
```

### Disposition

To specify a disposition (such as `inline` so the spreadsheet is opened inside the browser), use the `disposition` option:

```ruby
render csv: "buttons", disposition: 'inline'
```

If `render csv:` is called, the disposition defaults to `attachment`.

### File name

If Rails calls csvrb through default channels (because you use `format.csv {}` for example) you must set the filename using the response header:

```ruby
format.csv {
  response.headers['Content-Disposition'] = 'attachment; filename="my_new_filename.csv"'
}
```

If you use `render csv:` the gem will try to guess the file name:

```ruby
# filename of 'buttons'
render csv: 'buttons'
# filename of 'latest_buttons'
render csv: 'latest_buttons', template: 'featured/latest'
```

If that fails, pass the `:filename` parameter:

```ruby
render csv: "action_or_template", filename: "my_new_filename.csv"
```

### csv_rb Package Options

csv_rb provides three options for initializing a spreadsheet:

- **:csv_author** (String) - The author of the document
- **:csv_created_at** (Time) - Timestamp in the document properties (defaults to current time)
- **:csv_use_shared_strings** (Boolean) - This is passed to the workbook to specify that shared strings should be used when serializing the package.

To pass these to the new package, pass them to `render :csv` _or_ pass them as local variables.

For example, to set the author name, pass the `:csv_author` parameter to `render :csv` _or_ as a local variable:

```ruby
render csv: "index", csv_author: "Elmer Fudd"
render "index", locals: {csv_author: "Elmer Fudd"}
```

Other examples:

```ruby
render csv: "index", csv_created_at: 3.days.ago
render "index", locals: {csv_use_shared_strings: true}
```

### Partials

Partials work as expected, but you must pass in relevant spreadsheet variables:

```ruby
wb = csv_package.workbook
render :partial => 'cover_sheet', :locals => {:wb => wb}
wb.add_worksheet(name: "Content") do |sheet|
  sheet.add_row ['Content']
end
```

With the partial simply using the passed variables:

```ruby
wb.add_worksheet(name: "Cover Sheet") do |sheet|
  sheet.add_row ['Cover', 'Sheet']
end
```

### Mailers

To use an csv template to render a mail attachment, use the following syntax:

```ruby
class UserMailer < ActionMailer::Base
  def export(users)
    csv = render_to_string layout: false, handlers: [:csvrb], formats: [:csv], template: "users/export", locals: {users: users}
    attachment = Base64.encode64(csv)
    attachments["Users.csv"] = {mime_type: Mime[:csv], content: attachment, encoding: 'base64'}
    # For rails 4 use Mime::csv
    # attachments["Users.csv"] = {mime_type: Mime::csv, content: attachment, encoding: 'base64'}
    # self.instance_variable_set(:@_lookup_context, nil) # If attachments are rendered as content, try this and open an issue
    ...
  end
end
```

* If the route specifies or suggests the `:csv` format you do not need to specify `formats` or `handlers`.
* If the template (`users/export`) can refer to only one file (the csv.csvrb template), you do not need to specify `handlers`, provided the `formats` includes `:csv`.
* Specifying the encoding as 'base64' can avoid UTF-8 errors.

### Scripts

To generate a template within a script, you need to instantiate an ActionView context. Here are two gists showing how to perform this:

* [Using rails runner](https://gist.github.com/straydogstudio/323139591f2cc5d48fbc)
* [Without rails runner](https://gist.github.com/straydogstudio/dceb775ead81470cea70)

### Testing

There is no built-in way to test your resulting workbooks / templates. But here is a piece of code that may help you to find a way.

#### First, create a shared context

```ruby
RSpec.shared_context 'csvrb' do

  # all csv specs describe must be normalized
  # "folder/view_name.csv.csvrb"
  # allow to infer the template path
  template_name = description

  let(:template_path) do
    ['app', 'views', template_name]
  end

  # This helper will be used in tests
  def render_template(locals = {})
    csvrb_binding = Kernel.binding
    locals.each do |key, value|
      csvrb_binding.local_variable_set key, value
    end
    # define a default workbook and a default sheet useful when testing partial in isolation
    wb = CSVRb::Package.new.workbook
    csvrb_binding.local_variable_set(:wb, wb)
    csvrb_binding.local_variable_set(:sheet, wb.add_worksheet)

    # mimics an ActionView::Template class, presenting a 'source' method
    # to retrieve the content of the template
    csvrb_binding.eval(ActionView::Template::Handlers::CSVRbBuilder.call(Struct.new(:source).new(File.read(Rails.root.join(*template_path)))))
    csvrb_binding.local_variable_get(:wb)
  end
end
```

#### Include it in your spec files:

```ruby
require 'spec_helper'
require 'helpers/csvrb_context'

describe 'shared/_total_request.csv.csvrb' do
  include_context 'csvrb'

  before :each do
    # all the instance variables here are the one used in 'shared/_total_request.csv.csvrb'
    @widget = mock_model(Widget, name: 'My widget')
    @message_counts = Struct.new(:count_all, :positives, :negatives, :neutrals).new(42, 23, 15, 25)
  end

  it 'has a title line mentioning the widget' do
    wb = render_template
    sheet = wb.sheet_by_name('Réf. Requête')
    expect(sheet).to have_header_cells ['My widget : Messages de la requête']
  end

  it 'exports the message counts' do
    wb = render_template
    sheet = wb.sheet_by_name('Réf. Requête')
    expect(sheet).to have_cells(['Toutes tonalités', 'Tonalité positive', 'Tonalité négative', 'Tonalité neutre']).in_row(2)
    expect(sheet).to have_cells([42, 23, 15, 25]).in_row(3)
  end

end
```

#### Matchers used

```ruby

# encoding: UTF-8

require 'rspec/expectations'

module XslsMatchers

  RSpec::Matchers.define :have_header_cells do |cell_values|
    match do |worksheet|
      worksheet.rows[0].cells.map(&:value) == cell_values
    end

    failure_message do |actual|
      "Expected #{actual.rows[0].cells.map(&:value)} to be #{expected}"
    end
  end

  RSpec::Matchers.define :have_cells do |expected|
    match do |worksheet|
      worksheet.rows[@index].cells.map(&:value) == expected
    end

    chain :in_row do |index|
      @index = index
    end

    failure_message do |actual|
      "Expected #{actual.rows[@index].cells.map(&:value)} to include #{expected} at row #{@index}."
    end
  end
end

```


## Troubleshooting

### Mispellings

**It is easy to get the spelling wrong in the extension name, the format.csv statement, or in a render call.** Here are some possibilities:

* If it says your template is missing, check that its extension is `.csv.csvrb`.
* If you get the error `uninitialized constant Mime::XSLX` you have used `format.xslx` instead of `format.csv`, or something similar.

### Mailer Attachments: No content, cannot read, Invalid Byte Sequence in UTF-8

If you are having problems with rendering a template and attaching it to a template, try a few options:

* Make sure the attachment template does not have the same name as the mailer.
* After you have rendered the template to string, and before you call the mailer, execute `self.instance_variable_set(:@_lookup_context, nil)`. If you must do this, please open an issue.
* If you get Invalid Byte Sequence in UTF-8, pass `encoding: 'base64'` with the attachment:

```ruby
class UserMailer < ActionMailer::Base
  def export(users)
    csv = render_to_string handlers: [:csvrb], formats: [:csv], template: "users/export", locals: {users: users}
    attachments["Users.csv"] = {mime_type: Mime[:csv], content: csv, encoding: 'base64'}
    # For Rails 4 use Mime::csv
    # attachments["Users.csv"] = {mime_type: Mime::csv, content: csv, encoding: 'base64'}
    # self.instance_variable_set(:@_lookup_context, nil) # If attachments are rendered as content, try this and open an issue
    ...
  end
end
```

If you get these errors, please open an issue and share code so the bug can be isolated. Or comment on issue [#29](https://github.com/straydogstudio/csv_rb/issues/29) or [#25](https://github.com/straydogstudio/csv_rb/issues/25).

### Generated Files Can't Be Opened or Invalid Byte Sequence in UTF-8

Both these errors *appear* to be caused by Rails applying a layout to the template. Passing `layout: false` to `render :csv` should fix this issue. Version 0.5.0 attempts to fix this issue.

If you get this error, please open an issue and share code so the bug can be isolated.

### Rails 4.2 changes

Before Rails 4.2 you could call:

```ruby
  render csv: "users/index"
```

And csv_rb could adjust the paths and make sure the template was loaded from the right directory. This is no longer possible because the paths are cached between requests for a given controller. As a result, to display a template in another directory you must use the `:template` parameter (which is normal Rails behavior anyway):

```ruby
  render csv: "index", template: "users/index"
```

If the request format matches you should be able to call:

```ruby
  render "users/index"
```

This is a breaking change if you have the old syntax!

### Turbolinks

If you are using turbolinks, you may need to disable turbolinks when you link to your spreadsheet:

```ruby
# turbolinks 5:
link_to 'Download spreadsheet', path_to_sheet, data: {turbolinks: false}
```

### What to do

If you are having problems, try to isolate the issue. Use the console or a script to make sure your data is good. Then create the spreadsheet line by line without csvrb-Rails to see if you are having csvrb problems. If you can manually create the spreadsheet, create an issue and we will work it out.

## Dependencies

- [Rails](https://github.com/rails/rails)
- [csvrb](https://github.com/randym/csvrb)

## Authors

* [Noel Peden](https://github.com/straydogstudio)

## Contributors

Many thanks to [contributors](https://github.com/straydogstudio/csv_rb/graphs/contributors):

* [randym](https://github.com/randym)
* [sugi](https://github.com/sugi)
* [envek](https://github.com/envek)
* [engwan](https://github.com/engwan)
* [maxd](https://github.com/maxd)
* [firien](https://github.com/firien)
* [kaluzny](https://github.com/kaluznyo)
* [sly7-7](https://github.com/sly7-7)
* [kodram](https://github.com/kodram)
* [JohnSmall](https://github.com/JohnSmall)
* [BenoitHiller](https://github.com/BenoitHiller)

## Donations

Say thanks for csvrb-Rails by donating! It makes it easier for me to provide to open
source:

[![Click here to lend your support to: csvrb-Rails!](http://www.pledgie.com/campaigns/27737.png?skin_name=chrome)](http://www.pledgie.com/campaigns/27737)

## Change log

**May 1st, 2018**: 0.5.2 release

- Improved Rails 5 compatibility re MIME type

**March 29th, 2017**: 0.5.1 release

- Fix stack trace line numbers
- Thanks to [BenoitHiller](https://github.com/BenoitHiller)

**July 26st, 2016**: 0.5.0 release

- Support for Rails 5
- **Tested on on Rails 4.0, 4.1, 4.2, and 5.0**
- Bug fixes for unreadable files and UTF-8 errors

**July 13th, 2015**: 0.4.0 release

- Support for Rails 4.2
- **Removal of forced default_formats** (url format must match)
- **Tested only on Rails 4.1 and 4.2**
- **For Rails 3.2 or below, use 0.3.0**

**November 20th, 2014**: 0.3.0 release

- Support for Rails 4.2.beta4.
- **Removal of shorthand template syntax** (`render csv: 'another/directory'`)

**September 4, 2014**: 0.2.1 release

- Rails 4.2.beta1 no longer includes responder. This release checks for the existence of responder before configuring a default responder.
- Rails 4.2 testing, though not yet on Travis CI
- Author, created_at, and use_shared_strings parameters for CSVRb::Package.new

**April 9, 2014**: 0.2.0 release

- Require csvrb 2.0.1, which requires rubyzip 1.0.0
- Better render handling and testing, which might break former usage
- Rails 4.1 testing
- Mailer example update (**use render_to_string not render**)

**October 11, 2013**

- Handle (and test) respond_to override

**October 4, 2013**

- Added coveralls
- Raised testing to csvrb 2.0.1, roo 1.12.2, and rubyzip 1.0.0

**July 25, 2013**

- Documentation improved
- Testing for generating partial in mailer

**January 18, 2013**: 0.1.4 release

- Now supports Rails 4 (thanks [Envek](https://github.com/Envek))
- If you call render :csv on a request without :csv format, it should force the :csv format. Works on Rails 3.2+.

**December 6, 2012**: 0.1.3 release

- Fix for absolute template paths

**July 25, 2012**: 0.1.2 release

- Partials tested

**July 19, 2012**: 0.1.1 release

- Travis-ci added (thanks [randym](https://github.com/randym))
- render statements and filename tests fixes (thanks [engwan](https://github.com/engwan))

**July 17, 2012**: 0.1.0 release

- Tests completed
- Acts_as_csv tested, example in docs

**July 12, 2012**: 0.0.1 release

- Initial posting.
- It works, but there are no tests! Bad programmer!
