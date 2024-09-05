
use v5.40;
use experimental qw[ builtin ];
use builtin      qw[ export_lexically ];

use importer 'Scalar::Util' => qw[ dualvar ];

package const {
    sub import ($, $name, $value) {
        my $var = dualvar($value, $name);
        export_lexically( ('&'.$name) => sub :prototype() () { $var } )
    }
}
