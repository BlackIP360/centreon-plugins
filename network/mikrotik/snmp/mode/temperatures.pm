#
# Copyright 2018 Centreon (http://www.centreon.com/)
#
# Centreon is a full-fledged industry-strength solution that meets
# the needs in IT infrastructure and application monitoring for
# service performance.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

package network::mikrotik::snmp::mode::temperatures;

use base qw(centreon::plugins::templates::counter);

use strict;
use warnings;

sub set_counters {
    my ($self, %options) = @_;
    
    $self->{maps_counters_type} = [
        { name => 'global', type => 0, cb_prefix_output => 'prefix_temperature_output' }
    ];
    
    $self->{maps_counters}->{global} = [
        { label => '1min', set => {
                key_values => [ { name => '1min' } ],
                output_template => '1 minute average : %.1f C',
                perfdatas => [
                    { label => 'temperature_1min_avg', value => '1min_absolute', temperaturelate => '%.1f',
                      min => 0, max => 9999, unit => 'C' },
                ],
            }
        },
        { label => 'cpu_1min', set => {
                key_values => [ { name => 'cpu_1min' } ],
                output_template => '1 minute average : %.1f C',
                perfdatas => [
                    { label => 'temperature_cpu_1min_avg', value => 'cpu_1min_absolute', temperaturelate => '%.1f',
                      min => 0, max => 9999, unit => 'C' },
                ],
            }
        }
    ];
}

sub prefix_temperature_output {
    my ($self, %options) = @_;
    
    return "temperature ";
}

sub new {
    my ($class, %options) = @_;
    my $self = $class->SUPER::new(package => __PACKAGE__, %options);
    bless $self, $class;
    
    $self->{version} = '1.0';
    $options{options}->add_options(arguments =>
                                { 
                                });
    
    return $self;
}

sub manage_selection {
    my ($self, %options) = @_;

    if ($options{snmp}->is_snmpv1()) {
        $self->{output}->add_option_msg(short_msg => "Need to use SNMP v2c or v3.");
        $self->{output}->option_exit();
    }

    my $oid_AvgtemperatureMikro = '.1.3.6.1.4.1.14988.1.1.3.10.0';
    my $oid_AvgCputemperatureMikro = '.1.3.6.1.4.1.14988.1.1.3.11.0';
    my $snmp_result = $options{snmp}->get_leef(oids => [
            $oid_AvgtemperatureMikro,
            $oid_AvgCputemperatureMikro
        ], nothing_quit => 1);

    $self->{global} = { '1min' => $snmp_result->{$oid_AvgtemperatureMikro}/10, 'cpu_1min' => $snmp_result->{$oid_AvgCputemperatureMikro}/10};
}

1;

__END__

=head1 MODE

Check temperature.

=over 8

=item B<--warning-*>

Threshold warning.

can be 1min or cpu_1min

=item B<--critical-*>

Threshold critical.

can be 1min or cpu_1min

=back

=cut
