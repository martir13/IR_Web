#!/usr/local/bin/perl
##############################################################################
# Remark Web Survey Test Script                              Version 5.2.0   #
# (C) Copyright 2010            http://www.gravic.com/about/copyright.html   #
# Gravic, Inc.              			   http://www.gravic..com/   #
##############################################################################
# COPYRIGHT NOTICE                                                           #
# (C) Copyright 2010 Gravic, Inc. All Rights Reserved.		             #
#                                                                            #
# Warning: This program is protected by copyright laws and international     #
# treaties. Unauthorized reproduction or distribution of this program, or    #
# any poriton of it, may result in severe civil and criminal penalties and   #
# will be prosecuted to the maximum extent possible under the law.           #
##############################################################################

#constant to turn on STARTTLS support
$USE_STARTTLS = 0;
my $default_form_dir = "";
			   
#-----------------------------------------------------------------------------
# RETRIEVE SCRIPT NAME AND DIRECTORY
#-----------------------------------------------------------------------------
&get_script_name();

#-----------------------------------------------------------------------------
# SUBMIT TEST MAIL MESSAGE (IF SPECIFIED)
#-----------------------------------------------------------------------------

if ($ENV{'REQUEST_METHOD'} eq 'POST') 
{	
	my %submitted_data = ();

	require rwsutils5;
	%submitted_data = &store_post_data();

	$config_dir = $submitted_data{'CONFIG_DIR'};

	if (length($submitted_data{'EMAIL_DETAILS'}) > 0)
	{
		$email_recipient = $submitted_data{'EMAIL_RECIPIENT'};
		$submitted_data{'EMAIL_DETAILS'} =~ s/EMAIL_REPLACE/$email_recipient/;
		@query = split(/\?/, $submitted_data{'EMAIL_DETAILS'});
		&send_test_mail(@query);
		exit;
	}
}	

#-----------------------------------------------------------------------------
# BUILD REPORT
#-----------------------------------------------------------------------------

# Print HTML header
print "Content-type: text/html\n\n<html><body>";
print "<font face=\"verdana,arial,helvetica\" size=2><ol>\n";

print "<P><B><U>SECURITY NOTE:</U> <FONT COLOR=\"RED\"><I>THIS SCRIPT IS A DIAGNOSTICS TOOL AND SHOULD BE REMOVED FROM THE SERVER AFTER USE.</I></FONT></B></P>"; 

&environment_variables;
&miscellaneous_info;
&rws_test_script;
&rws_module_search;
&rws_admin_script;
&rws_data_script;
&rws_image_script;
&rws_configuration_directory_file;
&config_directory;
&rws_password_file;
&rws_admin_config_file;
&rws_default_form_dir;
&rws_html_dir;
&problem_report;

print "</ol></font></body></html>";
exit(0);

#-----------------------------------------------------------------------------
# ENVIRONMENT VARIABLES
#-----------------------------------------------------------------------------

sub environment_variables {

	print "<li><b><u>Environment Variables</u></b><ul>\n";
	foreach $var (sort keys(%ENV))
	{
		print "<li>$var = $ENV{$var}</li>\n";
	};
	print "</ul>\n";

};

#-----------------------------------------------------------------------------
# MISCELLANEOUS INFO
#-----------------------------------------------------------------------------

sub miscellaneous_info {

	print "<p>\n<li><b><u>Miscellaneous Info</u></b><dir>\n";
	print "PROGRAM NAME = $0<br>\n";
	print "OS NAME = $^O<br>\n";
	
	#verify the version of Perl
	if ($] < 5.004)
	{	
		$pi++; $problems .= "<li><a href=#P$pi>Error: RWS requires Perl 5.005 or greater.</a>";
		$first_line = "<a name=\"P$pi\"></a><font color=red>" . $first_line . "</font>";
		print "<a name=\"P$pi\"></a>PERL VERSION = <font color=red>$]</font><br>\n";
	}
	else
	{
		print "PERL VERSION = $]<br>\n";
	}
	print "EXECUTABLE NAME = $^X<br>\n";
	print "BASETIME = $^T<br>\n";
	print "EGID = $)<br>\n";
	print "GID = $(<br>\n";
	print "UID = $<<br></dir>\n";

};

#-----------------------------------------------------------------------------
# RWS TEST SCRIPT
#-----------------------------------------------------------------------------

sub rws_test_script {

	print "<p>\n<li><b><u>RWS Test Script Info</u></b><dir>\n";
	$rws_test = $cgi_dir . $script_name;
	print "location = $rws_test<br>\n";

	if (-e $rws_test) {
		print "exists = True<br>\n";
		if (-R $rws_test) {
			print "read (real id) = True<br>\n";		
		} else {
			$pi++; $problems .= "<li><a href=#P$pi>Error: The RWS Test Script requires read permissions.</a>";
			print "<a name=\"P$pi\"></a>read (real id) = <font color=red>False</font><br>\n";
		};
		if (-W $rws_test) {
			print "write (real id) = True<br>\n";		
		} else {
			print "write (real id) = False<br>\n";
		};
		if (-X $rws_test) {
			print "execute (real id) = True<br>\n";		
		} else {
			if ($os_type eq 'unix') {
				$pi++; $problems .= "<li><a href=#P$pi>Error: The RWS Test Script requires execute permissions.</a>";
				print "<a name=\"P$pi\"></a>execute (real id) = <font color=red>False</font><br>\n";
			} else {
				print "execute (real id) = False<br>\n";
			};
		};
		print "<br>\n";

		if (open (RWSTEST, "<$rws_test")) {
			$first_line = <RWSTEST>;
			chomp($first_line);
			@rws_test = <RWSTEST>;
			close RWSTEST;
			if ($os_type eq 'unix') {
				if ($first_line !~ /$^X/) {
					$pi++; $problems .= "<li><a href=#P$pi>Warning: The first line of the RWS Test Script must point to the PERL compiler.</a>";
					$first_line = "<a name=\"P$pi\"></a><font color=red>" . $first_line . "</font>";
				};
			};
			print "first line = $first_line<br>\n";

			$rws_test_version = &script_version(@rws_test);
			if (length($rws_test_version) > 0) {
				print "version = $rws_test_version<br>\n";			
			};
			print "<br>\n";
		}
		else {
			$pi++; $problems .= "<li><a href=#P$pi>Error: Unable to read from the RWS Test Script.</a>";
			print "<a name=\"P$pi\"></a>first line = <font color=red>error opening file</font><br>\n<br>\n";
		};

		($dev, $ino, $mode, $nlink, $uid, $gid, $rdev, $size, $atime, $mtime, $ctime) = stat($rws_test);
		print "file mode = $mode<br>\n";		
		print "user id = $uid<br>\n";		
		print "group id = $gid<br>\n";		
		print "size = $size</dir>\n";
	}
	else {
		$pi++; $problems .= "<li><a href=#P$pi>Error: Unable to locate the RWS Test Script. This could indicate a problem determining the CGI directory.</a>";
		print "<a name=\"P$pi\"></a>exists = <font color=red>False</font></dir>\n";
	};

};

#-----------------------------------------------------------------------------
# RWS ADMIN SCRIPT
#-----------------------------------------------------------------------------

sub rws_admin_script {
	
	my $tmp_msg ="";

	print "<p>\n<li><b><u>RWS Admin Script Info</u></b><dir>\n";
	$rws_admin = $cgi_dir . 'rwsad5.pl';

	if (! -e $rws_admin) {
		$tmp_msg = $tmp_msg . "location = $rws_admin<br>\n";
		$rws_admin = $cgi_dir . 'rwsad5.cgi';
	};

	if (! -e $rws_admin) {
		$tmp_msg = $tmp_msg . "location = $rws_admin<br>\n";
		$rws_admin = $cgi_dir . 'rwsad5.plx';
	};

	if (-e $rws_admin) {
		print "location = $rws_admin<br>\n";
		print "exists = True<br>\n";
		if (-R $rws_admin) {
			print "read (real id) = True<br>\n";		
		} else {
			$pi++; $problems .= "<li><a href=#P$pi>Error: The RWS Admin Script requires read permissions.</a>";
			print "<a name=\"P$pi\"></a>read (real id) = <font color=red>False</font><br>\n";
		};
		if (-W $rws_admin) {
			print "write (real id) = True<br>\n";		
		} else {
			print "write (real id) = False<br>\n";
		};
		if (-X $rws_admin) {
			print "execute (real id) = True<br>\n";		
		} else {
			if ($os_type eq 'unix') {
				$pi++; $problems .= "<li><a href=#P$pi>Error: The RWS Admin Script requires execute permissions.</a>";
				print "<a name=\"P$pi\"></a>execute (real id) = <font color=red>False</font><br>\n";
			} else {
				print "execute (real id) = False<br>\n";
			};
		};
		print "<br>\n";

		if (open (RWSADMIN, "<$rws_admin")) {
			$first_line = <RWSADMIN>;
			@rws_admin = <RWSADMIN>;
			chomp($first_line);
			close RWSADMIN;
			if ($os_type eq 'unix') {
				if ($first_line !~ /$^X/) {
					$pi++; $problems .= "<li><a href=#P$pi>Warning: The first line of the RWS Admin Script must point to the PERL compiler.</a>";
					$first_line = "<a name=\"P$pi\"></a><font color=red>" . $first_line . "</font>";
				};
			};
			print "first line = $first_line<br>\n";

			$rws_admin_version = &script_version(@rws_admin);
			if (length($rws_admin_version) > 0) {
				print "version = $rws_admin_version<br>\n";			
			};
			print "<br>\n";
		}
		else {
			$pi++; $problems .= "<li><a href=#P$pi>Error: Unable to read from the RWS Admin Script.</a>";
			print "<a name=\"P$pi\"></a>first line = <font color=red>error opening file</font><br>\n<br>\n";
		};

		($dev, $ino, $mode, $nlink, $uid, $gid, $rdev, $size, $atime, $mtime, $ctime) = stat($rws_admin);
		print "file mode = $mode<br>\n";		
		print "user id = $uid<br>\n";		
		print "group id = $gid<br>\n";		
		print "size = $size</dir>\n";
	}
	else {
		$tmp_msg = $tmp_msg . "location = $rws_admin<br>\n";
		print "$tmp_msg";
		$pi++; $problems .= "<li><a href=#P$pi>Error: Unable to locate the RWS Admin Script.</a>";
		print "<a name=\"P$pi\"></a>exists = <font color=red>False</font></dir>\n";
	};
};

#-----------------------------------------------------------------------------
# RWS DATA SCRIPT
#-----------------------------------------------------------------------------

sub rws_data_script {
	
	my $tmp_msg ="";

	print "<p>\n<li><b><u>RWS Data Script Info</u></b><dir>\n";
	$rws = $cgi_dir . 'rws5.pl';

	if (! -e $rws) {
		$tmp_msg = $tmp_msg . "location = $rws<br>\n";
		$rws = $cgi_dir . 'rws5.cgi';
	};

	if (! -e $rws) {
		$tmp_msg = $tmp_msg . "location = $rws<br>\n";
		$rws = $cgi_dir . 'rws5.plx';
	};

	if (-e $rws) {
		print "location = $rws<br>\n";
		print "exists = True<br>\n";
		if (-R $rws) {
			print "read (real id) = True<br>\n";		
		} else {
			$pi++; $problems .= "<li><a href=#P$pi>Error: The RWS Data Script requires read permissions.</a>";
			print "<a name=\"P$pi\"></a>read (real id) = <font color=red>False</font><br>\n";
		};
		if (-W $rws) {
			print "write (real id) = True<br>\n";		
		} else {
			print "write (real id) = False<br>\n";
		};
		if (-X $rws) {
			print "execute (real id) = True<br>\n";		
		} else {
			if ($os_type eq 'unix') {
				$pi++; $problems .= "<li><a href=#P$pi>Error: The RWS Data Script requires execute permissions.</a>";
				print "<a name=\"P$pi\"></a>execute (real id) = <font color=red>False</font><br>\n";
			} else {
				print "execute (real id) = False<br>\n";
			};
		};
		print "<br>\n";

		if (open (RWS, "<$rws")) {
			$first_line = <RWS>;
			@rws = <RWS>;
			chomp($first_line);
			close RWS;
			if ($os_type eq 'unix') {
				if ($first_line !~ /$^X/) {
					$pi++; $problems .= "<li><a href=#P$pi>Warning: The first line of the RWS Data Script must point to the PERL compiler.</a>";
					$first_line = "<a name=\"P$pi\"></a><font color=red>" . $first_line . "</font>";
				};
			};
			print "first line = $first_line<br>\n";

			$rws_version = &script_version(@rws);
			if (length($rws_version) > 0) {
				print "version = $rws_version<br>\n";			
			};
			print "<br>\n";
		}
		else {
			$pi++; $problems .= "<li><a href=#P$pi>Error: Unable to read from the RWS Data Script.</a>";
			print "<a name=\"P$pi\"></a>first line = <font color=red>error opening file</font><br>\n<br>\n";
		};

		($dev, $ino, $mode, $nlink, $uid, $gid, $rdev, $size, $atime, $mtime, $ctime) = stat($rws);
		print "file mode = $mode<br>\n";		
		print "user id = $uid<br>\n";		
		print "group id = $gid<br>\n";		
		print "size = $size</dir>\n";
	}
	else {
		$tmp_msg = $tmp_msg . "location = $rws<br>\n";
		print "$tmp_msg";
		$pi++; $problems .= "<li><a href=#P$pi>Error: Unable to locate the RWS Data Script.</a>";
		print "<a name=\"P$pi\"></a>exists = <font color=red>False</font></dir>\n";
	};

};

#-----------------------------------------------------------------------------
# RWS IMAGE SCRIPT
#-----------------------------------------------------------------------------

sub rws_image_script {
	
	my $tmp_msg ="";
	my $rws_image_version = "unknown";
	my $tmp_lines = "";

	print "<p>\n<li><b><u>RWS Image Server Script Info</u></b><dir>\n";
	$rws_img = $cgi_dir . 'rwsimg5.pl';

	if (! -e $rws_img) {
		$tmp_msg = $tmp_msg . "location = $rws_img<br>\n";
		$rws_img = $cgi_dir . 'rwsimg5.cgi';
	};

	if (! -e $rws_img) {
		$tmp_msg = $tmp_msg . "location = $rws_img<br>\n";
		$rws_img = $cgi_dir . 'rwsimg5.plx';
	};

	if (-e $rws_img) {
		print "location = $rws_img<br>\n";
		print "exists = True<br>\n";
		if (-R $rws_img) {
			print "read (real id) = True<br>\n";		
		} else {
			$pi++; $problems .= "<li><a href=#P$pi>Error: The RWS Image Server Script requires read permissions.</a>";
			print "<a name=\"P$pi\"></a>read (real id) = <font color=red>False</font><br>\n";
		};
		if (-W $rws_img) {
			print "write (real id) = True<br>\n";		
		} else {
			print "write (real id) = False<br>\n";
		};
		if (-X $rws_img) {
			print "execute (real id) = True<br>\n";		
		} else {
			if ($os_type eq 'unix') {
				$pi++; $problems .= "<li><a href=#P$pi>Error: The RWS Image Server Script requires execute permissions.</a>";
				print "<a name=\"P$pi\"></a>execute (real id) = <font color=red>False</font><br>\n";
			} else {
				print "execute (real id) = False<br>\n";
			};
		};
		print "<br>\n";

		if (open (RWSIMG, "<$rws_img")) {
			$first_line = <RWSIMG>;
			@rwsimg = <RWSIMG>;
			chomp($first_line);
			close RWSIMG;
			if ($os_type eq 'unix') {
				if ($first_line !~ /$^X/) {
					$pi++; $problems .= "<li><a href=#P$pi>Warning: The first line of the RWS Image Server Script must point to the PERL compiler.</a>";
					$first_line = "<a name=\"P$pi\"></a><font color=red>" . $first_line . "</font>";
				};
			};
			print "first line = $first_line<br>\n";

			$rws_version = &script_version(@rwsimg);
			if (length($rws_version) > 0) {
				print "version = $rws_version<br>\n";			
			};
			print "<br>\n";
		}
		else {
			$pi++; $problems .= "<li><a href=#P$pi>Error: Unable to read from the RWS Image Server Script.</a>";
			print "<a name=\"P$pi\"></a>first line = <font color=red>error opening file</font><br>\n<br>\n";
		};

		($dev, $ino, $mode, $nlink, $uid, $gid, $rdev, $size, $atime, $mtime, $ctime) = stat($rws_img);
		print "file mode = $mode<br>\n";		
		print "user id = $uid<br>\n";		
		print "group id = $gid<br>\n";		
		print "size = $size</dir>\n";
	}
	else {
		$tmp_msg = $tmp_msg . "location = $rws_img<br>\n";
		print "$tmp_msg";
		$pi++; $problems .= "<li><a href=#P$pi>Error: Unable to locate the RWS Image Server Script.</a>";
		print "<a name=\"P$pi\"></a>exists = <font color=red>False</font></dir>\n";
	};

};

#-----------------------------------------------------------------------------
# RWS CONFIGURATION DIRECTORY FILE
#-----------------------------------------------------------------------------

sub rws_configuration_directory_file {

	$cfg_dir = $cgi_dir;
	print "<p>\n<li><b><u>RWS Config Directory File</u></b><dir>\n";
	$rwsdir_cfg = $cfg_dir . 'rwsdir5.cfg';
	print "location = $rwsdir_cfg<br>\n";

	if (-e $rwsdir_cfg) {
		print "exists = True<br>\n";
		if (-R $rwsdir_cfg) {
			print "read (real id) = True<br>\n";		
		} else {
			$pi++; $problems .= "<li><a href=#P$pi>Error: The RWS Config Directory File requires read permissions.</a>";
			print "<a name=\"P$pi\"></a>read (real id) = <font color=red>False</font><br>\n";
		};
		if (-W $rwsdir_cfg) {
			print "write (real id) = True<br>\n";		
		} else {
			print "write (real id) = False<br>\n";
		};
		if (-X $rwsdir_cfg) {
			$pi++; $problems .= "<li><a href=#P$pi>Warning: The RWS Config Directory File should NOT have execute permissions.</a>";
			print "<a name=\"P$pi\"></a>execute (real id) = <font color=red>True</font><br>\n";		
		} else {
			print "execute (real id) = False<br>\n";
		};
		print "<br>\n";

		if (open (RWSDIRCFG, "<$rwsdir_cfg")) {
			print "file read = True<br>\n";
			$cfg_dir = <RWSDIRCFG>;
			close RWSDIRCFG;

			chomp($cfg_dir);

			# Check to see if there is a trailing slash
			if ($cfg_dir !~ m#[/|\\]$#) {

				# If not, find the first slash and append it to the end of the directory
				if ($cfg_dir =~  m#.*?([/|\\])#) {
					$cfg_dir .= $1;
				};
			};

			print "config directory = $cfg_dir<br>\n";
			if (-d $cfg_dir) {
				print "directory exists = True<br>\n";		
			} else {
				$pi++; $problems .= "<li><a href=#P$pi>Warning: The directory specified in the RWS Config Directory File does not exist. The CGI directory will be used instead.</a>";
				print "<a name=\"P$pi\"></a>directory exists = <font color=red>False</font><br>\n";
				$cfg_dir = $cgi_dir;
			};
		}
		else {
			$pi++; $problems .= "<li><a href=#P$pi>Error: The RWS Config Directory File requires read permissions.</a>";
			print "<a name=\"P$pi\"></a>file read = <font color=red>False</font><br>\n";
		};
		print "<br>\n";

		($dev, $ino, $mode, $nlink, $uid, $gid, $rdev, $size, $atime, $mtime, $ctime) = stat($rwsdir_cfg);
		print "file mode = $mode<br>\n";		
		print "user id = $uid<br>\n";		
		print "group id = $gid<br>\n";		
		print "size = $size</dir>\n";
	}
	else {
		print "exists = False</dir>\n";
	};

};


#-----------------------------------------------------------------------------
# CONFIG DIRECTORY
#-----------------------------------------------------------------------------

sub config_directory {

	print "<p>\n<li><b><u>Config Directory Info</u></b><dir>\n";
	print "directory = $cfg_dir<br>\n";
	if (-d $cfg_dir) {
		print "exists = True<br>\n";
		if (-R $cfg_dir) {
			print "read (real id) = True<br>\n";		
		} else {
			$pi++; $problems .= "<li><a href=#P$pi>Error: RWS requires read access to the config directory.</a>";
			print "<a name=\"P$pi\"></a>read (real id) = <font color=red>False</font><br>\n";
		};
		if (-W $cfg_dir) {
			print "write (real id) = True<br>\n";		
		} else {
			$pi++; $problems .= "<li><a href=#P$pi>Error: RWS requires write access to the config directory.</a>";
			print "<a name=\"P$pi\"></a>write (real id) = <font color=red>False</font><br>\n";
		};
		if (-X $cfg_dir) {
			print "execute (real id) = True<br>\n";		
		} else {
			print "execute (real id) = False<br>\n";
		};
		print "<br>\n";

		$rws_test = $cfg_dir . 'rws5.test';
		if (-e $rws_test) {
			unlink $rws_test;
			if (-e $rws_test) {
				$pi++; $problems .= "<li><a href=#P$pi>Error: RWS requires delete access to the config directory.</a>";
				print "<a name=\"P$pi\"></a>file delete = <font color=red>False</font><br>\n";
			};
		};

		if (!-e $rws_test) {
			if (open (RWSTEST, ">" . $rws_test)) {
				print "file create = True<br>\n";
				close RWSTEST;
				if (open (RWSTEST, "<" . $rws_test)) {
					print "file read = True<br>\n";
					close RWSTEST;
				} else {
					$pi++; $problems .= "<li><a href=#P$pi>Error: RWS requires file create permissions in the config directory.</a>";
					print "<a name=\"P$pi\"></a>file read = <font color=red>False</font><br>\n";
				};
				if (open (RWSTEST, ">" . $rws_test)) {
					print "file write = True<br>\n";
					close RWSTEST;
				} else {
					$pi++; $problems .= "<li><a href=#P$pi>Error: RWS requires write access to the config directory.</a>";
					print "<a name=\"P$pi\"></a>file write = <font color=red>False</font><br>\n";
				};
				
				unlink $rws_test;
				if (-e $rws_test) {
					$pi++; $problems .= "<li><a href=#P$pi>Error: RWS requires delete access to the config directory.</a>";
					print "<a name=\"P$pi\"></a>file delete = <font color=red>False</font><br>\n";
				} else {
					print "file delete = True<br>\n";
				};
			} else {
				$pi++; $problems .= "<li><a href=#P$pi>Error: RWS requires file create permissions in the config directory.</a>";
				print "<a name=\"P$pi\"></a>file create = <font color=red>False</font><br>\n";
			};
		};
		print "<br>\n";

		($dev, $ino, $mode, $nlink, $uid, $gid, $rdev, $size, $atime, $mtime, $ctime) = stat($cfg_dir);
		print "file mode = $mode<br>\n";		
		print "user id = $uid<br>\n";		
		print "group id = $gid</dir>\n";		

	} else {
		$pi++; $problems .= "<li><a href=#P$pi>Error: The config directory does not exist.</a>";
		print "<a name=\"P$pi\"></a>exists = <font color=red>False</font></dir>\n";
	};

};

#-----------------------------------------------------------------------------
# RWS PASSWORD FILE
#-----------------------------------------------------------------------------

sub rws_password_file {

	print "<p>\n<li><b><u>RWS Password File</u></b><dir>\n";
	$rws_cfg = $cfg_dir . 'rws5.cfg';
	print "location = $rws_cfg<br>\n";

	if (-e $rws_cfg) {
		print "exists = True<br>\n";
		if (-R $rws_cfg) {
			print "read (real id) = True<br>\n";		
		} else {
			$pi++; $problems .= "<li><a href=#P$pi>Error: RWS requires read access to the password file.</a>";
			print "<a name=\"P$pi\"></a>read (real id) = <font color=red>False</font><br>\n";
		};
		if (-W $rws_cfg) {
			print "write (real id) = True<br>\n";		
		} else {
			$pi++; $problems .= "<li><a href=#P$pi>Error: RWS requires write access to the password file.</a>";
			print "<a name=\"P$pi\"></a>write (real id) = <font color=red>False</font><br>\n";
		};
		if (-X $rws_cfg) {
			$pi++; $problems .= "<li><a href=#P$pi>Warning: The password file should NOT have execute permissions.</a>";
			print "<a name=\"P$pi\"></a>execute (real id) = <font color=red>True</font><br>\n";		
		} else {
			print "execute (real id) = False<br>\n";
		};
		print "<br>\n";

		if (open (RWSCFG, "<$rws_cfg")) {
			print "file read = True<br>\n";
			@rws_cfg = <RWSCFG>;
			close RWSCFG;

			unlink $rws_cfg;
			if (!-e $rws_cfg) {
				print "file delete = True<br>\n";
				if (open (RWSCFG, '>' . $rws_cfg)) {
					print "file write = True<br>\n";
					print RWSCFG @rws_cfg;
					close RWSCFG;
				}
				else {
					$pi++; $problems .= "<li><a href=#P$pi>Error: RWS requires write access to the password file.</a>";
					print "<a name=\"P$pi\"></a>file write = <font color=red>False</font><br>\n";
				};
			}
			else {
				$pi++; $problems .= "<li><a href=#P$pi>Error: RWS requires delete access to the password file.</a>";
				print "<a name=\"P$pi\"></a>file delete = <font color=red>False</font><br>\n";
			};
		}
		else {
			$pi++; $problems .= "<li><a href=#P$pi>Error: RWS requires read access to the password file.</a>";
			print "<a name=\"P$pi\"></a>file read = <font color=red>False</font><br>\n";
		};
		print "<br>\n";

		($dev, $ino, $mode, $nlink, $uid, $gid, $rdev, $size, $atime, $mtime, $ctime) = stat($rws_cfg);
		print "file mode = $mode<br>\n";		
		print "user id = $uid<br>\n";		
		print "group id = $gid<br>\n";		
		print "size = $size</dir>\n";
	}
	else {
		$pi++; $problems .= "<li><a href=#P$pi>Warning: The password file does not exist. Note: This is appropriate for a new installation.</a>";
		print "<a name=\"P$pi\"></a>exists = <font color=red>False</font></dir>\n";
	};

};

#-----------------------------------------------------------------------------
# RWS ADMIN CONFIG FILE
#-----------------------------------------------------------------------------

sub rws_admin_config_file {

	my $loc = "";
	my %form_vars = ();
	my $form_found = 0;

	print "<p>\n<li><b><u>RWSAdmin Config Info</u></b><dir>\n";
	$rwsadmin_cfg = $cfg_dir . 'rwsad5.cfg';
	print "location = $rwsadmin_cfg<br>\n";

	if (-e $rwsadmin_cfg) {
		print "exists = True<br>\n";
		if (-R $rwsadmin_cfg) {
			print "read (real id) = True<br>\n";		
		} else {
			$pi++; $problems .= "<li><a href=#P$pi>Error: RWS requires read access to the admin config file.</a>";
			print "<a name=\"P$pi\"></a>read (real id) = <font color=red>False</font><br>\n";
		};
		if (-W $rwsadmin_cfg) {
			print "write (real id) = True<br>\n";		
		} else {
			$pi++; $problems .= "<li><a href=#P$pi>Error: RWS requires write access to the admin config file.</a>";
			print "<a name=\"P$pi\"></a>write (real id) = <font color=red>False</font><br>\n";
		};
		if (-X $rwsadmin_cfg) {
			$pi++; $problems .= "<li><a href=#P$pi>Warning: The admin config file should NOT have execute permissions.</a>";
			print "<a name=\"P$pi\"></a>execute (real id) = <font color=red>True</font><br>\n";		
		} else {
			print "execute (real id) = False<br>\n";
		};
		print "<br>\n";

		if (open (RWSADMINCFG, "<$rwsadmin_cfg")) {
			print "file read = True<br>\n";
			@rwsadmin_cfg = <RWSADMINCFG>;
			close RWSADMINCFG;

			unlink $rwsadmin_cfg;
			if (!-e $rwsadmin_cfg) {
				print "file delete = True<br>\n";
				if (open (RWSADMINCFG, '>' . $rwsadmin_cfg)) {
					print "file write = True<br>\n";
					print RWSADMINCFG @rwsadmin_cfg;
					close RWSADMINCFG;
				}
				else {
					$pi++; $problems .= "<li><a href=#P$pi>Error: RWS requires write access to the admin config file.</a>";
					print "<a name=\"P$pi\"></a>file write = <font color=red>False</font><br>\n";
				};
			}
			else {
				$pi++; $problems .= "<li><a href=#P$pi>Error: RWS requires delete access to the admin config file.</a>";
				print "<a name=\"P$pi\"></a>file delete = <font color=red>False</font><br>\n";
			};

		}
		else {
			$pi++; $problems .= "<li><a href=#P$pi>Error: RWS requires read access to the admin config file.</a>";
			print "<a name=\"P$pi\"></a>file read = <font color=red>False</font><br>\n";
		};
		print "<br>\n";

		($dev, $ino, $mode, $nlink, $uid, $gid, $rdev, $size, $atime, $mtime, $ctime) = stat($rwsadmin_cfg);
		print "file mode = $mode<br>\n";		
		print "user id = $uid<br>\n";		
		print "group id = $gid<br>\n";		
		print "size = $size<p>\n";

		%defaults = ();

		foreach $rwsadmin_cfg (sort @rwsadmin_cfg) {
			chomp($rwsadmin_cfg);
			#remove the carriage return from the data
			$rwsadmin_cfg =~ s/\r//g;
	
			($hash_key, $hash_val) = split("=", $rwsadmin_cfg);
			$defaults{$hash_key} = $hash_val;

			#store the default form location
			if ($hash_key eq 'Location')
			{
				require rwsutils5;

				$default_form_dir = $hash_val;
				$default_form_dir = &return_full_path($default_form_dir,""); 
			}

			if (($hash_key eq 'Location') && ($form_found == 0) && ($hash_val eq $cgi_dir))
			{
				$pi++; $problems .= "<li><a href=#P$pi>Warning: The default form location is set to the <B>public</B> CGI directory.</a>";
				print "<a name=\"P$pi\"></a><font color=red>$hash_key = $hash_val</font><br>\n";
			}
			elsif($hash_key eq '')
			{
				print "<br>\n";
			}
			elsif($hash_key =~ /\]$/)
			{
				if($hash_key eq '[Forms]')
				{
					$form_found = 1;
				}
				print "$hash_key<br>\n";		
			}
			else {
				
				if ($form_found == 1)
				{
					require rwsutils5;

					$loc = &return_full_path($hash_val,$hash_key . ".cfg");
					print "<form action=\"$script_name\" method=\"post\">\n";
					print "Name=<B>" . $hash_key . "</B><BR>";
	 				print "Location=" . $hash_val . "<BR>";
					if(-e $loc) 
					{
						%form_vars = &read_config($loc,1);
		 				if(($form_vars{'[MISC]'}{'SendSubmissionEmails'} eq '1') || (-e &return_full_path($hash_val,"pause_page.html")) || ($form_configuration{'[MISC]'}{'#RULE0001#'} ne ""))
		 				{
							if ($form_vars{'[MISC]'}{'RecipientAddressList'} ne "")
							{
								print "Email Recipients=<B>" . $form_vars{'[MISC]'}{'RecipientAddressList'} . "</B><br />\n";
								if ($form_vars{'[MISC]'}{'EmailMethod'} eq "SMTP")
								{
									print "<input type=\"HIDDEN\" name=\"CONFIG_DIR\" value=\"$cfg_dir\"></input><input type=\"HIDDEN\" name=\"EMAIL_DETAILS\" value=\"$form_vars{'[MISC]'}{'EmailMethod'}?$form_vars{'[MISC]'}{'RecipientAddressList'}?$form_vars{'[MISC]'}{'AdminAddress'}?RWSTEST EMAIL [$hash_key]?$form_vars{'[MISC]'}{'SMTPServer'}?$form_vars{'[MISC]'}{'PortNumber'}?Automated Test Message: $hash_key?1?$form_vars{'[MISC]'}{'SMTPUsername'}?$form_vars{'[MISC]'}{'SMTPPassword'}\">\n";
								}
								else
								{
									print "<input type=\"HIDDEN\" name=\"CONFIG_DIR\" value=\"$cfg_dir\"></input><input type=\"HIDDEN\" name=\"EMAIL_DETAILS\" value=\"$form_vars{'[MISC]'}{'EmailMethod'}?$form_vars{'[MISC]'}{'SendmailServer'}?$form_vars{'[MISC]'}{'RecipientAddressList'}?$form_vars{'[MISC]'}{'AdminAddress'}?RWSTEST EMAIL [$hash_key]?Automated Test Message: $hash_key\">\n";
								}
		 					}
							else
							{
								print "Email Recipient: <input type=\"text\" name=\"EMAIL_RECIPIENT\"><br />\n";
								if ($form_vars{'[MISC]'}{'EmailMethod'} eq "SMTP")
								{
									print "<input type=\"HIDDEN\" name=\"CONFIG_DIR\" value=\"$cfg_dir\"></input><input type=\"HIDDEN\" name=\"EMAIL_DETAILS\" value=\"$form_vars{'[MISC]'}{'EmailMethod'}?EMAIL_REPLACE?$form_vars{'[MISC]'}{'AdminAddress'}?RWSTEST EMAIL [$hash_key]?$form_vars{'[MISC]'}{'SMTPServer'}?$form_vars{'[MISC]'}{'PortNumber'}?Automated Test Message: $hash_key?1?$form_vars{'[MISC]'}{'SMTPUsername'}?$form_vars{'[MISC]'}{'SMTPPassword'}\">\n";
								}
								else
								{
									print "<input type=\"HIDDEN\" name=\"CONFIG_DIR\" value=\"$cfg_dir\"></input><input type=\"HIDDEN\" name=\"EMAIL_DETAILS\" value=\"$form_vars{'[MISC]'}{'EmailMethod'}?$form_vars{'[MISC]'}{'SendmailServer'}?EMAIL_REPLACE?$form_vars{'[MISC]'}{'AdminAddress'}?RWSTEST EMAIL [$hash_key]?Automated Test Message: $hash_key\">\n";
								}
							}
							print "Email Method=<B>" . $form_vars{'[MISC]'}{'EmailMethod'} . "</B><BR />\n";
							if ($form_vars{'[MISC]'}{'EmailMethod'} eq "SendMail")
							{
								$sendmail_location = $form_configuration{'[MISC]'}{'SendmailServer'};
								if (open(SENDMAIL, "|$sendmail_location -t")) 
								{
									print "SendMail Server Connection=<B>Successful</B><BR />\n";	
								}
								else
								{
									$pi++;
									$problems .= "<li><a href=#P$pi>Warning: Unable to connect to SendMail server at $sendmail_location for form $hash_key.</a>";
									print "<a name=\"P$pi\"></a>SendMail Server Connection=<B><font color=red>Failed</font></B><BR />\n";									
								}
							}
							print "<input type=\"SUBMIT\" value=\"Send Test Email\">\n";
		 				}
		 				print "<BR>";
					}
					print "</form>\n";
				}
				else
				{
					print "$hash_key = $hash_val<br>\n";
				}
			};
		};
		print "</dir>\n";
	}
	else {
		$pi++; $problems .= "<li><a href=#P$pi>Warning: The admin config file does not exist. Note: This is appropriate for a new installation.</a>";
		print "<a name=\"P$pi\"></a>exists = <font color=red>False</font></dir>\n";
	};

};

#-----------------------------------------------------------------------------
# RWS DEFAULT FORM DIRECTORY
#-----------------------------------------------------------------------------

sub rws_default_form_dir 
{
	print "<p>\n<li><b><u>RWS Default Form Directory</u></b><dir>\n";
	print "location = $default_form_dir<br>\n";
	if (-d $default_form_dir) {
		print "exists = True<br>\n";
		if (-R $default_form_dir) {
			print "read (real id) = True<br>\n";		
		} else {
			$pi++; $problems .= "<li><a href=#P$pi>Error: RWS requires read access to the default form directory.</a>";
			print "<a name=\"P$pi\"></a>read (real id) = <font color=red>False</font><br>\n";
		};
		if (-W $default_form_dir) {
			print "write (real id) = True<br>\n";		
		} else {
			$pi++; $problems .= "<li><a href=#P$pi>Error: RWS requires write access to the default form directory.</a>";
			print "<a name=\"P$pi\"></a>write (real id) = <font color=red>False</font><br>\n";
		};
		if (-X $default_form_dir) {
			print "execute (real id) = True<br>\n";		
		} else {
			print "execute (real id) = False<br>\n";
		};
		print "<br>\n";

		$rws_test = $default_form_dir . 'rws5.test';
		if (-e $rws_test) {
			unlink $rws_test;
			if (-e $rws_test) {
				$pi++; $problems .= "<li><a href=#P$pi>Error: RWS requires delete access to the default form directory.</a>";
				print "<a name=\"P$pi\"></a>file delete = <font color=red>False</font><br>\n";
			};
		};

		if (!-e $rws_test) {
			if (open (RWSTEST, ">" . $rws_test)) {
				print "file create = True<br>\n";
				close RWSTEST;
				if (open (RWSTEST, "<" . $rws_test)) {
					print "file read = True<br>\n";
					close RWSTEST;
				} else {
					$pi++; $problems .= "<li><a href=#P$pi>Error: RWS requires file create permissions in the default form directory.</a>";
					print "<a name=\"P$pi\"></a>file read = <font color=red>False</font><br>\n";
				};
				if (open (RWSTEST, ">" . $rws_test)) {
					print "file write = True<br>\n";
					close RWSTEST;
				} else {
					$pi++; $problems .= "<li><a href=#P$pi>Error: RWS requires write access to the default form directory.</a>";
					print "<a name=\"P$pi\"></a>file write = <font color=red>False</font><br>\n";
				};
				
				unlink $rws_test;
				if (-e $rws_test) {
					$pi++; $problems .= "<li><a href=#P$pi>Error: RWS requires delete access to the default form directory.</a>";
					print "<a name=\"P$pi\"></a>file delete = <font color=red>False</font><br>\n";
				} else {
					print "file delete = True<br>\n";
				};
			} else {
				$pi++; $problems .= "<li><a href=#P$pi>Error: RWS requires file create permissions in the default form directory.</a>";
				print "<a name=\"P$pi\"></a>file create = <font color=red>False</font><br>\n";
			};
		};
		print "<br>\n";

		($dev, $ino, $mode, $nlink, $uid, $gid, $rdev, $size, $atime, $mtime, $ctime) = stat($default_form_dir);
		print "file mode = $mode<br>\n";		
		print "user id = $uid<br>\n";		
		print "group id = $gid</dir>\n";		

	} else {
		$pi++; $problems .= "<li><a href=#P$pi>Error: The default form directory does not exist.</a>";
		print "<a name=\"P$pi\"></a>exists = <font color=red>False</font></dir>\n";
	};
}

#-----------------------------------------------------------------------------
# RWS HTML DIRECTORY
#-----------------------------------------------------------------------------

sub rws_html_dir 
{
	if ($cgi_dir =~ /\//)
	{
		$html_dir = $cgi_dir_path . "html/5/";
	}
	else
	{
		$html_dir = $cgi_dir . "html\\5\\";
	}
	print "<p>\n<li><b><u>RWS HTML Directory</u></b><dir>\n";
	print "location = $html_dir <br>\n";
	if (-d $html_dir) {
		print "exists = True<br>\n";
		if (-R $html_dir) {
			print "read (real id) = True<br>\n";		
		} else {
			$pi++; $problems .= "<li><a href=#P$pi>Error: RWS requires read access to the default form directory.</a>";
			print "<a name=\"P$pi\"></a>read (real id) = <font color=red>False</font><br>\n";
		};
		print "<br>\n";

	@pages = ("setup.html", "changepassword.html", "data.html", "diagnostics.html", "edituser.html", "formremove.html", "general.html", "initialchange.html", "login.html", "logo.png", "printstats.html", "stats.html", "timeout.html", "users.html", "webforms.html");
	foreach $page (@pages)
	{
		$full_address = $html_dir . $page;
		print "file = $full_address <br>\n";
		if (open (HTML_FILE, $full_address))
		{
			close(HTML_FILE);
			next;
		}
		else
		{
			$pi++; $problems .= "<li><a href=#P$pi>Error: $page does not exist or does not have read permissions.</a>";
			print "<a name=\"P$pi\"></a>exists = <font color=red>False</font></dir>\n";
		}
	print "<br>\n";
	}		

	} else {
		$pi++; $problems .= "<li><a href=#P$pi>Error: The html directory does not exist.</a>";
		print "<a name=\"P$pi\"></a>exists = <font color=red>False</font></dir>\n";
	};
}

#-----------------------------------------------------------------------------
# PROBLEM REPORT
#-----------------------------------------------------------------------------

sub problem_report {
	print "<p>\n<li><b><u>Problem Report</u></b>\n";
	if (length($problems) > 0) {
		print "<ol>\n";
		print $problems;
		print "</ol>\n";
	} else {
		print "<ul><li>None</li></ul>\n";
	};
};

###---------- Get the current directory and script name ----------
sub get_script_name {
	$cgi_dir = '';
	$script_name = '';
	if (index($0,'\\') != -1) {	#### True if running on Dos/Windows	
		$script_name = substr($0, rindex($0, '\\') + 1);
		$cgi_dir = substr($0, 0, -(length($0) - rindex($0, '\\') - 1));
		$os_type = 'win';
	}
	else {				#### else running on *nix
		$script_name = substr($0, rindex($0, '/') + 1); 
		$cgi_dir = substr($0, 0, -(length($0) - rindex($0, '/') - 1));
		$os_type = 'unix';
	};

	$INC[$#INC + 1] = $cgi_dir;
};

###---------- Send test email ----------
sub send_test_mail {
	
	# Load mail (in the utils) routine
	require rwsutils5;

	my $email_method = $_[0];
	shift(@_);

	if ($email_method eq "SendMail")
	{
		&send_mail(@_);
	}
	else
	{
		# Send test email
		&smtp_mail(@_);
	}
	exit;
};

###---------- Validate an email address ----------
sub check_email 
{
	my $mail_addr = shift;

	if ($mail_addr eq "") {
		return(0);
	}
	elsif ($mail_addr =~ /^[\s]*[\w-.]+\@[\w-]+([\.]{1}[\w-]+)+[\s]*$/ ) {
    		return(1);
	};
	return(0);
};


###---------- Return script version ----------
sub script_version 
{
	my @sf = @_;
	my $line = "";
	my $version = "";

	foreach $line (@sf) {
		if ($line =~ /Version /) {
			$version = substr($line, rindex($line, 'Version ') + 8, 5);
			last;
		};
	};

	return($version);
};

#-----------------------------------------------------------------------------
# RWS MODULE SEARCH
#-----------------------------------------------------------------------------

sub rws_module_search {
	
	#set the local variables	
	my $exporter_mod = "Exporter.pm";
	my $carp_mod = "Carp.pm";
	my $cgi_mod = "CGI.pm";
	my $integer_mod = "integer.pm";
	my $rwsutils_mod = "rwsutils5.pm";
	my $rwsem5_mod = "rwsem5.pm";
	my $socket_mod = "Socket.pm";
	my $strict_mod = "strict.pm";
	my $base64_mod = "MIME/Base64.pm";
	my $hmac_mod = "Digest/HMAC_MD5.pm";
	my $ssl_mod = "IO/Socket/SSL.pm";
	my $ssleay_mod = "Net/SSLeay.pm";
	my $xml_simple = "XML/Simple.pm";
	my $tmp_path = "";
	my $mod_path = "";
	my $current_mod = "";
	my $mod_version = "";
	my $all_failed = "0";		
	my $tmp_msg = "";
	my $link_fail = "0";

	#set an array of modules that are needed
	my @modules = ($exporter_mod,$carp_mod,$cgi_mod,$integer_mod,$rwsutils_mod,$rwsem5_mod,$socket_mod,$strict_mod,$base64_mod,$hmac_mod,$ssl_mod,$ssleay_mod,$xml_simple);

	print "<p>\n<li><b><u>RWS Perl Module Info</u></b><dir>\n";
	
	#add paths to the variable @INC here if needed;
	#push (@INC, $config_dir);

	foreach $current_mod (@modules)
	{
		if ((($current_mod eq $ssl_mod) || ($current_mod eq $ssleay_mod)) && ($USE_STARTTLS == 0))
		{
			next;
		}

		#reset the failure variable
		$all_failed = "0";
		$tmp_msg = "";

		#loop thr each path
		foreach $tmp_path (@INC)
		{
			#construct full path and make sure there is not already a slash at the end of the path
			if (($tmp_path =~ /\//) && !($tmp_path =~ /\/$/))
			{
				$mod_path = $tmp_path . "/" . $current_mod;
			}
			elsif(($tmp_path =~ /\\/) && !($tmp_path =~ /\\$/))
			{
				$mod_path = $tmp_path . "\\" . $current_mod;
			}
			else
			{
				$mod_path = $tmp_path . $current_mod;
			}

			if (-e $mod_path) 
			{	
				$all_failed = "1";

				print "$current_mod location =  $mod_path<br>\n";
				print "exists = True<br>\n";
			
				#write out version information
				$mod_version = &rws_module_version($current_mod);
				if($mod_version eq "0")
				{
					open (RWSMOD, "<$mod_path");
					@rwsmod = <RWSMOD>;
					close RWSMOD;

					$mod_version = &script_version(@rwsmod);
					if (length($mod_version) > 0)
					{
						print "version = $mod_version<br>\n";
					}
					else
					{
						print "version = Unknown<br>\n";
					}
				}
				elsif($mod_version eq "X")
				{
					$link_fail = "1";
					print "<a name=\"P$pi\"></a>version = <font color=red>Unknown</font><br><br>\n";
				}
				else
				{
					print "version = $mod_version<br>\n";
				}
				
				if($link_fail eq "0")
				{
					($dev, $ino, $mode, $nlink, $uid, $gid, $rdev, $size, $atime, $mtime, $ctime) = stat($mod_path);	
					print "size = $size<br><br>\n";
				}

				$link_fail = "0";
			}
			else
			{
				$tmp_msg = $tmp_msg . "$current_mod location =  $mod_path<br>\n";
			}
		}	
		
		#determine if search was a total failure
		if($all_failed eq "0")
		{
			print "$tmp_msg";
			$pi++;
			print "<a name=\"P$pi\"></a>exists = <font color=red>False</font><br><br>\n";
			if ($current_mod eq $base64_mod)
			{
				$problems .= "<li><a href=#P$pi>Warning: Unable to locate the $current_mod. SMTP Authentication will not work.</a>";
			}
			elsif ($current_mod eq $hmac_mod)
			{
				$problems .= "<li><a href=#P$pi>Warning: Unable to locate the $current_mod. The CRAM-MD5 method of SMTP Authentication will not work.</a>";
			}
			elsif (($current_mod eq $ssl_mod) || ($current_mod eq $ssleay_mod))
			{
				$problems .= "<li><a href=#P$pi>Warning: Unable to locate the $current_mod. STARTTLS will not work with SMTP Authentication.</a>";
			}
			else
			{
				$problems .= "<li><a href=#P$pi>Warning: Unable to locate the $current_mod. This could indicate a problem determining the CGI directory.</a>";
			}
		}
	}
	print "</dir>\n";
};

#-----------------------------------------------------------------------------
# RWS MODULE VERSION SEARCH (returns 0 for unknown or version with or without *)
#-----------------------------------------------------------------------------
sub rws_module_version ($mod_name)
{
	my $mod = $_[0];
	my $mod_name = '';	
	my $module_version = "";	

	if ($mod eq "CGI.pm") 
	{
		eval {require CGI};
  		if ($@) 
		{
			$pi++; $problems .= "<li><a href=#P$pi>Error: Unable to create link with CGI Module.</a>";
			$first_line = "<a name=\"P$pi\"></a><font color=red>" . $first_line . "</font>";
			return "X";
		}
		else
		{
			$mod_name = CGI;
			if (defined ($module_version = $mod_name->VERSION()))
			{
				return $module_version;
			}	 
			else
			{
				return "0";
			}
		}
	}
	elsif ($mod eq "integer.pm") 
	{
		eval {require integer};
		if ($@)
		{
			$pi++; $problems .= "<li><a href=#P$pi>Error: Unable to create link with integer Module.</a>";
			$first_line = "<a name=\"P$pi\"></a><font color=red>" . $first_line . "</font>";
			return "X";
		}
		else
		{
			$mod_name = integer;
			if (defined ($module_version = $mod_name->VERSION()))
			{
				return $module_version;
			}	 
			else
			{
				return "0";
			}
		}
	}
	elsif ($mod eq "Socket.pm") 
	{
		eval {require Socket};
		if ($@)
		{
			$pi++; $problems .= "<li><a href=#P$pi>Error: Unable to create link with Socket Module.</a>";
			$first_line = "<a name=\"P$pi\"></a><font color=red>" . $first_line . "</font>";
			return "X";
		}
		else
		{
			$mod_name = Socket;
			if (defined ($module_version = $mod_name->VERSION()))
			{
				return $module_version;
			}	 
			else
			{
				return "0";
			}
		}
	}
	elsif ($mod eq "Exporter.pm") 
	{
		eval {require Exporter};
		if ($@)
		{
			$pi++; $problems .= "<li><a href=#P$pi>Error: Unable to create link with Exporter.</a>";
			$first_line = "<a name=\"P$pi\"></a><font color=red>" . $first_line . "</font>";
			return "X";
		}
		else
		{
			$mod_name = Exporter;
			if (defined ($module_version = $mod_name->VERSION()))
			{
				return $module_version;
			}	 
			else
			{
				return "0";
			}
		}
	}		
	elsif ($mod eq "strict.pm") 
	{
		eval {require strict};
		if ($@)
		{
			$pi++; $problems .= "<li><a href=#P$pi>Error: Unable to create link with strict Module.</a>";
			$first_line = "<a name=\"P$pi\"></a><font color=red>" . $first_line . "</font>";
			return "X";
		}
		else
		{
			$mod_name = strict;
			if (defined ($module_version = $mod_name->VERSION()))
			{
				return $module_version;
			}	 
			else
			{
				return "0";
			}
		}
	}
	elsif ($mod eq "Carp.pm") 
	{
		eval {require Carp};
		if ($@)
		{
			$pi++; $problems .= "<li><a href=#P$pi>Error: Unable to create link with Carp.</a>";
			$first_line = "<a name=\"P$pi\"></a><font color=red>" . $first_line . "</font>";
			return "X";
		}
		else
		{
			$mod_name = Carp;
			if (defined ($module_version = $mod_name->VERSION()))
			{
				return $module_version;
			}	 
			else
			{
				return "0";
			}
		}
	}
	elsif ($mod eq "rwsem5.pm") 
	{
		eval {require rwsem5};
		if ($@)
		{
			$pi++; $problems .= "<li><a href=#P$pi>Error: Unable to create link with rwsem5 Module.</a>";
			$first_line = "<a name=\"P$pi\"></a><font color=red>" . $first_line . "</font>";
			return "X";
		}
		else
		{
			$mod_name = rwsem5;
			if (defined ($module_version = $mod_name->VERSION()))
			{
				return $module_version;
			}	 
			else
			{
				return "0";
			}
		}
	}
	elsif ($mod eq "rwsutils5.pm") 
	{
		eval {require rwsutils5};
		if ($@)
		{
			$pi++; $problems .= "<li><a href=#P$pi>Error: Unable to create link with rwsutils5 Module.</a>";
			$first_line = "<a name=\"P$pi\"></a><font color=red>" . $first_line . "</font>";
			return "X";
		}
		else
		{
			$mod_name = rwsutils5;
			if (defined ($module_version = $mod_name->VERSION()))
			{
				return $module_version;
			}	 
			else
			{
				return "0";
			}
		}
	}
}