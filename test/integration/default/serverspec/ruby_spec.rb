require 'serverspec'

# Required by serverspec
set :backend, :exec

describe 'Ruby' do

  describe command('bash -l -c "ruby -v"') do
    its(:stdout) { should match /ruby 2.1.1*/ }
  end

end