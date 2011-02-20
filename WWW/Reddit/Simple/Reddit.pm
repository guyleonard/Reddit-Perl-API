package Reddit;

use strict;
use warnings;
use Carp;

use LWP::Simple;
use XML::Simple;

##################################################
#
# Constructor:
# Returns a new instance of the Reddit class, for
# all further processing. By default, the format
# of all returned data is XML. Version is always
# 2.0.
#
##################################################
sub new {
	my $class=shift;
	my $self={
		version=>"2.0",
		format=>"xml"
	};
	bless $self, $class;
	return $self;
}

#################################################
#
# Method : format
# Returns the current format of data returned by
# the Reddit object. You can also pass,
#	xml  - for XML
#	json - for JSON
#	rss  - for RSS
# to change the format of data.
#################################################
sub format{
	my $self=shift;
	my $data=shift;
	if (defined $data) {
		$self->{format}=$data if $data eq "xml" or $data eq "json" or $data eq "rss";
	}
	return $self->{format};
}

#################################################
#
# Method: version
# Fetches the current version. Fixed at 2.0
#
#################################################
sub version{
	return $_[0]->{version};
}

#################################################
#
# Method: search
# Searches reddit with the specified parameters
#
# Accepts a hash of the following format,
#	{
#		query=>"your query",
#		over18=>"yes|no",
#		author=>"your author",
#		site=>"domain",
#		orderby=>"relevance|top"
#	}
# Returns parsable XML if format is XML, else
# returns the raw data.
#
#################################################
sub search{
	my $self=shift;
	my $data=shift;
	croak "REDDIT: Search must be called by an instance only" if not defined ref $self;
	croak "REDDIT: No inputs specified" if not defined $data;
	my $url="http://www.reddit.com/search.".$self->{format}."?q=";
	$url.=$data->{query} if defined $data->{query};
	$url.=' author:'.$data->{author} if defined $data->{author};
	$url.=' over18:'.$data->{over18} if defined $data->{over18};
	$url.=' site:'.$data->{site} if defined $data->{site};
	$url.='&sort='.$data->{orderby} if defined $data->{orderby};
	carp q(REDDIT: over18 must be yes|no) if defined $data->{over18} and $data->{over18} ne "yes" and $data->{over18} ne "no";
	my $contents=get($url);
	if($self->{format} eq "xml") {
		my $xml=XMLin($contents);
		return $xml;
	}else{
		return $contents;
	}
}

#################################################
#
# Method: front_page 
# Fetches the frontpage of reddit, or of some
# subreddit
#
# Accepts a hash of the following format,
#	{
#		subreddit=>"subreddit",
#		type=>"new|top|controversial"
#	}
# Returns parsable XML if format is XML, else
# returns the raw data.
#
#################################################
sub front_page{
	my $self=shift;
	my $data=shift;
	my $subreddit="";
	$subreddit="r/".$data->{subreddit} if defined $data->{subreddit};
	if($data->{type}){
		$subreddit.="/".$data->{type}."/";
		carp "REDDIT: Type must be new/top/controversial only" 
			if $data->{type} ne "new" and $data->{type} ne "top" and $data->{type} ne "controversial";
	}
	my $url="http://www.reddit.com/".$subreddit.".".$self->{format};
	my $contents=get($url);
	if($self->{format} eq "xml") {
		my $xml=XMLin($contents);
		return $xml;
	}else{
		return $contents;
	}
}

#################################################
#
# Method: get_links_from_xml 
# Fetches the frontpage of reddit, or of some
# subreddit
#
# Accepts a valid XML that was generated from
# front_page() or search().
#
# Returns an array of the format,
# 	( {
#		link=>"http://....",
#		title=>"title"
#	  },
#	  {
#		link=>"http://...",
#		title=>"title"
#	  }...
# 	)
#
#################################################
sub get_links_from_xml{
	my $self=shift;
	my $xml=shift;
	croak "REDDIT: Provide an XML hash reference" if not defined ref $xml;
	my $contents=$xml->{channel}->{item};
	croak "REDDIT: No data in XML provided" if (not defined $contents);
	my @return_value=();
	if (ref $contents eq "ARRAY") {
		foreach(@$contents) {
			my $current_value={
				link=>$_->{link},
				title=>$_->{title}
			};
		push @return_value,$current_value;
		}
	}else{
		my $current_value={
			link=>$xml->{channel}->{item}->{link},
			title=>$xml->{channel}->{item}->{title}
		};
		push @return_value,$current_value;
	}
	return @return_value;
}

1;
