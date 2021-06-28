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

## Generate documentation

Run `rake doc` and open the doc/index.html

## Flow diagrams

You can generate flow diagrams calling a rake task:

```
  brew install graphviz
  SERVICE_METADATA="some-form-metadata" rails metadata:flow
```

This will generate an image with the flow for that metadata. Open that image
and profit!
