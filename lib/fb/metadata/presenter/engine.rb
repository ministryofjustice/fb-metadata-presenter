module Fb
  module Metadata
    module Presenter
      class Engine < ::Rails::Engine
        isolate_namespace Fb::Metadata::Presenter
      end
    end
  end
end
