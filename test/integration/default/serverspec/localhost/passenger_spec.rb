require 'spec_helper'

describe 'Passenger' do

  describe command('which passenger-status') do
    it { should return_stdout /\/usr\/local\/bin\/passenger-status/ }
  end

end