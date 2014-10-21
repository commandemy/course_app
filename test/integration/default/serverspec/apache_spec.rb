require 'serverspec'

# Required by serverspec
set :backend, :exec

describe 'Apache' do

  describe command('dpkg --get-selections | grep apache') do
    its(:stdout) { should match /.*apache2.*/ }
  end

end