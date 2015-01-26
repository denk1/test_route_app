package TestRouteApp::Model::Func;

sub new {
	
	bless {}, shift;
}
sub GetTag {
	my ($self, $string) = @_;
	my @matches = $string =~ m/(#\w+)/g;
	return \@matches;
}

sub AddSlashes {
	my ($self, $string) = @_;
	$string =~ s/'/\\'/g;
	return $string;
}

sub CutFirstSymbol {
	my ($self, $str) = @_;
	return substr $str, 1
}

1;
