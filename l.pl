#!/usr/bin/env perl
use strict;
use warnings;
use Gtk2 '-init';
use Gtk2::Gdk::Keysyms;
use XML::Simple;
use File::Slurp;

# writing pid
open PIDFILE, '>', "$ENV{HOME}/.config/l.pid" or die "Unable to open ~/.config/l.pid";
print PIDFILE $$;
close PIDFILE;
# Creating our window
my $win = Gtk2::Window->new('toplevel');
$win->signal_connect(delete_event => sub { Gtk2->main_quit; });
$win->signal_connect('key-press-event' => sub {
	my ($w, $e) = @_;
	$w->hide_all if $e->keyval == $Gtk2::Gdk::Keysyms{Escape};
	return 0;
});
$win->set_position('center_always');
$win->set_border_width(10);
$win->set_resizable(0);
# adding entries from config
my $data = XMLin(scalar read_file("$ENV{HOME}/.config/menu.xml"));
my @data;

my $vbox = Gtk2::VBox->new(0, 0);
foreach my $frame (sort keys %$data) {
	my $gtkframe = Gtk2::Frame->new($frame);
	my $bbox = Gtk2::HButtonBox->new;
	$bbox->set_spacing(5);
	$bbox->set_border_width(5);
	$bbox->set_layout('spread');
	foreach my $entry (@{$data->{$frame}->{entry}}) {
		my $button = newbutton(
			$win,
			$entry->{label},
			$entry->{exec},
			$entry->{icon},
		);
		$bbox->add($button);
	}
	$gtkframe->add($bbox);
	$vbox->add($gtkframe);
}

$win->add($vbox);
$SIG{USR1} = sub { $win->show_all };
$SIG{USR2} = sub { $win->hide_all };
$SIG{TERM} = sub { Gtk2->main_quit };
Gtk2->main;

sub newbutton {
	my ($win, $label, $exec, $icon) = @_;
	my $button = Gtk2::Button->new;
	my $gtklabel = Gtk2::Label->new_with_mnemonic($label);
	my $pixbuf = Gtk2::Gdk::Pixbuf->new_from_file_at_size($icon, 32, 32);
	my $image = Gtk2::Image->new_from_pixbuf($pixbuf);
	my $key = lc(substr $label, index($label, '_') + 1, 1);
	$button->signal_connect('clicked' => sub {
		my (undef, $e) = @_;
		system("$exec &");
		$win->hide_all;
	});
	$win->signal_connect('key-press-event' => sub {
		my (undef, $e) = @_;
		if ($e->keyval eq ord($key)) {
			system("$exec &");
			$win->hide_all;
		}
	});
	my $vbox = Gtk2::VBox->new(0, 0);
	$vbox->add($image);
	$vbox->add($gtklabel);
	$button->add($vbox);
	return $button;
}
