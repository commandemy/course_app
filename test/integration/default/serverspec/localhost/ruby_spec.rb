require 'spec_helper'

describe 'Ruby' do

  describe command('ruby -v') do
    it { should return_stdout /ruby 2.1.1*/ }
  end

  describe command('which ruby') do
    it { should return_stdout '/opt/rbenv/shims/ruby'}
  end

end