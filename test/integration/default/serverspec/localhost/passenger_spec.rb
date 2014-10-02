require 'spec_helper'

describe 'Passenger' do

  describe command('which passenger-status') do
    it { should return_stdout '/opt/rbenv/shims/passenger-status' }
  end

end