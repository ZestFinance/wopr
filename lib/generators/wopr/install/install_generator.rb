module Wopr
  class InstallGenerator < Rails::Generators::Base
    source_root File.expand_path('../templates', __FILE__)
    desc "Install wopr into your rails app"

    def install
      copy_file 'config/wopr.yml', 'config/wopr.yml'
      copy_file 'features/support/wopr.rb', 'features/support/wopr.rb'
    end
  end
end
