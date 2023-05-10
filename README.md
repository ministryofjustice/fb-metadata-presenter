# MetadataPresenter

Rails engine responsible for rendering the MoJ Form Builder metadata into
GOV.UK design system components.

## Installation

```ruby
gem 'metadata_presenter'
```

And then execute:

```bash
$ bundle
```

Or install it yourself as:
```bash
$ gem install metadata_presenter
```

## Setup & Mount

To mount the application:

```ruby
  mount MetadataPresenter::Engine => '/'
```

Or if you are using for another route (like the MoJ Editor as preview feature):

```ruby
  mount MetadataPresenter::Engine => '/preview', as: :preview
```

The MetadataPresenter controllers inherits from your main
`::ApplicationController` as default but you can overwrite if you need:

```ruby
  MetadataPresenter.parent_controller = '::MyAwesomeController'
```

The application that you mount requires to save and load user data from some
store (session or a backend API or direct to a database). In order to do
that you need to write the following methods in your controller:

1. save_user_data
2. load_user_data
3. editable?
4. create_submission
5. assign_autocomplete_items
6. reference_number_enabled?
7. show_reference_number
8. payment_link_enabled?
9. payment_link_url

The user answers can be accessed via `params[:answers]`.

An example of implementation:
```ruby
 class MyAwesomeController
   def save_user_data
     session[:user_data] = params[:answers]
   end

   def load_user_data
     session[:user_data]
   end
 end
```

The `editable?` is related if the pages and components could be editable in the
mountable app:

```ruby
  class MyAwesomeController
    def editable?
      false
    end
    helper_method :editable?
  end
```

The `create_submission` is related to process the submission in a backend
service.

The `autocomplete_items` takes the components on a page and retrieves any items for them that may exist. For the Editor it will make an API call, for the Runner it will look it up via an environment variable.

`reference_number_enabled?` method checks whether reference number is enabled in the Runner or Editor app. For the Runner app reference number is enabled when the `ENV['REFERENCE_NUMBER']` variable is present. In the Editor, reference number enabled is checked by checking the `ServiceConfiguration` table.

`show_reference_number` method will present the placeholder reference number if viewing in the Editor/Preview or will present a generated reference number if in the Runner.

`payment_link_enabled?` method checks whether payment link is enabled in the Runner or Editor app. For the Runner app payment link is enabled when the `ENV['PAYMENT_LINK']` variable is present. In the Editor, payment link enabled is checked by checking the `ServiceConfiguration` table.

`payment_link_url` method will present the payment link url. For the Runner this is the value of the `ENV['PAYMENT_LINK']` variable. In the Editor the value comes from the `ServiceConfiguration` table.

`save_and_return_enabled?` method checks whether save and return is enabled in the Runner or Editor app. In the Runner save and return is enabled when the `ENV['SAVE_AND_RETURN']` environment variable is present. In the Editor, save and return enabled can be ascertained by checking the `ServiceConfiguration` table.

## Generate documentation

Run `rake doc` and open the doc/index.html
