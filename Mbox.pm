package Chess::Mbox;

use Chess::PGN::Parse;
use Mail::MboxParser;


require 5.005_62;
use strict;
use warnings;

our $VERSION = '0.01';


# Preloaded methods go here.

sub Parse {
    my $class = shift;
    my %C = @_;

    my $mailbox     = $C{mbox};
    my $game_dir    = $C{output_dir};
    my $temp_file   = "/tmp/chessfile$$";

    my $mb = Mail::MboxParser->new($mailbox, decode => 'NEVER');

while (my $msg = $mb->next_message) {
#    print $msg->header->{subject}, "\n";

    my $pgnfile = $temp_file;
    open  T, ">$pgnfile" or die "couldnt open $pgnfile: $!";
    my $GAME = $msg->body($msg->find_body)->as_string;
    print T $GAME;
    close(T);

    my $pgn = Chess::PGN::Parse->new($pgnfile) or die "can't open $pgnfile\n";

    while ($pgn->read_game) {
	mkdir sprintf "%s/%s", $game_dir, $pgn->white;
	my $dir = sprintf "%s/%s/%s", $game_dir, $pgn->white, $pgn->black;
	mkdir $dir;
	my $file = sprintf "%s-%s", $pgn->date, $pgn->time;
	$file =~ s/:/-/g;
	my $F = "$dir/$file.pgn";
	print $F, $/;
	open F, ">$F" or die "couldnt open $F: $!";
	print F $GAME;
	close(F);
    }

}




}

1;
__END__
# Below is stub documentation for your module. You better edit it!

=head1 NAME

Chess::Mbox - write mbox files with chess games into them onto disk

=head1 SYNOPSIS

  use Chess::Mbox;
  Chess::Mbox->Parse (mmbox => $M, output_dir => $O);

=head1 DESCRIPTION

This was a script lying on my disk that I thought would be useful to others. It simply
takes a Unix mbox file and assumes each message is a chess game and writes to a directory
with first directory == white and directory below that == black and the file name == date + time
of match... after all you will have many rematches with a certain person. :)

=head2 EXPORT

None by default.


=head1 AUTHOR

T. M. Brannon <tbone@cpan.org>


=cut
