# Controller

package TestRouteApp::Controller::Foo;
use Data::Dumper;
use Array::Utils qw(:all);
use Mojo::Base 'Mojolicious::Controller';

# Action
sub index {
  my $self = shift;

  
  $self->render(template => 'Foo/index');

}

sub welcome {
  my $self = shift;
  my $db = $self->db;
  my $id = undef;
  $self->stash(db => $db, id => $id);
  $self->render(template => 'Foo/front_list_of_news' );
}

sub welcome2 {
  my $self = shift;

  if ($self->session('user'))
  {
     $self->stash(db => $self->db);
     $self->render(template => 'Foo/list_of_news');
    
  }
  else
  {
     $self->render(template => 'Foo/form_login');
  }
  
  
}

sub logout {
  my $self = shift;
  $self->session(expires => 1);
  $self->redirect_to('/admin');
}

sub login {
  my $self = shift;
  my $user = $self->param('user') || '';
  my $pass = $self->param('pass') || '';
  if ($self->users->check($user, $pass))
  {
     $self->session(user => $user);
     $self->redirect_to('/admin');
     return 1;  
  } 
  $self->redirect_to('/admin');
  return 0;

}

sub tag {
  my $self = shift;
  my $db = $self->db;
  $self->stash(db => $db);
  $self->render(template => 'Foo/front_list_of_news' );
}

sub news {
  my $self = shift;
  my $db = $self->db;
  $self->stash(db=> $db);
  $self->render(template => 'Foo/view_news');
}

sub add_news {
  my $self = shift;
  my $headline_news = $self->param('headline_news');
  my $content_news  = $self->param('content_news');
  $self->stash( headline => $headline_news, content => $content_news );
  $self->render('Foo/form_add_news');
}

sub adding_news {
  my $self = shift;
  my $headline_news = $self->param('headline_news');
  my $content_news  = $self->param('content_news');
  my $back = $self->param('button_preview');
  if($back)
  {
      $self->stash(headline => $headline_news, content => $content_news);
      $self->render('Foo/preview_news');
      return;
  }
  my $tags = $self->func->GetTag($content_news);
  my %data_news = ( headline => $self->func->AddSlashes($headline_news), content => $self->func->AddSlashes($content_news));
  my $db = $self->db;
  $db->InsertValue('articles', \%data_news);
  my $result_article = $db->GetTable('articles');
  my $result_tags = $db->GetTable('tags');

  my %tag_hash = ();
  while(my $next = $result_tags->hash) {
     $tag_hash{$next->{'tag'}} = $next->{'id'};

  }
  my $last_news_id;
  while(my $next_news = $result_article->array) {
	$last_news_id = $next_news->[0];
  }

  foreach my $tag (@{$tags}) {
     $tag = $self->func->CutFirstSymbol($tag);
     my %data_tag_article = ();
     if (!(exists $tag_hash{$tag}))
     {
	$db->InsertValue('tags', { tag => $tag });
	$result_tags = $db->GetTable('tags');
	my $last_tags_id;
	while(my $next_tags = $result_tags->array) {
            $last_tags_id = $next_tags->[0];
        }
	%data_tag_article = ( id_tag => $last_tags_id, id_news => $last_news_id )
       
     }
     else 
     {
        %data_tag_article = ( id_tag => $tag_hash{$tag}, id_news => $last_news_id );
     }
     $db->InsertValue('article_tag', \%data_tag_article);
  }
  $self->redirect_to('/admin');
}

sub preview_news {
	my $self = shift;
	my $headline_news = $self->param('headline_news');
	my $content_news  = $self->param('content_news');
	$self->stash(headline => $headline_news, content_news => $content_news);
	$self->render('Foo/preview_news');
}

sub delete_news {
	my $self = shift;
	my $id = $self->param('id');
	my %data = (id => $id);
	my %data_article_tag = (id_news => $id);
	my $result_tags = $self->db->GetTableWhereId('article_tag_view', 'id', $id );
	my @tags_array = ();
	while(my $next = $result_tags->hash) {
		push @tags_array, $next->{'id_tag'};
	}
	$self->db->DeleteWhere('articles', \%data);
	$self->db->DeleteWhere('article_tag', \%data_article_tag);
	foreach my $id_tag (@tags_array) {
		if(!$self->db->GetCountValue('article_tag', 'id_tag', $id_tag)) {
			my %data_tag = (id => $id_tag);
			$self->db->DeleteWhere('tags', \%data_tag);
		}
	}
	$self->redirect_to('/admin');
}

sub edit_news {
	my $self = shift;
	
	my $back = $self->param('back');
	if($back) {
		my $id_news = $self->param('id_news');
		my $headline = $self->param('headline_news');
		my $content  = $self->param('content_news');
		$self->stash( id => $id_news, headline => $headline, content => $content );
	}
	else {	
		my $id = $self->param('id');
		my $result_news = $self->db->GetTableWhereId('articles', 'id', $id);
		my $hash_news = $result_news->hash;
		$self->stash( id => $id, headline => $hash_news->{'headline'}, content => $hash_news->{'content'} );
	}
	
	$self->render('Foo/form_edit_news');
	
}

sub editing_news {
	my $self = shift;
	
	my $id = $self->param('id_news');
 	my $is_preview = $self->param('button_preview');
	my $headline_news = $self->param('headline_news');
  	my $content_news  = $self->param('content_news');
  	if ($is_preview) {
		$self->stash( id => $id, headline => $headline_news, content => $content_news );
		$self->render('Foo/preview_edit_news');
		return;
	}
	my $tags_new = $self->func->GetTag($content_news);
	my $result_news = $self->db->GetTableWhereId('articles', 'id', $id);
	my $hash_news = $result_news->hash;
	my $tags_old = $self->func->GetTag($hash_news->{'content'});
	my @adding_tags = array_minus( @{$tags_new}, @{$tags_old} );
	my @deleting_tags = array_minus( @{$tags_old}, @{$tags_new} );

	my $result_tags_all = $self->db->GetTable('tags');
	my %hash_tags_table = ();
	while (my $next = $result_tags_all->array) {
		$hash_tags_table{$next->[1]} = $next->[0];
	}
	foreach my $tag (@adding_tags) {
		if (exists $hash_tags_table{$self->func->CutFirstSymbol($tag)}) {
			my %data_tag_article = (id_tag => $hash_tags_table{$self->func->CutFirstSymbol($tag)}, id_news => $id);
			$self->db->InsertValue('article_tag', \%data_tag_article);
		}
		else {
			my %data_tag = (tag => $self->func->CutFirstSymbol($tag));
			$self->db->InsertValue('tags', \%data_tag);
			my $result_tag_last = $self->db->GetTable('tags');
			my $next_result_tag_last;
			my $id_tag_insert;
			while(my $next_result_tag_last = $result_tag_last->array) {
				$id_tag_insert = $next_result_tag_last->[0];
			}
			my %data_tag_article = (id_tag => $id_tag_insert, id_news => $id);
			$self->db->InsertValue('article_tag', \%data_tag_article);
		}
	}

	foreach my $tag (@deleting_tags) {	

		my %data_tag = (id_tag => $hash_tags_table{$self->func->CutFirstSymbol($tag)}, id_news => $id);
		$self->db->DeleteWhereHash('article_tag', \%data_tag);
		if(!($self->db->GetCountValue('article_tag', 'id_tag', $hash_tags_table{$self->func->CutFirstSymbol($tag)}))) {
			my %data_delete_tag = (id => $hash_tags_table{$self->func->CutFirstSymbol($tag)});
			$self->db->DeleteWhere('tags', \%data_delete_tag);
		}
	}
	my %data_update = (headline => $headline_news, content => $content_news);
	$self->db->UpdateWhere('articles', \%data_update, 'id', $id); 
	#$self->stash(test_variable => \@deleting_tags, test_hash => \%hash_tags_table);
	#$self->render('Foo/test_template');
	#return;
	$self->redirect_to("/admin")
}

1;

