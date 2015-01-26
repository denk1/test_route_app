package TestRouteApp::Model::DB;

use strict;
use warnings;

use Mojo::Pg;

my $pg; 
my $db; 

sub new { 
	my @user;
	my @password;
	my @db_name;
	my @location;
	if (open(my $fh, '<:encoding(UTF-8)', 'config.txt')) {
  		while (my $row = <$fh>) {
    			chomp $row;
    			if($row =~m/(user:\w*)/) {
    				@user = $row =~m/(:\w*)/;
    			}
    			if($row =~m/(password:\w*)/) {
    				@password = $row =~m/(:\w*)/;
    			}
    			if($row =~m/(db:\w*)/) {
    				@db_name = $row =~m/(:\w*)/;
    			}
			if($row =~m/(location:\w*)/) {
    				@location = $row =~m/(:\w*)/;
    			}
    		}
	
		my $user = substr $user[0], 1;
		my $password = substr $password[0], 1;
		my $db_name = substr $db_name[0], 1;
		my $location = substr $location[0], 1;
		$pg = Mojo::Pg->new("postgresql://$user:$password\@$location/$db_name");
		$db = $pg->db;
        }
	bless {}, shift
}

sub GetTable {
	my ($self, $name_table) = @_;
	return $db->query("SELECT * FROM $name_table ORDER BY id");
}

sub GetTableWhereId {
	my ($self, $name_table, $column_name, $where_value) = @_;
	return $db->query("SELECT * FROM $name_table WHERE $column_name=$where_value");
}

sub InsertValue {
	my ($self,$table_name, $data) = @_;
	my $string_query = 'INSERT INTO ';
	my $string_query_value = '('; 
	$string_query .= $table_name;
	$string_query .= ' ';
	$string_query .= '(';
	my $count = scalar keys(%{$data});      
	my $i = 0;
	foreach my $key (keys(%{$data})) {
		$i++;
		$string_query .= "$key";
		$string_query_value .= "E\'$data->{$key}\'";
		if ($i != $count)
		{
			$string_query .= ', ';
			$string_query_value .= ', ';
		}
	}
	$string_query_value .= ');';
	$string_query .= ') VALUES ';
	$string_query .= $string_query_value;
	$db->do($string_query);
	
}

sub DeleteWhere {
	my ($self, $table_name, $data) = @_;
	foreach my $key (keys(%{$data})) {
		my $value = $data->{$key};
		$db->do("DELETE FROM $table_name WHERE $key='$value'");
	}
}

sub DeleteWhereHash {
	my ($self, $table_name, $data) = @_;
	my $string_query = "DELETE FROM $table_name WHERE ";
	my $count = scalar keys(%{$data});
	my $i = 0;
	foreach my $key (keys(%{$data})) {
		$i++;
		if ($i != 1)
		{
			$string_query .= ' AND ';
		}
		my $value = $data->{$key};
		$string_query .= "$key = $value";
		
	}
	open (MYFILE, '>>report.txt'); 
	print MYFILE $string_query;
	print MYFILE "\n"; 
	close (MYFILE);
	$db->do($string_query);
}

sub GetCountValue {
	my ($self, $table_name, $field, $value) = @_;
	my $result = $db->query("SELECT count(*) FROM $table_name WHERE $field = $value");
	my $next = $result->array;
	return $next->[0];
}

sub UpdateWhere {
	my ($self, $table_name, $data, $where, $where_value) =@_;
	my $string_query = "UPDATE $table_name SET ";
	my $count = scalar keys(%{$data});
	my $i = 0;
	foreach my $key (keys(%{$data})) {
		$i++;
		$string_query .= "$key=E'$data->{$key}'";
		if ($i != $count)
		{
			$string_query .= ', ';
		}
		
	}
	$string_query .= " WHERE $where='$where_value'";
	$db->do($string_query);
}

1;
