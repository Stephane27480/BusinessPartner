#
#===============================================================================
#
#         FILE:  RestPath.pm
#
#  DESCRIPTION:  
#
#        FILES:  ---
#         BUGS:  ---
#        NOTES:  ---
#       AUTHOR:  Stéphane Bailleul (SBL), sbl27480@gmail.com
#      COMPANY:  
#      VERSION:  1.0
#      CREATED:  24/04/2020 10:03:58
#     REVISION:  ---
#===============================================================================
package RestPath ;
use Modern::Perl '2018';
use Moose;

#Attribute
has 'paths',	is => 'rw', isa => 'HashRef';
has 'base', is => 'rw', isa => 'Str';

sub main {
my $self	= shift;
my $attrRef = shift;
$self->buildBase( $attrRef );
$self->buildPath( $attrRef );
}#Main1

sub buildBase {
my $self 	= shift;
my $attrRef = shift; 
$self->base('');
	if ( defined $attrRef->{'prefix'} ){
		$self->base( $self->base . "/$attrRef->{'prefix'}" );
	}	
	
	if ( defined $attrRef->{version} ){
	$self->base( $self->base . "/$attrRef->{version}" );
	}	
	
	if ( defined $attrRef->{under} ){
		$self->base( $self->base . "/$attrRef->{under}s/$attrRef->{under}Id" );
	}	
	
	if ( defined $attrRef->{name} ){
		$self->base( $self->base . "/$attrRef->{name}s"); 
	}	

} #buildBase

sub buildPath {
	my $self 	= shift;
	my $attrRef = shift;
	my $actionKey ;
	my @httpPath ;
	$self->paths( {} );
	#Create
	$actionKey = "create_" . $attrRef->{name};
	$httpPath[0] = 'POST';
	$httpPath[1] = $self->base ;
	$self->paths->{$actionKey} = [ @httpPath ] ;
	#list
	$actionKey = "list_" . $attrRef->{name};
	$httpPath[0] = 'GET';
	$httpPath[1] = $self->base ;
	$self->paths->{$actionKey} = [ @httpPath ] ;
	
	#read
	$actionKey = "read_" . $attrRef->{name};
	$httpPath[0] = 'GET';
	$httpPath[1] = $self->base."/:".$attrRef->{name}."Id" ;
	$self->paths->{$actionKey} = [ @httpPath ] ;
	
	#update 
	$actionKey = "update_" . $attrRef->{name};
	$httpPath[0] = 'PUT';
	$httpPath[1] = $self->base."/:".$attrRef->{name}."Id" ;
	$self->paths->{$actionKey} = [ @httpPath ] ;
	#delete
	$actionKey = "delete_" . $attrRef->{name};
	$httpPath[0] = 'DELETE';
	$httpPath[1] = $self->base."/:".$attrRef->{name}."Id" ;
	$self->paths->{$actionKey} = [ @httpPath ] ;
	
}#buildPath

sub actionPath {
	my $self	= shift;
	my $action 	= shift;
	my $object	= shift;
	my $query	= shift;
	my $keyAction = lc($action) ."_$object";
	my @path = @{$self->paths->{$keyAction}};
	
	foreach my $key (keys %$query ) { 
		if ( $path[1] =~ /\Q:$key\EId/ ){
			$path[1] =~ s/\Q:$key\EId/$query->{$key}/;
			delete $query->{$key};
		}
	}
	return @path;
} #actionPath
1;

