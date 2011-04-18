# ABSTRACT: a productivity tool for developing patches for CPAN distributions
use strict;
use warnings;
package Patch::Zilla;

1;
__END__

=head1 TRIVIA

This tool started as a small script around 2009 initially called prep-patch.pl,
then cpan-prep-patch.pl.

At the Perl QA Hackathon 2011 in Amsterdam I finally coined the name
C<Patch::Zilla> under my shower.
Because it aims to be for patches what L<Dist::Zilla> is for distributions.
This is also a kind of hommage to RJBS which I met at the hackathon, and to
remember my first use of Dist::Zilla.

The original name of the command-line tool was C<pzil>, but this had two
problems:

=over 4

=item *

L<http://www.urbandictionary.com/define.php?term=pizil> [warning: shocking words]

=item *

not enough different from C<dzil>: this could cause mistakes, especially
because the user may want to use alternatively both C<Patch::Zilla> and
C<Dist::Zilla> in the same directory.

=back

The new name is C<pzal> (C<B<Pa>tch::B<Z>iB<l>la>) which also means I<puzzle>
in greek, and I find that cool!

=head1 SEE ALSO

=over 4

=item *

L<makepatch>

=item *

L<git-cpan-sendpatch>

=item *

CPAN.pm's distroprefs

=item *

L<CPAN::Patches>

=item *

L<http://savannah.nongnu.org/projects/quilt>: Quilt, a patch management tool

=item *

L<http://svn.debian.org/viewsvn/pkg-perl/scripts/forward-patch?view=markup>: a Debian script by Alessandro Ghedini for sending a patch to its RT queue.

=back

=cut

