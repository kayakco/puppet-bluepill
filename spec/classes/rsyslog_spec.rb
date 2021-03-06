require 'spec_helper'

describe 'bluepill::rsyslog' do
  let(:pre_condition) do
    <<PUPPET
class bluepill {
  $logrotate_defaults = {
    'compress' => false,
    'ifempty'  => false,
  }
}
include bluepill
PUPPET
  end

  let(:params) do
    {
      :log_path => '/tmp/bluepill.log',
      :logrotate_options => {
        'compress' => true,
      },
    }
  end

  it do
    should contain_file('/etc/rsyslog.d/45-bluepill.conf').with({
      :content => /local6\.\*\s+\/tmp\/bluepill.log/,
      :mode => '0644',
      :owner => 'root',
      :group => 'root',
    })

    should contain_logrotate__rule('bluepill').with({
      :compress => true,
      :path => '/tmp/bluepill.log',
      :ifempty => false,
    })

    should contain_exec('restart-rsyslog').with({
      :path        => ['/bin','/usr/bin','/sbin','/usr/sbin'],
      :command     => 'service rsyslog restart',
      :refreshonly => true,
    })
  end
end
