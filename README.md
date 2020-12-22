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

## Generate documentation

Run `rake doc` and open the doc/index.html
