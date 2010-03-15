#!/usr/bin/env perl
use strict;
use warnings;
use Gtk2 '-init';
use Gtk2::Gdk::Keysyms;
use Data::Dumper;

my @data;

# Reading config file
open CONFIG, "<$ENV{HOME}/.config/l.conf" or die "Could not open config file";
while (<CONFIG>) {
	chomp;
	next if $_ eq "";
	my ($ab, $des) = m/^(.) (.+)$/;
	my $comm = <CONFIG>;
	if (!$comm) {
		die "No command specified for '$des'";
	}
	chomp($comm);
	my $icon = <CONFIG>;
	if (!$comm) {
		die "No icon specified for '$des'";
	}
	chomp($icon);
	push @data, [$ab, $des, $comm, $icon];
}
close CONFIG;

# Creating our window
my $win = Gtk2::Window->new('toplevel');
$win->signal_connect(delete_event => sub { Gtk2->main_quit; });
$win->signal_connect('key-press-event' => \&keypress_cb);
$win->set_position('center_always');
$win->set_border_width('10');
$win->set_resizable(0);

my $vbox = Gtk2::VBox->new(0, 5);
# Creating a lookup label
foreach (@data) {
	my $hbox = Gtk2::HBox->new(1, 0);
	my $pixbuf = Gtk2::Gdk::Pixbuf->new_from_file_at_size(@{$_}[3], 32, 32);
	my $icon = Gtk2::Image->new_from_pixbuf($pixbuf);
	my $txt = "<b>@{$_}[0]</b>: @{$_}[1]\n<span size='small'>@{$_}[2]</span>";
	my $label = Gtk2::Label->new;
	$label->set_markup($txt);
	$label->set_justify('fill');
	$label->set_alignment(0, 0);
	$hbox->add($icon);
	$hbox->add($label);

	$vbox->add($hbox);
}

$win->add($vbox);
$win->show_all;
Gtk2->main;

sub keypress_cb {
	my ($w, $e) = (shift, shift);
	Gtk2->main_quit if $e->keyval == $Gtk2::Gdk::Keysyms{Escape};
	my $key = chr($e->keyval);
	my ($el) = grep {@{$_}[0] eq $key} @data;
	if ($el) {
		system("@{$el}[2] &");
		Gtk2->main_quit;
	}
}
