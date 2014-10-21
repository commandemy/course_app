require 'serverspec'

# Required by serverspec
set :backend, :exec

describe 'Passenger' do

  describe command('which passenger-status') do
    its(:stdout) { should match '/opt/rbenv/shims/passenger-status' }
  end

end