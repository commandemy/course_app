require 'spec_helper'

describe 'Apache' do

  describe command('dpkg --get-selections | grep apache') do
    it { should return_stdout /.*apache2.*/ }
  end

end