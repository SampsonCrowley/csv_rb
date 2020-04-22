CSVRb-Rails &mdash; Streaming CSVs with ActionView templates
===================================================

[![Gem Version](https://badge.fury.io/rb/csv_rb.svg)](http://badge.fury.io/rb/csv_rb)
![Total downloads](http://ruby-gem-downloads-badge.herokuapp.com/csv_rb?type=total)
![Downloads for latest release](http://ruby-gem-downloads-badge.herokuapp.com/csv_rb/6.0.2.4?label=6.0.2.4)

## Installation

In your Gemfile:

```ruby
gem 'csv'
gem 'csv_rb'
```

## Requirements

* \>= Rails 5.2
  - Latest Version Tested With:
    - 5.2
    - 6.0
* \>= Ruby 2.5
  - Latest Version Tested With:
    - 2.6
    - 2.7


## Usage

CSVRb provides a renderer and a template handler. It adds the `:csv` format and parses `.csv.csvrb` templates. This lets you take all the [csvrb](https://github.com/SampsonCrowley/csvrb) code out of your controller or model and place it inside the template, where view code belongs! Strongly inspired by Axlsx-Rails

### Controller

To use CSVRb set your instance variables in your controller and configure the response if needed:

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
csv << ['Cell 1', 'Cell 2']
```

This is where you place all your [csvrb](https://github.com/SampsonCrowley/csvrb) specific markup. Add worksheets, fill content, merge cells, add styles. See the [csvrb examples](https://github.com/SampsonCrowley/csvrb/tree/master/examples/example.rb) page to see what you can do.

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

If you use `render csv:` the gem will try to guess the file name based on the `:csv` key value

```ruby
# filename of 'buttons.csv'
render csv: 'buttons'
# filename of 'latest_buttons.csv'
render csv: 'latest_buttons', template: 'featured/latest'
```

If that fails, pass the `:filename` parameter:

```ruby
render csv: "action_or_template", filename: "my_new_filename.csv"
```

### Partials

Partials work as expected, but you must pass in relevant spreadsheet variables:

```ruby
csv << ['BEFORE']
render :partial => 'csv_partial', :locals => { csv: csv }
csv << ['AFTER']
```

With the partial simply using the passed variables:

```ruby
# _csv_partial.csv.csvrb

csv << ['Partial Content']
```

### Mailers

To use an csv template to render a mail attachment, use the following syntax:

```ruby
class UserMailer < ActionMailer::Base
  def export(users)
    csv = render_to_string layout: false, handlers: [:csvrb], formats: [:csv], template: "users/export", locals: {users: users}
    attachment = Base64.encode64(csv)
    attachments["Users.csv"] = {mime_type: Mime[:csv], content: attachment, encoding: 'base64'}
    # For rails 4 use Mime::CSV
    # attachments["Users.csv"] = {mime_type: Mime::CSV, content: attachment, encoding: 'base64'}
    # self.instance_variable_set(:@_lookup_context, nil) # If attachments are rendered as content, try this and open an issue
    ...
  end
end
```

* If the route specifies or suggests the `:csv` format you do not need to specify `formats` or `handlers`.
* If the template (`users/export` in this case) can refer to only one file (`users/export.csv.csvrb`), you do not need to specify `handlers`, provided the `formats` key includes `:csv`.
* Specifying the encoding as 'base64' can help avoid UTF-8 errors.

### Testing

There is no built-in way to test your resulting sheets at this time

## Authors

* [Sampson Crowley](https://github.com/SampsonCrowley)

## Contributors

Many thanks to [contributors](https://github.com/SampsonCrowley/csv_rb/graphs/contributors):

* [Noel Peden](https://github.com/straydogstudio) for creating axlsx

## Change log

**June 6th, 2019**: 0.5.2 release

- Initial Release
