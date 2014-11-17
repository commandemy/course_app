require 'chefspec'
require 'chefspec/berkshelf'

describe 'course_app::default' do

  context 'ssh build' do

    let(:chef_run) do
      ChefSpec::SoloRunner.new do |node|
        node.set['course_app']['build_style'] = "ssh"
      end.converge(described_recipe)
    end

    it 'uses the shh build if attribute is set' do
      stub_command("/usr/sbin/apache2 -t")

      expect(chef_run.node["course_app"]["build_style"]).to eq("ssh")
      expect(chef_run).to include_recipe('course_app::ssh_build')
    end
  end

  context 'artifact build' do

    let(:chef_run) do
      ChefSpec::SoloRunner.new do |node|
        node.set['course_app']['build_style'] = "artifact"
      end.converge(described_recipe)
    end

    it 'uses the artifact build if attribute is set' do
      stub_command("/usr/sbin/apache2 -t")
      stub_search("node", "role:database_server").and_return([])
      stub_search("node", "role:jenkins_server").and_return([])

      expect(chef_run.node["course_app"]["build_style"]).to eq("artifact")
      expect(chef_run).to include_recipe('course_app::artifact_build')
    end
  end

end