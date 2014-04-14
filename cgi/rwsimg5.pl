#!/usr/bin/perl
########################################################################################
# Remark Web Survey Image Server Script          Version 5.2.0	   	               #
# (C) Copyright 2010     http://www.gravic.com/about/copyrght.html                     #
# Gravic, Inc. http://www.gravic.com/ 						       #
########################################################################################
# COPYRIGHT NOTICE                                                           	       #
# (C) Copyright 2010 Gravic, Inc.            	 				       #
# All Rights Reserved.                  	    				       #
#										       #
# Warning: This program is protected by copyright laws and international               #
# treaties. Unauthorized reproduction or distribution of this program, or              #
# any poriton of it, may result in severe civil and criminal penalties and             #
# will be prosecuted to the maximum extent possible under the law.                     #
#######################################################################################

#get directory locations
($cgi_dir,$config_dir,$data_script) = &get_locations();

#add our cgi dir to the INC array
push (@INC,$cgi_dir);

require rwsutils5;

########################################################################################
#             GLOBAL CONSTANT LIST						       						   #
########################################################################################
$ALLOWED_FILES = "jpg|jpeg|gif|png|asf|avi|mov|mp3|mpeg|mpg|ram|rm|swf|wav|wmv";


#if a GET then display the login screen
if($ENV{'REQUEST_METHOD'} eq 'GET')
{
	&serve_image;
}
exit;

########################################################################################
# 	FUNCTION THAT DISPLAYS AN IMAGE													   #
#	USE: &serve_image($IMAGE_FILE_NAME);											   #
#   <IMG SRC="http://www.server.com/cgi-local/rwsimg5.pl?Form=Sample&Image=Test.gif">  #		       	       					   #		
########################################################################################
sub serve_image 
{
	my $image_file = "";
	my $size = 0;
	my $image_data = "";
	my $form_name = "";
	my $form_config = "";
	my %config_file = ();

	#get the image name
	$image_file	= &get_query_parameter('IMAGE');
	$image_file =~ s/%([A-Fa-f0-9][A-Fa-f0-9])/pack("c", hex($1))/ge;
	$image_file =~ s/([\+\t\n])/ /g;

	#see if this is the admin script calling the logo
	$admin_logo = get_query_parameter('ADMIN');

	#if it is the admin script, set the image_file to /html/5/logo.png
	if (($image_file eq "") && ($admin_logo eq "1"))
	{
		$image_file = $cgi_dir . "html\/5\/logo.png";
	}

	#make sure that we are dealing with a valid file
	if($image_file =~ /^.+\.($ALLOWED_FILES)$/i)
	{
		#determine the image type
		if (($image_file =~ /^.+\.gif$/i))
		{
			print "Content-type: image/gif\n";
		} 
		elsif (($image_file =~ /^.+\.png$/i))
		{
			print "Content-type: image/png\n";
		}
		elsif (($image_file =~ /^.+\.jpg$/i) || ($image_file =~ /^.+\.jpeg$/i))
		{
			print "Content-type: image/jpeg\n";
		}
		elsif (($image_file =~ /^.+\.asf$/i) || ($image_file =~ /^.+\.wmv$/i))
		{
			print "Content-type: video/x-ms-wmv\n";
		}
		elsif (($image_file =~ /^.+\.avi$/i))
		{
			print "Content-type: video/x-msvideo\n";
		}
		elsif (($image_file =~ /^.+\.mov$/i))
		{
			print "Content-type: video/quicktime\n";
		}
		elsif (($image_file =~ /^.+\.mp3$/i))
		{
			print "Content-type: audio/x-mpeg-3\n";
		}
		elsif (($image_file =~ /^.+\.mpg$/i) || ($image_file =~ /^.+\.mpeg$/i))
		{
			print "Content-type: video/mpeg\n";
		}
		elsif (($image_file =~ /^.+\.ram$/i) || ($image_file =~ /^.+\.rm$/i))
		{
			print "Content-type: application/x-pn-realaudio\n";
		}
		elsif (($image_file =~ /^.+\.wav$/i))
		{
			print "Content-type: audio/x-wav\n";
		}
		elsif (($image_file =~ /^.+\.swf$/i))
		{
			print "Content-type: application/x-shockwave-flash\n";
		}
	}
	else 
	{
		&general_error_screen('Invalid Image Type', '<B>Module:</B> RWS5<BR><B>Line:</B> ' . __LINE__ . '<BR><B>Details:</B> The image type specified is not supported/allowed');
		#print "ERROR! Invalid image type\n";
		return 1;
	}

	print "\n";
					
	#get the form name
	$form_name = lc(&get_query_parameter('FORM'));
	
	#get the full directory to the image
	$form_config = &return_full_path($config_dir,'rwsad5.cfg');
	
	if((-e $form_config) && ($admin_logo ne "1"))
	{
		%config_file = &read_config($form_config,1);
		if(exists $config_file{'[Forms]'}{$form_name})
		{
			$image_file = &return_full_path($config_file{'[Forms]'}{$form_name},$image_file);
			if(-e $image_file)
			{	  
				#open the image file in binary mode
				open(IMAGE, "<$image_file") || die "Can't open $image_file: $!";
				binmode(IMAGE);
				binmode(STDOUT);
				
				#loop thru writing the image contents
				($size) = (stat("$image_file"))[7];
			   	
			   	read(IMAGE,$image_data,$size);
				print $image_data;

				close(IMAGE);

				return (1);
			}
		}		
	}
	#otherwise, if we are loading the admin logo, load it
	elsif (($admin_logo eq "1") && (-e $image_file))
	{
		#open the image file in binary mode
		open(IMAGE, "<$image_file") || die "Can't open $image_file: $!";
		binmode(IMAGE);
		binmode(STDOUT);
				
		#loop thru writing the image contents
		($size) = (stat("$image_file"))[7];
		   	
		read(IMAGE,$image_data,$size);
		print $image_data;

		close(IMAGE);

		return (1);
	}
	return(0);
}

########################################################################################
# 	FUNCTION THAT GETS CGI + CONFIG DIRECTORIES  	       			       #	
#	USE: @dirs = &get_locations();	 	       #		
########################################################################################
sub get_locations
{
	my $dir_config = "";
	my $script_name = "";
	my $cgi_dir = "";
	my $config_dir = "";	
	my @dirs = ();
	
	#if running on Dos/Windows
	if (index($0,'\\') != -1)
	{
		$script_name = substr($0, rindex($0, '\\') + 1);
		$cgi_dir = substr($0, 0, -(length($0) - rindex($0, '\\') - 1));
	}
	#running on *nix
	else 
	{
		$script_name = substr($0, rindex($0, '/') + 1); 
		$cgi_dir = substr($0, 0, -(length($0) - rindex($0, '/') - 1));
	}

	$config_dir = $cgi_dir;
	$dir_config = $cgi_dir . 'rwsdir5.cfg';

	#check if user specfied different directory for config files
	if (-e $dir_config) 
	{
		if (open (DIR_FILE, $dir_config))
		{
			$config_dir = <DIR_FILE>;
			chomp($config_dir);
			if (!-d $config_dir)
			{
				$config_dir = $cgi_dir;
			}
			close (DIR_FILE);
		}
	}

	#check to see if there is a trailing slash
	if ($config_dir !~ m#[/|\\]$#)
	{
		#if not, find the first slash and append it to the end of the directory
		if ($config_dir =~  m#.*?([/|\\])#)
		{
			$config_dir .= $1;
		}
	}

	#add the directories to the array hash
	push (@dirs,$cgi_dir,$config_dir,$script_name);

	return (@dirs);
}