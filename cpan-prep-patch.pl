use utf8;

use strict;

use warnings;

use autodie;



use Cwd qw/cwd/;

use Archive::Tar;

use File::Spec;



use CPAN;

# TODO use personnal CPAN config too



my $orig_dir = cwd;



CPAN::HandleConfig->load;







@ARGV == 2 or die "invalid argument count";

unless ($ARGV[0] =~ m%^[A-Z0-9]+/.+\.(?:zip|tar\.(?:gz|bz2))$%) {

    print STDERR "Invalid distname '$ARGV[0]' (AUTHOR/file expected)!\n";

    CPAN::Shell->i($ARGV[0]);

    exit 2;

}

my $ext = $1;

$ARGV[1] =~ m|RT\d+| or die 'invalid bug number: /RT\d+/ expected';



my $keep_source_where = $CPAN::Config->{keep_source_where};

my $PAUSE_id = uc($ENV{PAUSE_ID} // '');

my $prefs_dir = $CPAN::Config->{prefs_dir} // '.';

# See 

my $patches_dir = File::Spec->catfile(($CPAN::Config->{patches_dir} // $prefs_dir), $PAUSE_id, 'patches');







my ($dist, $patch_desc) = @ARGV;

$dist =~ m%^(((.).)[^/]*)/(.+)\.(zip|tar\.(?:gz|bz2))$%;

my $dist_author = $1;

my $dist_archive = "$keep_source_where/authors/id/$3/$2/$dist";

my $dist_dir = $4;

my $dist_ext = $5;

#my $dist_source = $dist_archive;   # TODO Fix makepatch on windows

my $dist_source = $dist_dir;





my $patch_desc_short = $patch_desc =~ /\b(RT\d+)\b/ ? $1 : $patch_desc;

my $patch_dir = $dist_dir . "." . $patch_desc_short;

my $patch_file = "$dist_dir-$dist_author-$patch_desc_short.patch";

my $distropref_file = "$dist_dir-$dist_author-$patch_desc_short.yml";

my $patch_path = File::Spec->catfile($patches_dir, $patch_file);

my $distropref_path = File::Spec->catfile($prefs_dir, $distropref_file);



print <<EOF;

Dist: $dist

DistDir: $dist_dir

PatchDir: $patch_dir

Patch: $patch_file



EOF





sub extractTar

{

    my $tar = Archive::Tar->new($_[0]);

    $tar->extract();

}



sub extractZip

{

    my $zip = Archive::Zip->new($_[0]);

    $zip->extractTree();

}





# Get the distrib in the local cache

CPAN::Shell->get($dist);

print "\n";



chdir $orig_dir;



my $extract =

    $dist_ext =~ m/^zip/

    ? \&extractZip

    : \&extractTar;



if (-d $dist_dir) {

    die "Extract failed: directory '$dist_dir' already exists!";

}



unless (-d $patch_dir) {

    print "Extracting $dist to $patch_dir...\n";

    $extract->($dist_archive) or die "Extract failed: $!";

    -d $dist_dir or die "Distribution archive layout is non-standard! Where are the files?";

    rename $dist_dir, $patch_dir or die "Extract failed: $!";

} else {

    print "Directory $patch_dir already exists!\n";

}



if ($dist_source eq $dist_dir && ! -d $dist_dir) {

    print "Extracting $dist to $dist_dir...\n";

    $extract->($dist_archive);

}



if ($^O eq 'MSWin32') {

    print qq|Creating "$patch_dir.make.bat"...\n|;

    open my $f, ">:encoding(cp850)", "$patch_dir.make.bat" or die "$!";

    print $f <<EOF;

\@echo off

echo Creating "$patch_path"...

call makepatch -description "$patch_desc" "$dist_source" "$patch_dir" > "$patch_path"

echo Gzip...

gzip -c "$patch_path" > "$patch_path.gz"

EOF

    close $f;

}



if ($PAUSE_id) {

    print qq|Creating "$distropref_path"...\n|;

    open my $f, ">:utf8", $distropref_path;

    print $f <<EOF;

---

comment: "$patch_desc"

match:

  distribution: "^$dist\$"

patches:

  - "$PAUSE_id/patches/$patch_file.gz"

EOF

    close $f;

}