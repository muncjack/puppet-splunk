require 'spec_helper'

describe 'splunk' do
  context 'supported operating systems' do
    on_supported_os.each do |os, facts|
      if os.start_with?('windows')
        # Splunk Server not used supported on windows
      else
        context "on #{os}" do
          let(:facts) do
            facts
          end

          context 'splunk class without any parameters' do
            it { is_expected.to compile.with_all_deps }

            it { is_expected.to contain_class('splunk::params') }

            it { is_expected.to contain_service('splunk') }
            it { is_expected.to contain_package('splunk').with_ensure('installed') }
          end

          context 'with pkg_provider set to yum and manage_package_source set to false' do
            let(:params) do
              {
                'pkg_provider'          => 'yum',
                'package_name'          => 'splunk_server_X',
                'manage_package_source' => false
              }
            end

            it { is_expected.to compile.with_all_deps }
            it { is_expected.to contain_package('splunk_server_X').with_provider('yum').without_source }
          end
        end
      end
    end
  end

  context 'unsupported operating system' do
    describe 'splunk class without any parameters on Solaris/Nexenta' do
      let(:facts) do
        {
          os: {
            family:       'Solaris',
            name:         'Nexenta',
            architecture: 'sparc'
          },
          osfamily:        'Solaris',
          operatingsystem: 'Nexenta',
          kernel:          'SunOS',
          architecture:    'sparc'
        }
      end

      it { expect { is_expected.to contain_package('splunk') }.to raise_error(Puppet::Error, %r{unsupported osfamily/arch Solaris/sparc}) }
    end
  end
end
