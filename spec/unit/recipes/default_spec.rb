require 'chefspec'
require 'chefspec/berkshelf'

describe 'course_app::default' do

  context 'artifact build' do

    let(:chef_run) do
      ChefSpec::SoloRunner.new.converge(described_recipe)
    end

    it 'uses the artifact build if attribute is set' do
      stub_command("/usr/sbin/apache2 -t")
      stub_search("node", "role:database_server").and_return([])
      stub_search("node", "role:jenkins_server").and_return([])

      expect(chef_run).to include_recipe('course_app::artifact_build')
    end
  end

end