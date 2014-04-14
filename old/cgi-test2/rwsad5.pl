#!/usr/local/bin/perl

########################################################################################
# Remark Web Survey Administration Script          Version 5.2.0	               #
# (C) Copyright 2010     http://www.gravic.com/about/copyrght.html                     #
# Gravic, Inc. http://www.gravic.com/ 						       #
########################################################################################
# COPYRIGHT NOTICE                                                           	       #
# (C) Copyright 2010 Gravic, Inc.            	       #
# All Rights Reserved.                  	 		 		       					   #
#										       										   #
# Warning: This program is protected by copyright laws and international               #
# treaties. Unauthorized reproduction or distribution of this program, or              #
# any poriton of it, may result in severe civil and criminal penalties and             #
# will be prosecuted to the maximum extent possible under the law.                     #
########################################################################################

########################################################################################
#             GLOBAL INCLUDE HEADER LIST					       				   	   #
########################################################################################	

#get required dirs
($cgi_dir,$config_dir,$admin_script) = &get_locations();

#add our cgi dir to the INC array
push (@INC,$cgi_dir);

require rwsutils5;
require rwsxml5;
use CGI::Carp qw(fatalsToBrowser);

########################################################################################
#             GLOBAL CONSTANT LIST						       						   #
########################################################################################
$INTERVAL = 10;	
$ALLOWED_FILES = "html|htm|cfg|pwd|jpg|jpeg|gif|png|asf|avi|mov|mp3|mpeg|mpg|ram|rm|swf|wav|wmv|res|resx|rwsx";
$VERSION_NUMBER = "5.2";
$DIAGNOSTIC_MODE = 0;
$LOG_NAME = "RemarkWebSurveyLog.txt";
$MAX_SIZE = 10000000;
########################################################################################
#             GLOBAL STORAGE VARIABLES						       					   #
########################################################################################	
 
#get file locations
$install_config_file = $config_dir . 'rwsad5.cfg';
$rws_config_file = $config_dir . 'rws5.cfg';
$rws_em_file = $config_dir . 'rwsem5.cfg';	

%install_config = ();
%rws_config = ();

$session_uid = "";

########################################################################################
#             MAIN PROCEDURES 							       						   #
########################################################################################

#store the installation config file into a global hash
&get_installation_config_data();

#store the rws config file into a global hash if it exists
if(-e $install_config_file)
{
	%rws_install_config = &read_config($install_config_file,1);
}

if(-e $rws_config_file)
{
	%rws_config = &read_config($rws_config_file,1);
}

#set the log file name
$LOG_NAME = $config_dir . $LOG_NAME;

#Check to see if we are in diagnostic mode
if (($DIAGNOSTIC_MODE == 1) || ($rws_install_config{'[Defaults]'}{"Diagnostic"} eq 1))
{
	#if we are, set the diagnostic flag
	$diagnostic_on = 1;

	#generate a thread_ID
	$thread_ID = &generate_uid;
}

#peform any tasks that were requested (remove, install, update, view)
&perform_form_action();

########################################################################################
# 	FUNCTION THAT WRITES OUT THE RWS CONTROL PANEL 		       		       #	
#	USE: &display_main($NAV); use the 						       	       #		
########################################################################################
sub display_main
{
	my $html_text = "";
	my $tmp_list = "";
	my $htmlfile = "";
	my $NavPage = $_[0]; #Added in 4 in order to break the panel into navigation pages,
	my $form_address = $_[1]; #Added to help display web forms

	#add to the log if in diagnostic mode
	if ($diagnostic_on == 1)
	{
		&write_log($LOG_NAME, $MAX_SIZE, "rwsad5.pl", "display_main", "$NavPage = " . $NavPage . " && form_address = " . $form_address, $thread_ID, 1);
	}

	$temp_var = $rws_config{'[INFO]'}{$session_uid};
	($IP, $time, $permissions, $current_user) = split(/\|/, $temp_var);

	#Determine which page to display.
	if (($permissions != 1) && ($NavPage eq "Password"))
	{
		&display_change_password();
		return 1;		
	}
	elsif(($permissions != 1) && ($NavPage ne "Logout"))
	{
		&display_read_only($permissions);
		return 1;
	}
	elsif ($NavPage eq 'Data') {
		$htmlfile = "html/5/data.html";
		}
	elsif ($NavPage eq 'WebForms') {
		$htmlfile = "html/5/webforms.html";
		}
	elsif ($NavPage eq 'Setup') {
		$htmlfile = "html/5/setup.html";
		}
	elsif ($NavPage eq 'Install') {
		$htmlfile = "html/5/install.html";
		}
	elsif ($NavPage eq 'Password') {
		&display_change_password();
		return 1;
		}
	elsif ($NavPage eq 'Users') {
		$htmlfile = "html/5/users.html";
		}
	elsif ($NavPage eq 'Diagnostics') {
		$htmlfile = "html/5/diagnostics.html";
		}
	elsif ($NavPage eq 'Logout') {
		&remove_admin_info();
		$session_uid = "";
		&logged_out_screen("Session Logout","Details","You have successfully been logged out of the Control Panel.","OK","","DISPLAY_LOGIN!","CENTER");
		return 0;
		}
	else {
		$htmlfile = "html/5/data.html";
		$NavPage = 'Data';
		}

	#open up the external html file
	open (SRC_FILE, $cgi_dir . $htmlfile) || die print "Could not open file $htmlfile";
	
	#read the file into an array 
	@file_data = <SRC_FILE>;

	#close the source file because we are finished reading in the key=value pairs
	close (SRC_FILE);

	#loop thru storing the lines into the variable $html_text
 	foreach $source_lines (@file_data)
 	{	
 		#remove the \n character
 		chop ($source_lines);
		$html_text .=  $source_lines;
		 		
 	}

	#if we have the data page, insert the tabs
	if ($NavPage eq 'Data')
	{
		$tab_html = "<li><a href=\"@*(admin)@*(uid)&NAV=Setup\">Server Setup</a></li><li><a href=\"@*(admin)@*(uid)&NAV=WebForms\">Web Forms</a></li><li><a class=\"selected\">Data & Stats</a></li><li><a href=\"@*(admin)@*(uid)&NAV=Users\">Users</a></li><li><a href=\"@*(admin)@*(uid)&NAV=Password\">Password</a></li><li><a href=\"@*(admin)@*(uid)&NAV=Diagnostics\">Diagnostics</a></li>";
		$html_text =~ s/\@\*\(nav_tabs\)/$tab_html/g;
	} 

	#enter the diagnostics information
	if ($NavPage eq 'Diagnostics')
	{
		$diag_html = &diagnostics();
		$html_text =~ s/\@\*\(diagnostics\)/$diag_html/g;

		$test_script_html = &test_script_output();
		$html_text =~ s/\@\*\(test_script\)/$test_script_html/g;
	}       

	#get html text for the form drop downs
	$tmp_list = &return_form_list();

	#get html text for the form drop downs
	$user_list = &return_user_list();

	#get html text for the web form table
	$form_table_list = &return_form_table();

	#insert the admin script into form '@*()'
	$html_text =~ s/\@\*\(admin\)/$admin_script/g;

	#insert the default location into our form '@*()'
	$html_text =~ s/\@\*\(default_dir\)/$install_config{"[Defaults]"}{"Location"}/g;
	
	#insert the admin email address into our form '@*()'
	#$html_text =~ s/\@\*\(admin_email\)/$install_config{"[Defaults]"}{"AdminEmail"}/g;

	#insert the data script into form '@*()'
	$html_text =~ s/\@\*\(data\)/$form_address/g;
	
	#insert the date for the copyright dynamically into our form'@*()'
	@timeData = localtime(time);
	#the sixth value in the timeData array is the number of years since 1900
	$year_offset = $timeData[5];
	#add 1900 to get correct year
	$year = 1900 + $year_offset; 
	#inserts it into the form
	$html_text =~ s/\@\*\(year\)/$year/g;

	#insert the username
	#unescape out equals and endlines
	$current_user =~ s/\(equals\)/\=/g;
	$current_user =~ s/\(end\)/\n/g;

	use MIME::Base64;	

	#decode the username
	$decoded_user = decode_base64($current_user);

	$html_text =~ s/\@\*\(username\)/$decoded_user/g;

	#if the settings page, add in the values
	if ($htmlfile eq "html/5/setup.html")
	{

		#insert the image script into form '@*()'
		$html_text =~ s/\@\*\(img_script\)/$install_config{"[Defaults]"}{"ImageScript"}/g;

		#check/uncheck the enable auto download/upload feature in our form '@*()'
		if($install_config{"[Defaults]"}{"EnableAutoUpload"} eq 0)
		{
			$html_text =~ s/\@\*\(enable_auto_upload\)//g;
		}
		else
		{
		 	$html_text =~ s/\@\*\(enable_auto_upload\)/CHECKED/g;
		}
		#check/uncheck the enable auto download/upload feature in our form '@*()'
		if($install_config{"[Defaults]"}{"EnableAutoDownload"} eq 0)
		{
			$html_text =~ s/\@\*\(enable_auto_download\)//g;
		}
		else
		{
	 		$html_text =~ s/\@\*\(enable_auto_download\)/CHECKED/g;
		}
		#check/uncheck the use cgi redirect feature in our form '@*()'
		if($install_config{"[Defaults]"}{"CGIRedirect"} eq 0)
		{
			$html_text =~ s/\@\*\(cgi_redirection\)//g;
		}
		else
		{
	 		$html_text =~ s/\@\*\(cgi_redirection\)/CHECKED/g;
		}

		#check/uncheck the enable auto download/upload feature in our form '@*()'
		if($install_config{"[Defaults]"}{"BackUpData"} eq 0)
		{
			$html_text =~ s/\@\*\(auto_backup\)//g;
		}
		else
		{
	 		$html_text =~ s/\@\*\(auto_backup\)/CHECKED/g;
		}

		#set up the use local IP settings
		if($install_config{'[Defaults]'}{'LocalIP'} ne "")
		{
			$html_text =~ s/\@\*\(use_local_ip\)/CHECKED/g;
			$html_text =~ s/\@\*\(local_ip\)/$install_config{"[Defaults]"}{"LocalIP"}/g;
		}
		else
		{
			$html_text =~ s/\@\*\(use_local_ip\)//g;
			$html_text =~ s/\@\*\(local_ip\)//g;
		}

		#check/uncheck the enable auto download/upload feature in our form '@*()'
		if($install_config{"[Defaults]"}{"Diagnostic"} ne 1)
		{
			$html_text =~ s/\@\*\(diagnostic_mode\)//g;
		}
		else
		{
	 		$html_text =~ s/\@\*\(diagnostic_mode\)/CHECKED/g;
		}

	}

	#check/uncheck the remove server files feature in our form '@*()'
	if($install_config{"[Defaults]"}{"RemoveServerFiles"} eq 0)
	{
		$html_text =~ s/\@\*\(remove_server\)//g;
	}
	else
	{
	 	$html_text =~ s/\@\*\(remove_server\)/CHECKED/g;
	}
	#check/uncheck the logging feature in our form '@*()'
	if($install_config{"[Defaults]"}{"Logging"} eq 0)
	{
		$html_text =~ s/\@\*\(logging\)//g;
	}
	else
	{
	 	$html_text =~ s/\@\*\(logging\)/CHECKED/g;
	}
	#insert the form lists into our form '@*()'
	$html_text =~ s/\@\*\(form_list\)/$tmp_list/g;

	#insert the form table into our form '@*()'
	$html_text =~ s/\@\*\(form_table\)/$form_table_list/g;

	#insert the form lists into our form '@*()'
	$html_text =~ s/\@\*\(user_list\)/$user_list/g;
	
	#insert the uid into our form '@*()'
	if($session_uid ne "")
	{
		$html_text =~ s/\@\*\(uid\)/\?UID\=$session_uid/g;
	}
	else
	{
		$html_text =~ s/\@\*\(uid\)//g;
	}

	#insert the uid into our get forms '@*()'
	if($session_uid ne "")
	{
		$html_text =~ s/\@\*\(uid\_get\)/$session_uid/g;
	}
	else
	{
		$html_text =~ s/\@\*\(uid\_get\)//g;
	}

	#if this is the data screen, insert the administrative options
	$button_html = "<tr>	<td>&nbsp;</td>        <td><input type=\"button\" id=\"DOWNLOAD_DATA2\" name=\"DOWNLOAD_DATA2\" value=\"Download Data\" onclick=\"validate('DOWNLOAD');\" style=\"width: 144px\" /></td>        <td><input type=\"button\" id=\"INCOMPLETE_DATA\" name=\"INCOMPLETE_DATA\" value=\"Incomplete Data\" onclick=\"validate('INCOMPLETE');\" style=\"width: 144px\" /></td>    </tr>    <tr>    	<td>&nbsp;</td>        <td>&nbsp;</td>              <td><input type=\"button\" id=\"RESET_DATA\" name=\"RESET_DATA\" value=\"Reset Data\" onclick=\"validate('RESET');\" style=\"width: 144px\" /></td>    </tr>";
	$html_text =~ s/\@\*\(admin_buttons\)/$button_html/g;

	#if this is the data screen, replace the dynamic data screen description text
	$html_text =~ s/\@\*\(stats_permissions_description\)/view live online statistics\, download or view the data\, download data from respondents who have not yet completed the web form or reset the data for a web form/g;

	#insert the images cript in to display the logo
	#if the defined default exists, use that
	if (-e $install_config{"[Defaults]"}{"ImageScript"})
	{
		$html_text =~ s/\@\*\(img\)/$install_config{"[Defaults]"}{"ImageScript"}\?ADMIN\=1/g;  
	}
	#if not, check for rwsimg5.pl and use that
	elsif (-e $config_dir . 'rwsimg5.pl')
	{
		$html_text =~ s/\@\*\(img\)/rwsimg5\.pl\?ADMIN\=1/g;  
	}
	#if not, check for rwsimg5.cgi and use that
	elsif (-e $config_dir . 'rwsimg5.cgi')
	{
		$html_text =~ s/\@\*\(img\)/rwsimg5\.cgi\?ADMIN\=1/g;  
	}
	#if not, check for rwsimg5.plx and use that
	elsif (-e $config_dir . 'rwsimg5.plx')
	{
		$html_text =~ s/\@\*\(img\)/rwsimg5\.plx\?ADMIN\=1/g;  
	}
	#otherwise, get rid of the image tag altogether
	else
	{
		$html_text =~ s/\<img .*?src\=\"\@\*\(img\).*?\/\>//g;
	}
											   
	&display_html($html_text);

	#add to the log if in diagnostic mode
	if ($diagnostic_on == 1)
	{
		&write_log($LOG_NAME, $MAX_SIZE, "rwsad5.pl", "display_main", "None", $thread_ID, 0);
	}

	return 1;
}

########################################################################################
# 	FUNCTION PERFORMS THE ACTION OF THE FORM 		       		       				   #	
#	USE: &perform_form_action();					       	       					   #		
########################################################################################
sub perform_form_action
{
	my %submitted_data = ();
	my $key = "";
	my $action = "";
	my $form_name = "";
	my $entered_password = "";
	my $new_password = "";
	my $admin_email = "";
	my $default_location = "";
	my $enable_auto_upload = "0";
	my $enable_auto_download = "0";
	my $cgi_redirect = "0";
	my $logging = "0";
	my $time = "";
	my $query_id = "";
	my $tmp_str = "";
	my $info_index = 0;
	my $form_existed = 0;
	my $remove_server = 0;
	my $image_script = "";
	my $data_file = "";
	my $archive_file = "";
	my $back_location = "";
	my $data_lines = "";
	my $num_records = 0;
	my $cgi = "";
	my $valid_location = 0;
	my $permissions = "";
	my $whole_file = "";
	my $download_info = "";
	my @records = ();
	my $temp_size = 0;
	my $multi = 0;
	my $designer = 0;
				 
	#if a GET then check for UID, if valid UID navigate to page, otherwise display login
	if($ENV{'REQUEST_METHOD'} eq 'GET')
	{
		#determine if they are trying to download
		$download_info = &get_query_parameter('DOWNLOADTYPE');

		#add to the log if in diagnostic mode
		if ($diagnostic_on == 1)
		{
			&write_log($LOG_NAME, $MAX_SIZE, "rwsad5.pl", "perform_form_action", "$download_info = " . $download_info, $thread_ID, 1);
		}
		
		if($download_info ne '')
		{
			#get the sessionid and whether or not it is the designer			
			$session_uid = &get_query_parameter('UID');
			$designer = &get_query_parameter('DESIGNER');
			
			#designer variable only passed through the web input
			if ($designer != 0) 
			{
				$designer = 1;
			}

			if(&valid_session_time($designer) ne '1')
 			{
 			   	return 1;
			   	last;
 			 }

			#download log file
			if($download_info eq 'LOG')
			{
				&download_log(&get_query_parameter('FORMNAME'));
			}
			elsif($download_info eq 'DATA')
			{
				&download_data(&get_query_parameter('FORMNAME'));
			}
			elsif($download_info eq 'ALL')
			{
				$data_file = &get_query_parameter('DATANAME');
				$data_file =~ s/%20/ /g;

				#get the data file name
				$back_location = &return_full_path($install_config{'[Forms]'}{&get_query_parameter('FORMNAME')},$data_file);
							
				#construct the data file and archive file names				
				$data_file = $back_location . '.rwd';
				$archive_file = $back_location . '.rwa';
					
				#if there is data, return the archive file
			   	if(&archive_data($data_file,$archive_file))
			   	{
					if(open (DATAMAIN, "<$archive_file"))
					{
						#read the file into an array and close handle 
						@records=<DATAMAIN>;
						close (DATAMAIN);

						print "Content-type: application/octet-stream\n";
						print "Content-disposition: attachment; filename=$archive_file\n\n";
						print @records;
					}
					else
					{
						#error attempting to open data file
						&display_html('records?' . "-1|");
					}
					exit;	
			   	}
			   	exit;		
			}
			elsif($download_info eq 'NEW')
			{
				#get the data file name
				$back_location = &return_full_path($install_config{'[Forms]'}{&get_query_parameter('FORMNAME')},&get_query_parameter('DATANAME'));
							
				#construct the data file and archive file names				
				$data_file = $back_location . '.rwd';
				$archive_file = $back_location . '.rwa';
				
				#if there is new data, return the NEW data file
			   	if(-e $data_file)
			   	{
					if(open (DATAMAIN, "<$data_file"))
					{
						#read the file into an array and close the handle
						@records=<DATAMAIN>;
						close (DATAMAIN);

						print "Content-type: application/octet-stream\n";
						print "Content-disposition: attachment; filename=$data_file\n\n";
						print @records;

						#archive the data
						&archive_data($data_file,$archive_file);
					}
					else
					{
						#error attempting to open data file
						&display_html('records?' . "-1|");
					}
					exit;
			   	} 
			}

			#if someone is downloading the incomplete data
			elsif($download_info eq 'INCOMPLETE')
			{
				#get the form name
				$form_name = &get_query_parameter('FORMNAME');

				#if this is the web interface, generate the incomplete data file
				if ($designer eq "0")
				{
					#start the generating process
					&generate_incomplete($form_name);
				}

				#get the data path
				$back_location = &return_full_path($install_config{'[Forms]'}{$form_name});

				#set the data file and location
				$data_file = $form_name . "-incomplete\.rwd";
				$data_file_location = $back_location . $data_file;
				$data_lck_file_location = $data_file_location;
				$data_lck_file_location =~ s/\.rwd/-downloaded\.lck/;
				
				#if there is incomplete data, return the incomplete data file
			   	if(-e $data_file_location)
			   	{
					if(open (DATAMAIN, "<$data_file_location"))
					{
						#read the file into an array and close the handle
						@records=<DATAMAIN>;
						close (DATAMAIN);

						print "Content-type: application/octet-stream\n";
						print "Content-disposition: attachment; filename=$data_file\n\n";
						print @records;

						#COMMENTED OUT IN RWS 5.2 - We now leave the incomplete data file on the server to check to see if it is fresh or not upon request.
						#unlink($data_file_location);

						#create the lock file
						if (open(LOCKFILE, "<$data_lck_file_location")) 
						{
							close (LOCKFILE);
						}
					}
					else
					{
						#if this is the web interface, load a web page
						if ($designer eq "0")
						{
							&general_admin_screen("No Incomplete Data","Details","No incomplete data exists for the " . $form_name . " form.","OK","","MAIN!","CENTER","Data");
							return 1;
						}
						#otherwise return -1
						else
						{
							#error attempting to open data file
							&display_html('records?' . "-1|");
						}
					}
			   	} 
				else
				{
					#if this is the web interface, load a web page
					if ($designer eq "0")
					{
						&general_admin_screen("No Incomplete Data","Details","No incomplete data exists for the " . $form_name . " form.","OK","","MAIN!","CENTER","Data");
						return 1;
					}
					#otherwise return -1
					else
					{
						#error attempting to open data file
						&display_html('records?' . "-1|");
					}
				}
				exit;
			}	
		}
   		else
		{
			#Stores the session_id on a get
			$session_uid = &get_query_parameter('UID');

			#Stores the navigation page on a get
			$Page = &get_query_parameter('NAV');

			#Validates the session id if there is one, otherwise displays login
			if ($session_uid ne "")
			{
				if(&valid_session_time($designer) eq '1')
			   	{
				&display_main($Page);
				return 1;
 			   	}
				else
				{
				#invalid session page is displayed in the &valid_session_time function, so just return 1 to end the function
				return 1;
				}
				
			}				
			if ((-e $rws_config_file) && (-e $rws_em_file))
			{
				&display_login_page();
				return 1;
			}
			else
			{
				&display_change_password();
				return 1;
			}
		}
	}
	else
	{
		if($install_config{'[Defaults]'}{'EnableAutoUpload'} eq '1')
		{
			require CGI;

			# Force the temporary files directory to cgi_directory
			$CGITempFile::TMPDIRECTORY = $cgi_dir;

			$cgi = new CGI;

			%submitted_data = &store_cgi_data($cgi);
		}
		else
		{
			%submitted_data = &store_post_data();
		}
	}

	#determine the source of the call operation
	if (defined $submitted_data{'DESIGNER'})
	{
		if($submitted_data{'DESIGNER'} eq '1')
		{
			$designer = 1;
		}
	}

	#store the session ID
   	if($session_uid eq "")
   	{
   		$session_uid = &get_query_parameter('UID');
   	}

   	#convert form name to lower case	 	
  	$submitted_data{'FORMNAME'} = lc($submitted_data{'FORMNAME'});

	#loop thru the submitted data searching for the action
	foreach $key (keys %submitted_data)
	{

		#if the key equals file (needed for new designer upload call)
		if($key eq 'file')
		{
			#get the UTYPE and UID from the query parameter
			$upload_type = &get_query_parameter('UTYPE');
			$session_uid = &get_query_parameter('UID');

			#validate the session to make sure it is not logged out
			if(&valid_session_time('1') ne '1')
 			   	{
 			   		return 1;
			   		last;
 			   	}

			#if text, run upload_text
			if ($upload_type eq 'TEXT')
			{
				$data_lines = &upload_text($submitted_data{'file'},&get_query_parameter('FORMNAME'),&get_query_parameter('APPEND'));
				close ($submitted_data{'file'});
				&display_html($data_lines);
				exit;
			}

			#if image, run upload_image
			elsif ($upload_type eq 'IMAGE')
			{
				$data_lines = &upload_image($submitted_data{'file'},&get_query_parameter('FORMNAME'));
				close ($submitted_data{'file'});
				sleep(2);
				&display_html($data_lines);
				exit;
			}
		}	

	   	if($key eq 'FORM_ACTION')
		{
			#split the lines 'key=value' into (key, value) pairs
			($action, $form_name) = split (/\!/, $submitted_data{$key}, 2);

			#add to the log if in diagnostic mode
			if ($diagnostic_on == 1)
			{
				&write_log($LOG_NAME, $MAX_SIZE, "rwsad5.pl", "perform_form_action", "action = " . $action . " && form_name = " . $form_name, $thread_ID, 1);
			}

			#convert form name to lower case as long as not changing password then $form_name = new password
			if(($action ne 'CHANGE_PASSWORD') && ($action ne 'UPDATE') && ($action ne 'SMTP_TEST_EMAIL') && ($action ne 'EDIT_USER')) 
			{
				$form_name = lc($form_name);
			}

			#if the form name is blank, use the submitted_data formname key
			if ($form_name eq "")
			{
				$form_name = $submitted_data{'FORMNAME'};
			}

			#make sure that the session has not timed out
		   	if((substr($action,0,5) ne 'LOGIN') && ($action ne 'DISPLAY_LOGIN') && ($action ne 'CHANGE_PASSWORD'))
 			{
				if(&valid_session_time($designer) ne '1')
 			   	{
 			   		return 1;
			   		last;
 			   	}
 			}
			if($action eq 'UPLOAD_CREATE_FORM_DIR')
			{
				#create the new form directory
				&create_cgi_directory_upload($form_name,0700);
				return 1;
				last;
			}

			elsif($action eq 'AUTO_UPLOAD_ENABLED')
			{
				if($install_config{"[Defaults]"}{"EnableAutoUpload"} eq '1')
			  	{
					($IP, $time, $permissions, $username) = split(/\|/, $rws_config{'[INFO]'}{$session_uid});

					if ($permissions == 1)
					{
						&display_html("auto_upload_enabled=1");
					}
					else
					{
						($permission_level, $forms_access) = split(/\!/, $permissions);
						($overall_permissions, $upload, $download) = split(/\>/, $permission_level);

						if ($upload == 1)
						{
							&display_html("auto_upload_enabled=1");
						}
						else
						{
			  				&display_html("auto_upload_enabled=-1");
						}
					}
				}
				else
				{
					&display_html("auto_upload_enabled=0");
				}
				exit;	
			}
			elsif($action eq 'AUTO_DOWNLOAD_ENABLED')
			{
				if($install_config{"[Defaults]"}{"EnableAutoDownload"} eq '1')
			  	{
					($IP, $time, $permissions, $username) = split(/\|/, $rws_config{'[INFO]'}{$session_uid});

					if ($permissions == 1)
					{
						&display_html("auto_download_enabled=1");
					}
					else
					{
						($permission_level, $forms_access) = split(/\!/, $permissions);
						($overall_permissions, $upload, $download) = split(/\>/, $permission_level);

						if ($download == 1)
						{
							&display_html("auto_download_enabled=1");
						}
						else
						{
			  				&display_html("auto_download_enabled=-1");
						}
					}
				}
				else
				{
					&display_html("auto_download_enabled=0");
				}
				exit;	
			}
			elsif($action eq 'LOGOUT')
			{
				&remove_admin_info();
				$session_uid = "";
				&logged_out_screen("Session Logout","Details","You have successfully been logged out of the Control Panel.","OK","","DISPLAY_LOGIN!","CENTER");
			}
			elsif($action eq 'UPLOAD_REMOVE_DIR_FILES')
			{
				#delete the form directory
				&remove_directory_files_upload($form_name,$submitted_data{'REMOVE_DATA'});
				return 1;
				last;
			}
			elsif($action eq 'MAIN')
			{
				#delete the form directory
				&display_main;
				exit;
 			}
			elsif($action eq 'ACCESS_FORM')
			{
				#locate the directory for the form
				$form_config_dir = &return_full_path($install_config{'[Forms]'}{$form_name});

				#get the config file name
				$base_config_file = $form_name . '.cfg';
				$base_config_file = &convert_string($base_config_file);

				#get the full form config file path on the server
				$form_config_file = &return_full_path($form_config_dir,$base_config_file);

				#read the form configuration into the hash
				%form_configuration = &read_config($form_config_file,1);	

				#get the data script location from the config file
				$data_script_location = $form_configuration{'[MISC]'}{'DataScript'};

				$form_address = $data_script_location . "\?FORM\=" . $form_name;

				&display_main('WebForms', $form_address);
					
			}
			elsif($action eq 'ACCESS_TEST_SCRIPT')
			{
				&display_main('Diagnostics', $form_name);
			}
			elsif($action eq 'DATAPRESENT')
			{
				$form_allowed = 0;

				($IP, $time, $permissions, $username) = split(/\|/, $rws_config{'[INFO]'}{$session_uid});

				if ($permissions == 1)
				{
					$form_allowed = 1;
				}
				else
				{
					($permission_level, $forms_access) = split(/\!/, $permissions);
					if ($forms_access eq "*ALLFORMS*")
					{
						$form_allowed = 1;
					}
					else
					{
						@forms = split(/\>/, $forms_access);
						foreach $form_permissions (@forms)
						{
							if ($form_permissions eq $submitted_data{'FORMNAME'})
							{
								$form_allowed = 1;
							}
						}
					}
				}
	
				if ($form_allowed == 0)
				{
					&display_html("records=-1");
					exit;
				}

				#get the data file name
				$back_location = &return_full_path($install_config{'[Forms]'}{$submitted_data{'FORMNAME'}},$submitted_data{'DATANAME'});
							
				#construct the data file and archive file names				
				$data_file = $back_location . '.rwd';
				$archive_file = $back_location . '.rwa';

				if($submitted_data{'DOWNLOADTYPE'} eq 'INCOMPLETE')
				{
					#get the form name
					$form_name = $submitted_data{'FORMNAME'};

					#get the data path
					$back_location = &return_full_path($install_config{'[Forms]'}{$form_name});

					#get the config file name
					$base_config_file = $form_name . '.cfg';
					$base_config_file = &convert_string($base_config_file);

					#get the full form config file path on the server
					$form_config_file = &return_full_path($back_location,$base_config_file);

					#read the form configuration into the hash
					%form_configuration = &read_config($form_config_file,1);

					#open the form directory
					opendir (FORMDIR, $back_location);
							
					#build an array with all of the form names in them			
					@uid_files = readdir(FORMDIR);

					#close the form directory
					closedir (FORMDIR);

					#for each file in the directory
					foreach $incomplete_form (@uid_files)
					{
						#if it is not a UID file, skip
						if ($incomplete_form !~ /(\S.*)\.uid$/)
						{
							next;
						}

						#get the UID from the file name
						$incomplete_uid = $1;

						#set the complete path of the UID file
						$uid_file = $back_location . $incomplete_form;

						#if the uid file exists read it into global hash
						if(-e $uid_file)
						{
							%form_uid = &read_config($uid_file,1);
						}

						#check to see if there is incomplete data
						if (&check_incomplete_records($back_location) eq "1")
						{
							#if there is, return records=1
							&display_html("records=1");
							exit;
						}
					}

					#if there is no incomplete data, return records=0
					&display_html("records=0");
					exit;
				}
				elsif(!(-e $data_file) && (!(-e $archive_file))) 
				{
					&display_html("records=0");
				}
				elsif($submitted_data{'DOWNLOADTYPE'} eq 'ALL')
				{
					#if the data file exists get the size
					if(-e $data_file)
					{
						$temp_size = (-s $data_file);
					}

					#if the archive file exists get the size and add it to what we have
					if(-e $archive_file)
					{
						$temp_size += (-s $archive_file);
					}
					 
					&display_html("records=" . $temp_size);
				}
				elsif($submitted_data{'DOWNLOADTYPE'} eq 'NEW')
				{
					#if the data file exists get the size
					if(-e $data_file)
					{
						$temp_size = (-s $data_file);
					}
					&display_html("records=" . $temp_size);
				}
				exit;
			}
			elsif($action eq 'DOWNLOAD_ARCHIVE_DATA')
			{
				#get the data file name
				$back_location = &return_full_path($install_config{'[Forms]'}{$submitted_data{'FORMNAME'}},$submitted_data{'DATANAME'});
							
				#construct the data file and archive file names				
				$data_file = $back_location . '.rwd';
				$archive_file = $back_location . '.rwa';

				#archive the data
			   	&archive_data($data_file,$archive_file);

				&display_html('archive=1');
				exit;
			}
	  		elsif($action eq 'UPDATE')
			{
				#split the lines to get default_dir,email, and enable auto up/downloads
				($default_location,$enable_auto_upload,$cgi_redirect,$enable_auto_download,$logging,$image_script,$enable_autobackup,$local_ip,$diagnostic_mode) = split (/\>/, $form_name);

				#validate the default location
				$default_location = &validate_directory($default_location);
				
				#validate the image script
				$image_script = &validate_input($image_script);

				if($install_config{"[Defaults]"}{"ImageScript"} ne $image_script)
				{
					$install_config{"[Defaults]"}{"ImageScript"} = $image_script;
					$multi++;
				}

				#make sure there is a trailing slash at the end of the path
				$default_location = &return_full_path($default_location,"");

				if($install_config{"[Defaults]"}{"Location"} ne $default_location)
				{
					#validate the requested default location
					if(-d $default_location)
					{
						$valid_location = 1;
						if(!(-r $default_location))
						{
							$permissions .= "(read)";
						}
						if(!(-w $default_location))
						{
							$permissions .= "(write)";
						}
						if(!(-x $default_location))
						{
							$permissions .= "(execute)";
						}
						if ($permissions eq "")
						{
							$install_config{"[Defaults]"}{"Location"} = $default_location;
						} 
					}
					$multi++;
				}
				else
				{
					$valid_location = 1;
				}
				  
				if($enable_auto_upload eq 'true')
				{
					if($install_config{"[Defaults]"}{"EnableAutoUpload"} ne '1')
					{
						$install_config{"[Defaults]"}{"EnableAutoUpload"} = '1';	
						$multi++;
					}
				}
				else
				{
					if($install_config{"[Defaults]"}{"EnableAutoUpload"} ne '0')
					{
						$install_config{"[Defaults]"}{"EnableAutoUpload"} = '0';
						$multi++;
					}
				}

				if($cgi_redirect eq 'true')
				{
					if($install_config{"[Defaults]"}{"CGIRedirect"} ne '1')
					{
						$install_config{"[Defaults]"}{"CGIRedirect"} = '1';	
						$multi++;
					}
				}
				else
				{
					if($install_config{"[Defaults]"}{"CGIRedirect"} ne '0')
					{
						$install_config{"[Defaults]"}{"CGIRedirect"} = '0';
						$multi++;
					}
				}

	  			if($enable_auto_download eq 'true')
				{
					if($install_config{"[Defaults]"}{"EnableAutoDownload"} ne '1')
					{
						$install_config{"[Defaults]"}{"EnableAutoDownload"} = '1';	
						$multi++;
					}
				}
				else
				{
					if($install_config{"[Defaults]"}{"EnableAutoDownload"} ne '0')
					{
						$install_config{"[Defaults]"}{"EnableAutoDownload"} = '0';
						$multi++;
					}
				}
				if($logging eq 'true')
				{
					if($install_config{"[Defaults]"}{"Logging"} ne '1')
					{
						$install_config{"[Defaults]"}{"Logging"} = '1';	
						$multi++;
					}
				}
				else
				{
					if($install_config{"[Defaults]"}{"Logging"} ne '0')
					{
						$install_config{"[Defaults]"}{"Logging"} = '0';
						$multi++;
					}
				}
				if($enable_autobackup eq 'true')
				{
					if($install_config{"[Defaults]"}{"BackUpData"} ne '1')
					{
						$install_config{"[Defaults]"}{"BackUpData"} = '1';	
						$multi++;
					}
				}
				else
				{
					if($install_config{"[Defaults]"}{"BackUpData"} ne '0')
					{
						$install_config{"[Defaults]"}{"BackUpData"} = '0';
						$multi++;
					}
				}
				if($diagnostic_mode eq 'true')
				{
					if($install_config{"[Defaults]"}{"Diagnostic"} ne '1')
					{
						$install_config{"[Defaults]"}{"Diagnostic"} = '1';	
						$multi++;
					}
				}
				else
				{
					if($install_config{"[Defaults]"}{"Diagnostic"} ne '0')
					{
						$install_config{"[Defaults]"}{"Diagnostic"} = '0';
						$multi++;
					}
				}

				#if the local_ip value is different, add it to our settings
				if($install_config{"[Defaults]"}{"LocalIP"} ne $local_ip)
				{
					$install_config{"[Defaults]"}{"LocalIP"} = $local_ip;
					$multi++;
				}

				#rewrite out the installation config file with the element removed
				&write_config (\%install_config,$install_config_file,1);

				#make sure that the default location exists first
				if($valid_location == 1)
				{
					if($permissions eq "")
					{
						&general_admin_screen("Update Settings","Details","The settings of the administration control panel have been successfully updated.","OK","","MAIN!","CENTER","Setup");
					}
					elsif($multi > 1)
					{
						&general_admin_screen("Update Settings","Details","The settings of the administration control panel have been successfully updated.<BR>&nbsp;<BR><B>Note:</B> The default location specified, <I>" . $default_location . "</I>, does not have the required permissions! This directory needs - " . $permissions . " - permissions to be added.","OK","","MAIN!","CENTER","Setup");
					}
					else
					{
						&general_admin_screen("Update Settings","Details","The settings of the administration control panel were <B>not</B> updated.<BR>&nbsp;<BR><B>Note:</B> The default location specified, <I>" . $default_location . "</I>, does not have the required permissions! This directory needs - " . $permissions . " - permissions to be added.","OK","","MAIN!","CENTER","Setup");
					}
				}
				elsif($multi > 1)
				{
					&general_admin_screen("Update Settings","Details","The settings of the administration control panel have been successfully updated.<BR>&nbsp;<BR><B>Note:</B> The default location specified, <I>" . $default_location . "</I>, does not exist! This value cannot be updated.","OK","","MAIN!","CENTER","Setup");
				}
				else
				{
					&general_admin_screen("Update Settings","Details","The settings of the administration control panel were <B>not</B> updated.<BR>&nbsp;<BR><B>Note:</B> The default location specified, <I>" . $default_location . "</I>, does not exist! This value cannot be updated.","OK","","MAIN!","CENTER","Setup");
				}
			}
			elsif($action eq 'INSTALL')
			{	
				if(exists $install_config{'[Forms]'}{$form_name})
				{
					$form_existed = 1;
				}
				
				#make sure that all the files are there that are needed
				if(&valid_form($form_name,$submitted_data{'DESIGNER'}) == 1)
				{
					&add_form($form_name);

					#check to see if we have a restricted user
					($IP, $time, $permissions, $username) = split(/\|/, $rws_config{'[INFO]'}{$session_uid});

					#if so, we have to add this form to their list of permissions
					if (($permissions != 1) && ($permissions !~ /\*ALLFORMS\*/))
					{
						#check to make sure the permissions hasn't already been added (updating existing form)
						if ($permissions !~ /$form_name\>/)
						{
							#add it to the username entry
							$rws_config{'[USER]'}{$username} .= $form_name . ">";

							#split off the forms list
							($permissions_level, $forms_list) = split(/\!/, $rws_config{'[USER]'}{$username});

							#put the list of forms in an array
							@forms_array = split(/\>/, $forms_list);

							#start an ordered form list variable
							$ordered_form_list = "";

							#sort the forms in alphabetical order and add them to the ordered variable
							foreach $temp_form (sort @forms_array)
							{
								$ordered_form_list .= $temp_form . ">";								
							}

							#set the [USER] entry
							$rws_config{'[USER]'}{$username} = $permissions_level . "!" . $ordered_form_list;

							#grab the info level for the [INFO] entry
							($info_levels, $info_forms) = split(/\!/, $permissions);

							#replace the form list with the ordered form list
							$new_permissions = $info_levels . "!" . $ordered_form_list;						

							#recombine the config entry
							$rws_config{'[INFO]'}{$session_uid} = $IP . "|" . $time . "|" . $new_permissions . "|" . $username;

							#write out the new rws config file with the permissions
							&write_config(\%rws_config,$rws_config_file,1);
						}
					}
					
					#display appropriate message for install vs update
					if($submitted_data{'DESIGNER'} ne '1')
					{
						if($form_existed == 0)
						{
							&general_admin_screen("Form Installation","Details","The <B>$form_name</B> Form has been successfully installed.","OK","","MAIN!","CENTER","WebForms");
						}
						else
						{
							&general_admin_screen("Form Update","Details","The <B>$form_name</B> Form has been successfully updated.","OK","","MAIN!","CENTER","WebForms");
						}
					}
					else
					{
						&display_html("install=1");
		  				exit;
  					}
				}
				else
				{
					&display_html("install=0");
	  				exit;
				}
			}
			elsif($action eq 'REMOVE')
			{
				#store the value of the remove server files checkbox
				if(exists $submitted_data{'REMOVE_SERVER'})
				{
					$install_config{"[Defaults]"}{"RemoveServerFiles"} = '1';
				}
				else
				{
					$install_config{"[Defaults]"}{"RemoveServerFiles"} = '0';
				}
				#update the config file with the saved value for removing server files
				&write_config (\%install_config,$install_config_file,1);

				if($install_config{"[Defaults]"}{"RemoveServerFiles"} eq '1')
				{
					&form_remove_screen("Remove Form","Confirmation","Are you sure you want to remove the <B>$form_name</B> Form and <B>ALL</B> associated files?<DIR>","Yes","No","REMOVE_CONFIRMED!$form_name","RIGHT",$form_name);
				}
				else
				{
  					&form_remove_screen("Remove Form","Confirmation","Are you sure you want to remove the <B>$form_name</B> Form?","Yes","No","REMOVE_CONFIRMED!$form_name","RIGHT",$form_name);
				}
			}
			elsif($action eq 'REMOVE_CONFIRMED')
			{
				&remove_form($form_name);

				#check to see if any restricted users have the form added as a permission
				foreach $user_name (keys %{$rws_config{'[USER]'}})
				{
					#if so, remove them
					$rws_config{'[USER]'}{$user_name} =~ s/$form_name\>//g;
				}

				#check to see if any currently logged in sessions have the form added as a permssion
				foreach $hash (keys %{$rws_config{'[INFO]'}})
				{
					#if so, remove them
					$rws_config{'[INFO]'}{$hash} =~ s/$form_name\>//g;
				}

				#write out the new rws config file with the removed permissions
				&write_config(\%rws_config,$rws_config_file,1);

				if($install_config{"[Defaults]"}{"RemoveServerFiles"} eq '1')
				{
					&general_admin_screen("Remove Form","Details","The <B>$form_name</B> Form and all associated files have successfully been removed.","OK","","MAIN!","CENTER","WebForms");
				}
				else
				{
					&general_admin_screen("Remove Form","Details","The <B>$form_name</B> Form has been successfully removed.","OK","","MAIN!","CENTER","WebForms");
				}
			}
			elsif($action eq 'UPDATE_TIME')
			{
				&display_html("time_updated=1");
				exit;	
			}
			elsif($action eq 'DISPLAY_PASSWORD_CHANGE')
			{
				&display_change_password();	
			}
			elsif($action eq 'VIEW_LOG')
			{
				&display_log($form_name);	
			}
			elsif($action eq 'VIEW_DATA')
			{
				&display_data($form_name,'0');	
			}
			elsif($action eq 'VIEW_DATA_DETAILS')
			{
				&display_data($form_name,'1');	
			}
			elsif($action eq 'RESET_LOG')
			{
				&reset_data($form_name,'1');	
				&general_admin_screen("Reset Log","Details","The <B>$form_name</B> Form's log file has been successfully reset.","OK","","MAIN!","CENTER","WebForms");	
			}
			elsif($action eq 'RESET_DATA')
			{
				&reset_data($form_name,'0');
				&general_admin_screen("Reset Data","Details","The <B>$form_name</B> Form's data has been successfully reset.","OK","","MAIN!","CENTER","Data");	
			}
			elsif($action eq 'DOWNLOAD_LOG')
			{
				&download_log($form_name);	
			}
	  		elsif($action eq 'UPLOADIMAGES')    	
			{	
			   	$data_lines = &upload_image($submitted_data{'IMAGEFILE'},$submitted_data{'FORMNAME'});
				close ($submitted_data{'IMAGEFILE'});
				&display_html($data_lines);
				exit;	
			}
			elsif($action eq 'UPLOADTEXT')    	
			{
			   	$data_lines = &upload_text($submitted_data{'TEXTFILE'},$submitted_data{'FORMNAME'});
				close ($submitted_data{'TEXTFILE'});
				&display_html($data_lines);
				exit;
			}
			elsif($action eq 'CHANGE_PASSWORD')
			{
				use MIME::Base64;
				require rwsem5;

				#split the lines to get old and new passwords
				($entered_password, $new_password, $entered_username) = split (/\@\*\(\)/, $form_name);

				if ((-e $rws_config_file) && (-e $rws_em_file))
				{
					#take the lowercase of the username
					$username = lc($entered_username);
				}
				else
				{
					$username = "administrator";
				}

				#encode the username
				$encoded_username = encode_base64($username);

				$encoded_username =~ s/\=/\(equals\)/g;
				$encoded_username =~ s/\n/\(end\)/g;

				#if admin password not defined set the password to the default
				if((($username eq "administrator") && !(defined $rws_config{'[HASH]'}{$encoded_username})) || !(-e $rws_em_file))
				{
					$rws_config{'[HASH]'}{$encoded_username} = &HexDigest("rws");
					$rws_config{'[USER]'}{$encoded_username} = 1;

					my %rws_em = ();
					$rws_em{'[HASH]'} = &HexDigest($new_password);

					#write out the new rws config file with the new password
					&write_config(\%rws_em,$rws_em_file,1);
				}

				#make sure that the password entered is the password in the file
			 	if (&HexDigest($entered_password) eq $rws_config{'[HASH]'}{$encoded_username})
			 	{
					#encrypt the new password to the file
			 		$rws_config{'[HASH]'}{$encoded_username} = &HexDigest($new_password);

					#write out the new rws config file with the new password
					&write_config(\%rws_config,$rws_config_file,1);

					#check to see if there is a session id, if yes, display page with navigation, if no, display page with no navigation
					#Stores the session_id 
					$session_uid = &get_query_parameter('UID');

					#if this is a change password through the panel, display the general admin password changed screen
					if ($session_uid ne "") 
						{
						&general_admin_screen("Password Changed","Details","The administration control panel password has been successfully changed.","OK","","DISPLAY_LOGIN!","CENTER","Data");
						}
					#if this is the initial password change, display the login-type password changed screen
					else	
						{
						&logged_out_screen("Password Changed","Details","The administration control panel password has been successfully changed.","OK","","DISPLAY_LOGIN!","CENTER");
			 			}	
				}
				else
				{
					#the password does not match the current password, check to see if this is the initial password change
					if ((-e $rws_config_file) && (-e $rws_em_file)) 
					{
						#this is not the first password change, display the change password screen within the panel
			 			&general_admin_screen("Invalid Password","Details","The username and password supplied were invalid. Please check the username and password and try again.","OK","","DISPLAY_PASSWORD_CHANGE!","CENTER","Password");
					}
					else
					{
						#this is the first password change, go back to the initial password change when done
						&logged_out_screen("Invalid Password","Details","The username and password supplied was invalid. Please check the username and password and try again.","OK","","DISPLAY_LOGIN!","CENTER");
					}
				}
			}
			elsif($action eq 'DISPLAY_LOGIN')
			{
				&display_login_page();
	   		}
			elsif(substr($action,0,5) eq 'LOGIN')
			{
				if((-e $rws_config_file) && (-e $rws_em_file))
				{
					require rwsem5;
					use MIME::Base64;

					#if coming from the designer, the username is admin, otherwise get it from the input
					$username = lc($submitted_data{'USERNAME'});

					#encode the username
					$encoded_username = encode_base64($username);

					$encoded_username =~ s/\=/\(equals\)/g;
					$encoded_username =~ s/\n/\(end\)/g;

					#make sure that the password entered is the password in the file
				 	if (&HexDigest($submitted_data{'PASSWORD'}) eq $rws_config{'[HASH]'}{$encoded_username})
				 	{
						#get the current time
						$time = &localtime_in_minutes();

						#generate a session_id that will be passed in the QUERY_string
						$session_uid = &generate_uid();

						#Get the permissions level
						$permissions = $rws_config{'[USER]'}{$encoded_username};

						$permissions =~ s/\|/\>/g;

						$rws_config{'[INFO]'}{$session_uid} = "$ENV{'REMOTE_ADDR'}|$time|$permissions|$encoded_username";

						#write out the new rws config file with the new password
						&write_config(\%rws_config,$rws_config_file,1);

				  		#change the permissions to read/write for the user only
				  		chmod (0600, $rws_config_file);

						#if calling from the designer
						if ($designer == 1)
						{
			  	   			&display_html("login=$session_uid");
							exit;
						}
						else
						{
					 		&display_main();	
						}
						
				 	}	
					else
					{
  			  	   		if ($designer == 1)
						{
		  	   				&display_html("login=0");
							exit;
						}
						else
						{
								#supplied password and stored password don't match
			 					&logged_out_screen("Invalid Password","Details","The username and password supplied were invalid. Please check the username and password and try again.","OK","","DISPLAY_LOGIN!","CENTER");
						}
						
					}
				}
				else
				{
					if ($designer == 1)
					{
			  	   		&display_html("login=n/a");
	  					exit;
	  				}
					else
					{
						#force the user to add a password
						&display_change_password();
					}
				}	
			}
			elsif($action eq 'STATGLANCE')
			{
				#get the report type off of the form name
				($form_name, $report, $duration_value) = split (/\>/, $form_name);

				#if we have item analysis use analyze_data function
				if (($report eq "analysis") || ($report eq ""))
				{
					&display_stats_screen("Remark Live Stats","",&analyze_data($form_name),"OK","","MAIN!","CENTER","Data", $form_name, 0);
				}

				#if we have response report use response_report function
				elsif ($report eq "response")
				{
					&display_stats_screen("Remark Live Stats","",&response_report($form_name),"OK","","MAIN!","CENTER","Data", $form_name, 1);
				}
				else
				{
					&display_stats_screen("Remark Live Stats","",&duration_report($form_name, $duration_value),"OK","","MAIN!","CENTER","Data", $form_name, "2!" . $duration_value);
				}	
			}
			elsif($action eq 'PRINTSTATS')
			{
				#get the report type off of the form name
				($form_name, $report, $duration_value) = split (/\>/, $form_name);

				#if we have item analysis use analyze_data function
				if (($report eq "analysis") || ($report eq ""))
				{
					&display_print_stats("Remark Live Stats","",&analyze_data($form_name),"OK","","MAIN!","CENTER","Data", $form_name, 0);
				}

				#if we have response report use response_report function
				elsif ($report eq "response")
				{
					&display_print_stats("Remark Live Stats","",&response_report($form_name),"OK","","MAIN!","CENTER","Data", $form_name, 1);
				}
				else
				{
					&display_print_stats("Remark Live Stats","",&duration_report($form_name, $duration_value),"OK","","MAIN!","CENTER","Data", $form_name, "2!" . $duration_value);
				}
			}
			elsif($action eq 'VIEW_ADD_USER')
			{
				&display_user_edit(1);
			}
			elsif($action eq 'VIEW_INSTALL_FORM')
			{
				&display_main('Install');
			}
			elsif($action eq 'VIEW_USER_LIST')
			{
				&display_main('Users');
			}
			elsif($action eq 'VIEW_WEB_FORMS')
			{
				&display_main('WebForms');
			}
			elsif($action eq 'VIEW_EDIT_USER')
			{
				&display_user_edit(0, $form_name);
			}
			elsif($action eq 'EDIT_USER')
			{
				use MIME::Base64;
				require rwsem5;

				#split the lines to get old and new passwords
				($edit_username, $edit_password, $permissions, $forms, $editing) = split (/\@\*\(\)/, $form_name);

				#encode the username
				$encoded_username = encode_base64(lc($edit_username));

				$encoded_username =~ s/\=/\(equals\)/g;
				$encoded_username =~ s/\n/\(end\)/g;

				($edit_password, $new_password) = split (/\|/, $edit_password);

				if ($edit_password eq "1")
				{
					$rws_config{'[HASH]'}{$encoded_username} = &HexDigest($new_password);
				}

				$rws_config{'[USER]'}{$encoded_username} = $permissions;

				if ($permissions =~ /^0/)
				{
					$forms =~ s/\|/\>/g;
					$rws_config{'[USER]'}{$encoded_username} .= "!" . $forms;
				}

				#go through and timeout any instances of this user logged in
				foreach $info_keys (keys %{$rws_config{'[INFO]'}})
				{
					#split the IP entry into the IP address and the time it was logged
					($ip_address, $time, $temp_permissions, $current_user) = split (/\|/, $rws_config{'[INFO]'}{$info_keys});

					#if the encoded user's name is equal to the logged in username
					if($current_user eq $encoded_username)
					{
						#set the time to 0
						$rws_config{'[INFO]'}{$info_keys} = $ip_address . "|0|" . $temp_permissions . "|" . $current_user;
					}
				}

				#write out the new rws config file with the new password
				&write_config(\%rws_config,$rws_config_file,1);

				if ($editing eq "1")
				{
					&general_admin_screen("User Updated","Details","The settings for user \"" . lc($edit_username) . "\" have been updated.","OK","","DISPLAY_LOGIN!","CENTER","Users");
				}
				else
				{
					&general_admin_screen("User Added","Details","The user \"" . lc($edit_username) . "\" has successfully been added.","OK","","DISPLAY_LOGIN!","CENTER","Users");
				}
			}
			elsif($action eq 'DELETE_USER')
			{
				use MIME::Base64;
				require rwsem5;

				#encode the username
				$encoded_username = encode_base64(lc($form_name));

				$encoded_username =~ s/\=/\(equals\)/g;
				$encoded_username =~ s/\n/\(end\)/g;

				delete($rws_config{'[USER]'}{$encoded_username});
				delete($rws_config{'[HASH]'}{$encoded_username});

				#write out the new rws config file with the new password
				&write_config(\%rws_config,$rws_config_file,1);

				&general_admin_screen("User Deleted","Details","The user has successfully been deleted.","OK","","DISPLAY_LOGIN!","CENTER","Users");
			}
			elsif($action eq 'SEND_TEST_EMAIL')
			{
				@query = split(/\?/, $form_name);
				$email_method = @query[0];
				shift(@query);

				if ($email_method eq "SendMail")
				{
					&send_mail(@query);
				}
				else
				{
					# Send test email
					&smtp_mail(@query);
				}
			}
			elsif($action eq 'SMTP_TEST_EMAIL')
			{
				($local, $remote, $port, $to, $from, $username, $password) = split(/\|/, $form_name);
				
				&smtp_mail($to, $from, "SMTP Test Message", $remote, $port, "Test message.", 2, $username, $password, $local);
			}
			elsif($action eq 'INITIATE_INCOMPLETE_DATA_PROCESS')
			{
				#display the success
				&display_html("incomplete_data_process_initiated=1");

				#start the process
				&generate_incomplete($form_name);

	  			exit;
			}
			elsif($action eq 'IS_INCOMPLETE_DATA_PROCESS_FINISHED')
			{
				#get the data path
				$back_location = &return_full_path($install_config{'[Forms]'}{$form_name});

				#set the lock file
				$lock_file = &return_full_path($back_location, $form_name . "-incomplete-download.lck");
				$downloaded_lock_file = &return_full_path($back_location, $form_name . "-incomplete-downloaded.lck");
				$data_file = &return_full_path($back_location, $form_name . "-incomplete.rwd");
		

				#if there is a lock file, then the iniatiate process did not begin
				if (-e $downloaded_lock_file)
				{
					&display_html("incomplete_data_process_finished=0");
				}
				#if the lock file does exists, the process is still happening
				elsif ((-e $lock_file) || (!(-e $data_file)))
				{
					&display_html("incomplete_data_process_finished=99");
				}
				#otherwise, the process is finished
				else
				{
					&display_html("incomplete_data_process_finished=1");
				}
			}
		}		
	}

	#add to the log if in diagnostic mode
	if ($diagnostic_on == 1)
	{
		&write_log($LOG_NAME, $MAX_SIZE, "rwsad5.pl", "perform_form_action", "None", $thread_ID, 0);
	}

	return 1;
}

########################################################################################
# 	FUNCTION THAT REMOVES FORM FROM THE INSTALLATION CONFIG FILE  #
#	USE: &remove_form($FORM_NAME);					       	       #		
########################################################################################
sub remove_form
{
	my $form_name = $_[0];
	
	#add to the log if in diagnostic mode
	if ($diagnostic_on == 1)
	{
		&write_log($LOG_NAME, $MAX_SIZE, "rwsad5.pl", "remove_form", "form_name = " . $form_name, $thread_ID, 1);
	}


	#make sure the form exist (it should)
	if (exists $install_config{'[Forms]'}{$form_name})
	{
		#remove the server files BEFORE removing the install config entry
		if($install_config{'[Defaults]'}{'RemoveServerFiles'} eq '1')
		{
			&remove_server_files($form_name);
		}
		#remove the element from the hash
		delete $install_config{"[Forms]"}{$form_name};

		#rewrite out the installation config file with the element removed
		&write_config (\%install_config,$install_config_file,1);
	}

	#add to the log if in diagnostic mode
	if ($diagnostic_on == 1)
	{
		&write_log($LOG_NAME, $MAX_SIZE, "rwsad5.pl", "remove_form", "None", $thread_ID, 0);
	}

	return 1;
}

########################################################################################
# 	FUNCTION THAT ADDS A FORM TO THE INSTALLATION CONFIG FILE  #
#	USE: &add_form($FORM_NAME);					       	       #		
########################################################################################
sub add_form
{
	my $form_name = $_[0];	
	my $path_name = "";

	#add to the log if in diagnostic mode
	if ($diagnostic_on == 1)
	{
		&write_log($LOG_NAME, $MAX_SIZE, "rwsad5.pl", "add_form", "form_name = " . $form_name, $thread_ID, 1);
	}
	
	#get the full path by appending the form name to the default directory
	$path_name = &return_full_path($install_config{"[Defaults]"}{"Location"}, $form_name); 

 	#add the element to the hash
	$install_config{"[Forms]"}{$form_name} = $path_name;

	#rewrite out the installation config file with the element added
	&write_config (\%install_config,$install_config_file,1);	
	
	#add to the log if in diagnostic mode
	if ($diagnostic_on == 1)
	{
		&write_log($LOG_NAME, $MAX_SIZE, "rwsad5.pl", "display_main", "None", $thread_ID, 0);
	}

	return 1;
}

########################################################################################
# 	FUNCTION THAT RETURNS HTML FOR A LIST OF INSTALLED FORMS FROM THE INSTALLATION CONFIG FILE  #
#	USE: $HTML_TEXT = &return_form_list();					       	       #		
########################################################################################
sub return_form_list
{
	my $tmp_html = "";
	
	#add to the log if in diagnostic mode
	if ($diagnostic_on == 1)
	{
		&write_log($LOG_NAME, $MAX_SIZE, "rwsad5.pl", "return_form_list", "None", $thread_ID, 1);
	}

	#add a blank selection to be displayed first
	$tmp_html = "<OPTION SELECTED VALUE=\"\"></OPTION>\n";
	
	#loop thru each form and add it to the list
	foreach $key (sort keys %{$install_config{"[Forms]"}})
	{
		$tmp_html .= "<OPTION VALUE=\"$key\">$key</OPTION>\n";	
	}

	#add to the log if in diagnostic mode
	if ($diagnostic_on == 1)
	{
		&write_log($LOG_NAME, $MAX_SIZE, "rwsad5.pl", "return_form_list", "tmp_html = " . $tmp_html, $thread_ID, 0);
	}

	return $tmp_html;
}

########################################################################################
# 	FUNCTION THAT RETURNS HTML FOR A LIST OF INSTALLED FORMS FROM THE INSTALLATION CONFIG FILE  #
#	USE: $HTML_TEXT = &return_form_list();					       	       #		
########################################################################################
sub return_form_table
{
	my $tmp_html = "";

	#add to the log if in diagnostic mode
	if ($diagnostic_on == 1)
	{
		&write_log($LOG_NAME, $MAX_SIZE, "rwsad5.pl", "return_form_table", "None", $thread_ID, 1);
	}
	
	#loop thru each form and add it to the list
	foreach $key (sort keys %{$install_config{"[Forms]"}})
	{
		$tmp_html .= "<tr><td style=\"padding-left:8px; padding-right:8px;\">" . $key . "</td><td style=\"padding-left:8px; padding-right:8px;\"><input type=\"button\" id=\"ACCESS_FORM\" name=\"ACCESS_FORM\" value=\"Access Form\" onclick=\"validate('ACCESS_FORM', '" . $key . "');\" style=\"width: 144px\" /></td><td style=\"padding-left:8px; padding-right:8px;\"><input type=\"button\" id=\"VIEW_LOG2\" name=\"VIEW_LOG2\" value=\"View Log\" onclick=\"validate('VIEW_LOG', '" . $key . "');\" style=\"width: 144px\" /></td><td style=\"padding-left:8px; padding-right:8px;\"><input type=\"button\" id=\"DOWNLOAD_LOG2\" name=\"DOWNLOAD_LOG2\" value=\"Download Log\" onclick=\"validate('DOWNLOAD_LOG', '" . $key . "');\" style=\"width: 144px\" /></td></tr><tr><td>&nbsp;</td><td style=\"padding-left:8px; padding-right:8px;\"><input type=\"button\" id=\"RESET_LOG\" name=\"RESET_LOG\" value=\"Reset Log\" onclick=\"validate('RESET_LOG', '" . $key . "');\" style=\"width: 144px\" /></td><td style=\"padding-left:8px; padding-right:8px;\" colspan=\"2\"><input type=\"button\" id=\"REMOVE_FORM\" name=\"REMOVE_FORM\" value=\"Remove Form\" onclick=\"validate('VIEW_REMOVE_FORM', '" . $key . "');\" style=\"width: 144px\" /></td></tr>";
	}

	if ($tmp_html eq "")
	{
		$tmp_html = "<tr><td style=\"padding-left:8px; padding-right:8px;\: font-size:small;\" colspan=\"4\">There are currently no forms installed</td></tr>";
	}

	#add to the log if in diagnostic mode
	if ($diagnostic_on == 1)
	{
		&write_log($LOG_NAME, $MAX_SIZE, "rwsad5.pl", "return_form_table", "tmp_html = " . $tmp_html, $thread_ID, 0);
	}

	return $tmp_html;
}

########################################################################################
# 	FUNCTION THAT RETURNS HTML FOR A LIST OF INSTALLED FORMS FROM THE INSTALLATION CONFIG FILE  #
#	USE: $HTML_TEXT = &return_user_list();					       	       #		
########################################################################################
sub return_user_list
{
	my $tmp_html = "";

	#add to the log if in diagnostic mode
	if ($diagnostic_on == 1)
	{
		&write_log($LOG_NAME, $MAX_SIZE, "rwsad5.pl", "return_user_list", "None", $thread_ID, 1);
	}
	
	#initialize the temp html variable
	$tmp_html = "";
	
	#loop thru each user and add it to the list
	foreach $key (sort usersort keys %{$rws_config{'[USER]'}})
	{
		#get the permissions levels
		($permissions_level, $form_permissions) = split(/\!/, $rws_config{'[USER]'}{$key});

		#unescape out equals and endlines
		$key =~ s/\(equals\)/\=/;
		$key =~ s/\(end\)/\n/;

		use MIME::Base64;	

		#decode the username
		$temp_username = decode_base64($key);

		#determine the level of permissions
		if ($temp_username eq "administrator")
		{
			next;
		}

		if ($permissions_level eq "1")
		{
			$temp_level = "Administrator";
		}
		elsif (($form_permissions eq "*allforms*") || ($form_permissions eq "*ALLFORMS*"))
		{
			$temp_level = "Standard User";
		}
		else
		{
			$temp_level = "Restricted User";
		}

		#add it to the list
		$tmp_html .= "<tr><td style=\"padding-left:8px; padding-right:8px;\">" . $temp_username . "</td>
    <td style=\"padding-left:8px; padding-right:8px;\">" . $temp_level . "</td><td style=\"padding-left:8px; padding-right:8px;\"><input type=\"button\" id=\"EDIT_USER\" name=\"EDIT_USER\" value=\"Edit User\" onclick=\"validate('VIEW_EDIT_USER', '" . $temp_username . "');\" style=\"width: 100px\" /></td><td style=\"padding-left:8px; padding-right:8px;\"><input type=\"button\" id=\"DELETE_USER\" name=\"DELETE_USER\" value=\"Delete User\" onclick=\"validate('DELETE_USER', '" . $temp_username . "');\" style=\"width: 100px\" /></td></tr>";	
	}

	#add to the log if in diagnostic mode
	if ($diagnostic_on == 1)
	{
		&write_log($LOG_NAME, $MAX_SIZE, "rwsad5.pl", "return_user_list", "tmp_html = " . $tmp_html, $thread_ID, 0);
	}

	return $tmp_html;
}
										
########################################################################################
# 	FUNCTION THAT DISPLAYS HTML OF A GENERIC SCREEN FILLED WITH PARAMETERS #
#	USE: &general_admin_screen($title,$header,$msg,$ok_button,$cancel_button,$action_text,$button_align,$navigation_page));					       	       #		
########################################################################################
sub general_admin_screen
{
	my $html_title = $_[0];
	my $header_text = $_[1];
	my $msg_text = $_[2];
	my $ok_text = $_[3];
	my $cancel_text = $_[4];
	my $action_text = $_[5];
	my $button_align = $_[6];
	my $navigation_page = "$_[7]";    #added so that it returns to previous navigation screen
	my $html_text = "";
	
	#add to the log if in diagnostic mode
	if ($diagnostic_on == 1)
	{
		&write_log($LOG_NAME, $MAX_SIZE, "rwsad5.pl", "general_admin_screen", "html_title = " . $html_title . " && header_text = " . $header_text . " && msg_text = " . $msg_text . " && ok_text = " . $ok_text . " && cancel_text = " . $cancel_text . " && action_text = " . $action_text . " && button_alignment = " . $button_alignment . " && navigation_page = " . $navigation_page, $thread_ID, 1);
	}

	
	#open up the external html file
	open (SRC_FILE, $cgi_dir . "html/5/general.html") || die print "Could not open html/5/general.html";
	
	#read the file into an array 
	@file_data = <SRC_FILE>;

	#close the source file because we are finished reading in the key=value pairs
	close (SRC_FILE);

	#loop thru storing the lines
 	foreach $source_lines (@file_data)
 	{	
 		#remove the \n character
 		chop ($source_lines);
		$html_text .=  $source_lines;
		 		
 	}

	#store the session variables
	$temp_var = $rws_config{'[INFO]'}{$session_uid};
	($IP, $time, $permissions, $current_user) = split(/\|/, $temp_var);

	#insert the tabs
	if ($permissions eq "1")
	{
		$tab_html = "<li><a href=\"@*(admin)@*(uid)&NAV=Setup\">Server Setup</a></li><li><a href=\"@*(admin)@*(uid)&NAV=WebForms\">Web Forms</a></li><li><a href=\"@*(admin)@*(uid)&NAV=Data\">Data & Stats</a></li><li><a href=\"@*(admin)@*(uid)&NAV=Users\">Users</a></li><li><a href=\"@*(admin)@*(uid)&NAV=Password\">Password</a></li><li><a href=\"@*(admin)@*(uid)&NAV=Diagnostics\">Diagnostics</a></li>";
		$html_text =~ s/\@\*\(nav_tabs\)/$tab_html/g;
	}
	else
	{
		$tab_html = "<li><a href=\"@*(admin)@*(uid)&NAV=Data\">Data & Stats</a></li><li><a href=\"@*(admin)@*(uid)&NAV=Password\">Password</a></li>";
		$html_text =~ s/\@\*\(nav_tabs\)/$tab_html/g;
	}           

	#insert the username
	#unescape out equals and endlines
	$current_user =~ s/\(equals\)/\=/g;
	$current_user =~ s/\(end\)/\n/g;

	use MIME::Base64;	

	#decode the username
	$decoded_user = decode_base64($current_user);

	$html_text =~ s/\@\*\(username\)/$decoded_user/g;    

	#insert the admin script into form '@*()'
	$html_text =~ s/\@\*\(admin\)/$admin_script/g;

	#insert the title into our form '@*()'
	$html_text =~ s/\@\*\(html_title\)/$html_title/g;
	
	#insert the header into our form '@*()'
	$html_text =~ s/\@\*\(header\)/$header_text/g;
	
	#insert the message/question/confirmation into our form '@*()'
	$html_text =~ s/\@\*\(msg_text\)/$msg_text/g;														

	#insert the ok text into our form '@*()'
	$html_text =~ s/\@\*\(ok_text\)/$ok_text/g;
	
	#insert the cancel text into our form '@*()'
	$html_text =~ s/\@\*\(cancel_text\)/$cancel_text/g;

	#insert the action into our form '@*()'
	$html_text =~ s/\@\*\(action\)/$action_text/g;

	#insert the action into our form '@*()'
	$html_text =~ s/\@\*\(button_align\)/$button_align/g;

	#insert the date for the copyright dynamically '@*()'
	@timeData = localtime(time);
	#assigns the value localtime assigns for year to year_offset
	$year_offset = $timeData[5];
	#data is in years since 1900, adds 1900 to get correct year
	$year = 1900 + $year_offset; 
	$html_text =~ s/\@\*\(year\)/$year/g;
	
	#insert the uid into our form '@*()'
	if($session_uid ne '')
	{
		$html_text =~ s/\@\*\(uid\)/\?UID\=$session_uid/g;
	}
	else
	{
		$html_text =~ s/\@\*\(uid\)//g;
	}
 	
	#insert the uid for submitting into our form '@*()'- this is needed for the general admin screen to return to previous navigation using the get form on the page
	if($session_uid ne '')
	{
		$html_text =~ s/\@\*\(uid_submit\)/$session_uid/g;
	}
	else
	{
		$html_text =~ s/\@\*\(uid_submit\)//g;
	}	

	#insert the images cript in to display the logo
	#if the defined default exists, use that
	if (-e $install_config{"[Defaults]"}{"ImageScript"})
	{
		$html_text =~ s/\@\*\(img\)/$install_config{"[Defaults]"}{"ImageScript"}\?ADMIN\=1/g;  
	}
	#if not, check for rwsimg5.pl and use that
	elsif (-e $cgi_dir . 'rwsimg5.pl')
	{
		$html_text =~ s/\@\*\(img\)/rwsimg5\.pl\?ADMIN\=1/g;  
	}
	#if not, check for rwsimg5.cgi and use that
	elsif (-e $cgi_dir . 'rwsimg5.cgi')
	{
		$html_text =~ s/\@\*\(img\)/rwsimg5\.cgi\?ADMIN\=1/g;  
	}
	#if not, check for rwsimg5.plx and use that
	elsif (-e $cgi_dir . 'rwsimg5.plx')
	{
		$html_text =~ s/\@\*\(img\)/rwsimg5\.plx\?ADMIN\=1/g;  
	}
	#otherwise, get rid of the image tag altogether
	else
	{
		$html_text =~ s/\<img .*?src\=\"\@\*\(img\).*?\/\>//g;
	}

	#insert the navigation into our form '@*()'
	$html_text =~ s/\@\*\(nav\)/$navigation_page/g;	
								   
	&display_html($html_text);

	#add to the log if in diagnostic mode
	if ($diagnostic_on == 1)
	{
		&write_log($LOG_NAME, $MAX_SIZE, "rwsad5.pl", "general_admin_screen", "None", $thread_ID, 0);
	}

	return 1;
}
########################################################################################
# 	FUNCTION THAT DISPLAYS HTML OF THE FORM REMOVE SCREEN				#
#	USE: &form_remove_screen($title,$header,$msg,$ok_button,$cancel_button,$action_text,$button_align,$the_form);					       	       #		
########################################################################################
sub form_remove_screen
{
	my $html_title = $_[0];
	my $header_text = $_[1];
	my $msg_text = $_[2];
	my $ok_text = $_[3];
	my $cancel_text = $_[4];
	my $action_text = $_[5];
	my $button_align = $_[6];
	my $form_name = $_[7];
	my $html_text = "";
	my $file_list = "";

	#add to the log if in diagnostic mode
	if ($diagnostic_on == 1)
	{
		&write_log($LOG_NAME, $MAX_SIZE, "rwsad5.pl", "form_remove_screen", "html_title = " . $html_title . " && header_text = " . $header_text . " && msg_text = " . $msg_text . " && ok_text = " . $ok_text . " && cancel_text = " . $cancel_text . " && action_text = " . $action_text . " && button_alignment = " . $button_alignment . " && form_name = " . $form_name, $thread_ID, 1);
	}
	
	$temp_var = $rws_config{'[INFO]'}{$session_uid};
	($IP, $time, $permissions, $current_user) = split(/\|/, $temp_var);
	
	#open up the external html file
	open (SRC_FILE, $cgi_dir . "html/5/formremove.html") || die print "Could not open file html/5/formremove.html";
	
	#read the file into an array 
	@file_data = <SRC_FILE>;

	#close the source file because we are finished reading in the key=value pairs
	close (SRC_FILE);

	#loop thru storing the lines
 	foreach $source_lines (@file_data)
 	{	
 		#remove the \n character
 		chop ($source_lines);
		$html_text .=  $source_lines;
		 		
 	}			       

	#insert the admin script into form '@*()'
	$html_text =~ s/\@\*\(admin\)/$admin_script/g;

	#insert the title into our form '@*()'
	$html_text =~ s/\@\*\(html_title\)/$html_title/g;
	
	#insert the header into our form '@*()'
	$html_text =~ s/\@\*\(header\)/$header_text/g;
	
	#insert the message/question/confirmation into our form '@*()'
	$html_text =~ s/\@\*\(msg_text\)/$msg_text/g;														

	#insert the ok text into our form '@*()'
	$html_text =~ s/\@\*\(ok_text\)/$ok_text/g;
	
	#insert the cancel text into our form '@*()'
	$html_text =~ s/\@\*\(cancel_text\)/$cancel_text/g;

	#insert the action into our form '@*()'
	$html_text =~ s/\@\*\(action\)/$action_text/g;

	#insert the action into our form '@*()'
	$html_text =~ s/\@\*\(button_align\)/$button_align/g;

	#insert the username
	#unescape out equals and endlines
	$current_user =~ s/\(equals\)/\=/g;
	$current_user =~ s/\(end\)/\n/g;

	use MIME::Base64;	

	#decode the username
	$decoded_user = decode_base64($current_user);

	$html_text =~ s/\@\*\(username\)/$decoded_user/g;

	#insert the images cript in to display the logo
	#if the defined default exists, use that
	if (-e $install_config{"[Defaults]"}{"ImageScript"})
	{
		$html_text =~ s/\@\*\(img\)/$install_config{"[Defaults]"}{"ImageScript"}\?ADMIN\=1/g;  
	}
	#if not, check for rwsimg5.pl and use that
	elsif (-e $cgi_dir . 'rwsimg5.pl')
	{
		$html_text =~ s/\@\*\(img\)/rwsimg5\.pl\?ADMIN\=1/g;  
	}
	#if not, check for rwsimg5.cgi and use that
	elsif (-e $cgi_dir . 'rwsimg5.cgi')
	{
		$html_text =~ s/\@\*\(img\)/rwsimg5\.cgi\?ADMIN\=1/g;  
	}
	#if not, check for rwsimg5.plx and use that
	elsif (-e $cgi_dir . 'rwsimg5.plx')
	{
		$html_text =~ s/\@\*\(img\)/rwsimg5\.plx\?ADMIN\=1/g;  
	}
	#otherwise, get rid of the image tag altogether
	else
	{
		$html_text =~ s/\<img .*?src\=\"\@\*\(img\).*?\/\>//g;
	}

	#insert the date for the copyright dynamically '@*()'
	@timeData = localtime(time);
	#assigns the value localtime assigns for year to year_offset
	$year_offset = $timeData[5];
	#data is in years since 1900, adds 1900 to get correct year
	$year = 1900 + $year_offset; 
	$html_text =~ s/\@\*\(year\)/$year/g;
	
	if($install_config{'[Defaults]'}{'RemoveServerFiles'} eq '1')
	{
		#get the associated form files
		$file_list = &get_form_files($form_name);

		#insert the file list into our form '@*()'
		$html_text =~ s/\@\*\(file_list\)/$file_list/g;
	}

	#insert the uid into our form '@*()'
	if($session_uid ne '')
	{
		$html_text =~ s/\@\*\(uid\)/\?UID\=$session_uid/g;
	}
	else
	{
		$html_text =~ s/\@\*\(uid\)//g;
	}
 									   
	&display_html($html_text);

	#add to the log if in diagnostic mode
	if ($diagnostic_on == 1)
	{
		&write_log($LOG_NAME, $MAX_SIZE, "rwsad5.pl", "form_remove_screen", "None", $thread_ID, 0);
	}


	return 1;
}

########################################################################################
# 	FUNCTION THAT DISPLAYS A LOGIN PAGE #
#	USE: &display_login_page();					       	       #		
########################################################################################
sub display_login_page 
{
	my $html_text = "";
 	my $time = "";

	#add to the log if in diagnostic mode
	if ($diagnostic_on == 1)
	{
		&write_log($LOG_NAME, $MAX_SIZE, "rwsad5.pl", "display_login_page", "None", $thread_ID, 1);
	}


	#open up the external html file
	open (SRC_FILE, $cgi_dir . "html/5/login.html") || die print "Could not open file html/5/login.html";
	
	#read the file into an array 
	@file_data = <SRC_FILE>;

	#close the source file because we are finished reading in the key=value pairs
	close (SRC_FILE);

	#loop thru storing the lines
 	foreach $source_lines (@file_data)
 	{	
 		#remove the \n character
 		chop ($source_lines);
		$html_text .=  $source_lines;
		 		
 	}        

	#insert the date for the copyright dynamically '@*()'
	@timeData = localtime(time);
	#assigns the value localtime assigns for year to year_offset
	$year_offset = $timeData[5];
	#data is in years since 1900, adds 1900 to get correct year
	$year = 1900 + $year_offset; 
	$html_text =~ s/\@\*\(year\)/$year/g;
	
	#insert the uid into our form '@*()'
	if($session_uid ne '')
	{
		$html_text =~ s/\@\*\(uid\)/\?UID\=$session_uid/g;
	}
	else
	{
		$html_text =~ s/\@\*\(uid\)//g;
	}
	
	#insert the admin script into form '@*()'
	$html_text =~ s/\@\*\(admin\)/$admin_script/g;

	#insert the images cript in to display the logo
	#if the defined default exists, use that
	if (-e $install_config{"[Defaults]"}{"ImageScript"})
	{
		$html_text =~ s/\@\*\(img\)/$install_config{"[Defaults]"}{"ImageScript"}\?ADMIN\=1/g;  
	}
	#if not, check for rwsimg5.pl and use that
	elsif (-e $cgi_dir . 'rwsimg5.pl')
	{
		$html_text =~ s/\@\*\(img\)/rwsimg5\.pl\?ADMIN\=1/g;  
	}
	#if not, check for rwsimg5.cgi and use that
	elsif (-e $cgi_dir . 'rwsimg5.cgi')
	{
		$html_text =~ s/\@\*\(img\)/rwsimg5\.cgi\?ADMIN\=1/g;  
	}
	#if not, check for rwsimg5.plx and use that
	elsif (-e $cgi_dir . 'rwsimg5.plx')
	{
		$html_text =~ s/\@\*\(img\)/rwsimg5\.plx\?ADMIN\=1/g;  
	}
	#otherwise, get rid of the image tag altogether
	else
	{
		$html_text =~ s/\<img .*?src\=\"\@\*\(img\).*?\/\>//g;
	}


	&display_html($html_text);

	#add to the log if in diagnostic mode
	if ($diagnostic_on == 1)
	{
		&write_log($LOG_NAME, $MAX_SIZE, "rwsad5.pl", "display_login_page", "None", $thread_ID, 0);
	}


	return (1);
}

########################################################################################
# 	FUNCTION THAT DISPLAYS A CHANGE PASSWORD PAGE #
#	USE: &display_change_password();					       	       #		
########################################################################################
sub display_change_password 
{
	my $html_text = "";
 	my $htmlfile = "";

	#add to the log if in diagnostic mode
	if ($diagnostic_on == 1)
	{
		&write_log($LOG_NAME, $MAX_SIZE, "rwsad5.pl", "display_change_password", "None", $thread_ID, 1);
	}


	#If this is the first time logging in, display the change password without navigation. If not, with navigation.
	if ((-e $rws_config_file) && (-e $rws_em_file)) {
		$htmlfile = "html/5/changepassword.html";
		}
	else {
		$htmlfile = "html/5/initialchange.html";	
		}

	$temp_var = $rws_config{'[INFO]'}{$session_uid};
	($IP, $time, $permissions, $current_user) = split(/\|/, $temp_var);

	#open up the external html file
	open (SRC_FILE, $cgi_dir . "$htmlfile") || die print "Could not open file $htmlfile";
	
	#read the file into an array 
	@file_data = <SRC_FILE>;

	#close the source file because we are finished reading in the key=value pairs
	close (SRC_FILE);

	#loop thru storing the lines
 	foreach $source_lines (@file_data)
 	{	
 		#remove the \n character
 		chop ($source_lines);
		$html_text .=  $source_lines;
		 		
 	}

	#insert the tabs
	if ($permissions eq "1")
	{
		$tab_html = "<li><a href=\"@*(admin)@*(uid)&NAV=Setup\">Server Setup</a></li><li><a href=\"@*(admin)@*(uid)&NAV=WebForms\">Web Forms</a></li><li><a href=\"@*(admin)@*(uid)&NAV=Data\">Data & Stats</a></li><li><a href=\"@*(admin)@*(uid)&NAV=Users\">Users</a></li><li><a class=\"selected\">Password</a></li><li><a href=\"@*(admin)@*(uid)&NAV=Diagnostics\">Diagnostics</a></li>";
		$html_text =~ s/\@\*\(nav_tabs\)/$tab_html/g;
	}
	else
	{
		$tab_html = "<li><a href=\"@*(admin)@*(uid)&NAV=Data\">Data & Stats</a></li><li><a class=\"selected\">Password</a></li>";
		$html_text =~ s/\@\*\(nav_tabs\)/$tab_html/g;
	}        		
	
	#insert the uid into our form '@*()'
	if($session_uid ne '')
	{
		$html_text =~ s/\@\*\(uid\)/\?UID\=$session_uid/g;
	}
	else
	{
		$html_text =~ s/\@\*\(uid\)//g;
	}

	#insert the username
	#unescape out equals and endlines
	$current_user =~ s/\(equals\)/\=/g;
	$current_user =~ s/\(end\)/\n/g;

	use MIME::Base64;	

	#decode the username
	$decoded_user = decode_base64($current_user);

	$html_text =~ s/\@\*\(username\)/$decoded_user/g;

	#insert the date for the copyright dynamically '@*()'
	@timeData = localtime(time);
	#assigns the value localtime assigns for year to year_offset
	$year_offset = $timeData[5];
	#data is in years since 1900, adds 1900 to get correct year
	$year = 1900 + $year_offset; 
	$html_text =~ s/\@\*\(year\)/$year/g;

	#insert the images cript in to display the logo
	#if the defined default exists, use that
	if (-e $install_config{"[Defaults]"}{"ImageScript"})
	{
		$html_text =~ s/\@\*\(img\)/$install_config{"[Defaults]"}{"ImageScript"}\?ADMIN\=1/g;  
	}
	#if not, check for rwsimg5.pl and use that
	elsif (-e $cgi_dir . 'rwsimg5.pl')
	{
		$html_text =~ s/\@\*\(img\)/rwsimg5\.pl\?ADMIN\=1/g;  
	}
	#if not, check for rwsimg5.cgi and use that
	elsif (-e $cgi_dir . 'rwsimg5.cgi')
	{
		$html_text =~ s/\@\*\(img\)/rwsimg5\.cgi\?ADMIN\=1/g;  
	}
	#if not, check for rwsimg5.plx and use that
	elsif (-e $cgi_dir . 'rwsimg5.plx')
	{
		$html_text =~ s/\@\*\(img\)/rwsimg5\.plx\?ADMIN\=1/g;  
	}
	#otherwise, get rid of the image tag altogether
	else
	{
		$html_text =~ s/\<img .*?src\=\"\@\*\(img\).*?\/\>//g;
	}


	#insert the admin script into form '@*()'
	$html_text =~ s/\@\*\(admin\)/$admin_script/g;

	&display_html($html_text);

	#add to the log if in diagnostic mode
	if ($diagnostic_on == 1)
	{
		&write_log($LOG_NAME, $MAX_SIZE, "rwsad5.pl", "display_change_password", "None", $thread_ID, 0);
	}

	return (1);
}

########################################################################################
# 	FUNCTION THAT VALIDATES SESSION INACTIVITY
#	USE: &valid_session_time($designer);					       	       #		
########################################################################################
sub valid_session_time
{
	my $designer = $_[0];
	my $info_keys = "";
	my $curr_time = "";
	my $ip_address = "";
	my $time = "";
	my $uid = "";
	my $timeout = 0;
	my $uid_still_valid = 0;

	#add to the log if in diagnostic mode
	if ($diagnostic_on == 1)
	{
		&write_log($LOG_NAME, $MAX_SIZE, "rwsad5.pl", "valid_session_time", "designer = " . $design, $thread_ID, 1);
	}

	#if the rws config file does not exists then time could not have lapsed
	if(!(-e $rws_config_file))
	{
		if($designer != 1)
		{
			&logged_out_screen("Session Error","Details","Please login again before continuing.","OK","","DISPLAY_LOGIN!","CENTER");					
		}
		else
		{
			&display_html("login=expired");
			#add to the log if in diagnostic mode
			if ($diagnostic_on == 1)
			{
				&write_log($LOG_NAME, $MAX_SIZE, "rwsad5.pl", "valid_session_time", "return = 0", $thread_ID, 0);
			}
			exit;
		}
		#add to the log if in diagnostic mode
		if ($diagnostic_on == 1)
		{
			&write_log($LOG_NAME, $MAX_SIZE, "rwsad5.pl", "valid_session_time", "return = 0", $thread_ID, 0);
		}
 		return (0);
	}

	#get the current time
	$curr_time = &localtime_in_minutes();

	#for each IP entry in the file
	foreach $info_keys (keys %{$rws_config{'[INFO]'}})
	{
		#split the IP entry into the IP address and the time it was logged
		($ip_address, $time, $permissions, $current_user) = split (/\|/, $rws_config{'[INFO]'}{$info_keys});
	
		#if the entry is the user's IP address and if uid is the same
		if(($ip_address eq $ENV{'REMOTE_ADDR'}) && ($info_keys eq $session_uid))
		{
			#set the valid flag
			$uid_still_valid = 1;

			#if valid time then update the file
			if (abs($curr_time - $time) < $INTERVAL)
			{
				$permissions =~ s/\|/\>/g;
				$rws_config{'[INFO]'}{$info_keys} = $ip_address . '|' . &localtime_in_minutes() . '|' . $permissions . "|" . $current_user;
			}
			else
			{
				#remove the entry
				delete $rws_config{$info_keys};

				#clear the session id before the timeout message
				$session_uid = '';
				$timeout = 1;
			}
		}
			
		#not the same person, but check the time					
		elsif(abs($curr_time - $time) > $INTERVAL)
		{
			delete $rws_config{'[INFO]'}{$info_keys};	
		}
	}

	&write_config(\%rws_config,$rws_config_file,1);

	#if we timed out, display message
	if($timeout == 1)
	{
	    if($designer != 1)
		{
			&logged_out_screen("Session Timeout","Details","You have exceeded the session time limit between actions. Please login again before continuing.","OK","","DISPLAY_LOGIN!","CENTER");					
		}
		else
		{
			&display_html("login=expired");
			#add to the log if in diagnostic mode
			if ($diagnostic_on == 1)
			{
				&write_log($LOG_NAME, $MAX_SIZE, "rwsad5.pl", "valid_session_time", "return = 0", $thread_ID, 0);
			}
			exit;
		}
		#add to the log if in diagnostic mode
		if ($diagnostic_on == 1)
		{
			&write_log($LOG_NAME, $MAX_SIZE, "rwsad5.pl", "valid_session_time", "return = 0", $thread_ID, 0);
		}
 		return (0);
	}
	elsif($uid_still_valid != 1)
	{
		if($designer != 1)
		{
			&logged_out_screen("Session Expired","Details","This session has expired due to a logout. Please login again before continuing.","OK","","DISPLAY_LOGIN!","CENTER");					
		}
		else
		{
			&display_html("login=expired");
			#add to the log if in diagnostic mode
			if ($diagnostic_on == 1)
			{
				&write_log($LOG_NAME, $MAX_SIZE, "rwsad5.pl", "valid_session_time", "return = 0", $thread_ID, 0);
			}
			exit;
		}
		#add to the log if in diagnostic mode
		if ($diagnostic_on == 1)
		{
			&write_log($LOG_NAME, $MAX_SIZE, "rwsad5.pl", "valid_session_time", "return = 0", $thread_ID, 0);
		}
 		return (0);
	}
	else
	{
		#add to the log if in diagnostic mode
			if ($diagnostic_on == 1)
		{
			&write_log($LOG_NAME, $MAX_SIZE, "rwsad5.pl", "valid_session_time", "return = 1", $thread_ID, 0);
		}
		return(1);
	}
}

########################################################################################
# 	FUNCTION THAT UPLOADS IMAGES				       								   #
#	USE: $result = &UploadImage ($IMAGE_FILE,$FORM_NAME);		       				   #	
########################################################################################
sub upload_image
{
	my $image_file = $_[0];
	my $form_name = $_[1];
	my $image_output = "";
	my $data = "";
	my $whole_path ="";
	my $tmp_file = "";

	#add to the log if in diagnostic mode
	if ($diagnostic_on == 1)
	{
		&write_log($LOG_NAME, $MAX_SIZE, "rwsad5.pl", "upload_image", "image_file = " . $image_file . " && form_name = " . $form_name, $thread_ID, 1);
	}

	#convert the form name to lower case
	$form_name = lc($form_name);

    $image_output = $image_file;
    $image_output =~ s {.*[\:\\\/]} []gos;
    $image_output =~ s/[^A-Za-z0-9\._ \-=@\x80-\xFE]/_/go;

	$tmp_file = lc($image_output);

	#remove the line feed from the data
	chomp $form_name;
	
	#remove the carriage return from the data
	$form_name =~ s/\r//g;

	#make sure that we are dealing with a valid file
    if($tmp_file !~ /^.+\.($ALLOWED_FILES)$/)
    {
        return ("upload_image_denied=" . $image_output);
    }

	#construct true path
	$whole_path = &return_full_path($install_config{'[Defaults]'}{'Location'},$form_name);
	$whole_path = &return_full_path($whole_path,$image_output);

	#determine if the file already exists
    if (-e $whole_path)
    {
    	unlink $whole_path;
    }
	
    if (open IMAGE,">$whole_path")
    {
		#prepare for binary file
    	binmode(IMAGE);

        while (read $image_file,$data,1024) 
		{
                print IMAGE $data;
        }

		#set the file = to the server file
        $image_file = $image_output;

        #close the server file
        close IMAGE;

		#change to read-only
		chmod 0600, $whole_path;

	#add to the log if in diagnostic mode
	if ($diagnostic_on == 1)
	{
		&write_log($LOG_NAME, $MAX_SIZE, "rwsad5.pl", "upload_image", "upload = 1", $thread_ID, 0);
	}

		return("upload=1");
    }
    else
    {
	#add to the log if in diagnostic mode
	if ($diagnostic_on == 1)
	{
		&write_log($LOG_NAME, $MAX_SIZE, "rwsad5.pl", "upload_image", "upload_image_failed = " . $image_output, $thread_ID, 0);
	}
	
    	return("upload_image_failed=" . $image_output);
    }
}
########################################################################################
# 	FUNCTION THAT UPLOADS TEXT FILES				       							   #
#	USE: $result = &Upload_Text ($TEXT_FILE,$FORM_NAME);		       					   #	
########################################################################################
sub upload_text
{

	my $text_file = $_[0];
	my $form_name = $_[1];
	my $append_pass = $_[2];
	my $text_output = "";
	my $data = "";
	my $whole_path ="";
	my $legacy_pass = 0;
	my $pass51 = 0;
	my $merge_legacy = 0;
	my %password_list = ();
	my %parsed_files = {};

	#add to the log if in diagnostic mode
	if ($diagnostic_on == 1)
	{
		&write_log($LOG_NAME, $MAX_SIZE, "rwsad5.pl", "upload_text", "text_file = " . $text_file . " && form_name = " . $form_name . " && append_pass = " . $append_pass, $thread_ID, 1);
	}

	#convert the form name to lower case
	$form_name = lc($form_name);

    $text_output = lc($text_file);
    $text_output =~ s {.*[\:\\\/]} []gos;
    $text_output =~ s/[^A-Za-z0-9\._ \-=@\x80-\xFE]/_/go;
    $text_output =~ s/ /_/g;
			 
	#remove the line feed from the data
	chomp $form_name;
	
	#remove the carriage return from the data
	$form_name =~ s/\r//g;

    if($text_output !~ /^.+\.($ALLOWED_FILES)$/)
    {
        return("upload=" . $text_output);
    }

	#construct true path
	$whole_path = &return_full_path($install_config{'[Defaults]'}{'Location'},$form_name);
	$whole_path = &return_full_path($whole_path,$text_output);


   #if we have the legacy format of the webform.res file, set $legacy_pass flag to 1
   if ($whole_path =~ /^.+webform\.res$/)
   {
	$legacy_pass = 1;
   }
   #if we have the new format, set old_path to the legacy format to see if we are upgrading
   else
   {
	$old_path = $whole_path;
	$old_path =~ s/webform.*?\.resx/webform-old\.tmp/;

	#set a path for upgrading a 5.1 form
	$upgrade_path = $whole_path;
	$upgrade_path =~ s/webform.*?\.resx/webform\.tmp/;
   }

   #if it we are merging the password file
   if ((-e $whole_path) && ($append_pass == 1))
    {
	#if working with a .resx
	if ($legacy_pass != 1)
	{
		#parse the old files and store the values in an array
		$oldpasslist = &read_XML($whole_path, 'hash', 'pipe');
	}
	else
	{
		#store the password file into a hash, delete the original file
		%password_list = &read_config($whole_path,1);
	}
	unlink $whole_path; 
    }

    #check to see if we have a legacy file we are merging
    elsif ((-e $old_path) && ($append_pass == 1))
    {
	#store the password file into a hash
	%password_list = &read_config($old_path,1);
	
	#set the merg_legacy flag to 1
	$merge_legacy = 1;
    }
    #check to see if we have a 5.1 file and are appending
    elsif ((-e $upgrade_path) && ($append_pass == 1))
    {
	#parse the old files and store the values in an array
	$oldpasslist = &read_XML($upgrade_path, 'hash', 'pipe');

	#set a flag to see if there was a 5.1 file
	$pass51 = 1;
    }
    #check to see if we have a 5.1 file and aren't appending appending
    elsif ((-e $upgrade_path) && ($append_pass == 0))
    {
	#delete the file
	unlink $upgrade_path;
    }
    #otherwise delete the file
    elsif (-e $whole_path)
    {
    	unlink $whole_path; 
    }

    #attempt to create the file on the server
    if (open TEXT,">$whole_path")
    { 	    
	#if this is a legacy password file
	if (($append_pass ne '') && ($legacy_pass == 1))
	{
		#set a passwords_uploaded flag
		$passwords_uploaded = 0;

		#for each line (password) in the file)
		foreach $temp_line (<$text_file>)
		{
			#get rid of the endline
			chomp($temp_line);

			#set up an evaluation to get rid of hidden characters
			$eval_line = $temp_line;
			$eval_line =~ s/[^\w\[\]\s\:]//g;

			#if we have the first blank line, it is end of password section
			if ($eval_line !~ m/\w/)
			{
				$passwords_uploaded = 1;
			}

			#set the 0 to base64 encoding
			use MIME::Base64;
			$encoded_0 = encode_base64("0");
			chomp($encoded_0);

			#if we are still in the password section
			if (($passwords_uploaded eq '0') && ($eval_line !~ "[RESPONDENT ACCESS]"))
			{

				#strip out non-word characters
				$temp_line =~ s/[^\w\:]//g;

				#if we are merging the passwords
				if ($append_pass eq '1')
				{
					#check to see if there was already a usage defined in old file
					if ($password_list{'[RESPONDENT ACCESS]'}{$temp_line} ne '')
					{
						#add equals usage endline to the end of the password
						$temp_line .= "\=" . $password_list{'[RESPONDENT ACCESS]'}{$temp_line} . "\n";
					}

					#if no usage defined, add equals 0 endline to the password
					else
					{
						$temp_line .= "\=" . $encoded_0 . "\n";
					}
				}

				#if we're overwriting the password file, add equals 0 newline to each password
				elsif ($append_pass eq '0')
				{
					$temp_line .= "\=" . $encoded_0 . "\n";
				}
			}
			#otherwise we are in the email or name section and just need to add an endline
			else
			{
				$temp_line .= "\n";
			}

			#print it out to the new file
			print TEXT $temp_line;

			#close the server file
        		close TEXT;
		}			
	}
	#if we are working with a resx password file
	elsif (($append_pass == 1) && ($merge_legacy == 0))
	{
		#set a temp file path
		$temp_text_file = $whole_path;
		$temp_text_file =~ s/(webform.*?).resx/\1\_temp\.resx/;

		#open up the temp file and read in the new password file
		if (open (TEMP_XML, ">$temp_text_file"))
		{
			while (read $text_file,$data,1024) 
			{			
		
				print TEMP_XML $data;
			}
			close TEMP_XML;
		}

		#read in the new XML list
		my $newpasslist = read_fullXML($temp_text_file, 'hash', 'pipe');

		#delete the temp file
		unlink $temp_text_file;

		#if we are working with a rws 5.1 password file
		if ($pass51 == 1)
		{
			#go through each of the hashes of the new file
			foreach $hash (keys %{$newpasslist -> {respondents} -> {respondent}})
			{
				#check to see if it was defined in old file
				if ($oldpasslist -> {respondents} -> {respondent} -> {$hash} -> {usecount} ne "")
				{
					#if so, use its usecount
					$newpasslist -> {respondents} -> {respondent} -> {$hash} -> {usecount} = $oldpasslist -> {respondents} -> {respondent} -> {$hash} -> {usecount};
				}
			}
		}
		#otherwise we are working with 5.2 multiple password files
		else
		{

			#locate the directory for the form
			$form_config_dir = &return_full_path($install_config{'[Defaults]'}{'Location'},$form_name);

			$old_config_file = $form_name . '.tmp';
			$old_config_file = &convert_string($old_config_file);

			#get the full form config file path on the server
			$old_config_file = &return_full_path($form_config_dir,$old_config_file);

			#read the form configuration into the global hash
			%old_form_configuration = &read_config($old_config_file,1);

			#go through each of the hashes of the new file
			foreach $hash (keys %{$newpasslist -> {respondents} -> {respondent}})
			{
				#If we have a set of hash ranges
				if (%{$old_form_configuration{'[HashRanges]'}})
				{
					#loop through each key
					foreach $key (keys %{$old_form_configuration{'[HashRanges]'}})
					{
						#if we have a username
						if ($hash =~ /\:/)
						{
							#split the username and the password
							($hash_username, $hash_password) = split(/\:/, $hash);
						}
						else
						{
							#otherwise we just want the password
							$hash_password = $hash;
						}

						#get the range
						($range_begin, $range_end) = split(/\-/, $key);

						#if the hash falls in the range
						if (($hash_password ge $range_begin) && ($hash_password le $range_end))
						{
							#set the form hash file
							$password_file_name = $old_form_configuration{'[HashRanges]'}{$key};

							#change to .tmp extension
							$password_file_name =~ s/\.resx/\.tmp/;
	
							#end the loop
							last;
						}
					}
				}

				#check to see if the file is already in our parsed file list
				if (($parsed_files{$password_file_name} eq "") && ($password_file_name ne ""))
				{
					#set a variable_name
					$password_file_name =~ /webform-(.*?)\.tmp/;
					$variable_index = $1;

					#set the hash
					$parsed_files{$password_file_name} = $variable_index;

					#build the address of the file
					$password_file_path = &return_full_path($form_config_dir,$password_file_name);

					#parse the file into the variable index 
					$oldpasslist[$variable_index - 1] = read_fullXML($password_file_path, 'hash', 'pipe');
				}

				#check to see if it was defined in old file
				if (($password_file_name ne "") && ($oldpasslist[$parsed_files{$password_file_name} - 1] -> {respondents} -> {respondent} -> {$hash} -> {usecount} ne ""))
				{ 
					$newpasslist -> {respondents} -> {respondent} -> {$hash} -> {usecount} = $oldpasslist[$parsed_files{$password_file_name} - 1] -> {respondents} -> {respondent} -> {$hash} -> {usecount};
				}
				
			}
		}

		#output the new XML File
		write_passwordXML($whole_path, $newpasslist, 'hash', 'pipe','<?xml version="1.0" encoding="utf-8" standalone="yes"?>' . "\n" . '<!--RWS50 5.1.0.0 powered by RWSWebForms 5.1.0.0-->' . "\n");

		#change to read-only
        	chmod 0600, $whole_path;
        
 		return("upload=1");		
	}
	#if we are merging a legacy file with a new file type
	elsif (($append_pass == 1) && ($merge_legacy == 1))
	{
		#set a temp file path
		$temp_text_file = $whole_path;
		$temp_text_file =~ s/webform.*?\.resx/webform\_temp\.resx/;

		#open up the temp file and read in the new password file
		if (open (TEMP_XML, ">$temp_text_file"))
		{
			while (read $text_file,$data,1024) 
			{			
		
				print TEMP_XML $data;
			}
		close TEMP_XML;
		}

		#read in the new XML list
		my $newpasslist = read_fullXML($temp_text_file, 'hash', 'pipe');

		#delete the temp file
		unlink $temp_text_file;

		#go through each of the hashes of the new file
		foreach $hash (keys %{$newpasslist -> {respondents} -> {respondent}})
		{
			#add in a temp hash, remove the :
			$temp_hash = $hash;
			$temp_hash =~ s/\://;

			#check to see if there was already a usage defined in old file
			if ($password_list{'[RESPONDENT ACCESS]'}{$hash} ne '')
			{
				#if so, use its usecount
				$newpasslist -> {respondents} -> {respondent} -> {$hash} -> {usecount} = $password_list{'[RESPONDENT ACCESS]'}{$hash};
			}
			#otherwise it might not want
			elsif ($password_list{'[RESPONDENT ACCESS]'}{$temp_hash} ne '')
			{
				#if so, use its usecount
				$newpasslist -> {respondents} -> {respondent} -> {$hash} -> {usecount} = $password_list{'[RESPONDENT ACCESS]'}{$temp_hash};
			}
		}
		
		#close the server file
        	close TEXT;

		#output the new XML File
		write_passwordXML($whole_path, $newpasslist, 'hash', 'pipe','<?xml version="1.0" encoding="utf-8" standalone="yes"?>' . "\n" . '<!--RWS50 5.1.0.0 powered by RWSWebForms 5.1.0.0-->' . "\n");
        
		#change to read-only
        	chmod 0600, $whole_path;

 		return("upload=1");		
	}
	else
	{
		while (read $text_file,$data,1024) 
		{			
		
			print TEXT $data;
		}

		#close the server file
        	close TEXT;
	
		#if we have the config file, we can clean out the tmp files
    		if (lc($text_output) =~ /^.+\.cfg$/)
    		{
			#set the directory
			$rem_dir = &return_full_path($install_config{'[Defaults]'}{'Location'},$form_name);

			#see if the directory exists
			if(opendir (DIR, "$rem_dir"))
			{
				#loop thru all files		
				while($file = readdir(DIR))
				{
					#if we have a temp file
					if(lc($file) =~ /^.+\.tmp$/)
					{
						#if we have a password file
						if(lc($file) =~ /webform/)
						{
							#if we are leaving the old password files
							if ($append_pass == -1)	
							{
								#set the temp file
								$temp_file = $file;

								#if we have a RWS 5.0 res file
								if (lc($temp_file) =~ /webform-old/)
								{
									#remove the old and change back to a res extension
									$temp_file =~ s/\-old//;
									$temp_file =~ s/\.tmp/\.res/;
								}
								#otherwise we have a .resx file
								else
								{
									$temp_file =~ s/\.tmp/\.resx/;
								}

								#set the temp path
								$temp_path = &return_full_path($rem_dir,$temp_file);

								#set the original path
								$original_path = &return_full_path($rem_dir,$file);

								#copy the file over to a temp file
								if (open (TEMP, ">$temp_path"))
								{
									#copy the file over to a temp file
									if (open (SRC_FILE, "$original_path"))
									{
										@file_data=<SRC_FILE>;
									}

									close SRC_FILE;						

									#loop thru storing the lines
 									foreach $source_line (@file_data)
 									{
										print TEMP ($source_line);
									}

									close TEMP;
								}

								#remove the old file
								unlink $original_path;

							}
							#if it is a webform-old.tmp (former .res file) or not a webform-#.tmp (split .resx file) 
							elsif ((lc($file) =~ /webform-old/) || (lc($file) !~ /webform-/))
							{

								#load the config file
								$new_config_file = $form_name . '.cfg';
								$new_config_file = &convert_string($new_config_file);

								#get the full form config file path on the server
								$new_config_file = &return_full_path($rem_dir,$new_config_file);

								#read the form configuration into the global hash
								%new_form_configuration = &read_config($new_config_file,1);

								#if it is a password protected form, change it back
								if($new_form_configuration{'[MISC]'}{'PasswordProtected'} == 1)
								{
									#set the temp file
									$temp_file = $file;

									#if we have a RWS 5.0 res file
									if (lc($temp_file) =~ /webform-old/)
									{
										#remove the old and change back to a res extension
										$temp_file =~ s/\-old//;
										$temp_file =~ s/\.tmp/\.res/;
									}
									#otherwise we have a .resx file
									else
									{
										$temp_file =~ s/\.tmp/\.resx/;
									}

									#set the eval files
									$rws50_file = &return_full_path($rem_dir,"webform.res");
									$rws51_file = &return_full_path($rem_dir,"webform.resx");
									$rws52_file = &return_full_path($rem_dir,"webform-1.resx");

									#set the temp path
									$temp_path = &return_full_path($rem_dir,$temp_file);

									#set the original path
									$original_path = &return_full_path($rem_dir,$file);
	
									#if there isn't already a password file
									unless((-e $rws50_file) || (-e $rws51_file) || (-e $rws52_file))
									{
										#copy the file over to a temp file
										if (open (TEMP, ">$temp_path"))
										{
											#copy the file over to a temp file
											if (open (SRC_FILE, "$original_path"))
											{
												@file_data=<SRC_FILE>;
											}

											close SRC_FILE;						

											#loop thru storing the lines
 											foreach $source_line (@file_data)
 											{
												print TEMP ($source_line);
											}
		
											close TEMP;
										}
									}

									#remove the old file
									unlink $original_path;

								}
								#otherwise delete it
								else
								{
									unlink &return_full_path($rem_dir,$file);
								}
							}
							#otherwise just delete it
							else
							{
								#remove the file
								unlink &return_full_path($rem_dir,$file);
							}
							
						}
						#otherwise we have the config file
						else
						{
							#If we are leaving the old password files
							if($append_pass == -1)
							{
								#load the new config file
								$new_config_file = $form_name . '.cfg';
								$new_config_file = &convert_string($new_config_file);

								#get the full form config file path on the server
								$new_config_file = &return_full_path($rem_dir,$new_config_file);

								#read the form configuration into the global hash
								%new_form_configuration = &read_config($new_config_file,1);

								#load the old config file
								$old_config_file = &return_full_path($rem_dir,$file);

								#read the form configuration into the global hash
								%old_form_configuration = &read_config($old_config_file,1);
	
								#clear out the new hash ranges
								%{$new_form_configuration{'[HashRanges]'}} = ();

								#go through each of the hash maps and delete them
								foreach $hash (keys %{$old_form_configuration{'[HashRanges]'}})
								{
									$new_form_configuration{'[HashRanges]'}{$hash} = $old_form_configuration{'[HashRanges]'}{$hash};
								}

								#write out the config file
								&write_config(\%new_form_configuration,$new_config_file,1);
							}

							#remove the file
							unlink &return_full_path($rem_dir,$file);

						}
						
					}
				}
			}
    		}		
	}	

		#set the file = to the server file
		$text_file = $text_output;
		
		#change to read-only
        chmod 0600, $whole_path;

	#add to the log if in diagnostic mode
	if ($diagnostic_on == 1)
	{
		&write_log($LOG_NAME, $MAX_SIZE, "rwsad5.pl", "upload_text", "upload = 1", $thread_ID, 0);
	}
        
 		return("upload=1");
    } 
    else
    {
	#add to the log if in diagnostic mode
	if ($diagnostic_on == 1)
	{
		&write_log($LOG_NAME, $MAX_SIZE, "rwsad5.pl", "upload_text", "upload = " . $text_output, $thread_ID, 0);
	}

    	return("upload=" . $text_output);
    }
}

########################################################################################
# 	FUNCTION THAT WRITES OUT PLAIN TEXT TO THE BROWSWER 		       		       	   #		
#	USE: &display_plain_text($HTML_DATA);					       	       			   #		
########################################################################################
sub display_plain_text
{
	my $output_text = $_[0];

	#add to the log if in diagnostic mode
	if ($diagnostic_on == 1)
	{
		&write_log($LOG_NAME, $MAX_SIZE, "rwsad5.pl", "display_plain_text", "output_text = " . $output_text, $thread_ID, 1);
	}

	print "Content-type: text/html\n\n";
	#print "Content-type: text/plain\n\n";
	print "$output_text";

	#add to the log if in diagnostic mode
	if ($diagnostic_on == 1)
	{
		&write_log($LOG_NAME, $MAX_SIZE, "rwsad5.pl", "display_plain_text", "None", $thread_ID, 0);
	}

	return 1;
}

########################################################################################
# 	FUNCTION THAT CREATES A DIRECTORY ON THE SERVER 		       		       #	
#	USE: &create_cgi_directory($path,$permissions);					       	       #		
########################################################################################
sub create_cgi_directory_upload
{
	my $form_check = $_[0];
	my $dir_permissions = $_[1];

	#add to the log if in diagnostic mode
	if ($diagnostic_on == 1)
	{
		&write_log($LOG_NAME, $MAX_SIZE, "rwsad5.pl", "create_cgi_directory_upload", "form_check = " . $form_check . " && dir_permissions = " . $dir_permissions, $thread_ID, 1);
	}

	#develop the full path
	$new_dir = &return_full_path($install_config{'[Defaults]'}{'Location'},$form_check);

	#see if the directory exists
	if(opendir MY_DIR,$new_dir)
	{
		#get the permissions level
		($IP, $time, $permissions, $username) = split(/\|/, $rws_config{'[INFO]'}{$session_uid});

		#if a standard or restricted user
		if ($permissions != 1)
		{
			#set the form allowed flag to 0
			$form_allowed = 0;

			#split the permission level and the list of allowed forms
			($permission_level, $forms_access) = split(/\!/, $permissions);

			#if we have a standard user, they are allowed to upload
			if ($forms_access eq "*ALLFORMS*")
			{
				$form_allowed = 1;
			}

			else
			{

				#store the allowed forms
				@forms = split(/\>/, $forms_access);

				#loop through each allowed form
				foreach $form_permissions (@forms)
				{
					#if the form matches the form we are check, change the flag
					if ($form_permissions eq $form_check)
					{
						$form_allowed = 1;
					}
				}
			}

			#if no permssions, return 0
			if ($form_allowed == 0)
			{
				&display_html("createdir=-1");

				#add to the log if in diagnostic mode
				if ($diagnostic_on == 1)
				{
					&write_log($LOG_NAME, $MAX_SIZE, "rwsad5.pl", "create_cgi_directory_upload", "createdir = -1", $thread_ID, 0);
				}

				exit;
			}
		}

		closedir MY_DIR;
			 
		#we need to ask the user if they want to overwrite all files
 		&display_html("createdir=x");

		#add to the log if in diagnostic mode
		if ($diagnostic_on == 1)
		{
			&write_log($LOG_NAME, $MAX_SIZE, "rwsad5.pl", "create_cgi_directory_upload", "createdir = x", $thread_ID, 0);
		}
 		exit;	
	}
	elsif(!(mkdir($new_dir,$dir_permissions)))
	{
 		&display_html("createdir=0");

		#add to the log if in diagnostic mode
		if ($diagnostic_on == 1)
		{
			&write_log($LOG_NAME, $MAX_SIZE, "rwsad5.pl", "create_cgi_directory_upload", "createdir = 0", $thread_ID, 0);
		}

 		exit;	
	}
	else
	{
 		&display_html("createdir=1");
	
		#add to the log if in diagnostic mode
		if ($diagnostic_on == 1)
		{
			&write_log($LOG_NAME, $MAX_SIZE, "rwsad5.pl", "create_cgi_directory_upload", "createdir = 1", $thread_ID, 1);
		}

 		exit;
 	}	
	   
}

########################################################################################
# 	FUNCTION THAT REMOVES A DIRECTORY ON THE SERVER 		       		       #	
#	USE: &remove_directory_files_upload($path,remove_data);					       	       #		
########################################################################################
sub remove_directory_files_upload
{
	my $rem_dir = $_[0];
	my $rem_data = $_[1];
	my $file = "";
	my @files = ();
	my $ext = "rwd|rwa|log|uid";

	#add to the log if in diagnostic mode
	if ($diagnostic_on == 1)
	{
		&write_log($LOG_NAME, $MAX_SIZE, "rwsad5.pl", "remove_directory_files_upload", "rem_dir = " . $rem_dir . " && rem_data = " . $rem_data, $thread_ID, 1);
	}

	#develop the full path
	$rem_dir = &return_full_path($install_config{'[Defaults]'}{'Location'},$rem_dir);

	#see if the directory exists
	if(opendir (DIR, "$rem_dir"))
	{
		#loop thru all files
		while($file = readdir(DIR))
		{
			if(($file ne '.') && ($file ne '..'))
			{
				#if we have the data file and backing up is on
				if ((lc($file) =~ /^.+\.rwd$/) && ($install_config{"[Defaults]"}{"BackUpData"} eq "1"))
				{
					#if we are overwriting the data
					if($rem_data eq '1')
					{
						#the datafile is the file we have
						$datafile = &return_full_path($rem_dir,$file);

						#change the extension of the filename to rwa to find the archive file
						$archivefile = &return_full_path($rem_dir,$file);
						$archivefile =~ s/\.rwd$/\.rwa/;

						#archive the data so that all data is in the archive file
						&archive_data($datafile, $archivefile);

						#load the local time array
						@current_date = localtime(time);

						#set the renamed file name to archive-yearmonthdayhourminute.bak
						$renamed_file = &return_full_path($rem_dir, "archive-" . ($current_date[5] + 1900) . ($current_date[4] + 1) . $current_date[3] . $current_date[2] . $current_date[1] . ".bak");

						#rename the file to the backup file name
						rename($archivefile, $renamed_file);
					}

				}
				#if we have the archive file and backing up is on
				elsif ((lc($file) =~ /^.+\.rwa$/) && ($install_config{"[Defaults]"}{"BackUpData"} eq "1"))
				{
					#if we are overwriting the data
					if($rem_data eq '1')
					{
						#the archive file is the file we have
						$archivefile = &return_full_path($rem_dir,$file);

						#change the extension of the filename to rwd to find the data file
						$datafile = &return_full_path($rem_dir,$file);
						$datafile =~ s/\.rwa$/\.rwd/;

						#archive the data so that all data is in the archive file
						&archive_data($datafile, $archivefile);

						#load the local time array
						@current_date = localtime(time);

						#set the renamed file name to archive-yearmonthdayhourminute.bak
						$renamed_file = &return_full_path($rem_dir, "archive-" . ($current_date[5] + 1900) . ($current_date[4] + 1) . $current_date[3] . $current_date[2] . $current_date[1] . ".bak");

						#rename the file to the backup file name
						rename($archivefile, $renamed_file);
					}

				}
				#if we have a data or log file
				elsif(lc($file) =~ /^.+\.($ext)$/)
				{
					if($rem_data eq '1')
					{
						#remove the file
						unlink &return_full_path($rem_dir,$file);
					}
				}
				#if we have any other file not a password file	
				elsif ((lc($file) !~ m/^.+\.res$/) && (lc($file) !~ m/^.+\.bak$/) && (lc($file) !~ m/^.+\.tmp$/) && (lc($file) !~ m/^.+\.resx$/) && (lc($file) !~ m/^.+\.cfg$/))
				{
					#remove the file
					unlink &return_full_path($rem_dir,$file);
				}
				#if we have a .resx or .cfg file
				elsif ((lc($file) =~ m/^.+\.resx$/) || (lc($file) =~ m/^.+\.cfg$/))
				{
					#set the temp file
					$temp_file = $file;

					#change the extension
					$temp_file =~ s/\.resx/\.tmp/;
					$temp_file =~ s/\.cfg/\.tmp/;

					#set the temp path
					$temp_path = &return_full_path($rem_dir,$temp_file);

					#set the original path
					$original_path = &return_full_path($rem_dir,$file);

					#copy the file over to a temp file
					if (open (TEMP, ">$temp_path"))
					{
						#copy the file over to a temp file
						if (open (SRC_FILE, "$original_path"))
						{
							@file_data=<SRC_FILE>;
						}

						close SRC_FILE;						

						#loop thru storing the lines
 						foreach $source_line (@file_data)
 						{
							print TEMP ($source_line);
						}

						close TEMP;
					}

					#remove the old file
					unlink $original_path;
				}
				#if we have a .res file
				elsif (lc($file) =~ m/^.+\.res$/)
				{
					#set the temp file
					$temp_file = $file;

					#change the extension
					$temp_file =~ s/webform\.res/webform\-old\.tmp/;

					#set the temp path
					$temp_path = &return_full_path($rem_dir,$temp_file);

					#set the original path
					$original_path = &return_full_path($rem_dir,$file);

					#copy the file over to a temp file
					if (open (TEMP, ">$temp_path"))
					{
						#copy the file over to a temp file
						if (open (SRC_FILE, "$original_path"))
						{
							@file_data=<SRC_FILE>;
						}

						close SRC_FILE;						

						#loop thru storing the lines
 						foreach $source_line (@file_data)
 						{
							print TEMP ($source_line);
						}

						close TEMP;
					}

					#remove the old file
					unlink $original_path;
				}
			}	
		}

		#close the directory
		closedir (DIR);

		#the directory has been cleaned
 		&display_html("removedir=1");

		#add to the log if in diagnostic mode
		if ($diagnostic_on == 1)
		{
			&write_log($LOG_NAME, $MAX_SIZE, "rwsad5.pl", "remove_directory_files_upload", "removedir = 1", $thread_ID, 0);
		}

 		exit;
	}
	else
	{
		#the directory cannot be accessed
 		&display_html("removedir=0");

		#add to the log if in diagnostic mode
		if ($diagnostic_on == 1)
		{
			&write_log($LOG_NAME, $MAX_SIZE, "rwsad5.pl", "remove_directory_files_upload", "removedir = 0", $thread_ID, 0);
		}

 		exit;
	}
}

########################################################################################
# 	FUNCTION THAT CHECKS THAT FORM FILES EXIST ON THE SERVER 		       		       #	
#	USE: $result = &valid_form($form_name,$uploading);					       	       #		
########################################################################################
sub valid_form
{
	my $form_name = $_[0];
	my $uploading = $_[1];
	my $form_config_file = "";
	my $form_config_dir = "";
	my $num_pages = 0;
	my $page_index = 0;
	my $html_file = "";
	my $msg = "";
	my $base_config_file = "";
	my %form_configuration = (); 
	my @ignore_missing = ();
	my $item = "";
	my $found = 0;

	#add to the log if in diagnostic mode
	if ($diagnostic_on == 1)
	{
		&write_log($LOG_NAME, $MAX_SIZE, "rwsad5.pl", "valid_form", "form_name = " . $form_name . " && uploading = " . $uploading, $thread_ID, 1);
	}

	#locate the directory for the form
	$form_config_dir = &return_full_path($install_config{'[Defaults]'}{'Location'},$form_name);

	#see if directory exists on the server
	if(!(opendir MY_DIR,$form_config_dir))
	{
		if($uploading ne '1')
		{
			&general_admin_screen("Form Installation Failure","Details","The [" . $form_name . "] form could not be located on the server. Please try uploading your form again before continuing.","OK","","MAIN!","CENTER","Install");		
			#add to the log if in diagnostic mode
			if ($diagnostic_on == 1)
			{
				&write_log($LOG_NAME, $MAX_SIZE, "rwsad5.pl", "valid_form", "None", $thread_ID, 0);
			}	
			return (0);
			last;
		}
		else
		{
			&display_html("install=0");
			
			#add to the log if in diagnostic mode
			if ($diagnostic_on == 1)
			{
				&write_log($LOG_NAME, $MAX_SIZE, "rwsad5.pl", "valid_form", "install = 0", $thread_ID, 0);
			}

			exit;
		}
	}
   	else
	{
		closedir MY_DIR;
	}
	
	$base_config_file = $form_name . '.cfg';
	$base_config_file = &convert_string($base_config_file);

	#get the full form config file path on the server
	$form_config_file = &return_full_path($form_config_dir,$base_config_file);

	#read the form configuration into the global hash
	%form_configuration = &read_config($form_config_file,1);

	#determine if the file exists
	if (-e $form_config_file)
	{
		#read the form configuration into the global hash
		%form_configuration = &read_config($form_config_file,1);	

		#get the indices of the pages that should not exist because they are URLs
		@ignore_missing = split(/,/,$form_configuration{'[MISC]'}{'CompleteURLIndices'});

		#loop through each section header of the config file
		foreach $subkey (%form_configuration) 
		{

			#ignore if the header does not contain the word "page" (ie., [MISC], [Questions], [Map])
			if ($subkey !~ m/page/) 
			{
				next;
			}

			#if it is a header for a page
			else
			{
				#check to see if it is a redirect
				if ($form_configuration{$subkey}{'#REDIRECT#'} != 1)
				{

					#get the full path from the file stored in the SRC setting
					$html_file = &return_full_path($form_config_dir,$form_configuration{$subkey}{'#SRC#'});

					#if the html file is not there
					if (!(-e $html_file))
					{					
						#if it is missing, add it to the message
						$msg .= '<DIR>' . $html_file;

					}

					next;					
				}									
			}
		}

		#exit now if there are pages missing
		if($msg ne '')
		{
			if($uploading ne '1')
			{
				&general_admin_screen("Form Installation Failure","Details","The following pages are <B>missing</B>:<BR>" . $msg . "</DIR>Please try uploading your form again before continuing.","OK","","MAIN!","CENTER","Install");	
		
				#add to the log if in diagnostic mode
				if ($diagnostic_on == 1)
				{
					&write_log($LOG_NAME, $MAX_SIZE, "rwsad5.pl", "valid_form", "None", $thread_ID, 0);
				}
				
				return (0);
				last;
			}
			else
			{
				&display_html("install=$msg");

				#add to the log if in diagnostic mode
				if ($diagnostic_on == 1)
				{
					&write_log($LOG_NAME, $MAX_SIZE, "rwsad5.pl", "valid_form", "install = " . $form_name . " && uploading = " . $uploading, $thread_ID, 0);
				}			

				exit;
			}
		} 
	}
	else
	{
		if($uploading ne '1')
		{
			&general_admin_screen("Form Installation Failure","Details","The form configuration file [" . $form_config_file . "] could not be located. Please try uploading your form again before continuing.","OK","","MAIN!","CENTER","Install");

			#add to the log if in diagnostic mode
			if ($diagnostic_on == 1)
			{
				&write_log($LOG_NAME, $MAX_SIZE, "rwsad5.pl", "valid_form", "None", $thread_ID, 0);
			}					
			return (0);
		}
		else
		{
			&display_html("install=0");

			#add to the log if in diagnostic mode
			if ($diagnostic_on == 1)
			{
				&write_log($LOG_NAME, $MAX_SIZE, "rwsad5.pl", "valid_form", "install = " . $form_name . " && uploading = " . $uploading, $thread_ID, 0);
			}
			exit;
		}
	}
	#add to the log if in diagnostic mode
	if ($diagnostic_on == 1)
	{
		&write_log($LOG_NAME, $MAX_SIZE, "rwsad5.pl", "valid_form", "None", $thread_ID, 0);
	}

	return (1);
}

########################################################################################
# 	FUNCTION THAT STORES THE INSTALLATION CONFIG FILE INTO A HASH 		       		       #	
#	USE: &get_installation_config_data();					       	       #		
########################################################################################
sub get_installation_config_data
{
	#add to the log if in diagnostic mode
	if ($diagnostic_on == 1)
	{
		&write_log($LOG_NAME, $MAX_SIZE, "rwsad5.pl", "get_installation_config_data", "None", $thread_ID, 1);
	}

	#if the file exists, simply store it into a hash
	if(-e $install_config_file)
	{ 
		%install_config = &read_config($install_config_file,1);
	}
	else
	{
		$install_config{'[Defaults]'}{'Location'} = $cgi_dir;
		$install_config{'[Defaults]'}{'EnableAutoUpload'} = '1';
		$install_config{'[Defaults]'}{'EnableAutoDownload'} = '1';
		$install_config{'[Defaults]'}{'CGIRedirect'} = '1';
		$install_config{'[Defaults]'}{'Logging'} = '1';
		$install_config{"[Defaults]"}{"RemoveServerFiles"} = '1';
		$install_config{"[Defaults]"}{"BackUpData"} = '1';
		$install_config{"[Defaults]"}{"ImageScript"} = 'rwsimg5.pl';
		$install_config{'[Forms]'} = '';

		#write out the defaults
		&write_config(\%install_config,$install_config_file,1);
	}

	#add to the log if in diagnostic mode
	if ($diagnostic_on == 1)
	{
		&write_log($LOG_NAME, $MAX_SIZE, "rwsad5.pl", "get_installation_config_data", "None", $thread_ID, 0);
	}
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

	#add to the log if in diagnostic mode
	if ($diagnostic_on == 1)
	{
		&write_log($LOG_NAME, $MAX_SIZE, "rwsad5.pl", "get_locations", "None", $thread_ID, 1);
	}
	
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

	#add to the log if in diagnostic mode
	if ($diagnostic_on == 1)
	{
		&write_log($LOG_NAME, $MAX_SIZE, "rwsad5.pl", "get_locations", "None", $thread_ID, 0);
	}

	return (@dirs);
}

########################################################################################
# 	FUNCTION THAT RETURNS THE FILES ASSOCIATED WITH A GIVEN FORM #
#	USE: $files = &get_form_files($form_name);					       	       #		
########################################################################################
sub get_form_files
{
	my $form = $_[0];
	my $file_list = "";
	my $file = "";

	#add to the log if in diagnostic mode
	if ($diagnostic_on == 1)
	{
		&write_log($LOG_NAME, $MAX_SIZE, "rwsad5.pl", "get_form_files", "form = " . $form, $thread_ID, 1);
	}

	#check to make sure the form exists (should be the case)
	if(exists $install_config{'[Forms]'}{$form})
	{
		#try to open the directory where the form is located
		if(opendir MY_DIR,$install_config{'[Forms]'}{$form})
		{
			#loop thru the files in the directory
			while($file = readdir(MY_DIR))
			{
				if(($file ne '.') && ($file ne '..'))
				{
					#add the file to the return list
					$file_list .= &return_full_path($install_config{'[Forms]'}{$form},$file) . '<BR>';	
				}
			}

			#close the directory
			closedir MY_DIR;
		}
	}
	$file_list .= '</DIR>';

	#add to the log if in diagnostic mode
	if ($diagnostic_on == 1)
	{
		&write_log($LOG_NAME, $MAX_SIZE, "rwsad5.pl", "get_form_files", "file_list" . $file_list, $thread_ID, 0);
	}
	return $file_list;
}

########################################################################################
# 	FUNCTION THAT REMOVES THE FILES ASSOCIATED WITH A GIVEN FORM #
#	USE: &remove_server_files($form_name);					       	       #		
########################################################################################
sub remove_server_files
{
	my $form = $_[0];
	my $file = "";

	#add to the log if in diagnostic mode
	if ($diagnostic_on == 1)
	{
		&write_log($LOG_NAME, $MAX_SIZE, "rwsad5.pl", "remove_server_files", "form = " . $form, $thread_ID, 1);
	}

	#check to make sure the form exists (should be the case)
	if(exists $install_config{'[Forms]'}{$form})
	{
		#try to open the directory where the form is located
		if(opendir MY_DIR,$install_config{'[Forms]'}{$form})
		{
			#loop thru the files in the directory
			while($file = readdir(MY_DIR))
			{
				if(($file ne '.') && ($file ne '..'))
				{
					#remove the file
					unlink &return_full_path($install_config{'[Forms]'}{$form},$file);	
				}
			}

			#close the directory
			closedir MY_DIR;

			#remove the dir folder too
			rmdir $install_config{'[Forms]'}{$form} 
		}
	}
	#add to the log if in diagnostic mode
	if ($diagnostic_on == 1)
	{
		&write_log($LOG_NAME, $MAX_SIZE, "rwsad5.pl", "remove_server_files", "None", $thread_ID, 0);
	}
	return (1);
}

########################################################################################
# 	FUNCTION THAT ADDS NEW RECORDS TO THE ARCHIVE DATA FILE	 	 					   #
#	USE: $data = &archive_data($RWD_FILE,$RWA_FILE);			   	   			   	   #		
########################################################################################
sub archive_data
{
	my $data_file = $_[0];
	my $archive_file = $_[1];
	my $location = "";
	my $data_lines = "";
	my @file_data = ();
	my $all_lines = "";

	#add to the log if in diagnostic mode
	if ($diagnostic_on == 1)
	{
		&write_log($LOG_NAME, $MAX_SIZE, "rwsad5.pl", "archive_data", "data_file = " . $data_file . " && archive_file = " . $archive_file, $thread_ID, 1);
	}
					
	#if the archive file or data file exists
	if((-e $archive_file) || (-e $data_file))
	{
		#if the data file exists, open it and open the archive for append
		if(-e $data_file)
		{
			open (DATAMAIN, "<$data_file") || die &display_html('archive=-1');
			open (ARCHIVE, ">>$archive_file") || die &display_html('archive=-1');

			#loop thru setting $data_lines to the next line of the file
 			while (defined ($data_lines = <DATAMAIN>))
 			{
 				#remove the line feed from the data
 				chomp $data_lines;
 				
 				#remove the carriage return from the data
 				$data_lines =~ s/\r//g;
 
 				#make sure we have data
 				next if $data_lines =~ /^\s*$/;
 
 				#add the data from the NEW file to the archive file
 				print ARCHIVE "$data_lines\n";
 			}

			#close the archive file
			close (ARCHIVE) || die &display_html('archive=-1');
			
			#set the archive file permissions
			chmod 0600, $archive_file;

			#close the NEW data file and delete the NEW data file
			close (DATAMAIN);
			unlink $data_file;

			#add to the log if in diagnostic mode
			if ($diagnostic_on == 1)
			{
				&write_log($LOG_NAME, $MAX_SIZE, "rwsad5.pl", "archive_data", "Archive successful", $thread_ID, 0);
			}

			return (1);
		}
		else
		{
			#there is no NEW data, but there is archived data

			#add to the log if in diagnostic mode
			if ($diagnostic_on == 1)
			{
				&write_log($LOG_NAME, $MAX_SIZE, "rwsad5.pl", "archive_data", "No New Data", $thread_ID, 0);
			}

			return (1);
		}	
	}
	else
	{
		#no data at all

		#add to the log if in diagnostic mode
		if ($diagnostic_on == 1)
		{
			&write_log($LOG_NAME, $MAX_SIZE, "rwsad5.pl", "archive_data", "No Data", $thread_ID, 0);
		}

		return (0);
	}
}

########################################################################################
# 	FUNCTION THAT DISPLAYS THE LOG FILE						 	 					   #
#	USE: &display_log($form_name); 	   			   	   								   #		
########################################################################################
sub display_log
{
	my $form_name = $_[0];
	my $every_other = 0;
	my $i = 0;
	my $location = "";
	my $log_file = "";
	my @records = ();
	my $line = "";
	my $html_text = "";
	my $tmp_form = "";
	my $base_config_file = "";
	my $form_config_file = "";
	my $form_config_dir = "";
	my %form_configuration = ();

	#add to the log if in diagnostic mode
	if ($diagnostic_on == 1)
	{
		&write_log($LOG_NAME, $MAX_SIZE, "rwsad5.pl", "display_log", "form_name = " . $form_name, $thread_ID, 1);
	}

	#locate the directory for the form
	$form_config_dir = &return_full_path($install_config{'[Forms]'}{$form_name});

	#get the log file name
	$base_config_file = $form_name . '.cfg';
	$base_config_file = &convert_string($base_config_file);

	#get the full form config file path on the server
	$form_config_file = &return_full_path($form_config_dir,$base_config_file);

	#read the form configuration into the hash
	%form_configuration = &read_config($form_config_file,1);
	
	$log_file = $form_configuration{'[MISC]'}{'LogFile'};
	if ($log_file eq '')
	{
		$log_file = 'log-file';
	}
	$log_file .= '.log';

	#get the full location
	$location = &return_full_path($install_config{'[Forms]'}{$form_name},$log_file);

	#check for data files
	if(!(-e $location)) 
	{
		&general_admin_screen("No Log File","Details","No log exists for the " . $form_name . " form.","OK","","MAIN!","CENTER","WebForms");
		return 1;
	}

	#open the log file
	open (LOG_FILE, $location) || die &general_error_screen('No Log File','<B>' . $location . '</B> could not be located.');
	@records = <LOG_FILE>;
	close (LOG_FILE);
	chomp(@records);

	$tmp_form = uc($form_name);

	$html_text = "<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.01 Transitional//EN\">\n";
	$html_text .= "<html><HEAD><META HTTP-EQUIV=\"pragma\" CONTENT=\"no-cache; charset=UTF-8\"><TITLE>$tmp_form LOG FILE</TITLE>";
	$html_text .= "<SCRIPT LANGUAGE=\"JAVASCRIPT\">\n";
	$html_text .= "function perform_navigate(action_name)\n";
	$html_text .= "{\n";
	$html_text .= "switch(action_name)\n";
	$html_text .= "{\n";
	$html_text .= "case \"OK\":\n";
	$html_text .= "document.RWSADMINGET.UID.value = \"@*(uid)\"\n";
	$html_text .= "document.RWSADMINGET.NAV.value = \"WebForms\"\n";
	$html_text .= "document.RWSADMINGET.submit();\n";
	$html_text .= "break\;\n";
	$html_text .= "}\n}\n";
	$html_text .= "</SCRIPT>";

	$html_text .= "</HEAD><body><H2><CENTER>$tmp_form LOG FILE</CENTER></H2><center><table border=1><tr><td><table border=0 cellpadding=2 cellspacing=4>\n<tr><td SCOPE=\"COL\" BGCOLOR=\"#D3D3D3\">";

	$header = "<b><font face='Verdana,Arial' size=2>Entry</font></b></td><td SCOPE=\"COL\" BGCOLOR=\"#D3D3D3\"><b><font face='Verdana,Arial' size=2>UID</font></b></td><td SCOPE=\"COL\" BGCOLOR=\"#D3D3D3\"><b><font face='Verdana,Arial' size=2>Action</font></b></td><td SCOPE=\"COL\" BGCOLOR=\"#D3D3D3\"><b><font face='Verdana,Arial' size=2>Access</font></b></td><td SCOPE=\"COL\" BGCOLOR=\"#D3D3D3\"><b><font face='Verdana,Arial' size=2>Encrypted Password</font></b></td><td SCOPE=\"COL\" BGCOLOR=\"#D3D3D3\"><b><font face='Verdana,Arial' size=2>IP Address</font></b></td><td SCOPE=\"COL\" BGCOLOR=\"#D3D3D3\"><b><font face='Verdana,Arial' size=2>Date</font></b></td><td SCOPE=\"COL\" BGCOLOR=\"#D3D3D3\"><b><font face='Verdana,Arial' size=2>Time</font></b></td></tr>\n";
	$html_text .= "$header<tr><td><tt>";

	#print the log
	foreach $line (@records) 
	{
		$i++;

		$line =~  s/failed/<font color=red>failed<\/font>/g;
		$line =~  s/denied/<font color=red>denied<\/font>/g;
		$line =~  s/permitted/<font color=green>permitted<\/font>/g;
		$line =~  s/successful/<font color=green>successful<\/font>/g;

		if ($every_other eq 0) 
		{
			$line =~ s/\t/<\/tt><\/td><td><tt>/g;
			$line .= "</tt></td></tr>\n<tr>";
			$line .= ($i eq (@records)) ? "<td SCOPE=\"ROW\" bgcolor=\"#D3D3D3\"><tt>" : "<td SCOPE=\"ROW\" bgcolor=\"#EFEFEF\"><tt>";
			$line = "$i<\/tt><\/td><td><tt>" . $line;
			
			$every_other = 1;
		} 
		else
		{
			$line =~ s/\t/<\/tt><\/td><td SCOPE=\"ROW\" bgcolor=\"#EFEFEF\"><tt>/g;
			$line .= "</tt></td></tr>\n<tr>";
			$line .= ($i eq (@records)) ? "<td SCOPE=\"ROW\" bgcolor=\"#D3D3D3\"><tt>" : "<td><tt>";
			$line = "$i<\/tt><\/td><td SCOPE=\"ROW\" bgcolor=\"#EFEFEF\"><tt>" . $line;
			
			$every_other = 0;
		}

		$html_text .= $line;
	}
	$html_text .= "</tt>$header";
	$html_text .= "</table></td></tr></table></center>";
	$html_text .= "<FORM NAME=\"RWSADMINGET\" ACTION=\"@*(admin)\" OnClick=\"perform_navigate('OK')\;\" METHOD=\"GET\">\n";
	$html_text .= "<CENTER><INPUT TYPE=\"BUTTON\" ID=\"SUBMIT\" NAME=\"SUBMIT\" VALUE=\"Control Panel\"></INPUT></CENTER>\n";
	$html_text .= "<INPUT TYPE=\"HIDDEN\" ID=\"UID\" NAME=\"UID\"></INPUT>\n";
	$html_text .= "<INPUT TYPE=\"HIDDEN\" ID=\"NAV\" NAME=\"NAV\"></INPUT>\n";
	$html_text .= "</FORM></body></html>";

	#insert the uid into our form '@*()'
	if($session_uid ne '')
	{
		$html_text =~ s/\@\*\(uid\)/$session_uid/g;
	}
	else
	{
		$html_text =~ s/\@\*\(uid\)//g;
	}

	#insert the admin script into form '@*()'
	$html_text =~ s/\@\*\(admin\)/$admin_script/g;

	&display_html($html_text);

	#add to the log if in diagnostic mode
	if ($diagnostic_on == 1)
	{
		&write_log($LOG_NAME, $MAX_SIZE, "rwsad5.pl", "display_log", "None", $thread_ID, 0);
	}
	exit;
}

########################################################################################
# 	FUNCTION THAT DISPLAYS THE DATA FILE					 	 					   #
#	USE: &display_data($form_name,$details); 	  			   	   					   #		
########################################################################################
sub display_data
{
	my $form_name = $_[0];
	my $details = $_[1];
	my $every_other = 0;
	my $i = 0;
	my $location = "";
	my $archive_location = "";
	my $tmp_file = "";
	my $data_file = "";
	my $archive_file = "";
	my @records = ();
	my $line = "";
	my $html_text = "";
	my $tmp_form = "";
	my $counter = 0;
	my %form_configuration = ();
	my $base_config_file = "";
	my $form_config_file = "";
	my $form_config_dir = "";
	my @pair = ();
	my $key = "";
	my $ques = "";
	my $ans = "";
	my $row_text = "";

	#add to the log if in diagnostic mode
	if ($diagnostic_on == 1)
	{
		&write_log($LOG_NAME, $MAX_SIZE, "rwsad5.pl", "display_data", "form_name = " . $form_name . " && details = " . $details, $thread_ID, 1);
	}

	#locate the directory for the form
	$form_config_dir = 	&return_full_path($install_config{'[Forms]'}{$form_name});

	#get the log file name
	$base_config_file = $form_name . '.cfg';
	$base_config_file = &convert_string($base_config_file);

	#get the full form config file path on the server
	$form_config_file = &return_full_path($form_config_dir,$base_config_file);

	#read the form configuration into the hash
	%form_configuration = &read_config($form_config_file,1);

	#get the log file name
	$tmp_file = $form_configuration{'[MISC]'}{'DataFile'};
	if ($tmp_file eq '')
	{												   
		$tmp_file = 'data-file';
	}
	$data_file = $tmp_file . '.rwd';
	$archive_file = $tmp_file . '.rwa';
	
	#get the full location
	$location = &return_full_path($install_config{'[Forms]'}{$form_name},$data_file);
	$archive_location = &return_full_path($install_config{'[Forms]'}{$form_name},$archive_file);
		  
	#check for data files
	if((!(-e $location)) && (!(-e $archive_location))) 
	{
		&general_admin_screen("No Data","Details","No data exists for the " . $form_name . " form.","OK","","MAIN!","CENTER","Data");
		return 1;
	}
	
	#open the archive data file
	if(-e $archive_location)
	{
		open (DATA_FILE, $archive_location) || die &general_error_screen('File Access Error','An error occurred attempting to open the <B>' . $archive_location . '</B> archive file.');
		@records = <DATA_FILE>;
		close (DATA_FILE);
	}

	#open the data file
	if(-e $location)
	{ 
		open (DATA_FILE, $location) || die &general_error_screen('File Access Error','An error occurred attempting to open the <B>' . $location . '</B> data file.');
		push (@records,<DATA_FILE>);
		close (DATA_FILE);
	}
	
	chomp(@records);

	$tmp_form = uc($form_name);

	$html_text = "<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.01 Transitional//EN\">\n";
	$html_text .= "<html><HEAD><meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\" /><TITLE>$tmp_form DATA FILE</TITLE>";
	$html_text .= "<SCRIPT LANGUAGE=\"JAVASCRIPT\">\n";
	$html_text .= "function perform_navigate(action_name)\n";
	$html_text .= "{\n";
	$html_text .= "switch(action_name)\n";
	$html_text .= "{\n";
	$html_text .= "case \"OK\":\n";
	$html_text .= "document.RWSADMINGET.UID.value = \"@*(uid)\"\n";
	$html_text .= "document.RWSADMINGET.NAV.value = \"Data\"\n";
	$html_text .= "document.RWSADMINGET.submit();\n";
	$html_text .= "break\;\n";
	$html_text .= "}\n}\n";
	$html_text .= "</SCRIPT>";

	$html_text .= "</HEAD><body><H2><CENTER>$tmp_form DATA FILE</CENTER></H2><center>";
	$html_text .= "<FORM NAME=\"RWSADMIN\" ACTION=\"@*(admin)?UID\=@*(uid)\" METHOD=\"POST\">\n";

	#change the link depending on details
	if($details eq '1')
	{
		$html_text .= "<CENTER><INPUT TYPE=\"SUBMIT\" ID=\"VIEW_LESS\" VALUE=\"View Fewer Details\"></INPUT></CENTER><BR>";
	}
	else
	{
		$html_text .= "<CENTER><INPUT TYPE=\"SUBMIT\" ID=\"VIEW_MORE\" VALUE=\"View More Details\"></INPUT></CENTER><BR>";
	}

	$html_text .= "<table border=1><tr><td><table border=0 cellpadding=2 cellspacing=4>\n<tr>";
	$header = "<TD SCOPE\"COL\" BGCOLOR=\"#D3D3D3\"><b><font face='Verdana,Arial' size=2>Entry</font></b></td>";
		
	if($details eq '1')
	{
		$header .= "<TD SCOPE\"COL\" BGCOLOR=\"#999999\"><b><font face='Verdana,Arial' size=2>UID</font></b></td>";
		$header .= "<TD SCOPE\"COL\" BGCOLOR=\"#999999\"><b><font face='Verdana,Arial' size=2>IP Address</font></b></td>";
		$header .= "<TD SCOPE\"COL\" BGCOLOR=\"#999999\"><b><font face='Verdana,Arial' size=2>Time</font></b></td>";
		$header .= "<TD SCOPE\"COL\" BGCOLOR=\"#999999\"><b><font face='Verdana,Arial' size=2>Date</font></b></td>";
	}

	#add in the login data to the beginning
	if (($form_configuration{'[Questions]'}{$form_configuration{'[MISC]'}{'PasswordQuestionKey'} . '_DISPLAY'} ne '0') && ($form_configuration{'[Questions]'}{$form_configuration{'[MISC]'}{'PasswordQuestionKey'} . '_DISPLAY'} ne ""))
	{
		$header .= "<TD SCOPE\"COL\" BGCOLOR=\"#D3D3D3\"><b><font face='Verdana,Arial' size=2>$form_configuration{'[Questions]'}{$form_configuration{'[MISC]'}{'PasswordQuestionKey'} . '_NAME'}</font></b></td>";
		
		#if we have the username set to display, add that too
		if (($form_configuration{'[Questions]'}{$form_configuration{'[MISC]'}{'UsernameQuestionKey'} . '_DISPLAY'} ne '0') && ($form_configuration{'[Questions]'}{$form_configuration{'[MISC]'}{'UsernameQuestionKey'} . '_DISPLAY'} ne ""))
		{
			$header .= "<TD SCOPE\"COL\" BGCOLOR=\"#D3D3D3\"><b><font face='Verdana,Arial' size=2>$form_configuration{'[Questions]'}{$form_configuration{'[MISC]'}{'UsernameQuestionKey'} . '_NAME'}</font></b></td>";
		}
	}

	#loop thru adding the tables columns
	for ($counter=1; $counter<=$form_configuration{'[MISC]'}{'NumQuestions'}; $counter++)
	{
		$prefix = sprintf("%04d",$counter);
		
		$question_ID = $form_configuration{'[Map]'}{'Q' . $prefix};

		#skip if login page
		if (($question_ID eq $form_configuration{'[MISC]'}{'PasswordQuestionKey'}) || ($question_ID eq $form_configuration{'[MISC]'}{'UsernameQuestionKey'}))
		{
			next;
		}

		#determine wether or not to add the column
		if($form_configuration{'[Questions]'}{$question_ID . '_DISPLAY'} ne '0')
		{
			$header .= "<TD SCOPE\"COL\" BGCOLOR=\"#D3D3D3\"><b><font face='Verdana,Arial' size=2>$form_configuration{'[Questions]'}{$question_ID . '_NAME'}</font></b></td>";	
		}
	}

	$header .= "</tr>\n";
	$html_text .= "$header<tr><td><tt>";

	#print the data
	foreach $line (@records) 
	{
		$i++;
		$row_text = "<TD BGCOLOR=\"#@*(color)\"><FONT FACE=\"Verdana,Arial\" SIZE=\"2\">$i</FONT></TD>";
		
		if($details eq '1')
		{
			$row_text .= "<TD SCOPE\"ROW\" BGCOLOR=\"#@*(color)\"><FONT FACE=\"Verdana,Arial\" SIZE=\"2\">@*(session)</FONT></TD>";
			$row_text .= "<TD SCOPE\"ROW\" BGCOLOR=\"#@*(color)\"><FONT FACE=\"Verdana,Arial\" SIZE=\"2\">@*(ip)</FONT></TD>";
			$row_text .= "<TD SCOPE\"ROW\" BGCOLOR=\"#@*(color)\"><FONT FACE=\"Verdana,Arial\" SIZE=\"2\">@*(sub_time)</FONT></TD>";
			$row_text .= "<TD SCOPE\"ROW\" BGCOLOR=\"#@*(color)\"><FONT FACE=\"Verdana,Arial\" SIZE=\"2\">@*(date)</FONT></TD>";
		}

		#add in the login data to the beginning
		if(($form_configuration{'[Questions]'}{$form_configuration{'[MISC]'}{'PasswordQuestionKey'} . '_DISPLAY'} ne "0") && ($form_configuration{'[Questions]'}{$form_configuration{'[MISC]'}{'PasswordQuestionKey'} . '_DISPLAY'} ne ""))
		{
			$row_text .= "<TD SCOPE\"ROW\" BGCOLOR=\"#@*(color)\"><FONT FACE=\"Verdana,Arial\" SIZE=\"2\">@*($form_configuration{'[MISC]'}{'PasswordQuestionKey'})</FONT></TD>";
	
			#add in the username if set to display		
			if(($form_configuration{'[Questions]'}{$form_configuration{'[MISC]'}{'UsernameQuestionKey'} . '_DISPLAY'} ne "0") && ($form_configuration{'[Questions]'}{$form_configuration{'[MISC]'}{'UsernameQuestionKey'} . '_DISPLAY'} ne ""))
			{
				$row_text .= "<TD SCOPE\"ROW\" BGCOLOR=\"#@*(color)\"><FONT FACE=\"Verdana,Arial\" SIZE=\"2\">@*($form_configuration{'[MISC]'}{'UsernameQuestionKey'})</FONT></TD>";
			}
		}

		$html_text .= "<TR>";

		#loop thru adding the tables columns
		for ($counter=1; $counter<=$form_configuration{'[MISC]'}{'NumQuestions'}; $counter++)
		{
			$prefix = sprintf("%04d",$counter);

			$question_ID = $form_configuration{'[Map]'}{'Q' . $prefix};

			#skip if login page
			if (($question_ID eq $form_configuration{'[MISC]'}{'PasswordQuestionKey'}) || ($question_ID eq $form_configuration{'[MISC]'}{'UsernameQuestionKey'}))
			{
				next;
			}
			
			#determine wether or not to add the column
			if($form_configuration{'[Questions]'}{$question_ID . '_DISPLAY'} ne '0')
			{
				$row_text .= "<TD SCOPE\"ROW\" BGCOLOR=\"#@*(color)\"><FONT FACE=\"Verdana,Arial\" SIZE=\"2\">@*($question_ID)</FONT></TD>";	
			}
		}
		
		#store each key=value pair in an array
		@pair = split(/\t/,$line);

		#loop thru the array inserting answers
		foreach $key (@pair)
		{
			#get the QX value
			$ques = (split(/\=/,$key,2))[0];
			
			#get the answer value
			$ans = (split(/\=/,$key,2))[1];


			$ascii_char = chr(11);
			$ans =~ s/$ascii_char/,/g;

			#insert the extra details
			if($ques eq 'DATE')
			{
				$row_text =~ s/\@\*\(date\)/$ans/g;
			}
			elsif($ques eq 'TIME')
			{
				$row_text =~ s/\@\*\(sub_time\)/$ans/g;
			}
			elsif($ques eq 'UID')
			{
				$row_text =~ s/\@\*\(session\)/$ans/g;
			}
			elsif($ques eq 'IP')
			{
				$row_text =~ s/\@\*\(ip\)/$ans/g;
			}
			else
			{
				$row_text =~ s/\@\*\($ques\)/$ans/g;
			}
		}

		#if there is no IP (data tracking turned off), remove the IP holder
		$row_text =~ s/\@\*\(ip\)//g;
		
		#loop thru removing any answers	that were not defined
		for ($counter=1; $counter<=$form_configuration{'[MISC]'}{'NumQuestions'}; $counter++)
		{
			$prefix = sprintf("%04d",$counter);

			$question_ID = $form_configuration{'[Map]'}{'Q' . $prefix};

			#insert the question answer into the table
			$row_text =~ s/\@\*\($question_ID\)//g;
		}

		if ($every_other eq 0) 
		{
			#insert the color into the table
			$row_text =~ s/\@\*\(color\)/FFFFFF/g;
			$every_other = 1;
		} 
		else
		{
			#insert the color into the table
			$row_text =~ s/\@\*\(color\)/EFEFEF/g;
			$every_other = 0;
		}

		if($details eq '0')
		{
			#insert the question answer into the table
			$row_text =~ s/\@\*\(session\)//g;
			$row_text =~ s/\@\*\(ip\)//g;
			$row_text =~ s/\@\*\(date\)//g;
			$row_text =~ s/\@\*\(sub_time\)//g;
		}


		#remove answer id tags
		$row_text =~ s/\@\*\[(\S*?)\]\*\@//g;

		$html_text .= $row_text . "</TR>";
	}
	$html_text .= "</tt>$header";
	$html_text .= "</table></td></tr></table></center>";
	
	if($details eq '1')
	{
		$html_text .= "<INPUT TYPE=\"HIDDEN\" ID=\"FORM_ACTION\" NAME=\"FORM_ACTION\" VALUE=\"VIEW_DATA!$form_name\"></INPUT>\n";
	}
	else
	{
		$html_text .= "<INPUT TYPE=\"HIDDEN\" ID=\"FORM_ACTION\" NAME=\"FORM_ACTION\" VALUE=\"VIEW_DATA_DETAILS!$form_name\"></INPUT>\n";
	}
	$html_text .= "</FORM>";
	$html_text .= "<FORM NAME=\"RWSADMINGET\" ACTION=\"@*(admin)\" METHOD=\"GET\">";
	$html_text .= "<CENTER><INPUT TYPE=\"BUTTON\" ID=\"Control Panel\" onClick=\"perform_navigate('OK')\;\" NAME=\"Control Panel\" VALUE=\"Control Panel\"></INPUT></CENTER>\n";
	$html_text .= "<INPUT TYPE=\"HIDDEN\" ID=\"UID\" NAME=\"UID\"></INPUT>\n";
	$html_text .= "<INPUT TYPE=\"HIDDEN\" ID=\"NAV\" NAME=\"NAV\"></INPUT>\n";

	$html_text .= "</FORM></body></html>";

	#insert the uid into our form '@*()'
	if($session_uid ne '')
	{
		$html_text =~ s/\@\*\(uid\)/$session_uid/g;
	}
	else
	{
		$html_text =~ s/\@\*\(uid\)//g;
	}

	#insert the admin script into form '@*()'
	$html_text =~ s/\@\*\(admin\)/$admin_script/g;

	&display_html($html_text);

	#add to the log if in diagnostic mode
	if ($diagnostic_on == 1)
	{
		&write_log($LOG_NAME, $MAX_SIZE, "rwsad5.pl", "display_data", "None", $thread_ID, 0);
	}
	exit;
}

########################################################################################
# 	FUNCTION THAT PERFORMS A LOGOUT							 	 					   #
#	USE: &remove_admin_info(); 	  			   	   									   #		
########################################################################################
sub remove_admin_info
{
	my $info_keys = "";
	my $curr_time = "";
	my $ip_address = "";
	my $time = "";
	my $uid = "";

	#add to the log if in diagnostic mode
	if ($diagnostic_on == 1)
	{
		&write_log($LOG_NAME, $MAX_SIZE, "rwsad5.pl", "remove_admin_info", "None", $thread_ID, 1);
	}

	#if the rws config file does not exists then time could not have lapsed
	if(!(-e $rws_config_file))
	{
		return (1);
	}

	#get the current time
	$curr_time = &localtime_in_minutes();

	#for each IP entry in the file
	foreach $info_keys (keys %{$rws_config{'[INFO]'}})
	{
		#split the IP entry into the IP address and the time it was logged
		($ip_address, $time, $permissions, $current_user) = split (/\|/, $rws_config{'[INFO]'}{$info_keys});

		#if the entry is the user's IP address and if uid is the same
		if(($ip_address eq $ENV{'REMOTE_ADDR'}) && ($info_keys eq $session_uid))
		{
			delete $rws_config{$info_keys};
			&write_config(\%rws_config,$rws_config_file,1); 
			last;
		}
	}

	#add to the log if in diagnostic mode
	if ($diagnostic_on == 1)
	{
		&write_log($LOG_NAME, $MAX_SIZE, "rwsad5.pl", "remove_admin_info", "None", $thread_ID, 0);
	}
}		
										
########################################################################################
# 	FUNCTION THAT RESETS THE DATA FILES					 	 					       #
#	USE: &reset_data($FormName,$log); 	  			   	   							   #		
########################################################################################
sub reset_data
{
	my $form = $_[0];
	my $log = $_[1];
	my $file = "";
	my $ext = "";

	#add to the log if in diagnostic mode
	if ($diagnostic_on == 1)
	{
		&write_log($LOG_NAME, $MAX_SIZE, "rwsad5.pl", "reset_data", "form = " . $form . "  && log = " . $log, $thread_ID, 1);
	}

	if($log eq '1')
	{
		$ext = "log";
	}
	else
	{
		$ext = "rwd|rwa";
	}

	#check to make sure the form exists (should be the case)
	if(exists $install_config{'[Forms]'}{$form})
	{
		#try to open the directory where the form is located
		if(opendir MY_DIR,$install_config{'[Forms]'}{$form})
		{
			#loop thru the files in the directory
			while($file = readdir(MY_DIR))
			{
				if(($file ne '.') && ($file ne '..'))
				{
					#remove the data file(s)
					if(lc($file) =~ /^.+\.($ext)$/)
					{
						unlink &return_full_path($install_config{'[Forms]'}{$form},$file);	
					}
				}					  
			}
			#close the directory
			closedir MY_DIR;
		}
	}

	#add to the log if in diagnostic mode
	if ($diagnostic_on == 1)
	{
		&write_log($LOG_NAME, $MAX_SIZE, "rwsad5.pl", "reset_data", "None", $thread_ID, 1);
	}
	return (1);
}

########################################################################################
# 	FUNCTION THAT RESETS THE DATA FILES					 	 					       #
#	USE: &download_log($FormName); 	  			   	   				   				   #		
########################################################################################
sub download_log
{
   	my $form_name = $_[0];
	my $location = "";
	my $log_file = "";
	my @records = ();
	my $base_config_file = "";
	my $form_config_file = "";
	my $form_config_dir = "";
	my %form_configuration = ();

	#add to the log if in diagnostic mode
	if ($diagnostic_on == 1)
	{
		&write_log($LOG_NAME, $MAX_SIZE, "rwsad5.pl", "download_log", "form_name = " . $form_name, $thread_ID, 1);
	}

	#locate the directory for the form
	$form_config_dir = &return_full_path($install_config{'[Forms]'}{$form_name});

	#get the log file name
	$base_config_file = $form_name . '.cfg';
	$base_config_file = &convert_string($base_config_file);

	#get the full form config file path on the server
	$form_config_file = &return_full_path($form_config_dir,$base_config_file);

	#read the form configuration into the hash
	%form_configuration = &read_config($form_config_file,1);
	
	$log_file = $form_configuration{'[MISC]'}{'LogFile'};
	if ($log_file eq '')
	{
		$log_file = 'log-file';
	}
	$log_file .= '.log';

	#get the full location
	$location = &return_full_path($install_config{'[Forms]'}{$form_name},$log_file);

	if(!(-e $location)) 
	{
		&general_admin_screen("No Log","Details","No log file exists for the " . $form_name . " form.","OK","","MAIN!","CENTER","WebForms");
		return 1;
	}

	#open the log file
	open (LOG_FILE, $location) || die &general_error_screen('No Log File','<B>' . $location . '</B> could not be opened.');
	@records = <LOG_FILE>;
	close (LOG_FILE);

	print "Content-type: application/octet-stream\n";
	print "Content-disposition: attachment; filename=$log_file\n\n";
	print @records;

	#add to the log if in diagnostic mode
	if ($diagnostic_on == 1)
	{
		&write_log($LOG_NAME, $MAX_SIZE, "rwsad5.pl", "download_log", "None", $thread_ID, 0);
	}

	return 1;
}

########################################################################################
# 	FUNCTION THAT DOWNLOADS THE DATA FILE	       				       #
#	USE: &download_data($form_name); 	  			   	       #		
########################################################################################
sub download_data
{
	my $form_name = $_[0];
	my $location = "";
	my $archive_location = "";
	my $data_file = "";
	my $archive_file = "";
	my @archive_records = ();
	my %form_configuration = ();
	my $base_config_file = "";
	my $form_config_file = "";
	my $form_config_dir = "";

	#add to the log if in diagnostic mode
	if ($diagnostic_on == 1)
	{
		&write_log($LOG_NAME, $MAX_SIZE, "rwsad5.pl", "download_data", "form_name = " . $form_name, $thread_ID, 1);
	}	

	#locate the directory for the form
	$form_config_dir = &return_full_path($install_config{'[Forms]'}{$form_name});

	#get the log file name
	$base_config_file = $form_name . '.cfg';
	$base_config_file = &convert_string($base_config_file);

	#get the full form config file path on the server
	$form_config_file = &return_full_path($form_config_dir,$base_config_file);

	#read the form configuration into the hash
	%form_configuration = &read_config($form_config_file,1);

	#get the log file name
	$data_file = $form_configuration{'[MISC]'}{'DataFile'};
	if ($data_file eq '')
	{												   
		$data_file = 'data-file';
	}
	$archive_file = $data_file;
	$data_file .= '.rwd';
	$archive_file .= '.rwa';

	#get the full locations
	$location = &return_full_path($install_config{'[Forms]'}{$form_name},$data_file);
	$archive_location = &return_full_path($install_config{'[Forms]'}{$form_name},$archive_file);

	#if there is no data file
	if((!(-e $location)) && (!(-e $archive_location))) 
	{
		&general_admin_screen("No Data","Details","No data exists for the " . $form_name . " form.","OK","","MAIN!","CENTER","Data");
		return 1;
	}

	print "Content-type: application/octet-stream\n";
	print "Content-disposition: attachment; filename=$form_name-data.rwd\n\n";

	#open the archive file
	if(-e $archive_location)
	{
		open (DATA_FILE, $archive_location) || die &general_error_screen('Data File Access Error','<B>' . $archive_location . '</B> could not be opened.');
		@archive_records = <DATA_FILE>;
		close (DATA_FILE);
	}

	#open the data file
	if(-e $location)
	{
		open (DATA_FILE, $location) || die &general_error_screen('Data File Access Error','<B>' . $location . '</B> could not be opened.');
		push (@archive_records, <DATA_FILE>);
		close (DATA_FILE);
	}
	print @archive_records;

	#add to the log if in diagnostic mode
	if ($diagnostic_on == 1)
	{
		&write_log($LOG_NAME, $MAX_SIZE, "rwsad5.pl", "download_data", "None", $thread_ID, 0);
	}
	return 1;
}
########################################################################################
# 	FUNCTION THAT DISPLAYS HTML OF INVALID SESSION SCREENS FILLED WITH PARAMETERS #
#	USE: &logged_out_screen($title,$header,$msg,$ok_button,$cancel_button,$action_text,$button_align);					       	       #		
########################################################################################
sub logged_out_screen
{
	my $html_title = $_[0];
	my $header_text = $_[1];
	my $msg_text = $_[2];
	my $ok_text = $_[3];
	my $cancel_text = $_[4];
	my $action_text = $_[5];
	my $button_align = $_[6];
	my $html_text = "";

	#add to the log if in diagnostic mode
	if ($diagnostic_on == 1)
	{
		&write_log($LOG_NAME, $MAX_SIZE, "rwsad5.pl", "logged_out_screen", "html_title = " . $html_title . " && header_text = " . $header_text . " && msg_text = " . $msg_text, $thread_ID, 1);
	}
	
	#open up the external html file
	open (SRC_FILE, $cgi_dir . "html/5/timeout.html") || die print "Could not open file html/5/timeout.html";
	
	#read the file into an array 
	@file_data = <SRC_FILE>;

	#close the source file because we are finished reading in the key=value pairs
	close (SRC_FILE);

	#loop thru storing the lines
 	foreach $source_lines (@file_data)
 	{	
 		#remove the \n character
 		chop ($source_lines);
		$html_text .=  $source_lines;
		 		
 	}         

	#insert the admin script into form '@*()'
	$html_text =~ s/\@\*\(admin\)/$admin_script/g;

	#insert the title into our form '@*()'
	$html_text =~ s/\@\*\(html_title\)/$html_title/g;
	
	#insert the header into our form '@*()'
	$html_text =~ s/\@\*\(header\)/$header_text/g;
	
	#insert the message/question/confirmation into our form '@*()'
	$html_text =~ s/\@\*\(msg_text\)/$msg_text/g;														

	#insert the ok text into our form '@*()'
	$html_text =~ s/\@\*\(ok_text\)/$ok_text/g;
	
	#insert the cancel text into our form '@*()'
	$html_text =~ s/\@\*\(cancel_text\)/$cancel_text/g;

	#insert the action into our form '@*()'
	$html_text =~ s/\@\*\(action\)/$action_text/g;

	#insert the action into our form '@*()'
	$html_text =~ s/\@\*\(button_align\)/$button_align/g;

	#insert the date for the copyright dynamically '@*()'
	@timeData = localtime(time);
	#assigns the value localtime assigns for year to year_offset
	$year_offset = $timeData[5];
	#data is in years since 1900, adds 1900 to get correct year
	$year = 1900 + $year_offset; 
	$html_text =~ s/\@\*\(year\)/$year/g;
	
	#insert the uid into our form '@*()'
	if($session_uid ne '')
	{
		$html_text =~ s/\@\*\(uid\)/\?UID\=$session_uid/g;
	}
	else
	{
		$html_text =~ s/\@\*\(uid\)//g;
	}

	#insert the images cript in to display the logo
	#if the defined default exists, use that
	if (-e $install_config{"[Defaults]"}{"ImageScript"})
	{
		$html_text =~ s/\@\*\(img\)/$install_config{"[Defaults]"}{"ImageScript"}\?ADMIN\=1/g;  
	}
	#if not, check for rwsimg5.pl and use that
	elsif (-e $cgi_dir . 'rwsimg5.pl')
	{
		$html_text =~ s/\@\*\(img\)/rwsimg5\.pl\?ADMIN\=1/g;  
	}
	#if not, check for rwsimg5.cgi and use that
	elsif (-e $cgi_dir . 'rwsimg5.cgi')
	{
		$html_text =~ s/\@\*\(img\)/rwsimg5\.cgi\?ADMIN\=1/g;  
	}
	#if not, check for rwsimg5.plx and use that
	elsif (-e $cgi_dir . 'rwsimg5.plx')
	{
		$html_text =~ s/\@\*\(img\)/rwsimg5\.plx\?ADMIN\=1/g;  
	}
	#otherwise, get rid of the image tag altogether
	else
	{
		$html_text =~ s/\<img .*?src\=\"\@\*\(img\).*?\/\>//g;
	}
 									   
	&display_html($html_text);

	#add to the log if in diagnostic mode
	if ($diagnostic_on == 1)
	{
		&write_log($LOG_NAME, $MAX_SIZE, "rwsad5.pl", "logged_out_screen", "None", $thread_ID, 0);
	}

	return 1;
}

########################################################################################
# 	FUNCTION THAT ANALYZES THE DATA FOR A GIVEN FORM AND RETURNS THE HTML OUTPUT   #
#	USE: &analyze_data($form_name);					       	       #		
########################################################################################
sub analyze_data
{
	my $form_name = $_[0];
	$question_ID = "";
	%statistics = ();
	my @answers = ();
	my $statoutput = "";
	my %num_responses = ();

	#add to the log if in diagnostic mode
	if ($diagnostic_on == 1)
	{
		&write_log($LOG_NAME, $MAX_SIZE, "rwsad5.pl", "analyze_data", "form_name = " . $form_name, $thread_ID, 1);
	}

	#locate the directory for the form
	$form_config_dir = &return_full_path($install_config{'[Forms]'}{$form_name});

	#get the config file name
	$base_config_file = $form_name . '.cfg';
	$base_config_file = &convert_string($base_config_file);

	#get the full form config file path on the server
	$form_config_file = &return_full_path($form_config_dir,$base_config_file);

	#read the form configuration into the hash
	%form_configuration = &read_config($form_config_file,1);

	#get the data and archive file names
	$data_file = &return_full_path($install_config{'[Forms]'}{$form_configuration{'[MISC]'}{'FormName'}},$form_configuration{'[MISC]'}{'DataFile'});
	$archive_file = $data_file . '.rwa';
	$data_file .= '.rwd';

	#if there is a .rwa file
	if (open(DATA, $archive_file)) {

		#read in each line
		while( $line = <DATA> ){

			#increase the total number of responses
			$num_responses{'Total'}++;

			#loop through the questions
			for ($counter=1; $counter<=$form_configuration{'[MISC]'}{'NumQuestions'}; $counter++)
				{
				#create the prefix to lookup the ID
				$prefix = 'Q' . sprintf("%04d",$counter);

				#get the QID
				$question_ID = $form_configuration{'[Map]'}{$prefix};

				#if it is a textbox question, skip
				if ($form_configuration{'[Questions]'}{$question_ID . '_TYPE'} eq "TEXT")
				{
					next;
				}

				#if a line has the QID=non whitespace characters followed by a tab or endline
				if ($line =~ /$question_ID\=([\S\ ]*)[\t\n]/) {

					#increase the number of responses for that question
					$num_responses{$question_ID}++;
					#store the temp variable in temp_response
					$temp_response = $1;
					$mult_char = chr(11);

					#if it does not have multiple responses, increment the hash for that response
					if ($temp_response !~ /[\(\$mult_char\)]/) {
						$statistics{$question_ID}{$temp_response}++;
						}

					#if it does have multiple responses, increment the hash for each response
					else {						
						$temp_response =~ s/\(//;
						$temp_response =~ s/\)//;

						@answers = split (/$mult_char/, $temp_response);
						foreach (@answers) {
							$statistics{$question_ID}{$_}++;
							}
						}
					}
				}
			}
		close FILE;
		}

	#if there is a .rwd file
	if (open(DATA, $data_file)) {

		#read in each line
		while( $line = <DATA> ){

			#increase the total number of responses
			$num_responses{'Total'}++;

			#loop through the questions
			for ($counter=1; $counter<=$form_configuration{'[MISC]'}{'NumQuestions'}; $counter++)
				{
				#create the prefix to lookup the ID
				$prefix = 'Q' . sprintf("%04d",$counter);

				#get the QID
				$question_ID = $form_configuration{'[Map]'}{$prefix};

				#if it is a textbox question, skip
				if ($form_configuration{'[Questions]'}{$question_ID . '_TYPE'} eq "TEXT")
				{
					next;
				}

				#if a line has the QID=non whitespace characters followed by a tab or endline
				if ($line =~ /$question_ID\=([\S\ ]*)[\t\n]/) {

					#increase the number of responses for that question
					$num_responses{$question_ID}++;
					#store the temp variable in temp_response
					$temp_response = $1;
					$mult_char = chr(11);

					#if it does not have multiple responses, increment the hash for that response
					if ($temp_response !~ /[\(\$mult_char\)]/) {
						$statistics{$question_ID}{$temp_response}++;
						}

					#if it does have multiple responses, increment the hash for each response
					else {						
						$temp_response =~ s/\(//;
						$temp_response =~ s/\)//;

						@answers = split (/$mult_char/, $temp_response);
						foreach (@answers) {
							$statistics{$question_ID}{$_}++;
							}
						}
					}
				}
			}
		close FILE;
		}

	#set the html output to the total number of responses
	$statoutput = 'Total responses: ' . $num_responses{'Total'} . "<BR><table>";

	#loop through each question
	for ($counter=1; $counter<=$form_configuration{'[MISC]'}{'NumQuestions'}; $counter++)
		{
		#create the prefix to lookup the ID
		$prefix = 'Q' . sprintf("%04d",$counter);

		#get the QID
		$question_ID = $form_configuration{'[Map]'}{$prefix};

		#if it is the password question, skip
		if (($question_ID eq $form_configuration{'[MISC]'}{'PasswordQuestionKey'}) || ($question_ID eq $form_configuration{'[MISC]'}{'UsernameQuestionKey'}))
		{
			next;
		}

		#if it is a textbox question, skip
		if ($form_configuration{'[Questions]'}{$question_ID . '_TYPE'} eq "TEXT")
			{
				next;
			}

		#if no question text, use the field name
		if($form_configuration{'[Questions]'}{$question_ID . '_TEXT'} ne "")
		{
			$question_text_display = $form_configuration{'[Questions]'}{$question_ID . '_TEXT'};
		}
		else
		{
			$question_text_display = $form_configuration{'[Questions]'}{$question_ID . '_NAME'};
		}

		#if the display is set to on
		if ($form_configuration{'[Questions]'}{$question_ID . '_DISPLAY'} == 1) 
			{

			#add the question html
			$statoutput .= "</table><BR><STRONG>" . $question_text_display . "</STRONG><br>";
			$statoutput .= $num_responses{$question_ID} . " responses, " . ($num_responses{'Total'} - $num_responses{$question_ID}) . " missing <br /><br /><table border=\"0\" width=\"525\"><tr>";

			#add each response html and a table to show the graph	
			foreach $response (sort statsort keys %{$statistics{$question_ID}}) 
			{
				#set a temporary variable for the text label
				$response_label = $response;

				#check to see if there is an HTML display for the response
				if ($form_configuration{'[AnswerMap]'}{'[' . $question_ID . '][' . $response_label . ']'} ne "")
				{
					$response_label = $form_configuration{'[AnswerMap]'}{'[' . $question_ID . '][' . $response_label . ']'};
				}

				#remove the answer ids
				$response_label =~ s/\@\*\[(\S*?)\]\*\@//g;

				$statoutput .= "<td align=\"right\" width=\"215\">" . $response_label . " </td><td width=\"10\">\&nbsp\;</td><td><table height=\"20px\" width=\"200px\"><tr><td width=\"" . sprintf("%.0f", ($statistics{$question_ID}{$response} / $num_responses{$question_ID}) * 200) . "\" style=\"background-color: @*(GRAPH_COLOR)\"></td><td width=\"" . (200 -sprintf("%.0f", ($statistics{$question_ID}{$response} / $num_responses{$question_ID}) * 200)) . "\"></td></tr></table></td><td width=\"100\" align=\"right\">" . $statistics{$question_ID}{$response} . " (" . sprintf("%.2f", ($statistics{$question_ID}{$response} / $num_responses{$question_ID}) * 100) . "%) </td></tr>";
			}
		} 
	}

	#add the final close table tag
	$statoutput .= "</table>";

	#replace any pipes with their question text
	while ($statoutput =~ m/\[PIPE\_ID\](\S*?)\[\/PIPE\]/)
	{
		$question_text = $form_configuration{'[Questions]'}{$1 . '_TEXT'};
		$statoutput =~ s/\[PIPE\_ID\]$1\[\/PIPE\]/\[$question_text\]/g;
	}

	#add to the log if in diagnostic mode
	if ($diagnostic_on == 1)
	{
		&write_log($LOG_NAME, $MAX_SIZE, "rwsad5.pl", "analyze_data", "None", $thread_ID, 1);
	}

	return $statoutput;
}

########################################################################################
# 	FUNCTION THAT DISPLAYS THE STATISTICS SCREEN #
#	USE: &general_admin_screen($title,$header,$msg,$ok_button,$cancel_button,$action_text,$button_align,$navigation_page));					       	       #		
########################################################################################
sub display_stats_screen
{
	my $html_title = $_[0];
	my $header_text = $_[1];
	my $msg_text = $_[2];
	my $ok_text = $_[3];
	my $cancel_text = $_[4];
	my $action_text = $_[5];
	my $button_align = $_[6];
	my $navigation_page = "$_[7]";    #added so that it returns to previous navigation screen
	my $form = $_[8];
	my $report = $_[9];	#added to select radio button of current report - 0 is item analysis, 1 is response report
	my $html_text = "";
	my $interval_length = "";

	#add to the log if in diagnostic mode
	if ($diagnostic_on == 1)
	{
		&write_log($LOG_NAME, $MAX_SIZE, "rwsad5.pl", "display_stats_screen", "html_title = " . $html_title . " && header_text = " . $header_text . " && msg_text = " . $msg_text, $thread_ID, 1);
	}

	#locate the directory for the form
	$form_config_dir = &return_full_path($install_config{'[Forms]'}{$form});

	#get the log file name
	$base_config_file = $form . '.cfg';
	$base_config_file = &convert_string($base_config_file);

	#get the full form config file path on the server
	$form_config_file = &return_full_path($form_config_dir,$base_config_file);

	#read the form configuration into the hash
	%form_configuration = &read_config($form_config_file,1);

	#get the log file name
	$data_file = $form_configuration{'[MISC]'}{'DataFile'};
	if ($data_file eq '')
	{												   
		$data_file = 'data-file';
	}
	$archive_file = $data_file;
	$data_file .= '.rwd';
	$archive_file .= '.rwa';

	#get the full locations
	$location = &return_full_path($install_config{'[Forms]'}{$form},$data_file);
	$archive_location = &return_full_path($install_config{'[Forms]'}{$form},$archive_file);
	
	#check for data files
	if((!(-e $location)) && (!(-e $archive_location))) 
	{
		&general_admin_screen("No Data","Details","No data exists for the " . $form_name . " form.","OK","","MAIN!","CENTER","Data");
		return 1;
	}
	
	#open up the external html file
	open (SRC_FILE, $cgi_dir . "html/5/stats.html") || die print "Could not open html/5/general.html";
	
	#read the file into an array 
	@file_data = <SRC_FILE>;

	#close the source file because we are finished reading in the key=value pairs
	close (SRC_FILE);

	#loop thru storing the lines
 	foreach $source_lines (@file_data)
 	{	
 		#remove the \n character
 		chop ($source_lines);
		$html_text .=  $source_lines;
		 		
 	}        

	$temp_var = $rws_config{'[INFO]'}{$session_uid};
	($IP, $time, $permissions, $current_user) = split(/\|/, $temp_var);

	#insert the tabs
	if ($permissions eq "1")
	{
		$tab_html = "<li><a href=\"@*(admin)@*(uid)&NAV=Setup\">Server Setup</a></li><li><a href=\"@*(admin)@*(uid)&NAV=WebForms\">Web Forms</a></li><li><a class=\"selected\">Data & Stats</a></li><li><a href=\"@*(admin)@*(uid)&NAV=Users\">Users</a></li><li><a href=\"@*(admin)@*(uid)&NAV=Password\">Password</a></li><li><a href=\"@*(admin)@*(uid)&NAV=Diagnostics\">Diagnostics</a></li>";
		$html_text =~ s/\@\*\(nav_tabs\)/$tab_html/g;
	}
	else
	{
		$tab_html = "<li><a class=\"selected\">Data & Stats</a></li><li><a href=\"@*(admin)@*(uid)&NAV=Password\">Password</a></li>";
		$html_text =~ s/\@\*\(nav_tabs\)/$tab_html/g;
	}   

	#insert the username
	#unescape out equals and endlines
	$current_user =~ s/\(equals\)/\=/g;
	$current_user =~ s/\(end\)/\n/g;

	use MIME::Base64;	

	#decode the username
	$decoded_user = decode_base64($current_user);

	$html_text =~ s/\@\*\(username\)/$decoded_user/g;

	#insert the admin script into form '@*()'
	$html_text =~ s/\@\*\(admin\)/$admin_script/g;

	#insert the title into our form '@*()'
	$html_text =~ s/\@\*\(html_title\)/$html_title/g;
	
	#insert the header into our form '@*()'
	$html_text =~ s/\@\*\(header\)/$header_text/g;
	
	#insert the message/question/confirmation into our form '@*()'
	$html_text =~ s/\@\*\(msg_text\)/$msg_text/g;														

	#insert the ok text into our form '@*()'
	$html_text =~ s/\@\*\(ok_text\)/$ok_text/g;
	
	#insert the cancel text into our form '@*()'
	$html_text =~ s/\@\*\(cancel_text\)/$cancel_text/g;

	#insert the action into our form '@*()'
	$html_text =~ s/\@\*\(action\)/$action_text/g;

	#insert the button alignment into our form '@*()'
	$html_text =~ s/\@\*\(button_align\)/$button_align/g;
	
	#insert the form name into our form '@*()'
	$html_text =~ s/\@\*\(form_name\)/$form/g;

	#insert the graph color into our form '@*()'
	$html_text =~ s/\@\*\(GRAPH_COLOR\)/\#FFFFFF/g;

	if ($report == 1)
	{
		#insert the checked response_report into our form '@*()'
		$html_text =~ s/\@\*\(response\_report\)/checked\=\"checked\"/g;

		#remove the checked item_analysis into our form '@*()'
		$html_text =~ s/\@\*\(item\_analysis\)//g;

		#remove the checked duration_report into our form '@*()'
		$html_text =~ s/\@\*\(duration\_report\)//g;

		#remove the duration value from our form '@*()'
		$html_text =~ s/\@\*\(interval\_report\)//g;
	}
	elsif ($report == 0)
	{
		#insert the checked item_analysis into our form '@*()'
		$html_text =~ s/\@\*\(item\_analysis\)/checked\=\"checked\"/g;

		#remove the checked response_report into our form '@*()'
		$html_text =~ s/\@\*\(response\_report\)//g;

		#remove the checked duration_report into our form '@*()'
		$html_text =~ s/\@\*\(duration\_report\)//g;

		#remove the duration value from our form '@*()'
		$html_text =~ s/\@\*\(interval\_report\)//g;
	}
	else
	{
		($report, $interval_length) = split(/\!/, $report);	

		#remove the checked item_analysis into our form '@*()'
		$html_text =~ s/\@\*\(item\_analysis\)//g;

		#remove the checked response_report into our form '@*()'
		$html_text =~ s/\@\*\(response\_report\)//g;

		#add the checked duration_report into our form '@*()'
		$html_text =~ s/\@\*\(duration\_report\)/checked\=\"checked\"/g;

		#add the duration value from our form '@*()'
		$html_text =~ s/\@\*\(interval\_report\)/$interval_length/g;
	}

	#insert the date for the copyright dynamically '@*()'
	@timeData = localtime(time);
	#assigns the value localtime assigns for year to year_offset
	$year_offset = $timeData[5];
	#data is in years since 1900, adds 1900 to get correct year
	$year = 1900 + $year_offset; 
	$html_text =~ s/\@\*\(year\)/$year/g;

	#insert the images cript in to display the logo
	#if the defined default exists, use that
	if (-e $install_config{"[Defaults]"}{"ImageScript"})
	{
		$html_text =~ s/\@\*\(img\)/$install_config{"[Defaults]"}{"ImageScript"}\?ADMIN\=1/g;  
	}
	#if not, check for rwsimg5.pl and use that
	elsif (-e $cgi_dir . 'rwsimg5.pl')
	{
		$html_text =~ s/\@\*\(img\)/rwsimg5\.pl\?ADMIN\=1/g;  
	}
	#if not, check for rwsimg5.cgi and use that
	elsif (-e $cgi_dir . 'rwsimg5.cgi')
	{
		$html_text =~ s/\@\*\(img\)/rwsimg5\.cgi\?ADMIN\=1/g;  
	}
	#if not, check for rwsimg5.plx and use that
	elsif (-e $cgi_dir . 'rwsimg5.plx')
	{
		$html_text =~ s/\@\*\(img\)/rwsimg5\.plx\?ADMIN\=1/g;  
	}
	#otherwise, get rid of the image tag altogether
	else
	{
		$html_text =~ s/\<img .*?src\=\"\@\*\(img\).*?\/\>//g;
	}
	
	#insert the uid into our form '@*()'
	if($session_uid ne '')
	{
		$html_text =~ s/\@\*\(uid\)/\?UID\=$session_uid/g;
		$html_text =~ s/\@\*\(uid\_get\)/$session_uid/g;
	}
	else
	{
		$html_text =~ s/\@\*\(uid\)//g;
		$html_text =~ s/\@\*\(uid\_get\)//g;
	}
 	
	#insert the uid for submitting into our form '@*()'- this is needed for the general admin screen to return to previous navigation using the get form on the page
	if($session_uid ne '')
	{
		$html_text =~ s/\@\*\(uid_submit\)/$session_uid/g;
	}
	else
	{
		$html_text =~ s/\@\*\(uid_submit\)//g;
	}	

	#insert the navigation into our form '@*()'
	$html_text =~ s/\@\*\(nav\)/$navigation_page/g;	
								   
	&display_html($html_text);

	#add to the log if in diagnostic mode
	if ($diagnostic_on == 1)
	{
		&write_log($LOG_NAME, $MAX_SIZE, "rwsad5.pl", "display_stats_screen", "None", $thread_ID, 0);
	}

	return 1;
}

########################################################################################
# 	FUNCTION THAT DISPLAYS HTML OF A GENERIC SCREEN FILLED WITH PARAMETERS #
#	USE: &general_admin_screen($title,$header,$msg,$ok_button,$cancel_button,$action_text,$button_align,$navigation_page));					       	       #		
########################################################################################
sub display_print_stats
{
	my $html_title = $_[0];
	my $header_text = $_[1];
	my $msg_text = $_[2];
	my $ok_text = $_[3];
	my $cancel_text = $_[4];
	my $action_text = $_[5];
	my $button_align = $_[6];
	my $navigation_page = $_[7];    #added so that it returns to previous navigation screen
	my $form = $_[8];
	my $report = $_[9];	#added to select radio button of current report - 0 is item analysis, 1 is response report
	my $html_text = "";
	my $interval_length = "";

	#add to the log if in diagnostic mode
	if ($diagnostic_on == 1)
	{
		&write_log($LOG_NAME, $MAX_SIZE, "rwsad5.pl", "display_print_stats", "html_title = " . $html_title . " && header_text = " . $header_text . " && msg_text = " . $msg_text, $thread_ID, 1);
	}
	
	
	#open up the external html file
	open (SRC_FILE, $cgi_dir . "html/5/printstats.html") || die print "Could not open html/5/general.html";
	
	#read the file into an array 
	@file_data = <SRC_FILE>;

	#close the source file because we are finished reading in the key=value pairs
	close (SRC_FILE);

	#loop thru storing the lines
 	foreach $source_lines (@file_data)
 	{	
 		#remove the \n character
 		chop ($source_lines);
		$html_text .=  $source_lines;
		 		
 	}        

	#insert the admin script into form '@*()'
	$html_text =~ s/\@\*\(admin\)/$admin_script/g;

	#insert the title into our form '@*()'
	$html_text =~ s/\@\*\(html_title\)/$html_title/g;
	
	#insert the header into our form '@*()'
	$html_text =~ s/\@\*\(header\)/$header_text/g;
	
	#insert the message/question/confirmation into our form '@*()'
	$html_text =~ s/\@\*\(msg_text\)/$msg_text/g;														

	#insert the ok text into our form '@*()'
	$html_text =~ s/\@\*\(ok_text\)/$ok_text/g;
	
	#insert the cancel text into our form '@*()'
	$html_text =~ s/\@\*\(cancel_text\)/$cancel_text/g;

	#insert the action into our form '@*()'
	$html_text =~ s/\@\*\(action\)/$action_text/g;

	#insert the button alignment into our form '@*()'
	$html_text =~ s/\@\*\(button_align\)/$button_align/g;

	#insert the form name into our form '@*()'
	$html_text =~ s/\@\*\(form_name\)/$form/g;

	#insert the graph color into our form '@*()'
	$html_text =~ s/\@\*\(GRAPH_COLOR\)/\#C0C0C0/g;

	if ($report == 1)
	{
		#insert the checked response_report into our form '@*()'
		$html_text =~ s/\@\*\(response\_report\)/checked\=\"checked\"/g;

		#remove the checked item_analysis into our form '@*()'
		$html_text =~ s/\@\*\(item\_analysis\)//g;

		#remove the checked duration_report into our form '@*()'
		$html_text =~ s/\@\*\(duration\_report\)//g;

		#remove the duration value from our form '@*()'
		$html_text =~ s/\@\*\(interval\_report\)//g;
	}
	elsif ($report == 0)
	{
		#insert the checked item_analysis into our form '@*()'
		$html_text =~ s/\@\*\(item\_analysis\)/checked\=\"checked\"/g;

		#remove the checked response_report into our form '@*()'
		$html_text =~ s/\@\*\(response\_report\)//g;

		#remove the checked duration_report into our form '@*()'
		$html_text =~ s/\@\*\(duration\_report\)//g;

		#remove the duration value from our form '@*()'
		$html_text =~ s/\@\*\(interval\_report\)//g;
	}
	else
	{
		($report, $interval_length) = split(/\!/, $report);	

		#remove the checked item_analysis into our form '@*()'
		$html_text =~ s/\@\*\(item\_analysis\)//g;

		#remove the checked response_report into our form '@*()'
		$html_text =~ s/\@\*\(response\_report\)//g;

		#add the checked duration_report into our form '@*()'
		$html_text =~ s/\@\*\(duration\_report\)/checked\=\"checked\"/g;

		#add the duration value from our form '@*()'
		$html_text =~ s/\@\*\(interval\_report\)/$interval_length/g;
	}

	#insert the date for the copyright dynamically '@*()'
	@timeData = localtime(time);
	#assigns the value localtime assigns for year to year_offset
	$year_offset = $timeData[5];
	#data is in years since 1900, adds 1900 to get correct year
	$year = 1900 + $year_offset; 
	$html_text =~ s/\@\*\(year\)/$year/g;
	
	#insert the uid into our form '@*()'
	if($session_uid ne '')
	{
		$html_text =~ s/\@\*\(uid\)/\?UID\=$session_uid/g;
	}
	else
	{
		$html_text =~ s/\@\*\(uid\)//g;
	}
 	
	#insert the uid for submitting into our form '@*()'- this is needed for the general admin screen to return to previous navigation using the get form on the page
	if($session_uid ne '')
	{
		$html_text =~ s/\@\*\(uid_submit\)/$session_uid/g;
	}
	else
	{
		$html_text =~ s/\@\*\(uid_submit\)//g;
	}	

	#insert the navigation into our form '@*()'
	$html_text =~ s/\@\*\(nav\)/$navigation_page/g;	
								   
	&display_html($html_text);

	#add to the log if in diagnostic mode
	if ($diagnostic_on == 1)
	{
		&write_log($LOG_NAME, $MAX_SIZE, "rwsad5.pl", "display_print_stats", "None", $thread_ID, 1);
	}

	return 1;
}


########################################################################################
# 	FUNCTION THAT SORTS THE STATISTICS DATA 				       #	
#	USE: sort statsort keys %hash		   		          	       #		
########################################################################################
sub statsort 
{
	#create an empty hash to store the html values in
	%html_values = ();

	#first sort by the higher number of responses
	if ($statistics{$question_ID}{$b} != $statistics{$question_ID}{$a})
	{
		$statistics{$question_ID}{$b} <=> $statistics{$question_ID}{$a};
	}

	#if same number of responses, sort alphabetically
	else
	{
		#If there is an HTML value for a checkbox, store that in the html hash
		if ($form_configuration{'[AnswerMap]'}{'[' . $question_ID . '][' . $a . ']'})
		{
			$html_value{$a} = $form_configuration{'[AnswerMap]'}{'[' . $question_ID . '][' . $a . ']'};
		}
		#Otherwise use the value in the key
		else
		{
			$html_value{$a} = $a;
			$html_value{$a} =~ s/([\S\_]*?)\@\*\[(\S*?)\]\*\@//g;
		}

		#If there is an HTML value for a checkbox, store that in the html hash
		if ($form_configuration{'[AnswerMap]'}{'[' . $question_ID . '][' . $b . ']'})
		{
			$html_value{$b} = $form_configuration{'[AnswerMap]'}{'[' . $question_ID . '][' . $b . ']'};
		}
		#Otherwise use the value in the key
		else
		{
			$html_value{$b} = $b;
			$html_value{$b} =~ s/([\S\_]*?)\@\*\[(\S*?)\]\*\@//g;
		}

		lc($html_value{$a}) cmp lc($html_value{$b});
	}
}	

########################################################################################
# 	FUNCTION THAT ANALYZES THE DATA FOR A GIVEN FORM AND RETURNS THE HTML OUTPUT   #
#	USE: &response_report($form_name);					       	       #		
########################################################################################
sub response_report
{
	my $form_name = $_[0];
	$question_ID = "";
	my @answers = ();
	my $statoutput = "";
	my %num_responses = ();
	my $ans_counter = 0;

	#add to the log if in diagnostic mode
	if ($diagnostic_on == 1)
	{
		&write_log($LOG_NAME, $MAX_SIZE, "rwsad5.pl", "response_report", "form_name = " . $form_name, $thread_ID, 1);
	}

	#locate the directory for the form
	$form_config_dir = &return_full_path($install_config{'[Forms]'}{$form_name});

	#get the config file name
	$base_config_file = $form_name . '.cfg';
	$base_config_file = &convert_string($base_config_file);

	#get the full form config file path on the server
	$form_config_file = &return_full_path($form_config_dir,$base_config_file);

	#read the form configuration into the hash
	%form_configuration = &read_config($form_config_file,1);

	#get the data and archive file names
	$data_file = &return_full_path($install_config{'[Forms]'}{$form_configuration{'[MISC]'}{'FormName'}},$form_configuration{'[MISC]'}{'DataFile'});
	$archive_file = $data_file . '.rwa';
	$data_file .= '.rwd';

	#if there is a .rwa file
	if (open(DATA, $archive_file)) 
	{

		#read in each line
		while( $line = <DATA> )
		{

			#loop through the questions
			for ($counter=1; $counter<=$form_configuration{'[MISC]'}{'NumQuestions'}; $counter++)
			{
				#create the prefix to lookup the ID
				$prefix = 'Q' . sprintf("%04d",$counter);

				#get the QID
				$question_ID = $form_configuration{'[Map]'}{$prefix};

				#if it is not a textbox question, skip
				if ($form_configuration{'[Questions]'}{$question_ID . '_TYPE'} ne "TEXT")
				{
					next;
				}

				#if a line has the QID=non whitespace characters followed by a tab or endline
				if ($line =~ /$question_ID\=([\S\ ]*)[\t\n]/) {

					#increase the number of responses for that question
					$num_responses{$question_ID}++;
					#store the temp variable in temp_response
					$temp_response = $1;

					$ans_counter = scalar keys %{$statistics{$question_ID}};

					$statistics{$question_ID}{$ans_counter} = $temp_response;

				}
			}
		}
		close FILE;
	}

	#if there is a .rwd file
	if (open(DATA, $data_file)) 
	{

		#read in each line
		while( $line = <DATA> )
		{

			#loop through the questions
			for ($counter=1; $counter<=$form_configuration{'[MISC]'}{'NumQuestions'}; $counter++)
			{
				#create the prefix to lookup the ID
				$prefix = 'Q' . sprintf("%04d",$counter);

				#get the QID
				$question_ID = $form_configuration{'[Map]'}{$prefix};

				#if it is not a textbox question, skip
				if ($form_configuration{'[Questions]'}{$question_ID . '_TYPE'} ne "TEXT")
				{
					next;
				}

				#if a line has the QID=non whitespace characters followed by a tab or endline
				if ($line =~ /$question_ID\=([\S\ ]*)[\t\n]/) 
				{

					#increase the number of responses for that question
					$num_responses{$question_ID}++;
					#store the temp variable in temp_response
					$temp_response = $1;

					$ans_counter = scalar keys %{$statistics{$question_ID}};

					$statistics{$question_ID}{$ans_counter} = $temp_response;

				}
			}
		}
		close FILE;
	}

	#set the html output to the total number of responses
	$statoutput = "";

	#loop through each question
	for ($counter=1; $counter<=$form_configuration{'[MISC]'}{'NumQuestions'}; $counter++)
	{
		#create the prefix to lookup the ID
		$prefix = 'Q' . sprintf("%04d",$counter);

		#get the QID
		$question_ID = $form_configuration{'[Map]'}{$prefix};

		#if it is the password question, skip
		if (($question_ID eq $form_configuration{'[MISC]'}{'PasswordQuestionKey'}) || ($question_ID eq $form_configuration{'[MISC]'}{'UsernameQuestionKey'}))
		{
			next;
		}

		#if it is not a textbox question, skip
		if ($form_configuration{'[Questions]'}{$question_ID . '_TYPE'} ne "TEXT")
		{
			next;
		}

		#if no question text, use the field name
		if($form_configuration{'[Questions]'}{$question_ID . '_TEXT'} ne "")
		{
			$question_text_display = $form_configuration{'[Questions]'}{$question_ID . '_TEXT'};
		}
		else
		{
			$question_text_display = $form_configuration{'[Questions]'}{$question_ID . '_NAME'};
		}

		#if the display is set to on
		if (($form_configuration{'[Questions]'}{$question_ID . '_DISPLAY'} == 1) && ($form_configuration{'[Questions]'}{$question_ID . '_RWS_HIDDEN'} ne "1"))
		{

			#add the question html
			$statoutput .= "<table width=\"700px\" border=\"1\"><tr><td style=\"vertical-align:top\"><BR><STRONG>" . $question_text_display . "</STRONG></tr></td>";

			$number_responses = scalar keys %{$statistics{$question_ID}};

			#add each response html and a table to show the graph	
			for ($output_counter = 0; $output_counter <= $number_responses; $output_counter++)
			{
				#set a temporary variable for the text label
				$response_label = $statistics{$question_ID}{$output_counter};

				#check to see if there is an HTML display for the response
				if ($form_configuration{'[AnswerMap]'}{'[' . $question_ID . '][' . $response_label . ']'} ne "")
				{
					$response_label = $form_configuration{'[AnswerMap]'}{'[' . $question_ID . '][' . $response_label . ']'};
				}

				#remove the answer ids
				$response_label =~ s/\@\*\[(\S*?)\]\*\@//g;

				$statoutput .= "<tr height=\"auto\"><td style=\"border-style:solid\;vertical-aligh:top\">" . $response_label . " </td></tr>\n";
			}

			#add the close table tag
			$statoutput .= "</table><br /><br />";
		} 
	}

	#replace any pipes with their question text
	while ($statoutput =~ m/\[PIPE\_ID\](\S*?)\[\/PIPE\]/)
	{
		$question_text = $form_configuration{'[Questions]'}{$1 . '_TEXT'};
		$statoutput =~ s/\[PIPE\_ID\]$1\[\/PIPE\]/\[$question_text\]/g;
	}

	#add to the log if in diagnostic mode
	if ($diagnostic_on == 1)
	{
		&write_log($LOG_NAME, $MAX_SIZE, "rwsad5.pl", "response_report", "None", $thread_ID, 0);
	}

	return $statoutput;
}

########################################################################################
# 	FUNCTION THAT ADDS RECORDS TO THE INCOMPLETE DATA FILE			   #
#	USE: $add_success=&add_incomplete_records(); 				       	       			   	   #		
########################################################################################
sub add_incomplete_records
{
	my $data_file = "";
	my $key_index = "";
	my $lock_file = "";
	my $key = "";
	my $value = "";
	my $ques = "";
	my %merge_hash = ();
	my %data_hash = ();
	my $counter = 0;
	my $lock_cnt = 0;
	my $data_line = "";
	my $month = "";
	my $yr = "";
	my $hour = "";
	my $append = "AM";
	my $prefix = "";
	my @visited_pages = ();
	my $tmp_key = "";
	my $tmp_index = "";
	my $data_directory = $_[0];
	my $incomplete_uid = $_[1];
	my $formname = $_[2];

	#add to the log if in diagnostic mode
	if ($diagnostic_on == 1)
	{
		&write_log($LOG_NAME, $MAX_SIZE, "rwsad5.pl", "add_incomplete_records", "data_directory = " . $data_directory . " && incomplete_uid = " . $incomplete_uid . " && form_name = " . $form_name, $thread_ID, 1);
	}

	#get the data file name
	$data_file = $data_directory . $formname . "-incomplete";
	$lock_file = $data_file . '.lck';
	$data_file .= '.rwd';

	#if lock file exists, delay up to 5 seconds before opening the data file
	while ((-e $lock_file) and ($lock_cnt < 5)) 
	{
		sleep 1;
		$lock_cnt++;
	}

	#if the lock file does not exist, create it
	if (!(-e $lock_file))
	{
		if (open (LOCK_FILE, ">$lock_file")) 
		{
			close(LOCK_FILE);
		}
	}
	
			
	#loop thru all submitted items - skip MISC section
	foreach $key_index (sort keys %form_uid)
	{ 
		if($key_index ne '[MISC]')
		{
			foreach $key (sort keys %{$form_uid{$key_index}})
			{ 
				#turns '[Page_X]' into X]
				$tmp_index = (split(/\_/,$key_index))[1];

				#turns 'X]' into X
				$tmp_index = (split(/\]/,$tmp_index))[0];

				#do NOT write out info for pages that were NOT truly submitted (BACK BUTTON WAS USED)
				@visited_pages = split(/\,/,$form_uid{'[MISC]'}{'SubmittedPages'});
				foreach $tmp_key (@visited_pages)
				{
					if($tmp_key eq $tmp_index)
					{
						#add all page items into ONE HASH
						$merge_hash{$key} = $form_uid{$key_index}{$key};

						last;
					} 	
				} 		
			}
		}
	}
	
	#add the password entry if protected
	if($form_configuration{'[MISC]'}{'PasswordProtected'} eq '1')
 	{
		#Get the QID for the password question
		$password_question_ID =  $form_configuration{'[MISC]'}{'PasswordQuestionKey'};
		$data_hash{$password_question_ID} = $form_uid{'[MISC]'}{'PWD'};

		#Add the username if there is one
		if ($form_configuration{'[MISC]'}{'UsernameQuestionKey'} ne "")
		{
			$data_hash{$form_configuration{'[MISC]'}{'UsernameQuestionKey'}} = $form_uid{'[MISC]'}{'USER'};
		}
 	}

	#loop thru the MERGED hash storing the data hash of key=value
	foreach $key_index (sort mysort keys %merge_hash)
	{
		#converts QID_RWS_XXXX to QID
		$ques = (split(/\_/,$key_index))[0];	

		#if it's an other question, skip it as it will be added later
		if (($key_index =~ /\_OTHER$/) && ($key_index !~ /MPD\-/) && ($merge_hash{$key_index} ne "on"))
		{
			next;
		}	
		
		#store the correct answer, if checkbox use part of the KEY not value (on)!
		if($merge_hash{$key_index} eq 'on')
		{
			#if there is an other question
			if($merge_hash{$key_index . '_OTHER'} ne "")
			{
				#find the answer id
				$key_index =~ m/\@\*\[(\S*?)\]\*\@/;

				$answer_id = $1;

				#set the value to the other value
				$value = "@*[" . $answer_id . "]*@" . $merge_hash{$key_index . '_OTHER'};
			}
			#if not, set $value to the value
			else
			{
				$value = (split(/\_/,$key_index,2))[1]; 
			}
		}
		else
		{
			#if there is an other question
			if ($merge_hash{$ques . '_' . $merge_hash{$key_index} . '_OTHER'} ne "")
			{
				#find the answer id
				$merge_hash{$key_index} =~ m/\@\*\[(\S*?)\]\*\@/;

				$answer_id = $1;

				#set the value to the other value
				$value = "@*[" . $answer_id . "]*@" . $merge_hash{$ques . '_' . $merge_hash{$key_index} . '_OTHER'};
			}
			#if not, set $value to the value
			else
			{
				$value = $merge_hash{$key_index};
			}
		}

		#replace CRLF with a space
		$value =~ s/\r\l/ /g;

		#if there is a value
		if ($value ne "")
		{
			#if there isn't already a value for the question, add the value to the hash 
			if(!(exists $data_hash{$ques}))	
			{
				$data_hash{$ques} = $value;	
			}
			#otherwise, add parentheses and commas
			else
			{
				#if there are parentheses, remove them temporarily
				if (($data_hash{$ques} =~ /^\(/) && ($data_hash{$ques} =~ /\)$/))
				{
					$data_hash{$ques} = substr($data_hash{$ques},1,length($data_hash{$ques})-2);
				}

				#add the new value and reinsert the parantheses
				$data_hash{$ques} .= "," . $value;
				$data_hash{$ques} = "(" . $data_hash{$ques} . ")";
			}
		}
		#otherwise go to the next pair
		else
		{
			next;
		}
	}

	#loop thru the data hash and write the data
	for ($counter=1; $counter<=$form_configuration{'[MISC]'}{'NumQuestions'}; $counter++)
	{
		#create the prefix to lookup the ID
		$prefix = 'Q' . sprintf("%04d",$counter);

		#get the QID
		$question_ID = $form_configuration{'[Map]'}{$prefix};

		#if defined, write QID=Answer
		if($data_hash{$question_ID} ne '')
		{
			$data_line .= $question_ID . '=' . $data_hash{$question_ID} . "\t"; 		
		}
	}

	#check to see if there is actual data in the UID file - if not, do not write anything to data file
	if ($data_line eq "")
	{
		#clean up the lock file if it exists
		if(-e $lock_file)
		{
			unlink $lock_file; 
		}

		return 1;
	}

	#open the data file - IF OPEN FAILS KILL LOCK FILE TOO
	if(!(open(DATADIR, ">>$data_file")))
	{
		#if the error message is not define, give it a default one
		if ($form_configuration{'[MISC]'}{'ErrorMessageFileAccess'} eq "")
		{
			$form_configuration{'[MISC]'}{'ErrorMessageFileAccess'} = "File Access Error: An error occurred attempting to access a file. Please check the file and directory permissions before continuing.";
		}

		&show_server_error($ERROR_NUM_FILE_ACCESS,"File Access Error",$form_configuration{'[MISC]'}{'ErrorMessageFileAccess'} . " [" . $data_file . "]", __LINE__);

		#clean up the lock file if it exists
		if(-e $lock_file)
		{
			unlink $lock_file; 
		}
		return 0;
	}
	
	#add the UID value
	$data_line .= 'UID=' . $incomplete_uid . "\t";

	#write out the data to the file
	print DATADIR "$data_line\n";

	if(!(close (DATADIR)))
	{
		if(-e $lock_file)
		{
			unlink $lock_file; 
		}
		return 0;
	}

	#clean up the lock file if it exists
	if(-e $lock_file)
	{
		unlink $lock_file; 
	}

	#set the file permissions
	chmod(0600, $data_file);

	#add to the log if in diagnostic mode
	if ($diagnostic_on == 1)
	{
		&write_log($LOG_NAME, $MAX_SIZE, "rwsad5.pl", "add_incomplete_records", "None", $thread_ID, 1);
	}

	return(1);
}

########################################################################################
# 	FUNCTION THAT CHECKS FOR INCOMPLETE DATA RECORDS			   #
#	USE: $incomplete_present=&check_incomplete_records(); 				       	       			   	   #		
########################################################################################
sub check_incomplete_records
{
	my $data_file = "";
	my $key_index = "";
	my $key = "";
	my $value = "";
	my $ques = "";
	my %merge_hash = ();
	my %data_hash = ();
	my $counter = 0;
	my $append = "AM";
	my $prefix = "";
	my @visited_pages = ();
	my $tmp_key = "";
	my $tmp_index = "";
	my $data_directory = $_[0];

	#add to the log if in diagnostic mode
	if ($diagnostic_on == 1)
	{
		&write_log($LOG_NAME, $MAX_SIZE, "rwsad5.pl", "check_incomplete_records", "data_directory = " . $data_directory, $thread_ID, 1);
	}
		
	#loop thru all submitted items - skip MISC section
	foreach $key_index (sort keys %form_uid)
	{ 
		if($key_index ne '[MISC]')
		{
			foreach $key (sort keys %{$form_uid{$key_index}})
			{ 
				#turns '[Page_X]' into X]
				$tmp_index = (split(/\_/,$key_index))[1];

				#turns 'X]' into X
				$tmp_index = (split(/\]/,$tmp_index))[0];

				#do NOT write out info for pages that were NOT truly submitted (BACK BUTTON WAS USED)
				@visited_pages = split(/\,/,$form_uid{'[MISC]'}{'SubmittedPages'});
				foreach $tmp_key (@visited_pages)
				{
					if($tmp_key eq $tmp_index)
					{
						#add all page items into ONE HASH
						$merge_hash{$key} = $form_uid{$key_index}{$key};

						last;
					} 	
				} 		
			}
		}
	}

	#loop thru the MERGED hash storing the data hash of key=value
	foreach $key_index (sort mysort keys %merge_hash)
	{
		#converts QID_RWS_XXXX to QID
		$ques = (split(/\_/,$key_index))[0];	

		#if it's an other question, skip it as it will be added later
		if (($key_index =~ /\_OTHER$/) && ($key_index !~ /MPD\-/) && ($merge_hash{$key_index} ne "on"))
		{
			next;
		}	
		
		#store the correct answer, if checkbox use part of the KEY not value (on)!
		if($merge_hash{$key_index} eq 'on')
		{
			#if there is an other question
			if($merge_hash{$key_index . '_OTHER'} ne "")
			{
				#find the answer id
				$key_index =~ m/\@\*\[(\S*?)\]\*\@/;

				$answer_id = $1;

				#set the value to the other value
				$value = "@*[" . $answer_id . "]*@" . $merge_hash{$key_index . '_OTHER'};
			}
			#if not, set $value to the value
			else
			{
				$value = (split(/\_/,$key_index,2))[1]; 
			}
		}
		else
		{
			#if there is an other question
			if ($merge_hash{$ques . '_' . $merge_hash{$key_index} . '_OTHER'} ne "")
			{
				#find the answer id
				$merge_hash{$key_index} =~ m/\@\*\[(\S*?)\]\*\@/;

				$answer_id = $1;

				#set the value to the other value
				$value = "@*[" . $answer_id . "]*@" . $merge_hash{$ques . '_' . $merge_hash{$key_index} . '_OTHER'};
			}
			#if not, set $value to the value
			else
			{
				$value = $merge_hash{$key_index};
			}
		}

		#replace CRLF with a space
		$value =~ s/\r\l/ /g;

		#if there is a value
		if ($value ne "")
		{
			#if there isn't already a value for the question, add the value to the hash 
			if(!(exists $data_hash{$ques}))	
			{
				$data_hash{$ques} = $value;	
			}
			#otherwise, add parentheses and commas
			else
			{
				#if there are parentheses, remove them temporarily
				if (($data_hash{$ques} =~ /^\(/) && ($data_hash{$ques} =~ /\)$/))
				{
					$data_hash{$ques} = substr($data_hash{$ques},1,length($data_hash{$ques})-2);
				}

				#add the new value and reinsert the parantheses
				$data_hash{$ques} .= "," . $value;
				$data_hash{$ques} = "(" . $data_hash{$ques} . ")";
			}
		}
		#otherwise go to the next pair
		else
		{
			next;
		}
	}

	#loop thru the data hash and write the data
	for ($counter=1; $counter<=$form_configuration{'[MISC]'}{'NumQuestions'}; $counter++)
	{
		#create the prefix to lookup the ID
		$prefix = 'Q' . sprintf("%04d",$counter);

		#get the QID
		$question_ID = $form_configuration{'[Map]'}{$prefix};

		#if defined, write QID=Answer
		if($data_hash{$question_ID} ne '')
		{
			return 1;		
		}
	}

	#add to the log if in diagnostic mode
	if ($diagnostic_on == 1)
	{
		&write_log($LOG_NAME, $MAX_SIZE, "rwsad5.pl", "check_incomplete_records", "None", $thread_ID, 0);
	}

	return 0;
}

########################################################################################
# 	FUNCTION THAT DISPLAYS THE EDIT USER PAGE		       		       #	
#	USE: &display_user_edit($edit); use the 						       	       #		
########################################################################################
sub display_user_edit
{
	my $html_text = "";
	my $tmp_list = "";
	my $htmlfile = "";
	my $add = $_[0];
	my $username = $_[1]; #Added to help display web forms

	#add to the log if in diagnostic mode
	if ($diagnostic_on == 1)
	{
		&write_log($LOG_NAME, $MAX_SIZE, "rwsad5.pl", "display_user_edit", "add = " . $add . " && username = " . $username, $thread_ID, 1);
	}

	$htmlfile = "html/5/edituser.html";

	$temp_var = $rws_config{'[INFO]'}{$session_uid};
	($IP, $time, $permissions, $current_user) = split(/\|/, $temp_var);

	#open up the external html file
	open (SRC_FILE, $cgi_dir . $htmlfile) || die print "Could not open file $htmlfile";
	
	#read the file into an array 
	@file_data = <SRC_FILE>;

	#close the source file because we are finished reading in the key=value pairs
	close (SRC_FILE);

	#loop thru storing the lines into the variable $html_text
 	foreach $source_lines (@file_data)
 	{	
 		#remove the \n character
 		chop ($source_lines);
		$html_text .=  $source_lines;
		 		
 	}

	#insert the admin script into form '@*()'
	$html_text =~ s/\@\*\(admin\)/$admin_script/g;

	#insert the default location into our form '@*()'
	$html_text =~ s/\@\*\(default_dir\)/$install_config{"[Defaults]"}{"Location"}/g;
	
	#insert the admin email address into our form '@*()'
	#$html_text =~ s/\@\*\(admin_email\)/$install_config{"[Defaults]"}{"AdminEmail"}/g;

	#insert the data script into form '@*()'
	$html_text =~ s/\@\*\(data\)/$form_address/g;
	
	#insert the date for the copyright dynamically into our form'@*()'
	@timeData = localtime(time);
	#the sixth value in the timeData array is the number of years since 1900
	$year_offset = $timeData[5];
	#add 1900 to get correct year
	$year = 1900 + $year_offset; 
	#inserts it into the form
	$html_text =~ s/\@\*\(year\)/$year/g;

	#insert the images cript in to display the logo
	#if the defined default exists, use that
	if (-e $install_config{"[Defaults]"}{"ImageScript"})
	{
		$html_text =~ s/\@\*\(img\)/$install_config{"[Defaults]"}{"ImageScript"}\?ADMIN\=1/g;  
	}
	#if not, check for rwsimg5.pl and use that
	elsif (-e $cgi_dir . 'rwsimg5.pl')
	{
		$html_text =~ s/\@\*\(img\)/rwsimg5\.pl\?ADMIN\=1/g;  
	}
	#if not, check for rwsimg5.cgi and use that
	elsif (-e $cgi_dir . 'rwsimg5.cgi')
	{
		$html_text =~ s/\@\*\(img\)/rwsimg5\.cgi\?ADMIN\=1/g;  
	}
	#if not, check for rwsimg5.plx and use that
	elsif (-e $cgi_dir . 'rwsimg5.plx')
	{
		$html_text =~ s/\@\*\(img\)/rwsimg5\.plx\?ADMIN\=1/g;  
	}
	#otherwise, get rid of the image tag altogether
	else
	{
		$html_text =~ s/\<img .*?src\=\"\@\*\(img\).*?\/\>//g;
	}

	#insert the username
	#unescape out equals and endlines
	$current_user =~ s/\(equals\)/\=/g;
	$current_user =~ s/\(end\)/\n/g;

	use MIME::Base64;	

	#decode the username
	$decoded_user = decode_base64($current_user);

	$html_text =~ s/\@\*\(username\)/$decoded_user/g;

	#add a blank selection to be displayed first
	$form_list_html = "";
	
	#loop thru each form and add it to the list
	foreach $key (sort keys %{$install_config{"[Forms]"}})
	{
		my $replace_key = $key . "_CHECKED";
		$form_list_html .= "\&nbsp\;\&nbsp\;\&nbsp\;\&nbsp\;\&nbsp\;\&nbsp\;\&nbsp\;\&nbsp\;\<input type\=\"checkbox\" id=\"forms\" name=\"forms\" value\=\"$key\" @*($replace_key) \/\> $key\<br \/\>\n";	
	}

	#insert the form lists into our form '@*()'
	$html_text =~ s/\@\*\(form_checks\)/$form_list_html/g;

	#if editing, select the checked options
	if ($add == 0)
	{
		#set the title to "Edit User"
		$html_text =~  s/\@\*\(EditUserTitle\)/Edit User/g;

		#set the edit user flag to 1
		$html_text =~  s/\@\*\(EditFlag\)/1/g;

		#encode the username
		$encoded_username = encode_base64($username);

		$encoded_username =~ s/\=/\(equals\)/g;
		$encoded_username =~ s/\n/\(end\)/g;

		#if it is set to admin
		if($rws_config{'[USER]'}{$encoded_username} == 1)
		{
			$html_text =~  s/\@\*\(administrator_CHECKED\)/checked\=\"checked\"/g;
		}
		#otherwise we have stats only, get the form names
		else
		{
			($permissions, $form_list) = split (/\!/, $rws_config{'[USER]'}{$encoded_username});

			#get the auto upload and download permissions
			($admin, $upload, $download) = split (/\|/, $permissions);

			if (($form_list eq "*allforms*") || ($form_list eq "*ALLFORMS*"))
			{
				$html_text =~  s/\@\*\(all_CHECKED\)/checked\=\"checked\"/g;

				#if automatic publishing is enabled, check it
				if ($upload == 1)
				{
					$html_text =~  s/\@\*\(regular_publish\)/checked\=\"checked\"/g;
					$html_text =~  s/\@\*\(restricted_publish\)//g;
				}
				else
				{
					$html_text =~  s/\@\*\(regular_publish\)//g;
					$html_text =~  s/\@\*\(restricted_publish\)//g;
				}

				#if automatic downloading is enabled, check it
				if ($download == 1)
				{
					$html_text =~  s/\@\*\(regular_download\)/checked\=\"checked\"/g;
					$html_text =~  s/\@\*\(restricted_download\)//g;
				}
				else
				{
					$html_text =~  s/\@\*\(regular_download\)//g;
					$html_text =~  s/\@\*\(restricted_download\)//g;
				}

			}
			else
			{
				#if automatic publishing is enabled, check it
				if ($upload == 1)
				{
					$html_text =~  s/\@\*\(restricted_publish\)/checked\=\"checked\"/g;
					$html_text =~  s/\@\*\(regular_publish\)//g;
				}
				else
				{
					$html_text =~  s/\@\*\(restricted_publish\)//g;
					$html_text =~  s/\@\*\(regular_publish\)//g;
				}

				#if automatic downloading is enabled, check it
				if ($download == 1)
				{
					$html_text =~  s/\@\*\(restricted_download\)/checked\=\"checked\"/g;
					$html_text =~  s/\@\*\(regular_download\)//g;
				}
				else
				{
					$html_text =~  s/\@\*\(restricted_download\)//g;
					$html_text =~  s/\@\*\(regular_download\)//g;
				}

				$html_text =~  s/\@\*\(some_CHECKED\)/checked\=\"checked\"/g;
				@form_array = split (/\>/, $form_list);
				foreach $form (@form_array)
				{
					my $replace_key = $form . "_CHECKED";
					$html_text =~  s/\@\*\($replace_key\)/checked\=\"checked\"/g;
				}
			}
		}
	}

	#removed the checked tags
	$html_text =~ s/\@\*\(\@\*\(\w*?\_CHECKED\)//g;

	#if we're adding a user
	if ($add == 1)
	{
		#set the title to "Add User"
		$html_text =~  s/\@\*\(EditUserTitle\)/Add User/g;

		#set the edit user flag to 0
		$html_text =~  s/\@\*\(EditFlag\)/0/g;

		#display username textbox
		$username_text = "Username \<input type\=\"text\" name\=\"UserName\" id\=\"UserName\" />";
		$html_text =~ s/\@\*\(user_name\)/$username_text/g;

		#remove the password checkbox (need to define, no need to check to change)
		$html_text =~ s/\@\*\(Password_Checkbox\)//g;

		#set the change password flag to 1
		$change_password_java = "var changePassword = 1\;";
		$html_text =~ s/\@\*\(PasswordJavascript\)/$change_password_java/g;

		#add the code to the page to check to see if the usernames already exist; start with administrator
		$username_check_java = "if(document.RWSADMIN.UserName.value.toLowerCase() == 'administrator'";

		#for each username in the config file
		foreach $username_key (keys %{$rws_config{'[USER]'}})
		{
			#unescape out equals and endlines
			$username_key =~ s/\(equals\)/\=/g;
			$username_key =~ s/\(end\)/\n/g;

			use MIME::Base64;	

			#decode the username
			$decoded_username_key = decode_base64($username_key);

			#add the username to the if claus
			$username_check_java .= " || document.RWSADMIN.UserName.value.toLowerCase() == '" . $decoded_username_key . "'";
		}
		$username_check_java .= ")\n";
		$username_check_java .= "{\n";
	
		#set up an alert that the username already exists
		$username_check_java .= "alert(\"Cannot create user. A user already exists with that username. Please try a different username.\")\;\n";
		$username_check_java .= "document.RWSADMIN.UserName.focus()\;\n";
		$username_check_java .= "break\;\n";
		$username_check_java .= "}\n";

		#replace the text in the page
		$html_text =~ s/\@\*\(UsernameCheck\)/$username_check_java/g;

		#set standard user checked by default
		$html_text =~  s/\@\*\(all_CHECKED\)/checked\=\"checked\"/g;
	}
	else
	{
		#display username information
		$username_text = "Username: $username \<input type\=\"hidden\" name\=\"UserName\" id\=\"UserName\" value\=\"$username\" />";
		$html_text =~ s/\@\*\(user_name\)/$username_text/g;

		#add the checkbox to see if they want to change the password
		$change_password_checkbox = "<input type=\"checkbox\" name=\"Change_Password\" id=\"Change_Password\" />Change Password <br />New ";
		$html_text =~ s/\@\*\(Password_Checkbox\)/$change_password_checkbox/g;

		#add the script that handles what to do if the change password box is checked
		$change_password_java = "if (document.RWSADMIN.Change_Password.checked)\n";
		$change_password_java .= "{\n";
		$change_password_java .= "var changePassword = 1\;\n";
		$change_password_java .= "}\n";
		$change_password_java .= "else\n";
		$change_password_java .= "{\n";
		$change_password_java .= "var changePassword = 0\;\n";
		$change_password_java .= "}\n";
		$html_text =~ s/\@\*\(PasswordJavascript\)/$change_password_java/g;

		#get rid of the UsernameCheck tag
		$html_text =~s/\@\*\(UsernameCheck\)//g;
	}
	
	#insert the uid into our form '@*()'
	if($session_uid ne "")
	{
		$html_text =~ s/\@\*\(uid\)/\?UID\=$session_uid/g;
	}
	else
	{
		$html_text =~ s/\@\*\(uid\)//g;
	}

	#insert the uid into our get forms '@*()'
	if($session_uid ne "")
	{
		$html_text =~ s/\@\*\(uid\_get\)/$session_uid/g;
	}
	else
	{
		$html_text =~ s/\@\*\(uid\_get\)//g;
	}
											   
	&display_html($html_text);

	#add to the log if in diagnostic mode
	if ($diagnostic_on == 1)
	{
		&write_log($LOG_NAME, $MAX_SIZE, "rwsad5.pl", "display_user_edit", "None", $thread_ID, 0);
	}

	return 1;
}

########################################################################################
# 	FUNCTION THAT DISPLAYS READ-ONLY SCREEN		       		       #	
#	USE: &display_read_only($permissions); use the 						       	       #		
########################################################################################
sub display_read_only
{

	$temp_var = $rws_config{'[INFO]'}{$session_uid};
	($IP, $time, $permissions, $current_user) = split(/\|/, $temp_var);

	($permission_level, $forms_access) = split(/\!/, $permissions);
	($overall_permissions, $upload, $download) = split(/\>/, $permission_level);


	$permissions = $_[0];

	#add to the log if in diagnostic mode
	if ($diagnostic_on == 1)
	{
		&write_log($LOG_NAME, $MAX_SIZE, "rwsad5.pl", "display_read_only", "permissions = " . $permissions, $thread_ID, 1);
	}

	$htmlfile = "html/5/data.html";

	#open up the external html file
	open (SRC_FILE, $cgi_dir . $htmlfile) || die print "Could not open file $htmlfile";
	
	#read the file into an array 
	@file_data = <SRC_FILE>;

	#close the source file because we are finished reading in the key=value pairs
	close (SRC_FILE);

	#loop thru storing the lines into the variable $html_text
 	foreach $source_lines (@file_data)
 	{	
 		#remove the \n character
 		chop ($source_lines);
		$html_text .=  $source_lines;
		 		
 	}

	#insert the tabs
	{
		$tab_html = "<li><a class=\"selected\">Data & Stats</a></li><li><a href=\"@*(admin)@*(uid)&NAV=Password\">Password</a></li>";
		$html_text =~ s/\@\*\(nav_tabs\)/$tab_html/g;
	}

	if ($download == 1)
	{
		#if this is the data screen, insert the administrative options
		$button_html = "<tr>	<td>&nbsp;</td>        <td><input type=\"button\" id=\"DOWNLOAD_DATA2\" name=\"DOWNLOAD_DATA2\" value=\"Download Data\" onclick=\"validate('DOWNLOAD');\" style=\"width: 144px\" /></td>        <td><input type=\"button\" id=\"INCOMPLETE_DATA\" name=\"INCOMPLETE_DATA\" value=\"Incomplete Data\" onclick=\"validate('INCOMPLETE');\" style=\"width: 144px\" /></td>    </tr>";
		$html_text =~ s/\@\*\(admin_buttons\)/$button_html/g;

		#also add the dynamic description text
		$html_text =~ s/\@\*\(stats_permissions_description\)/view live online statistics\, download or view the data\ or download data from respondents who have not yet completed the web form/g;

	}
	else
	{
		#clear out the admin button        
		$html_text =~ s/\@\*\(admin_buttons\)//g;

		#also add the dynamic description text
		$html_text =~ s/\@\*\(stats_permissions_description\)/view the data or live online statistics/g;
	}

	#insert the admin script into form '@*()'
	$html_text =~ s/\@\*\(admin\)/$admin_script/g;

	#insert the default location into our form '@*()'
	$html_text =~ s/\@\*\(default_dir\)/$install_config{"[Defaults]"}{"Location"}/g;
	
	#insert the admin email address into our form '@*()'
	#$html_text =~ s/\@\*\(admin_email\)/$install_config{"[Defaults]"}{"AdminEmail"}/g;

	#insert the data script into form '@*()'
	$html_text =~ s/\@\*\(data\)/$form_address/g;
	
	#insert the date for the copyright dynamically into our form'@*()'
	@timeData = localtime(time);
	#the sixth value in the timeData array is the number of years since 1900
	$year_offset = $timeData[5];
	#add 1900 to get correct year
	$year = 1900 + $year_offset; 
	#inserts it into the form
	$html_text =~ s/\@\*\(year\)/$year/g;

	#insert the username
	#unescape out equals and endlines
	$current_user =~ s/\(equals\)/\=/g;
	$current_user =~ s/\(end\)/\n/g;

	use MIME::Base64;	

	#decode the username
	$decoded_user = decode_base64($current_user);

	$html_text =~ s/\@\*\(username\)/$decoded_user/g;

	#insert the images cript in to display the logo
	#if the defined default exists, use that
	if (-e $install_config{"[Defaults]"}{"ImageScript"})
	{
		$html_text =~ s/\@\*\(img\)/$install_config{"[Defaults]"}{"ImageScript"}\?ADMIN\=1/g;  
	}
	#if not, check for rwsimg5.pl and use that
	elsif (-e $cgi_dir . 'rwsimg5.pl')
	{
		$html_text =~ s/\@\*\(img\)/rwsimg5\.pl\?ADMIN\=1/g;  
	}
	#if not, check for rwsimg5.cgi and use that
	elsif (-e $cgi_dir . 'rwsimg5.cgi')
	{
		$html_text =~ s/\@\*\(img\)/rwsimg5\.cgi\?ADMIN\=1/g;  
	}
	#if not, check for rwsimg5.plx and use that
	elsif (-e $cgi_dir . 'rwsimg5.plx')
	{
		$html_text =~ s/\@\*\(img\)/rwsimg5\.plx\?ADMIN\=1/g;  
	}
	#otherwise, get rid of the image tag altogether
	else
	{
		$html_text =~ s/\<img .*?src\=\"\@\*\(img\).*?\/\>//g;
	}

	($permissions_value, $forms_allowed) = split (/\!/, $permissions);

	if (($forms_allowed eq "*allforms*") || ($forms_allowed eq "*ALLFORMS*"))
	{
		$form_list_html = &return_form_list;
	}
	else
	{
		#add a blank selection to be displayed first
		$form_list_html = "<OPTION SELECTED VALUE=\"\"></OPTION>\n";

		@form_array = split (/\>/, $forms_allowed);
	
		#loop thru each form and add it to the list
		foreach $key (@form_array)
		{
			$form_list_html .= "<OPTION VALUE=\"$key\">$key</OPTION>\n";	
		}

	}

	#insert the form lists into our form '@*()'
	$html_text =~ s/\@\*\(form_list\)/$form_list_html/g;
	
	#insert the uid into our form '@*()'
	if($session_uid ne "")
	{
		$html_text =~ s/\@\*\(uid\)/\?UID\=$session_uid/g;
	}
	else
	{
		$html_text =~ s/\@\*\(uid\)//g;
	}

	#insert the uid into our get forms '@*()'
	if($session_uid ne "")
	{
		$html_text =~ s/\@\*\(uid\_get\)/$session_uid/g;
	}
	else
	{
		$html_text =~ s/\@\*\(uid\_get\)//g;
	}
											   
	&display_html($html_text);

	#add to the log if in diagnostic mode
	if ($diagnostic_on == 1)
	{
		&write_log($LOG_NAME, $MAX_SIZE, "rwsad5.pl", "display_read_only", "None", $thread_ID, 0);
	}

	return 1;
}

########################################################################################
# 	FUNCTION THAT ANALYZES THE DATA FOR A GIVEN FORM AND RETURNS THE HTML OUTPUT   #
#	USE: &duration_report($form_name);					       	       #		
########################################################################################
sub duration_report
{
	my $form_name = $_[0];
	my $interval = $_[1];
	$question_ID = "";
	%statistics = ();
	my @answers = ();
	my $statoutput = "";
	my %num_responses = ();
	my $total_time = "";

	#add to the log if in diagnostic mode
	if ($diagnostic_on == 1)
	{
		&write_log($LOG_NAME, $MAX_SIZE, "rwsad5.pl", "duration_report", "form_name = " . $form_name . " && interval = " . $interval, $thread_ID, 1);
	}

	#locate the directory for the form
	$form_config_dir = &return_full_path($install_config{'[Forms]'}{$form_name});

	#get the config file name
	$base_config_file = $form_name . '.cfg';
	$base_config_file = &convert_string($base_config_file);

	#get the full form config file path on the server
	$form_config_file = &return_full_path($form_config_dir,$base_config_file);

	#read the form configuration into the hash
	%form_configuration = &read_config($form_config_file,1);

	#get the data and archive file names
	$data_file = &return_full_path($install_config{'[Forms]'}{$form_configuration{'[MISC]'}{'FormName'}},$form_configuration{'[MISC]'}{'DataFile'});
	$archive_file = $data_file . '.rwa';
	$data_file .= '.rwd';

	#if there is a .rwa file
	if (open(DATA, $archive_file)) 
	{

		#read in each line
		while( $line = <DATA> )
		{

			#increase the total number of responses
			$num_responses{'Total'}++;

			if ($line =~ /DURATION\=(\d*)[\t\n]?/)
			{
				$submission_time = $1;
				$total_time += $submission_time;
				$temp_interval = int($submission_time / ($interval * 60));
				$statistics{$temp_interval}++;		
			}
		}
		close FILE;
	}

	#if there is a .rwd file
	if (open(DATA, $data_file)) 
	{

		#read in each line
		while( $line = <DATA> )
		{
			#increase the total number of responses
			$num_responses{'Total'}++;

			if ($line =~ /DURATION\=(\d*)[\t\n]?/)
			{	
				$submission_time = $1;
				$total_time += $submission_time;
				$temp_interval = int($submission_time / ($interval * 60));
				$statistics{$temp_interval}++;			
			}
		}
	close FILE;
	}

	#set the html output to the total number of responses
	$statoutput = 'Total responses: ' . $num_responses{'Total'} . "<BR><table>";

	$max_interval = 0;

	#go through each value to find the highest length
	foreach $interval_range (sort keys %statistics)
	{
		#if the highest interval is less than the current interval, set it to the current interval
		if ($max_interval < $interval_range)
		{
			$max_interval = $interval_range;
		}
	}

	$question_text_display = "Duration";

	#add the question html
	$statoutput .= "</table><BR><STRONG>" . $question_text_display . "</STRONG><br>";
	$statoutput .= "Average time per response: " . int(($total_time / $num_responses{'Total'}) / 60) . " Minute(s), " . (($total_time / $num_responses{'Total'}) % 60) . " Second(s) <br /><br /><table border=\"0\" width=\"525\"><tr>";

	#loop through each question
	for ($counter=0; $counter<=$max_interval; $counter++)
	{
		#add each response html and a table to show the graph	
		#set a temporary variable for the text label
		$range_label = $counter * $interval . " - " . ($counter + 1) * $interval . " Minutes";

		$statoutput .= "<td align=\"right\" width=\"215\">" . $range_label . " </td><td width=\"10\">\&nbsp\;</td><td><table height=\"20px\" width=\"200px\"><tr><td width=\"" . sprintf("%.0f", ($statistics{$counter} / $num_responses{'Total'}) * 200) . "\" style=\"background-color: @*(GRAPH_COLOR)\"></td><td width=\"" . (200 -sprintf("%.0f", ($statistics{$counter} / $num_responses{'Total'}) * 200)) . "\"></td></tr></table></td><td width=\"100\" align=\"right\">" . $statistics{$counter} . " (" . sprintf("%.2f", ($statistics{$counter} / $num_responses{'Total'}) * 100) . "%) </td></tr>"; 
	}

	#add the final close table tag
	$statoutput .= "</table>";

	#add to the log if in diagnostic mode
	if ($diagnostic_on == 1)
	{
		&write_log($LOG_NAME, $MAX_SIZE, "rwsad5.pl", "duration_report", "None", $thread_ID, 0);
	}

	return $statoutput;
}

########################################################################################
# 	FUNCTION THAT OUTPUTS THE DIANGOSTIC RESULTS   #
#	USE: &diagnostics();					       	       #		
########################################################################################
sub diagnostics
{
	#add to the log if in diagnostic mode
	if ($diagnostic_on == 1)
	{
		&write_log($LOG_NAME, $MAX_SIZE, "rwsad5.pl", "diagnostics", "None", $thread_ID, 1);
	}

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


	#SCRIPTS SECTION
	$diagnosticoutput .= "<p style=\"margin-left:10px; font-size:small;\"><span style=\"font-size:medium; font-weight:bold;\">Script Information</span><br><br>\n";

	#----------RWS Admin Script Section ----------------------------------------------------------------
	$diagnosticoutput .= "<strong>RWS Admin Script Info</strong><br>\n";
	$rws_admin = $cgi_dir . 'rwsad5.pl';
	$rwsadmin_read = 0;
	$rwsadmin_execute = 0;

	if (! -e $rws_admin) 
	{
		$rws_admin = $cgi_dir . 'rwsad5.cgi';
	};

	if (! -e $rws_admin) 
	{
		$rws_admin = $cgi_dir . 'rwsad5.plx';
	};

	if (-e $rws_admin) 
	{
		$diagnosticoutput .= "Script found with ";

		if (-R $rws_admin) 
		{
			$rwsadmin_read = 1;
			$diagnosticoutput .= "read";		
		} 

		if (-W $rws_admin) 
		{
			$diagnosticoutput .= ", write";		
		} 

		if (-X $rws_admin) 
		{
			$diagnosticoutput .= ", execute";
			$rwsadmin_execute = 1;		
		} 

		$diagnosticoutput .= " permissions.<br>\n";
		if (($rwsadmin_read == 0) || (($rwsadmin_execute == 0) && ($os_type eq 'unix')))
		{
			$diagnosticoutput .= "<span style=\"font-weight:bold; color:#FF0000;\" >Error: ";
			if ($rwsadmin_read == 0)
			{
				$diagnosticoutput .= "The RWS Admin Script requires read permissions. ";
			}
			if (($rwsadmin_execute == 0) && ($os_type eq 'unix'))
			{
				$diagnosticoutput .= "The RWS Admin Script requires execute permissions. ";
			}
			$diagnosticoutput .= "</span><br />\n";
		}
		
		if (open (RWSADMIN, "<$rws_admin")) {
			@rws_admin = <RWSADMIN>;
			chomp($first_line);
			close RWSADMIN;

			$rws_admin_version = &script_version(@rws_admin);
			if (length($rws_admin_version) > 0) {
				$diagnosticoutput .= "Script Version: " . $rws_admin_version . "<br />\n";			
			};
		}
	}
	else
	{
		$diagnosticoutput .= "<span style=\"font-weight:bold; color:#FF0000;\" >Error: RWS Admin script not found.</span><br />\n";
	}
	$diagnosticoutput .= "<br />\n";

	#----------RWS Admin HTML Section ----------------------------------------------------------------
	$diagnosticoutput .= "<strong>RWS Admin HTML Info</strong><br>\n";
	if ($cgi_dir =~ /\//)
	{
		$html_dir = $cgi_dir_path . "html/5/";
	}
	else
	{
		$html_dir = $cgi_dir . "html\\5\\";
	}

	if (-d $html_dir) 
	{
		if (-R $html_dir) 
		{
			$missing_html = 0;
			@missing_page = ();
			@pages = ("setup.html", "changepassword.html", "data.html", "diagnostics.html", "edituser.html", "formremove.html", "general.html", "initialchange.html", "login.html", "logo.png", "printstats.html", "stats.html", "timeout.html", "users.html", "webforms.html");
			foreach $page (@pages)
			{
				$full_address = $html_dir . $page;
				if (open (HTML_FILE, $full_address))
				{
					close(HTML_FILE);
					next;
				}
				else
				{
					$missing_html = 1;
					push(@missing_pages, $page);
				}
			}
			if ($missing_html == 0)
			{
				$diagnosticoutput .= "All HTML files found with read permissions. <br />";
			}
			else
			{
				$diagnosticoutput .= "<span style=\"font-weight:bold; color:#FF0000;\" >Error: The following HTML files are missing or do not have read permissions: ";
				$missing_page_flag = 0;
				foreach $missing_page (@missing_pages)
				{
					if ($missing_page_flag == 1)
					{
						$diagnosticoutput .= ", ";
					}
					$diagnosticoutput .= $missing_page;
					$missing_page_flag = 1;
				}
				$diagnosticoutput .= ".</span><br />\n";
			}				
		} 
		else {
			$diagnosticoutput .= "<span style=\"font-weight:bold; color:#FF0000;\" >Error: The HTML folder does not have read permissions.</span><br />\n";
		};	
	} else {
		$diagnosticoutput .= "<span style=\"font-weight:bold; color:#FF0000;\" >Error: The HTML folder does not exist.</span><br />\n";
	};
	$diagnosticoutput .= "<br />\n";


	#----------RWS Data Script Section----------------------------------------------------------------
	$diagnosticoutput .= "<strong>RWS Data Script Info</strong><br>\n";
	$rws_data = $cgi_dir . 'rws5.pl';
	$rwsdata_read = 0;
	$rwsdata_execute = 0;
	$rwsdata_write = 0;

	if (! -e $rws_data) 
	{
		$rws_data = $cgi_dir . 'rws5.cgi';
	};

	if (! -e $rws_data) 
	{
		$rws_data = $cgi_dir . 'rws5.plx';
	};

	if (-e $rws_data) 
	{
		$diagnosticoutput .= "Script found with ";

		if (-R $rws_data) 
		{
			$rwsdata_read = 1;
			$diagnosticoutput .= "read";		
		} 

		if (-W $rws_data) 
		{
			$diagnosticoutput .= ", write";
			$rwsdata_write = 1;		
		} 

		if (-X $rws_data) 
		{
			$diagnosticoutput .= ", execute";
			$rwsdata_execute = 1;		
		} 

		$diagnosticoutput .= " permissions.<br>\n";
		if (($rwsdata_read == 0) || ((($rwsdata_execute == 0) || ($rwsdata_write == 0)) && ($os_type eq 'unix')))
		{
			$diagnosticoutput .= "<span style=\"font-weight:bold; color:#FF0000;\" >Error: ";
			if ($rwsdata_read == 0)
			{
				$diagnosticoutput .= "The RWS Data Script requires read permissions. ";
			}
			if (($rwsdata_execute == 0) && ($os_type eq 'unix'))
			{
				$diagnosticoutput .= "The RWS Data Script requires execute permissions. ";
			}
			if (($rwsdata_write == 0) && ($os_type eq 'unix'))
			{
				$diagnosticoutput .= "The RWS Data Script requires write permissions. ";
			}
			$diagnosticoutput .= "</span><br />\n";
		}

		if (open (RWSDATA, "<$rws_data")) {
			@rws_data = <RWSDATA>;
			close RWSADMIN;

			$rws_data_version = &script_version(@rws_data);
			if (length($rws_data_version) > 0) {
				$diagnosticoutput .= "Script Version: " . $rws_data_version . "<br />\n";			
			};
		}
	}
	else
	{
		$diagnosticoutput .= "<span style=\"font-weight:bold; color:#FF0000;\" >Error: RWS Data script not found.</span><br />\n";
	}
	$diagnosticoutput .= "<br />\n";


	#RWS Image Script Section
	$diagnosticoutput .= "<strong>RWS Image Script Info</strong><br>\n";
	$rws_image = $cgi_dir . 'rwsimg5.pl';
	$rwsimage_read = 0;
	$rwsimage_execute = 0;

	if (! -e $rws_image) 
	{
		$rws_image = $cgi_dir . 'rwsimg5.cgi';
	};

	if (! -e $rws_image) 
	{
		$rws_image = $cgi_dir . 'rwsimg5.plx';
	};

	if (-e $rws_image) 
	{
		$diagnosticoutput .= "Script found with ";

		if (-R $rws_image) 
		{
			$rwsimage_read = 1;
			$diagnosticoutput .= "read";		
		} 

		if (-W $rws_image) 
		{
			$diagnosticoutput .= ", write";		
		} 

		if (-X $rws_image) 
		{
			$diagnosticoutput .= ", execute";
			$rwsimage_execute = 1;		
		} 

		$diagnosticoutput .= " permissions.<br>\n";
		if (($rwsimage_read == 0) || (($rwsimage_execute == 0) && ($os_type eq 'unix')))
		{
			$diagnosticoutput .= "<span style=\"font-weight:bold; color:#FF0000;\" >Error: ";
			if ($rwsimage_read == 0)
			{
				$diagnosticoutput .= "The RWS Image Script requires read permissions. ";
			}
			if (($rwsimage_execute == 0) && ($os_type eq 'unix'))
			{
				$diagnosticoutput .= "The RWS Image Script requires execute permissions. ";
			}
			$diagnosticoutput .= "</span><br />\n";
		}

		if (open (RWSIMAGE, "<$rws_image")) {
			@rws_image = <RWSIMAGE>;
			close RWSIMAGE;

			$rws_image_version = &script_version(@rws_image);
			if (length($rws_image_version) > 0) {
				$diagnosticoutput .= "Script Version: " . $rws_image_version . "<br />\n";			
			};
		}
	}
	else
	{
		$diagnosticoutput .= "<span style=\"font-weight:bold; color:#FF0000;\" >Error: RWS Image script not found.</span><br />\n";
	}
	$diagnosticoutput .= "<br />\n";


	#RWS Utils Module Section
	$diagnosticoutput .= "<strong>RWS Utilities Module Info</strong><br>\n";
	$rws_utils = $cgi_dir . 'rwsutils5.pm';
	$rwsutils_read = 0;

	if (-e $rws_utils) 
	{
		$diagnosticoutput .= "Module found with ";

		if (-R $rws_utils) 
		{
			$rwsutils_read = 1;
			$diagnosticoutput .= "read";		
		} 

		if (-W $rws_utils) 
		{
			$diagnosticoutput .= ", write";		
		} 

		if (-X $rws_utils) 
		{
			$diagnosticoutput .= ", execute";	
		} 

		$diagnosticoutput .= " permissions.<br>\n";
		if ($rwsutils_read == 0)
		{
			$diagnosticoutput .= "<span style=\"font-weight:bold; color:#FF0000;\" >Error: ";
			$diagnosticoutput .= "The RWS Utilities Module requires read permissions. ";
			$diagnosticoutput .= "</span><br />\n";
		}

		if (open (RWSUTILS, "<$rws_utils")) {
			@rws_utils = <RWSUTILS>;
			close RWSUTILS;

			$rws_utils_version = &script_version(@rws_utils);
			if (length($rws_utils_version) > 0) {
				$diagnosticoutput .= "Script Version: " . $rws_utils_version . "<br />\n";			
			};
		}
	}
	else
	{
		$diagnosticoutput .= "<span style=\"font-weight:bold; color:#FF0000;\" >Error: RWS Utillities Module not found.</span><br />\n";
	}
	$diagnosticoutput .= "<br />\n";


	#RWS MD5 Module Section
	$diagnosticoutput .= "<strong>RWS EM5 Module Info</strong><br>\n";
	$rws_md5 = $cgi_dir . 'rwsem5.pm';
	$rwsmd5_read = 0;

	if (-e $rws_md5) 
	{
		$diagnosticoutput .= "Module found with ";

		if (-R $rws_md5) 
		{
			$rwsmd5_read = 1;
			$diagnosticoutput .= "read";		
		} 

		if (-W $rws_md5) 
		{
			$diagnosticoutput .= ", write";		
		} 

		if (-X $rws_md5) 
		{
			$diagnosticoutput .= ", execute";	
		} 

		$diagnosticoutput .= " permissions.<br>\n";
		if ($rwsmd5_read == 0)
		{
			$diagnosticoutput .= "<span style=\"font-weight:bold; color:#FF0000;\" >Error: ";
			$diagnosticoutput .= "The RWS EM5 Module requires read permissions. ";
			$diagnosticoutput .= "</span><br />\n";
		}

		if (open (RWSMD5, "<$rws_md5")) {
			@rws_md5 = <RWSMD5>;
			close RWSMD5;

			$rws_md5_version = &script_version(@rws_md5);
			if (length($rws_md5_version) > 0) {
				$diagnosticoutput .= "Script Version: " . $rws_md5_version . "<br />\n";			
			};
		}
	}
	else
	{
		$diagnosticoutput .= "<span style=\"font-weight:bold; color:#FF0000;\" >Error: RWS EM5 Module not found.</span><br />\n";
	}
	$diagnosticoutput .= "<br />\n";


	#RWS XML Module Section
	$diagnosticoutput .= "<strong>RWS XML Module Info</strong><br>\n";
	$rws_xml = $cgi_dir . 'rwsxml5.pm';
	$rwsxml_read = 0;

	if (-e $rws_xml) 
	{
		$diagnosticoutput .= "Module found with ";

		if (-R $rws_xml) 
		{
			$rwsxml_read = 1;
			$diagnosticoutput .= "read";		
		} 

		if (-W $rws_xml) 
		{
			$diagnosticoutput .= ", write";		
		} 

		if (-X $rws_xml) 
		{
			$diagnosticoutput .= ", execute";	
		} 

		$diagnosticoutput .= " permissions.<br>\n";
		if ($rwsxml_read == 0)
		{
			$diagnosticoutput .= "<span style=\"font-weight:bold; color:#FF0000;\" >Error: ";
			$diagnosticoutput .= "The RWS XML Module requires read permissions. ";
			$diagnosticoutput .= "</span><br />\n";
		}

		if (open (RWSXML, "<$rws_xml")) {
			@rws_xml = <RWSXML>;
			close RWSXML;

			$rws_xml_version = &script_version(@rws_xml);
			if (length($rws_xml_version) > 0) {
				$diagnosticoutput .= "Script Version: " . $rws_xml_version . "<br />\n";			
			};
		}
	}
	else
	{
		$diagnosticoutput .= "<span style=\"font-weight:bold; color:#FF0000;\" >Error: RWS XML Module not found.</span><br />\n";
	}
	$diagnosticoutput .= "<br />\n";


	#FORMS SECTION
	$diagnosticoutput .= "<hr><p style=\"margin-left:10px; font-size:small;\"><span style=\"font-size:medium; font-weight:bold;\">Installed Forms</span><br \><br \>\n";


	$default_form_dir = $install_config{'[Defaults]'}{'Location'};
	$default_form_dir = &return_full_path($default_form_dir,""); 

	foreach $rwsadmin_cfg (sort keys %{$install_config{'[Forms]'}}) 
	{
			
		($hash_key, $hash_val) = split("=", $rwsadmin_cfg);
		$hash_key = $rwsadmin_cfg;
		$hash_val = $install_config{'[Forms]'}{$rwsadmin_cfg};

		$loc = &return_full_path($hash_val,$hash_key . ".cfg");
		$diagnosticoutput .= "Name=<B>" . $hash_key . "</B><BR>";
		$diagnosticoutput .= "Location=" . $hash_val . "<BR>";
		if(-e $loc) 
		{
			%form_vars = &read_config($loc,1);
			if(($form_vars{'[MISC]'}{'SendSubmissionEmails'} eq '1') || (-e &return_full_path($hash_val,"pause_page.html")) || ($form_configuration{'[MISC]'}{'#RULE0001#'} ne ""))
			{
				if ($form_vars{'[MISC]'}{'RecipientAddressList'} ne "")
				{
					#escape out the Recipient Address List
					$form_vars{'[MISC]'}{'RecipientAddressList'} =~ s/\</\&lt\;/g;
					$form_vars{'[MISC]'}{'RecipientAddressList'} =~ s/\>/\&gt\;/g;
					$form_vars{'[MISC]'}{'RecipientAddressList'} =~ s/\"/\&quot\;/g;


					#do the same for the From Address
					$form_vars{'[MISC]'}{'AdminAddress'} =~ s/\</\&lt\;/g;
					$form_vars{'[MISC]'}{'AdminAddress'} =~ s/\>/\&gt\;/g;
					$form_vars{'[MISC]'}{'AdminAddress'} =~ s/\"/\&quot\;/g;

					$diagnosticoutput .= "Email Recipients=<B>" . $form_vars{'[MISC]'}{'RecipientAddressList'} . "</B><br />\n";

					$escaped_formname = $hash_key;
					$escaped_formname =~ s/\-/\_\_/g;


					if ($form_vars{'[MISC]'}{'EmailMethod'} eq "SMTP")
					{
						$diagnosticoutput .= "<input type=\"HIDDEN\" name=\"". $escaped_formname . "_EMAIL_DETAILS\" value=\"$form_vars{'[MISC]'}{'EmailMethod'}?$form_vars{'[MISC]'}{'RecipientAddressList'}?$form_vars{'[MISC]'}{'AdminAddress'}?RWSTEST EMAIL [$hash_key]?$form_vars{'[MISC]'}{'SMTPServer'}?$form_vars{'[MISC]'}{'PortNumber'}?Automated Test Message: $hash_key?2?$form_vars{'[MISC]'}{'SMTPUsername'}?$form_vars{'[MISC]'}{'SMTPPassword'}\">\n";
					}
					else
					{
						$diagnosticoutput .= "<input type=\"HIDDEN\" name=\"CONFIG_DIR\" value=\"$cfg_dir\"></input><input type=\"HIDDEN\" name=\"". $escaped_formname . "_EMAIL_DETAILS\" value=\"$form_vars{'[MISC]'}{'EmailMethod'}?$form_vars{'[MISC]'}{'SendmailServer'}?$form_vars{'[MISC]'}{'RecipientAddressList'}?$form_vars{'[MISC]'}{'AdminAddress'}?RWSTEST EMAIL [$hash_key]?Automated Test Message: $hash_key\">\n";
					}
				}
				else
				{
					$escaped_formname = $hash_key;
					$escaped_formname =~ s/\-/\_\_/g;

					$diagnosticoutput .= "Email Recipient: <input type=\"text\" name=\"" . $escaped_formname . "_EMAIL_RECIPIENT\"><br />\n";
					if ($form_vars{'[MISC]'}{'EmailMethod'} eq "SMTP")
					{
						$diagnosticoutput .= "<input type=\"HIDDEN\" name=\"". $escaped_formname . "_EMAIL_DETAILS\" value=\"$form_vars{'[MISC]'}{'EmailMethod'}?EMAIL_REPLACE?$form_vars{'[MISC]'}{'AdminAddress'}?RWSTEST EMAIL [$hash_key]?$form_vars{'[MISC]'}{'SMTPServer'}?$form_vars{'[MISC]'}{'PortNumber'}?Automated Test Message: $hash_key?2?$form_vars{'[MISC]'}{'SMTPUsername'}?$form_vars{'[MISC]'}{'SMTPPassword'}\">\n";
					}
					else
					{
						$diagnosticoutput .= "<input type=\"HIDDEN\" name=\"CONFIG_DIR\" value=\"$cfg_dir\"></input><input type=\"HIDDEN\" name=\"". $escaped_formname . "_EMAIL_DETAILS\" value=\"$form_vars{'[MISC]'}{'EmailMethod'}?$form_vars{'[MISC]'}{'SendmailServer'}?EMAIL_REPLACE?$form_vars{'[MISC]'}{'AdminAddress'}?RWSTEST EMAIL [$hash_key]?Automated Test Message: $hash_key\">\n";
					}
				}
				$diagnosticoutput .= "Email Method=<B>" . $form_vars{'[MISC]'}{'EmailMethod'} . "</B><BR />\n";
				if ($form_vars{'[MISC]'}{'EmailMethod'} eq "SendMail")
				{
					$sendmail_location = $form_configuration{'[MISC]'}{'SendmailServer'};
					if (open(SENDMAIL, "|$sendmail_location -t")) 
					{
						$diagnosticoutput .= "SendMail Server Connection=<B>Successful</B><BR />\n";	
					}
					else
					{
						$pi++;
						$problems .= "<li><a href=#P$pi>Warning: Unable to connect to SendMail server at $sendmail_location for form $hash_key.</a>";
						$diagnosticoutput .= "<a name=\"P$pi\"></a>SendMail Server Connection=<B><font color=red>Failed</font></B><BR />\n";									
					}
				}
				$diagnosticoutput .= "<input type=\"button\" value=\"Send Test Email\" onclick=\"validate('SEND_TEST_EMAIL', '$escaped_formname');\">\n";
			}
			$diagnosticoutput .= "<BR><BR>";
		}
	}
	$diagnosticoutput .= "</p>\n";

	#add to the log if in diagnostic mode
	if ($diagnostic_on == 1)
	{
		&write_log($LOG_NAME, $MAX_SIZE, "rwsad5.pl", "diagnostics", "None", $thread_ID, 0);
	}

	return $diagnosticoutput;
}

########################################################################################
# 	FUNCTION THAT CHECKS ON THE TEST SCRIPT AND OUTPUTS THE DIAGNOSTICS TAB TEXT   #
#	USE: &test_script_output();					       	       #		
########################################################################################
sub test_script_output
{
	#add to the log if in diagnostic mode
	if ($diagnostic_on == 1)
	{
		&write_log($LOG_NAME, $MAX_SIZE, "rwsad5.pl", "test_script_output", "None", $thread_ID, 1);
	}

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


	#SCRIPTS SECTION
	$test_output = "<p style=\"margin-left:10px; font-size:small;\"><span style=\"font-size:medium; font-weight:bold;\">RWS Test Script</span><br><br>\n";

	#----------RWS Admin Script Section ----------------------------------------------------------------
	$rws_admin = $cgi_dir . 'rwstest5.pl';
	$test_script_name = 'rwstest5.pl';

	if (! -e $rws_admin) 
	{
		$rws_admin = $cgi_dir . 'rwstest5.cgi';
		$test_script_name = 'rwstest5.cgi';
	};

	if (! -e $rws_admin) 
	{
		$rws_admin = $cgi_dir . 'rwstest5.plx';
		$test_script_name = 'rwstest5.plx';
	};

	if (-e $rws_admin) 
	{
		$test_output .= "RWS test script is installed. You can access the script by clicking the button below. <strong>For security purposes, we recommend you only have the script uploaded when needed.</strong></p>\n";
		$test_output .= "<p style=\"margin-left:10px; font-size:small;\"><INPUT TYPE=\"HIDDEN\" ID=\"TEST_SCRIPT_NAME\" NAME=\"TEST_SCRIPT_NAME\" VALUE=\"" . $test_script_name ."\" /><INPUT TYPE=\"button\" VALUE=\"Access Test Script\" onclick=\"validate('ACCESS_TEST_SCRIPT');\"></p>\n";
	}
	else
	{
		$test_output .= "RWS test script is not currently installed. Upload the test script to receive a full diagnostic report when contacting Remark Support with issues.</p>\n";
	}
	$test_output .= "<hr>\n";

	#add to the log if in diagnostic mode
	if ($diagnostic_on == 1)
	{
		&write_log($LOG_NAME, $MAX_SIZE, "rwsad5.pl", "test_script_output", "None", $thread_ID, 0);
	}

	return $test_output;
}

########################################################################################
# 	FUNCTION THAT SORTS THE CONFIRMATION DATA				       #	
#	USE: sort usersort keys %hash		   		          	       #		
########################################################################################
sub usersort 
{
	$first_item = $a;
	$second_item = $b;
	#unescape out equals and endlines
	$first_item =~ s/\(equals\)/\=/g;
	$first_item =~ s/\(end\)/\n/g;
	$second_item =~ s/\(equals\)/\=/g;
	$second_item =~ s/\(end\)/\n/g;

	use MIME::Base64;	

	decode_base64($first_item) cmp decode_base64($second_item);
}

########################################################################################
# 	FUNCTION THAT RETURNS THE SCRIPT VERSION NUMBER				       #	
#	USE: $version = &script_version(@script_file)   		          	       #		
########################################################################################
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

########################################################################################
# 	FUNCTION THAT STARTS THE INCOMPLETE DATA PROCESSing			       #	
#	USE: &generate_incomplete($form_name)   	          	       #		
########################################################################################
sub generate_incomplete 
{
	my $form_name = $_[0];	

	#add to the log if in diagnostic mode
	if ($diagnostic_on == 1)
	{
		&write_log($LOG_NAME, $MAX_SIZE, "rwsad5.pl", "generate_incomplete", "form_name = " . $form_name, $thread_ID, 1);
	}

	#get the data path
	$back_location = &return_full_path($install_config{'[Forms]'}{$form_name});

	#get the config file name
	$base_config_file = $form_name . '.cfg';
	$base_config_file = &convert_string($base_config_file);

	#get the full form config file path on the server
	$form_config_file = &return_full_path($back_location,$base_config_file);

	#read the form configuration into the hash
	%form_configuration = &read_config($form_config_file,1);

	#open the form directory
	opendir (FORMDIR, $back_location);
							
	#build an array with all of the form names in them			
	@uid_files = readdir(FORMDIR);

	#close the form directory
	closedir (FORMDIR);

	#create a lock file
	$lock_file = &return_full_path($back_location, $form_name . "-incomplete-download.lck");
	$downloaded_lock_file = &return_full_path($back_location, $form_name . "-incomplete-downloaded.lck");

	#if the lock file does not exist, create it
	if (!(-e $lock_file))
	{
		if (open (LOCK_FILE, ">$lock_file")) 
		{
			close(LOCK_FILE);
		}
	}

	#if the downloaded lock file exists, delete it
	if (-e $downloaded_lock_file)
	{
		unlink($downloaded_lock_file);
	}

	#check to see if there is already a data file
	$data_file = &return_full_path($back_location, $form_name . "-incomplete.rwd");

	#set a flag to see if the file contains the latest incomplete data
	$file_is_current = 1;

	#if there is a data file
	if (-e $data_file)
	{
		#for each file in the directory
		foreach $incomplete_form (@uid_files)
		{
			#if it is not a UID file, skip
			if ($incomplete_form !~ /(\S.*)\.uid$/)
			{
				next;
			}

			#get the UID from the file name
			$incomplete_uid = $1;

			#set the complete path of the UID file
			$uid_file = $back_location . $incomplete_form;

			#if the uid file exists read it into global hash
			if((-M $data_file) > (-M $uid_file))
			{
				$file_is_current = 0;
				last;
			}
		}

		#if the file exists and is not current
		if ($file_is_current == 0)
		{
			unlink $data_file; 
		}
	}
	else
	{
		$file_is_current = 0;
	}	

	#if we don't have a current file, create one
	if ($file_is_current == 0)
	{
		#for each file in the directory
		foreach $incomplete_form (@uid_files)
		{
			#if it is not a UID file, skip
			if ($incomplete_form !~ /(\S.*)\.uid$/)
			{
				next;
			}

			#get the UID from the file name
			$incomplete_uid = $1;

			#set the complete path of the UID file
			$uid_file = $back_location . $incomplete_form;

			#if the uid file exists read it into global hash
			if(-e $uid_file)
			{
				%form_uid = &read_config($uid_file,1);
			}

			#add the incomplete records for the UID file into the incomplete data file
			&add_incomplete_records($back_location, $incomplete_uid, $form_name);
		}
	}

	#clean up the lock file if it exists
	if(-e $lock_file)
	{
		unlink $lock_file; 
	}

	#add to the log if in diagnostic mode
	if ($diagnostic_on == 1)
	{
		&write_log($LOG_NAME, $MAX_SIZE, "rwsad5.pl", "generate_incomplete", "None", $thread_ID, 1);
	}

	return 1;
};