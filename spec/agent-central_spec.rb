# encoding: UTF-8

require_relative 'spec_helper'

describe 'openstack-telemetry::agent-central' do
  describe 'ubuntu' do
    let(:runner) { ChefSpec::Runner.new(UBUNTU_OPTS) }
    let(:node) { runner.node }
    let(:chef_run) { runner.converge(described_recipe) }

    include_context 'telemetry-stubs'
    include_examples 'expect-runs-common-recipe'

    it 'installs the agent-central package' do
      expect(chef_run).to install_package 'ceilometer-agent-central'
    end

    it 'starts agent-central service' do
      expect(chef_run).to start_service('ceilometer-agent-central')
    end
  end
end
