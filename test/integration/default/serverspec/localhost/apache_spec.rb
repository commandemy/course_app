require 'spec_helper'

describe 'Apache' do

  describe command('dpkg --get-selections | grep apache') do
    it { should return_stdout /.*apache2.*/ }
  end

  #describe file('/etc/apache2/envvars') do
  #  it { should be_file }
  #  its(:content) { should match /ubuntu/ }
  #end

end