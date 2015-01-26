# Application
package TestRouteApp;
use Mojo::Base 'Mojolicious';
use TestRouteApp::Model::Users;
use TestRouteApp::Model::DB;
use TestRouteApp::Model::Func;

sub startup {
  my $self = shift;
  $self->helper(users => sub { state $users = TestRouteApp::Model::Users->new });
  $self->helper(db => sub { state $db = TestRouteApp::Model::DB->new});
  $self->helper(func => sub { state $func = TestRouteApp::Model::Func->new});
  # Router
  my $r = $self->routes;

  # Route
  my $add_news = $r->under('/admin');
  $add_news->any('/add_news')->to('foo#add_news');
  $add_news->post('/adding_news')->to('foo#adding_news');
  $add_news->post('/preview_news')->to('foo#preview_news');
  $add_news->get('/delete_news')->to('foo#delete_news');
  $add_news->any('/edit_news/:id')->to('foo#edit_news');
  $add_news->any('/editing_news')->to('foo#editing_news');
  $r->any('/')->to('foo#welcome');
  $r->get('/logout')->to('foo#logout');
  $r->get('/login')->to('foo#login');
  $r->get('/admin')->to('foo#welcome2');
  $r->get('/tag/:id')->to('foo#tag');
  $r->get('/:id')->to('foo#news');
  
}
1;
