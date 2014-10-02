require 'spec_helper'

describe 'Artifact' do

  describe file('/tmp/blog.tar') do
    it { should be_file }
  end

  describe file('/home/course_app/blog/current/environments.rb') do
    it { should be_file }
    its(:content) { should match /mysql/ }
    its(:content) { should match /10.11.12.110/ }
  end

end