#!/usr/local/bin/perl

########################################################################################
# Remark Web Survey Collection Script         	 Version 5.2.0	 	               #
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
####################################################### #################################

########################################################################################
#             GLOBAL INCLUDE HEADER LIST			 		       #
########################################################################################	

#store server locations that will be used to build file names
($cgi_dir,$config_dir,$data_script) = &get_locations();

#add our cgi dir to the INC array
push (@INC,$cgi_dir);

#utility module used in RWS
require rwsutils5;
require rwsxml5;

########################################################################################
#             GLOBAL CONSTANT LIST						       						   #
########################################################################################

#change these values to what you want to see in confirmation pages and email notifications for missing values
$MISSING_ANSWERS = "No Response";
$MISSING_QUESTION_TEXT = "";
	
$CGI_MPD = "RWS_MPD";

#question suffix for Form Configuration file
$HTML_REPLACE_ERROR_TAG = "ERROR_MESSAGE";
$ERROR_NUM_FILE_ACCESS = "1000";
$ERROR_NUM_INVALID_PASSWORD = "2000";
$ERROR_NUM_PASSWORD_EXPIRED = "3000";
$ERROR_NUM_SUBMISSION_CAPACITY = "4000";
$ERROR_NUM_WEBFORM_UNAVAILABLE = "5000";

#Set this to 1 in order to allow non-ASCII foreign characters to display properly when piped, auto-filled, etc.
#NOTE: Changing this value to 1 could leave your server vulnerable if you have Server Side Includes (SSI) turned on
$ALLOW_UNICODE = 0;

$USE_STARTTLS = 0;

#my $cr = pack ('c',13);
#my $lf = pack ('c',10);
#$CRLF = $cr . $lf;

$DIAGNOSTIC_MODE = 0;
$LOG_NAME = "RemarkWebSurveyLog.txt";
$MAX_SIZE = 10000000;

########################################################################################
#             GLOBAL STORAGE VARIABLES						       					   #
########################################################################################	

%form_configuration = ();
%form_directories = ();
%form_uid = ();
%hash_config_file = ();

$installation_config_file = &return_full_path($config_dir,'rwsad5.cfg');
$form_config_file = "";
$form_hash_file = "";
$session_uid = "";
$uid_file = "";
$legacy_pass = 0;

########################################################################################
#             MAIN PROCEDURES 							       						   #
########################################################################################	

#store the rws config file into a global hash if it exists
if(-e $installation_config_file)
{
	%rws_install_config = &read_config($installation_config_file,1);
}

#set the log file name
$LOG_NAME = $config_dir . $LOG_NAME;

#Check to see if we are in diagnostic mode
if (($DIAGNOSTIC_MODE == 1) || ($rws_i_nstalconfig{'[Defaults]'}{"Diagnostic"} == 1))
{
	#if we are, set the diagnostic flag
	$diagnostic_on = 1;

	#generate a thread_ID
	$thread_ID = &generate_uid;
}
   
&perform_form_action;

########################################################################################
# 			PERL SUBROUTINE / FUNCTION AREA				       						   #
########################################################################################

########################################################################################
# 	FUNCTION THAT APPENDS NEW HASHES TO AN EXISTING HASH			       			   #
#	USE: %new_hash = &append_hash (\%ORIGINAL_HASH,$KEY_NAME,\%APPEND_HASH);		   #	
########################################################################################
sub append_hash
{
	#local variable referencing passed in data - holds the original hash
	my %original_hash = %{$_[0]};
	
	#local variable referencing passed in data - holds the hash key name
	my $hash_key = $_[1];

	#local variable referencing passed in data - holds the append hash
	my %new_hash = %{$_[2]};

	#add to the log if in diagnostic mode
	if ($diagnostic_on == 1)
	{
		&write_log($LOG_NAME, $MAX_SIZE, "rws5.pm", "append_hash", "hash_key = " . $hash_key, $thread_ID, 1);
	}
	
	#local variables for indexing
	my $key_index = "";	
	my $new_key = "";

	#remove old hash before storing new values
	delete $original_hash{$hash_key};

	#loop thru the keys in the appending hash
	foreach $new_key (keys %new_hash)
	{
		#ignore values that do not matter (hidden vars, etc)
		if(($new_key ne 'FORM_ACTION') && ($new_key ne 'BACK') && ($new_key ne 'PAUSE') && ($new_key ne 'RWS_NAME') && ($new_key ne 'PAGE_KEY') && ($new_key !~ /_RWS_TYPE/) && ($new_key !~ /_RWS_NAME/) && ($new_key !~ /_RWS_NA/) && ($new_key ne 'x') && ($new_key ne 'y'))
		{
			#replace crlf with a bell
			$new_hash{$new_key} =~ s/\r\n/\a/g;

			#if we have a hidden key, convert &gt; back to > and &quot; back to "
			if ($new_key =~ /\_HIDDEN/)
			{
				$new_hash{$new_key} =~ s/\&gt\;/\>/g;
				$new_hash{$new_key} =~ s/\&quot\;/\>/g;
			}

			#append new hash to existing hash at designated family/key
			$original_hash{$hash_key}{$new_key} = $new_hash{$new_key};
		}
	}	

	#add to the log if in diagnostic mode
	if ($diagnostic_on == 1)
	{
		&write_log($LOG_NAME, $MAX_SIZE, "rws5.pm", "append_hash", "None", $thread_ID, 0);
	}

	#the hash has been added, so we may exit returning the new hash
	return (%original_hash);
}

########################################################################################
# 	FUNCTION THAT MERGES THE UID HASH WITH AN EXISTING HASH			       			   #
#	USE: %new_hash = &merge_uid_hash (\%ORIGINAL_HASH,$SKIP_KEY_NAME,);		       	   #	
########################################################################################
sub merge_uid_hash
{
	#local variable referencing passed in data - holds the original hash
	my %original_hash = %{$_[0]};
	
	#local variable referencing passed in data - holds the hash key name
	my $skip_hash_key = $_[1];

	#add to the log if in diagnostic mode
	if ($diagnostic_on == 1)
	{
		&write_log($LOG_NAME, $MAX_SIZE, "rws5.pm", "merge_uid_hash", "skip_hash_key = " . $skip_hash_key, $thread_ID, 1);
	}
	
	#local variables for indexing
	my $key_index = "";	
	my $uid_key = "";
	my $tmp_index = "";
	my $tmp_key = "";

	#loop thru the keys in the uid hash
	foreach $uid_key (keys %form_uid)
	{
		#skip the requested key as well as the MISC heading - also skip x + y (image buttons)		
		next if (($uid_key eq $skip_hash_key) || ($uid_key eq '[MISC]') || ($uid_key eq 'x') || ($uid_key eq 'y'));

		#loop thru the keys for the specific header key
		foreach $key_index (sort keys %{$form_uid{$uid_key}})
		{	
			next if(($key_index eq 'QUESTION_START') || ($key_index eq 'QUESTION_END'));

			#turns '[Page_X]' into X]
			$tmp_index = (split(/\_/,$uid_key))[1];

			#turns 'X]' into X
			$tmp_index = (split(/\]/,$tmp_index))[0];

			#do NOT write out info for pages that were NOT truly submitted (BACK BUTTON WAS USED)
			@visited_pages = split(/\,/,$form_uid{'[MISC]'}{'SubmittedPages'});
			foreach $tmp_key (@visited_pages)
			{
				if($tmp_key eq $tmp_index)
				{
					$original_hash{$key_index} = $form_uid{$uid_key}{$key_index};
					last;
				}
			} 
		}
	}

	#add to the log if in diagnostic mode
	if ($diagnostic_on == 1)
	{
		&write_log($LOG_NAME, $MAX_SIZE, "rws5.pm", "merge_uid_hash", "None", $thread_ID, 0);
	}

	#the hash has been added, so we may exit returning the new hash
	return (%original_hash);
}

########################################################################################
# 	FUNCTION THAT LOADS A SUB-HASH FROM A HASH OF HASHES			       			   #
#	USE: %RETURN_HASH = &load_hash (\%ORIGINAL_HASH,$KEY_NAME);		       			   #	
########################################################################################
sub load_hash
{
	#local variables referencing passed in data
	my %original_hash = %{$_[0]};
	
	#local variable referencing passed in data - holds the hash key name
	my $hash_key = $_[1];

	#add to the log if in diagnostic mode
	if ($diagnostic_on == 1)
	{
		&write_log($LOG_NAME, $MAX_SIZE, "rws5.pm", "load_hash", "hash_key = " . $hash_key, $thread_ID, 1);
	}

	#local variables for indexing
	my $key_index;
	
	#initialize our return hash
	my %ret_hash = ();

	#loop thru the existing hash searching for the passed in key
	foreach $key_index (keys %original_hash)
	{
		#if the key passed in matches the current family then continue
		if ($hash_key eq $key_index)
		{
			#set the return hash to the hash at the designated family/key
			$ret_hash{$key_index} = $original_hash{$key_index};	

			#the hash has been loaded, so we may exit returning the new hash
			return (%ret_hash);
		}
	}

	#add to the log if in diagnostic mode
	if ($diagnostic_on == 1)
	{
		&write_log($LOG_NAME, $MAX_SIZE, "rws5.pm", "load_hash", "None", $thread_ID, 0);
	}

	#return the original hash with no additions as key was not found
	return (%ret_hash);
}

########################################################################################
# 	FUNCTION THAT RELOADS AN HTML PAGE WITH STORED VALUES VIA REGULAR EXPRESSIONS  	   #
#	USE: $NEW_HTML = &reload_form_replacement($HTML_FILE,$ERR_TXT,$ERR_NUM,$PAGE_KEY); #	
########################################################################################
sub reload_form_replacement
{
	#store the passed in file names
	my $html_file = $_[0];
	my %err_text = %{$_[1]};;
	my $err_num = $_[2];
	my $target_key = $_[3];
	my $all_lines = "";
	my $key = "";
	my $sub_key = "";
	my $base_key = "";
	my $whole_error_tag = "";	
	my $source_lines = "";
	my @multi_list = ();	
	my %key_values = ();
	my $start_err = "";
	my $end_err = "";
	my $border = '0';
	my $confirm_data = "";
	my $back_location = "";
	my @file_data = ();
	my $confirm_text = "";
	my $begin_confirm_copy = 0;
	my $checkbox_answer = "";
	my $checkbox_temp = "";
	my %multiple_answer = ();
	my $multilist_answer = "";
	my $multilist_temp = "";
	my $answer_temp = "";

	#add to the log if in diagnostic mode
	if ($diagnostic_on == 1)
	{
		&write_log($LOG_NAME, $MAX_SIZE, "rws5.pm", "reload_form_replacement", "html_file = " . $html_file . " && target_key = " . $target_key, $thread_ID, 1);
	}
	
	#if the error message is not define, give it a default one
	if ($form_configuration{'[MISC]'}{'ErrorMessageFileAccess'} eq "")
	{
		$form_configuration{'[MISC]'}{'ErrorMessageFileAccess'} = "File Access Error: An error occurred attempting to access a file. Please check the file and directory permissions before continuing.";
 	}
 	#check to see if the source file exists
	if (-e $html_file)
	{
		#open the source file and set the source file handle
		open (SRC_FILE, $html_file) || die &show_server_error($ERROR_NUM_FILE_ACCESS,"File Access Error",$form_configuration{'[MISC]'}{'ErrorMessageFileAccess'} . " [" . $html_file . "]", __LINE__);
	}
	else
	{
		&show_server_error($ERROR_NUM_FILE_ACCESS,"File Access Error",$form_configuration{'[MISC]'}{'ErrorMessageFileAccess'} . " [" . $html_file . "]", __LINE__);
		exit;
	}

	#read in the uid file
	if (-e $uid_file)
	{
		%form_uid = &read_config($uid_file,1);

		#read in the key=value pairs that must be merged back into the HTML file
		%key_values = &read_config($uid_file,1);
		#use the form config file to search for defaults
		if(!(exists $key_values{$target_key}))
		{
			%key_values = %form_configuration;
		}
	}

	#don't change the target_key if it is an info page
	if (($target_key ne "[info_page]") && ($target_key ne "[reset_pause_page]"))
	{
		#add the current page to the uid file
		$form_uid{'[MISC]'}{'ActiveKey'} = $target_key;

	}

	if ($target_key ne "[info_page]")
	{
		#write out a uid file
		&write_config(\%form_uid,$uid_file,1);
	}

   	#read the file into an array 
	@file_data=<SRC_FILE>;

	#close the source file because we are finished reading in the key=value pairs
	close (SRC_FILE);

	#loop thru storing the lines
 	foreach $source_lines (@file_data)
 	{	
 		#remove the \n character
 		chop ($source_lines);

		#if we are copying the html section for the confirm page
		if($begin_confirm_copy == 1)
		{
			#make sure we have not reached the end of the copy
			if($source_lines =~ "@*(CONFIRM_END)")
			{
				$begin_confirm_copy=0;
			}
			else
			{
				#copy the html into a scalar
				$confirm_text .= $source_lines;
			}
		}
		#set the copy hmtl flag and insert a replacement holder
		elsif($source_lines =~ "@*(CONFIRM_START)")
		{
			
			$begin_confirm_copy = 1;
			$all_lines .= "@*(CONFIRM_REPLACE)\n";
		}
		#copy the regular html
		else
		{
			$all_lines .=  $source_lines;
		} 		
 	}

	#handle possible error case by inserting message OR removing error TAG
	if(scalar keys %err_text)
	{
		$border = $form_configuration{'[MISC]'}{'ErrorBorder'};
		$whole_error_tag = '<TABLE WIDTH="100%" BORDER="' . $border . '" CELLPADDING="6" CELLSPACING="3" BGCOLOR="' . $form_configuration{'[MISC]'}{'ErrorBackColor'} . '"><TR><TD>';

		if($form_configuration{'[MISC]'}{'ErrorFontBold'} eq '1')
		{
			$whole_error_tag .= '<B>';
		}
		if($form_configuration{'[MISC]'}{'ErrorFontItalic'} eq '1')
		{
			$whole_error_tag .= '<I>';
		}
		if($form_configuration{'[MISC]'}{'ErrorFontUnderline'} eq '1')
		{
			$whole_error_tag .= '<U>';
		}
		
		#construct main error tag here
		$whole_error_tag .= '<FONT FACE="' . $form_configuration{'[MISC]'}{'ErrorFontName'} . '" SIZE="' . $form_configuration{'[MISC]'}{'ErrorFontSize'} . '" COLOR="' . $form_configuration{'[MISC]'}{'ErrorHighlightColor'} . '">'; 

		foreach $qid (sort mysort keys %err_text)
		{

			$whole_error_tag .= '<P>' . $err_text{$qid} . '</P>'; 
			

			#construct error replacement tags
			$start_err = $qid . '_START_ERR';
			$end_err = $qid . '_END_ERR';

			#check for required error tags in table first
			$all_lines =~ s/required\_question\:\@\*\($start_err\)/border:1px double $form_configuration{'[MISC]'}{'ErrorHighlightColor'} \;/g;	

			$all_lines =~ s/\@\*\($start_err\)/<FONT COLOR="$form_configuration{'[MISC]'}{'ErrorHighlightColor'}">*/g;	
			$all_lines =~ s/\@\*\($end_err\)/<\/FONT>/g;		
		}

		$whole_error_tag .= '</FONT>';
		
		if($form_configuration{'[MISC]'}{'ErrorFontUnderline'} eq '1')
		{
			$whole_error_tag .= '</U>';
		}
		if($form_configuration{'[MISC]'}{'ErrorFontItalic'} eq '1')
		{
			$whole_error_tag .= '</I>';
		}
		if($form_configuration{'[MISC]'}{'ErrorFontBold'} eq '1')
		{
			$whole_error_tag .= '</B>';
		}
		
		$whole_error_tag .= '</TD></TR></TABLE>';

		$all_lines =~ s/\*\($HTML_REPLACE_ERROR_TAG\)/$whole_error_tag/g;
	}
	else
	{
		$all_lines =~ s/\*\($HTML_REPLACE_ERROR_TAG\)//g;
	}

	#insert confirmation page data
	if($confirm_text ne '')
	{
		$confirm_data = &add_confirmation_data($confirm_text,0,1,1);
		$all_lines =~ s/\@\*\(CONFIRM_REPLACE\)/$confirm_data/g;
	}

	#replace remaining error tags
	$all_lines =~ s/required\_question\:\@\*\([a-fA-F0-9\-]*?_START_ERR\)//g;
	$all_lines =~ s/\@\*\([a-fA-F0-9\-]*?_START_ERR\)//g;	
	#$all_lines =~ s/\@\*\([a-fA-F0-9\-]*?_END_ERR\)//g;

	#loop thru the key values replacing the special characters in the HTML file with the saved values
	foreach $key (keys %{$key_values{$target_key}})
	{					  
		#reinsert lf
		$key_values{$target_key}{$key} =~ s/\a/\n/g;
		
		#this will handle checkboxes '@^()'
		$all_lines =~ s/\@\^\(\Q$key\E\)/CHECKED/g;

		#this will handle radio buttons '@+()'
		$all_lines =~ s/\@\+\(\Q$key$key_values{$target_key}{$key}\E\)/CHECKED/g;

		#make sure there exists an '%' sign if there is than we have a multi-list
		if ($key =~ /([\S]*\_RWS\_MPD)-/)
		{	
			$multi_list = $1;
			
			#this will handle mulitple lists '@!()' by removing the incrementing number (index)
			$all_lines =~ s/\@\!\(\Q$multi_list$key_values{$target_key}{$key}\E\)/SELECTED/g;
		}
		else
		{
			#this will handle single lists '@!()'
			$all_lines =~ s/\@\!\(\Q$key$key_values{$target_key}{$key}\E\)/SELECTED/g;
		}

		#make sure the global constant is off
		if ($ALLOW_UNICODE != 1)	
		{
			#escape bad characters:  *TO UN-ESCAPE USE THE FOLLOWING - [$variable] =~ s/&#(\d+);/pack("c",$1)/ge;
			$key_values{$target_key}{$key} =~ s/([\<\!\-\#\>\|\0])/'&#'.ord($1).';'/ge;;
		}

		#this will handle text boxes and textareas '@*()'
		$all_lines =~ s/\@\*\(\Q$key\E\)/$key_values{$target_key}{$key}/g;
	}
	
	#insert the formname into our form '@*()'
	if(exists $form_configuration{'[MISC]'}{'FormName'})
	{
		$all_lines =~ s/\@\*\(form_query\)/\?FORM\=$form_configuration{'[MISC]'}{'FormName'}/g;
	}
	else
	{
		$all_lines =~ s/\@\*\(form_query\)//g;
	}

	#insert the uid into our form '@*()'
	if($session_uid ne '')
	{
		$all_lines =~ s/\@\*\(uid\)/\&UID\=$session_uid/g;
	}
	else
	{
		$all_lines =~ s/\@\*\(uid\)//g;
	}
	
	#insert the image server script into form '@*()'
	$all_lines =~ s/\@\*\(img\)/$form_directories{'[Defaults]'}{'ImageScript'}/g;  
	
	#insert the data script into form '@*()'
	$all_lines =~ s/\@\*\(data\)/$data_script_location/g;

	#find any query parameter inserts
	while ($all_lines =~ /\&\#64\;\&\#42\;\&\#40\;QUERY_(.*?)\&\#41\;\&\#42\;\&\#64\;/)
	{
		#save the parameter name
		$parameter = $1;

		#set the replace text to the parameter 
		$parameter_replace_text = $form_uid{'[Queries]'}{lc($parameter)};

		#turn > into &gt;
		$parameter_replace_text =~ s/\>/&gt\;/g;

		#turn " into &qout;
		$parameter_replace_text =~ s/\"/&quot\;/g;
	
		#replace the text
		$all_lines =~ s/\&\#64\;\&\#42\;\&\#40\;QUERY_$parameter\&\#41\;\&\#42\;\&\#64\;/$parameter_replace_text/;
	}

	#find any escaped out query parameter inserts
	while ($all_lines =~ /\@\*\(QUERY_(.*?)\)\*\@/)
	{
		#save the parameter name
		$parameter = $1;

		#set the replace text to the parameter 
		$parameter_replace_text = $form_uid{'[Queries]'}{lc($parameter)};

		#turn > into &gt;
		$parameter_replace_text =~ s/\>/&gt\;/g;

		#turn " into &qout;
		$parameter_replace_text =~ s/\"/&quot\;/g;
	
		#replace the text
		$all_lines =~ s/\@\*\(QUERY_$parameter\)\*\@/$parameter_replace_text/;
	}

	#find the randomized answers by saving the content between each @*(START_RANDOMIZE) and @*(END_RANDOMIZE)
	while ($all_lines =~ m/\@\*\(START\_RANDOMIZE\)(.*?)\@\*\(END\_RANDOMIZE\)/) 
	{
		#save the temp string into answer choices
		$answer_choices = $1;

		#set a number of rows flag
		my $number_rows = 1;

		#if we have an blank line, split it off first
		if ($answer_choices =~ /\@\*\(END\_NON\_RESPONSE\_ANSWER\_CHOICE\)/)
		{
			($blank_answer_choice, $answer_choices) = split(/\@\*\(END\_NON\_RESPONSE\_ANSWER\_CHOICE\)/, $answer_choices);
		}


		#split the answer choices at @*(END_ANSWER_CHOICE)
		@answers = split(/\@\*\(END\_ANSWER\_CHOICE\)/, $answer_choices);

		#loop through each of the answer choices to check for multiple answer columns
		foreach $single_answer_choice (@answers)
		{
			#replace the overall table for the answer with a @*(answer_option_table) flag
			$single_answer_choice =~ s/(\<table.*?\>[\w\W]*\<\/table.*?\>)/\@\*\(answer_option_table\)/;

			#set removed_table to the code we stripped out
			$removed_table = $1;

			#see if there are any remaining </tr><tr> tags, if so, we have another row (meaning mutliple answer columns)
			while($single_answer_choice =~ /\<\/tr.*?\>[.\n\r]*?\<tr.*?\>/)
			{
				#if so, strip out the rows and up the number_rows flag
				$single_answer_choice =~ s/\<\/tr.*?\>[.\n\r]*?\<tr.*?\>//;
				$number_rows++;
			}

			#replace the answer table back into the code
			$single_answer_choice =~ s/\@\*\(answer_option_table\)/$removed_table/;					
		}

		#declare a temp array
		my @temp_list = ();

		#if there is a blank answer response for drop-down lists, add it to the array first
		if ($blank_answer_choice ne "")
		{
			push (@temp_list, $blank_answer_choice);
		}

		#loop through the array, randomly removing one element and storing it into @temp_list
		while (@answers)
		{
			push (@temp_list, splice(@answers, rand(@answers), 1));
		}

		#set answers to the temp_list
		@answers = @temp_list;

		#set an empty array to store the text from columns without answer choices
		my @empty_columns = ();

		#count the number of lines
		$number_lines = $#answers;

		#set the answer_choices text to nothing to start
		$answer_choices = "";

		#counter to determine what row we are on
		$tempflag = 0;

		#store each line into the new answer_choices
		foreach $answer_line (@answers) 
		{
			#if this row has an answer choice in it, print it out
			if ($answer_line =~ m/\<input/)
			{
				#check to see if we need to start a new row
				if ($tempflag >= ($number_lines / $number_rows))
				{
					$answer_choices .= "</tr>\n<tr>";
					$tempflag = 0;
				}
			
				#add this to the answer_choices text
				$answer_choices .= $answer_line;
				$tempflag++;
			}
			#if not, put it in the empty_columns array
			else
			{
				push(@empty_columns, $answer_line);
				next;
			}
		}

		#add in the empty lines to the answer_choices text
		foreach $empty_line (@empty_columns) 
		{
			$answer_choices .= $empty_line;
		}

		#replace the new line in the old one's spot
		$all_lines =~ s/\@\*\(START\_RANDOMIZE\)(.*?)\@\*\(END\_RANDOMIZE\)/$answer_choices/;
	}

	#replace remaining textboxes with nothing (removes special characters)	
	$all_lines =~ s/\@\*\(.*?\)//g;

	#replace remaining checkboxes with nothing (removes special characters)	
   	$all_lines =~ s/\@\^\(.*?\)//g;

	#replace remaining radio buttons with nothing (removes special characters)	
	$all_lines =~ s/\@\+\(.*?\)//g;

	#replace remaining lists with nothing (removes special characters)	
	$all_lines =~ s/\@\!\(.*?\)//g;

	#insert piping answers
	$all_lines = &piping($all_lines, 1);

	#add to the log if in diagnostic mode
	if ($diagnostic_on == 1)
	{
		&write_log($LOG_NAME, $MAX_SIZE, "rws5.pm", "reload_form_replacement", "None", $thread_ID, 0);
	}

	#return the 'new' source file with the values merged into the HTML file
	return $all_lines; 
}

########################################################################################
# 	FUNCTION THAT WRITES OUT ALL OF THE HASH VALUES to STDOUT 		       			   #
#	USE: &print_hash(%HASH_NAME);		       				       					   #		
########################################################################################
sub print_hash
{
	#variables holding parameter data
	my %hash_array = @_;

	#add to the log if in diagnostic mode
	if ($diagnostic_on == 1)
	{
		&write_log($LOG_NAME, $MAX_SIZE, "rws5.pm", "print_hash", "None", $thread_ID, 1);
	}

	#local variables
	my $hash_family = "";
	my $hash_key = "";
	
	#loop thru printing all hash values
	foreach $hash_family (keys %hash_array)
	{
		print "\n$hash_family\n";
		foreach $hash_key (keys %{$hash_array{$hash_family}})
		{
 			print "$hash_key: $hash_array{$hash_family}{$hash_key}\n";
		}
	}

	#add to the log if in diagnostic mode
	if ($diagnostic_on == 1)
	{
		&write_log($LOG_NAME, $MAX_SIZE, "rws5.pm", "print_hash", "None", $thread_ID, 0);
	}
}

########################################################################################
# 	FUNCTION THAT VALIDATES CREDENTIALS FROM A UID FILE     		       			   #	
#	USE: &validate_credentials($HASH);	               								   #		
########################################################################################
sub validate_credentials
{
	my $respondent_hash = $_[0];
	my $password_file_name = $form_hash_file;
	my %file_hash = ();
	my $key = "";

	#add to the log if in diagnostic mode
	if ($diagnostic_on == 1)
	{
		&write_log($LOG_NAME, $MAX_SIZE, "rws5.pm", "validate_credentials", "respondent_hash = " . $respondent_hash, $thread_ID, 1);
	}

	if(!(-e $password_file_name))
	{	
		#add to the log if in diagnostic mode
		if ($diagnostic_on == 1)
		{
			&write_log($LOG_NAME, $MAX_SIZE, "rws5.pm", "validate_credentials", "No Password File", $thread_ID, 0);
		}

		return (0);
	}

	else
	{
		#if the UID file has not been read in
		if ((! %form_uid) && (-e $uid_file))
		{
			#read in the uid file
			%form_uid = &read_config($uid_file,1);
		}

		#if we have XML hash file
		if ($legacy_pass == 0)
		{
			#If we have a set of hash ranges
			if (%{$form_configuration{'[HashRanges]'}})
			{
				#loop through each key
				foreach $key (keys %{$form_configuration{'[HashRanges]'}})
				{
					#if we have a username
					if ($respondent_hash =~ /\:/)
					{
						#split the username and the password
						($hash_username, $hash_password) = split(/\:/, $respondent_hash);
					}
					else
					{
						#otherwise we just want the password
						$hash_password = $respondent_hash;
					}

					#get the range
					($range_begin, $range_end) = split(/\-/, $key);
		

					#if the hash falls in the range
					if (($hash_password ge $range_begin) && ($hash_password le $range_end))
					{
						#set the form hash file
						$password_file_name =~ s/webform.*?\.resx/$form_configuration{'[HashRanges]'}{$key}/;

						#end the loop
						last;
					}

				}

			}
			
			#load the XML file into %file_hash
			%file_hash = &read_XML($password_file_name, $respondent_hash);

			#if there is an entry defined for it, the login exists
			if ($file_hash{'exists'} == 1)
			{			
				#if we are trying to RELOGIN - make sure passwords match
				if($form_uid{'[MISC]'}{'PWD'} ne '')
				{
					#if we have a username
					if ($form_uid{'[MISC]'}{'USER'} ne '')
					{
						#combine the encrypted username and password pair
						$user_and_pass = &HexDigest(&BinaryEncoding(lc($form_uid{'[MISC]'}{'USER'}))) . ":" . $form_uid{'[MISC]'}{'PWD'};

						#return one if it matches
						if ($respondent_hash eq $user_and_pass)
						{
							#add to the log if in diagnostic mode
							if ($diagnostic_on == 1)
							{
								&write_log($LOG_NAME, $MAX_SIZE, "rws5.pm", "validate_credentials", "Password and User Match", $thread_ID, 0);
							}

							return (1);
						}
						else
						{
							#add to the log if in diagnostic mode
							if ($diagnostic_on == 1)
							{
								&write_log($LOG_NAME, $MAX_SIZE, "rws5.pm", "validate_credentials", "Password and User Don't Match", $thread_ID, 0);
							}
							return (-1);
						}
					}
					else
					{
						if ($respondent_hash eq $form_uid{'[MISC]'}{'PWD'})
						{
							#add to the log if in diagnostic mode
							if ($diagnostic_on == 1)
							{
								&write_log($LOG_NAME, $MAX_SIZE, "rws5.pm", "validate_credentials", "Password Matches", $thread_ID, 0);
							}

							return (1);
						}
						else
						{
							#add to the log if in diagnostic mode
							if ($diagnostic_on == 1)
							{
								&write_log($LOG_NAME, $MAX_SIZE, "rws5.pm", "validate_credentials", "Password Doesn't Match", $thread_ID, 0);
							}

							return (-1);
						}
					}	
				}
				#if not re-logging in, write out piping values to UID
				else
				{
					#if there is stuff to add to the UID file
					if (($file_hash{'pipe_text'} ne "") || ($file_hash{'email'} ne "") || ($file_hash{'name'} ne ""))
					{
						#if there is piping
						if ($file_hash{'pipe_text'} ne "")
						{

							#create a hashfile
							my %uid_hash = {};

							#read in the pipe hash
							%uid_hash = &read_pipe($file_hash{'pipe_text'});

							#loop through the key/value hash
							foreach $key (keys %uid_hash)
							{
								if ($key !~ /HASH\(.*\)/)
								{
									#add it to the hash
									$form_uid{'[PIPE]'}{$key} = $uid_hash{$key};
								}
							}
						}

						#if there is piping
						if ($file_hash{'email'} ne "")
						{
							#add it to the hash
							$form_uid{'[MISC]'}{'RespondentEmailAddress'} = $file_hash{'email'};
						}

						#if there is a name
						if ($file_hash{'name'} ne "")
						{
							#add it to the hash
							$form_uid{'[MISC]'}{'RespondentName'} = $file_hash{'name'};
						}
						
						#write out the uid file
						&write_config(\%form_uid,$uid_file,1);
					}
					#add to the log if in diagnostic mode
					if ($diagnostic_on == 1)
					{
						&write_log($LOG_NAME, $MAX_SIZE, "rws5.pm", "validate_credentials", "Validation Successful", $thread_ID, 0);
					}
					return (1);
				}
				last;
			}
			
		}
		#otherwise using RWS5.0 file format
		else
		{
			#read the hash file - should have headers
			%file_hash = &read_config($password_file_name,1);

			#set a temp hash and eliminate the colon (5.0 backwards compatibility)
			$temp_hash = $respondent_hash;
			$temp_hash =~ s/\://;
		
			#loop thru each key=value pair looking for the 'ID' key
			foreach $key (keys %{$file_hash{'[RESPONDENT ACCESS]'}})
			{
				if ($key eq $temp_hash)
				{
					#if we are trying to RELOGIN - make sure passwords match
					if($form_uid{'[MISC]'}{'PWD'} ne '')
					{
						#if we have a username
						if ($form_uid{'[MISC]'}{'USER'} ne '')
						{
							#combine the encrypted username and password pair
							$user_and_pass = &HexDigest(&BinaryEncoding(lc($form_uid{'[MISC]'}{'USER'}))) . $form_uid{'[MISC]'}{'PWD'};

							#return one if it matches
							if ($key eq $user_and_pass)
							{
								#add to the log if in diagnostic mode
								if ($diagnostic_on == 1)
								{
									&write_log($LOG_NAME, $MAX_SIZE, "rws5.pm", "validate_credentials", "Password and User Match", $thread_ID, 0);
								}
								return (1);
							}
							else
							{
								#add to the log if in diagnostic mode
								if ($diagnostic_on == 1)
								{
									&write_log($LOG_NAME, $MAX_SIZE, "rws5.pm", "validate_credentials", "Password and User Don't Match", $thread_ID, 0);
								}
								return (-1);
							}
						}
						else
						{
							if ($key eq $form_uid{'[MISC]'}{'PWD'})
							{
								#add to the log if in diagnostic mode
								if ($diagnostic_on == 1)
								{
									&write_log($LOG_NAME, $MAX_SIZE, "rws5.pm", "validate_credentials", "Password Matches", $thread_ID, 0);
								}
								return (1);
							}
							else
							{
								#add to the log if in diagnostic mode
								if ($diagnostic_on == 1)
								{
									&write_log($LOG_NAME, $MAX_SIZE, "rws5.pm", "validate_credentials", "Password Doesn't Match", $thread_ID, 0);
								}
								return (-1);
							}
						}	
					}
					else
					{
						#add to the log if in diagnostic mode
						if ($diagnostic_on == 1)
						{
							&write_log($LOG_NAME, $MAX_SIZE, "rws5.pm", "validate_credentials", "Validation Successful", $thread_ID, 0);
						}
						return (1);
					}
					last;
				}
			}
		}
	}
	#add to the log if in diagnostic mode
	if ($diagnostic_on == 1)
	{
		&write_log($LOG_NAME, $MAX_SIZE, "rws5.pm", "validate_credentials", "Validation Failed", $thread_ID, 0);
	}
	return (0);	
}

########################################################################################
# 	FUNCTION THAT INCREMENTS PASSWORD USES			     		       				   #	
#	USE: $valid_password = &password_status($PASSWORD_FILE,$PASSWORD_HASH,$INC);       #		
########################################################################################
sub password_status
{
	use MIME::Base64;
	require rwsem5;

	my $file_name = $_[0];
	my $password_hash = $_[1];
	my $increment_password = $_[2];
	my %file_hash = ();
	my $key = "";
	my $lock_file = "";
	my $lock_cnt = 0;

	#add to the log if in diagnostic mode
	if ($diagnostic_on == 1)
	{
		&write_log($LOG_NAME, $MAX_SIZE, "rws5.pm", "password_status", "file_name = " . $file_name . " && password_hash = " . $password_hash . " && increment_password = " . $increment_password, $thread_ID, 1);
	}

	#if there's a username and it hasn't already been appended, append the password to it for encryption
	if (($form_configuration{'[MISC]'}{'UsernameQuestionKey'} ne "")  && ($password_hash !~ /\:/))
	{
		#see if the USER field is already defined
		if ($form_uid{'[MISC]'}{'USER'} ne "")
		{
			$password_hash = &HexDigest(&BinaryEncoding(lc($form_uid{'[MISC]'}{'USER'}))) . ":" .$password_hash;
		}
		#if not, check the query parameter (this is an auto login)
		elsif (&get_query_parameter('USER') ne "")
		{
			$password_hash = &HexDigest(&BinaryEncoding(lc(&get_query_parameter('USER')))) . ":" . $password_hash;
		}
	}

	#determine if there was a password limit established
 	if(($form_configuration{'[MISC]'}{'PasswordUseLimit'} ne '0') && ($form_configuration{'[MISC]'}{'PasswordUseLimit'} ne ""))
	{
		#generate a lock file name		
		$lock_file = $file_name . '.lck';

		if ($legacy_pass == 0)
		{
			#If we have a set of hash ranges
			if (%{$form_configuration{'[HashRanges]'}})
			{
				#loop through each key
				foreach $key (keys %{$form_configuration{'[HashRanges]'}})
				{
					#if we have a username
					if ($password_hash =~ /\:/)
					{
						#split the username and the password
						($hash_username, $hash_password) = split(/\:/, $password_hash);
					}
					else
					{
						#otherwise we just want the password
						$hash_password = $password_hash;
					}

					#get the range
					($range_begin, $range_end) = split(/\-/, $key);		

					#if the hash falls in the range
					if (($hash_password ge $range_begin) && ($hash_password le $range_end))
					{
						#set the form hash file
						$file_name =~ s/webform.*?\.resx/$form_configuration{'[HashRanges]'}{$key}/;

						#update the lock file name		
						$lock_file = $file_name . '.lck';

						#end the loop
						last;
					}

				}

			}

			#parse the file into file_hash
			%file_hash = &read_XML($file_name, $password_hash);

			#store the count in $password_count
			$password_count = $file_hash{'usecount'};

			#if blank, count is 0
			if ($password_count eq "")
			{
				$password_count = 0;
			}
			#otherwise decode it
			else
			{
				$password_count = decode_base64($password_count);
			}
		}
		#if legacy hash file
		else
		{
			#read the config file that was passed in - should have headers
			%file_hash = &read_config($file_name,1);

			#store the count in $password_count
			$password_count = decode_base64($file_hash{'[RESPONDENT ACCESS]'}{$password_hash});
		}

		#add a default error message if there isn't one
 		if ($form_configuration{'[MISC]'}{'ErrorMessagePasswordExpired'} eq "")
		{
			$form_configuration{'[MISC]'}{'ErrorMessagePasswordExpired'} = "The password supplied has expired. Please contact the form administrator and request a new password before continuing.";
 		}

		#if above the allowed amount
		if($password_count >= $form_configuration{'[MISC]'}{'PasswordUseLimit'})
		{
			#add a default error message if there isn't one
			if ($form_configuration{'[MISC]'}{'ErrorMessagePasswordExpired'} eq "")
			{
				$form_configuration{'[MISC]'}{'ErrorMessagePasswordExpired'} = "The password supplied has expired. Please contact the form administrator and request a new password before continuing.";
			}

			&show_server_error($ERROR_NUM_PASSWORD_EXPIRED,"Password Expired",$form_configuration{'[MISC]'}{'ErrorMessagePasswordExpired'}, __LINE__);
			&add_log_record('password expired','denied');
	
			#add to the log if in diagnostic mode
			if ($diagnostic_on == 1)
			{
				&write_log($LOG_NAME, $MAX_SIZE, "rws5.pm", "password_status", "Password Expired", $thread_ID, 0);
			}

			return 0;
		}
		elsif($increment_password == 1)
		{  				
			#if lock file exists, delay up to 5 seconds before opening the password file
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

			#increment the password_count
			$password_count++;

			#if we have XML hash
			if ($legacy_pass == 0)
			{
				#encode the password count
				$encoded_password_count = encode_base64($password_count++);

				#remove possible endlines
				chomp($encoded_password_count);

				#write out the XMLfile
				&increment_passwordXML($file_name, $password_hash, $encoded_password_count);
			}
			#otherwise running legacy hash
			else
			{
				#encode the value
				$file_hash{'[RESPONDENT ACCESS]'}{$password_hash} = encode_base64($password_count++);

				#write back out the password file with the adjusted increment
				&write_config (\%file_hash,$file_name,1);
			}
			
			#clean up the lock file if it exists
			if(-e $lock_file)
			{
				unlink $lock_file; 
			}

			#add to the log if in diagnostic mode
			if ($diagnostic_on == 1)
			{
				&write_log($LOG_NAME, $MAX_SIZE, "rws5.pm", "password_status", "Password Valid and Incremented", $thread_ID, 0);
			}

			#return ok if increment successful
			return 1;
		}
		else
		{
			#clean up the lock file if it exists
			if(-e $lock_file)
			{
				unlink $lock_file; 
			}

			#add to the log if in diagnostic mode
			if ($diagnostic_on == 1)
			{
				&write_log($LOG_NAME, $MAX_SIZE, "rws5.pm", "password_status", "Password Valid", $thread_ID, 0);
			}

			#return ok if not incrementing and not expired
			return 1;
		}
	}
	else
	{
		#clean up the lock file if it exists
		if(-e $lock_file)
		{
			unlink $lock_file; 
		}

		#add to the log if in diagnostic mode
		if ($diagnostic_on == 1)
		{
			&write_log($LOG_NAME, $MAX_SIZE, "rws5.pm", "password_status", "Password Valid", $thread_ID, 0);
		}

		#return ok if there is no limit on password uses
		return 1;
	}
}

########################################################################################
# 	FUNCTION THAT HANDLES BRANCHING				     		       					   #	
#	USE: $next_page = &perform_branch($PAGE_HEADER_KEY, %SUBMITTED_DATA);		       #		
########################################################################################
sub perform_branch
{
	my $hash_key = $_[0];
	my %submit_hash = %{$_[1]};
	my %page_rules = ();
	my %target_hash = ();
	my $target_page_key ="";
	my $target_page ="";	
	my $key = "";
	my $value = "";
	my $tmp_page = "";

	#add to the log if in diagnostic mode
	if ($diagnostic_on == 1)
	{
		&write_log($LOG_NAME, $MAX_SIZE, "rws5.pm", "perform_branch", "hash_key = " . $hash_key, $thread_ID, 1);
	}

	#add the previously submitted pages from the uid file
	%submit_hash = &merge_uid_hash(\%submit_hash,$hash_key);

	#extract the page of the form config hash 
	%page_rules = &load_hash (\%form_configuration,$hash_key);

	#loop thru all the keys evaluating rules
	foreach $key (sort keys %{$page_rules{$hash_key}})
	{
		#if we have located a page rule
		if(substr($key,0,5) eq "#RULE")
		{
			#get the rule and the target page key (delimited by tab)
			($value, $target_page_key) = split (/\t/, $page_rules{$hash_key}{$key});

			#lc target_pagekey
			$target_page_key = lc($target_page_key);

			#check for the [Auto] setting
			if($target_page_key eq '[auto]')
			{
				if($hash_key ne '[confirmation_page]')
				{
					#turns '[Page_X]' into X]
					$hash_key = (split(/\_/,$hash_key))[1];

					#turns 'X]' into X
					$hash_key = (split(/\]/,$hash_key))[0];

					#increment the page
					$hash_key++;

					#assign target to what 'should be the next page'
					$target_page_key = '[page_' . $hash_key . ']'; 
				}
				else
				{
					#try to locate a complete form page in the sequence
					$target_page_key = '[complete_page_1]';
					if(!(exists $form_configuration{$target_page_key}))	
					{
						if($form_configuration{'[MISC]'}{'DefaultWebFormCompletePage'} =~ /^http/)
						{
							#make sure the password has not expired
							if(&password_status($form_hash_file,$form_uid{'[MISC]'}{'PWD'},0) == 0)
							{
								exit;
							}

							#check for pipes on the redirect
							$form_configuration{'[MISC]'}{'DefaultWebFormCompletePage'} = &piping($form_configuration{'[MISC]'}{'DefaultWebFormCompletePage'});
							&browser_redirect($form_configuration{'[MISC]'}{'DefaultWebFormCompletePage'},$form_directories{'[Defaults]'}{'CGIRedirect'},\%submit_hash);
							
							#be sure to return 'complete_page' so we know we are finished
							return ("complete_page_x");
						}
						else
						{
							$target_page_key = '[complete_page_' . $form_configuration{'[MISC]'}{'DefaultWebFormCompletePage'} . ']';
							if(!(exists $form_configuration{$target_page_key}))	
							{
	 	   						&general_error_screen('Form Branch Error','<B>Module:</B> RWS5<BR><B>Line:</B> ' . __LINE__ . '<BR><B>Details:</B>  The designated branch path is invalid. Please contact the form administrator before continuing.',$form_configuration{'[MISC]'}{'AdminAddress'});
							}
						}
					}
				}

		  		#if there are no more pages in the sequence, load the 1st success page 
				if(!(exists $form_configuration{$target_page_key}))	
				{
					#try to locate a confirmation page in the sequence else, try complete page
					$target_page_key = '[confirmation_page]';
					if(!(exists $form_configuration{$target_page_key}))	
					{
						#try to locate a complete form page in the sequence
						$target_page_key = '[complete_page_1]';
						if(!(exists $form_configuration{$target_page_key}))	
						{
							if($form_configuration{'[MISC]'}{'DefaultWebFormCompletePage'} =~ /^http/)
							{
								#make sure the password has not expired
								if(&password_status($form_hash_file,$form_uid{'[MISC]'}{'PWD'},0) == 0)
								{
									exit;
								}

								#check for pipes on the redirect
								$form_configuration{'[MISC]'}{'DefaultWebFormCompletePage'} = &piping($form_configuration{'[MISC]'}{'DefaultWebFormCompletePage'});
								&browser_redirect($form_configuration{'[MISC]'}{'DefaultWebFormCompletePage'},$form_directories{'[Defaults]'}{'CGIRedirect'},\%submit_hash);
								
								#be sure to return 'complete_page' so we know we are finished
								return ("complete_page_x");
							}
							else
							{
								$target_page_key = '[complete_page_' . $form_configuration{'[MISC]'}{'DefaultWebFormCompletePage'} . ']';
								if(!(exists $form_configuration{$target_page_key}))	
								{
		 	   						&general_error_screen('Form Branch Error','<B>Module:</B> RWS5<BR><B>Line:</B> ' . __LINE__ . '<BR><B>Details:</B>  The designated branch path is invalid. Please contact the form administrator before continuing.',$form_configuration{'[MISC]'}{'AdminAddress'});
								}
							}
						}
					}
				}
			}
			
			#if we are to branch to a random page, simply set the target key = the page just submitted
			elsif($target_page_key eq '[random]')
			{
				$target_page_key = $hash_key;
			}

			#determine if the branching criteria for this rule was met OR failsafe page
			if ($value eq "*default*")
			{		
				#extract the page from the form config hash 
				%target_hash = &load_hash (\%form_configuration,$target_page_key);	
				
				#determine if the page we are supposed to go to is part of a random group
				if (defined $target_hash{$target_page_key}{"#RANDOM_ID#"})
				{
					#if greater than 0 then we have a random group
					if($target_hash{$target_page_key}{"#RANDOM_ID#"} ne '-1')
					{
						#get the key from the next random page
						$target_page_key = 	&next_random_page($target_hash{$target_page_key}{"#RANDOM_ID#"});

						#if a URL was specified goto that page instead
						if($target_page_key =~ /^http/)
						{
							#make sure the password has not expired
							if(&password_status($form_hash_file,$form_uid{'[MISC]'}{'PWD'},0) == 0)
							{
								exit;
							}

							#check for pipes on the redirect
							$target_page_key = &piping($target_page_key);
							&browser_redirect($target_page_key,$form_directories{'[Defaults]'}{'CGIRedirect'},\%submit_hash);
							return ($target_page_key);  
						}
						else
						{
							#extract the new random page from the form config hash 
							%target_hash = &load_hash(\%form_configuration,$target_page_key);
						}
					}
				}
		
				#get the target file from the target hash
				$target_page = $target_hash{$target_page_key}{"#SRC#"};
	
				#if a URL was specified goto that page instead
				if($target_page =~ /^http/)
				{
					#make sure the password has not expired
					if(&password_status($form_hash_file,$form_uid{'[MISC]'}{'PWD'},0) == 0)
					{
						exit;
					}

					#check for pipes on the redirect
					$target_page = &piping($target_page);
					&browser_redirect($target_page,$form_directories{'[Defaults]'}{'CGIRedirect'},\%submit_hash); 
				}
				else
				{
					#concatenate the form's directory with the target page
					$target_page = &return_full_path($form_directories{'[Forms]'}{$form_configuration{'[MISC]'}{'FormName'}},$target_page);	

					#make sure the password has not expired
					if($target_page =~ /complete\_page/)
					{
						if(&password_status($form_hash_file,$form_uid{'[MISC]'}{'PWD'},0) == 0)
						{
							exit;
						}
					}

					#navigate to the appropriate page
					&display_html(&reload_form_replacement($target_page,'','',$target_page_key));
				}	
				#return success
				return ($target_page_key);
				
				last;
			}
			elsif (eval($value))
			{
				#extract the page from the form config hash 
				%target_hash = &load_hash(\%form_configuration,$target_page_key);	
				
				#determine if the page we are supposed to go to is part of a random group
				if (defined $target_hash{$target_page_key}{"#RANDOM_ID#"})
				{
					if($target_hash{$target_page_key}{"#RANDOM_ID#"} ne '-1')
					{
						#get the key from the next random page
						$target_page_key = 	&next_random_page($target_hash{$target_page_key}{"#RANDOM_ID#"});

						#if a URL was specified goto that page instead
						if($target_page_key =~ /^http/)
						{
							if(&password_status($form_hash_file,$form_uid{'[MISC]'}{'PWD'},0) == 0)
							{
								exit;
							}

							#check for pipes on the redirect
							$target_page_key = &piping($target_page_key);
							&browser_redirect($target_page_key,$form_directories{'[Defaults]'}{'CGIRedirect'},\%submit_hash);
							return ($target_page_key);  
						}
						else
						{
							#extract the new random page from the form config hash 
							%target_hash = &load_hash(\%form_configuration,$target_page_key);
						}
					}
				}

				#get the target file from the target hash
				$target_page = $target_hash{$target_page_key}{"#SRC#"};

				#if a URL was specified goto that page instead
				if($target_page =~ /^http/)
				{
					if(&password_status($form_hash_file,$form_uid{'[MISC]'}{'PWD'},0) == 0)
					{
						exit;
					}

					#check for pipes on the redirect
					$target_page = &piping($target_page);
					&browser_redirect($target_page,$form_directories{'[Defaults]'}{'CGIRedirect'},\%submit_hash);  
				}
				else
				{
					#concatenate the form's dircetory with the target page
					$target_page = &return_full_path($form_directories{'[Forms]'}{$form_configuration{'[MISC]'}{'FormName'}},$target_page);	
					
					if($target_page =~ /complete\_page/)
					{
						if(&password_status($form_hash_file,$form_uid{'[MISC]'}{'PWD'},0) == 0)
						{
							exit;
						}
					}

					#navigate to the appropriate page
					&display_html(&reload_form_replacement($target_page,'','',$target_page_key));
				}	
				#return success
				return ($target_page_key);	
				
				last;
			}
		}
	}

	#add to the log if in diagnostic mode
	if ($diagnostic_on == 1)
	{
		&write_log($LOG_NAME, $MAX_SIZE, "rws5.pm", "perform_branch", "None", $thread_ID, 0);
	}


	#return failure
	return (0);
}
########################################################################################
# 	FUNCTION THAT GETS CGI + CONFIG DIRECTORIES  	       			       			   #	
#	USE: @dirs = &get_locations();	 	       										   #		
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
		&write_log($LOG_NAME, $MAX_SIZE, "rws5.pm", "get_locations", "None", $thread_ID, 1);
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
		&write_log($LOG_NAME, $MAX_SIZE, "rws5.pm", "get_locations", "None", $thread_ID, 0);
	}


	return (@dirs);
}

########################################################################################
# 	FUNCTION PERFORMS THE ACTION OF THE FORM 		       		       				   #	
#	USE: &perform_form_action();					       	       					   #		
########################################################################################
sub perform_form_action
{
	my %submitted_data = ();
	my $form_name = ""; 
	my $key = "";
	my $action = "";
	my $method = "";
	my $tmp_hash = "";
	my $next_page = "";
	my $back_location = "";
	my $timed_out = '1';
	my $full_url = "";
	my $current_page = "";
	my $archive_file = "";
	my $id_param = "";
	my $tmp_page = "";
	my $target_page = "";
	my $address = "";
	my @emails = ();
	my $valid_pass = 0;
	my $email_body = "";
	my %merged_data = ();
	my $lock_cnt = 0;
	my $uid_lock_file = "";
	my @pages = ();
	my $last_page = "";
	my $active_page = "";
	my $full_data_script_location = "";
	my $email_call = "";

	#get the form the script is requesting
	$form_name = &get_query_parameter('FORM');
	$form_name = lc($form_name);

	#add to the log if in diagnostic mode
	if ($diagnostic_on == 1)
	{
		&write_log($LOG_NAME, $MAX_SIZE, "rws5.pm", "perform_form_action", "form_name = " . $form_name, $thread_ID, 1);
	}

	
	#if missing or not found then show message and exit
	if($form_name eq '')
	{
		&general_error_screen('Form Not Specified','<B>Module:</B> RWS5<BR><B>Line:</B> ' . __LINE__ . '<BR><B>Details:</B> A form name must be appended to the end of the data script URL.<BR><DIR><I>Example:</I> ' . $ENV{'SCRIPT_NAME'} . '?FORM=FormNameHere</DIR>');
		exit;
	}

	#read the installation configuration file into the global hash
	%form_directories = &read_config($installation_config_file,1);

	#set the form config location correctly based on the form name
	$form_config_file = &return_full_path($form_directories{'[Forms]'}{$form_name},$form_name . '.cfg');

	#set the hashlist config location correctly based on the form name
	$form_hash_file = &return_full_path($form_directories{'[Forms]'}{$form_name},'webform.resx');

	#make sure we have .resx file, otherwise set to legacy mode
	if(-e $form_hash_file)
	{
		$legacy_pass = 0;
	}
	#check to see if we have a 5.2 password file
	elsif(-e &return_full_path($form_directories{'[Forms]'}{$form_name},'webform-1.resx'))
	{
		$legacy_pass = 0;
		$form_hash_file = &return_full_path($form_directories{'[Forms]'}{$form_name},'webform-1.resx');
	}
	else
	{
		$legacy_pass = 1;
		$form_hash_file = &return_full_path($form_directories{'[Forms]'}{$form_name},'webform.res');
	}

	#make sure that the form was installed before continuing
	if(!(exists $form_directories{'[Forms]'}{$form_name}))
	{ 
		&general_error_screen('Form Not Found','<B>Module:</B> RWS5<BR><B>Line:</B> ' . __LINE__ . '<BR><B>Details:</B> The <B>' . $form_name . '</B> Form could not be located. Please try reinstalling your form before continuing.');
		exit;
	}
	
	#read the form configuration into the global hash
	%form_configuration = &read_config($form_config_file,1);

	#get the data script location from the config file
	$data_script_location = $form_configuration{'[MISC]'}{'DataScript'};

	#check to make sure the form is within the live dates
	&check_live_form($form_configuration{'[MISC]'}{'LiveStartTime'}, $form_configuration{'[MISC]'}{'LiveEndTime'});

	#check to make sure the form is under the nunmber of respondents
	&check_number_respondents($form_name);
		
	#if a GET then display the login screen	or reload the old location
	if($ENV{'REQUEST_METHOD'} eq 'GET')
	{
		#get the UID from the query string	
		$session_uid = &get_query_parameter('UID');

		#if the UID variable is defined
		if($session_uid ne '')
		{
			#reconstruct the uid file name
			$uid_file = &return_full_path($form_directories{'[Forms]'}{$form_name},$session_uid);
			$uid_file .= '.uid';

			#if the UID file does NOT exist, then treat as new session
			if(!(-e $uid_file))
			{
				$session_uid = '';	
			}
		}

		#see if this is trying to load a popupinfo page
		$info_page = &get_query_parameter('POPUPINFO');
			
		#load the popupinfo page
		if ($info_page ne "")
		{
			#get the expected file location
			$back_location = &return_full_path($form_directories{'[Forms]'}{$form_name},$info_page);
	  				
	  		#display the user constructed page
	  		&display_html(&reload_form_replacement($back_location,'','','[info_page]'));
		  		
			exit;
		}

		#if UID is blank then we are on a new session
		if($session_uid eq '')
		{
			#generate a session_id that will be passed in the QUERY_string
			$session_uid = &generate_uid();
		
			#if password protected, display login screen
			if($form_configuration{'[MISC]'}{'PasswordProtected'} eq '1')
			{
				#attempt to read in the ID parameter from the query string
				$id_param = &get_query_parameter('PWD');

				#attempt to get the encrypted password and replace =s back into it
				$encrypted_id_param = &get_query_parameter('RWS');
				$encrypted_id_param =~ s/\%3[Dd]/\=/g;
				
				#if they are NOT auto-logging in from a link
				if (($id_param eq '') && ($encrypted_id_param eq ''))
				{
					#create the initial uid file
					&generate_uid_file;

					#write out a uid file
					&write_config(\%form_uid,$uid_file,1);

					#construct the location of the login page
					$back_location = &return_full_path($form_directories{'[Forms]'}{$form_name},'login_page.html');

					#display the user constructed login page else display file access error message
					if (-e $back_location)
					{
						&display_html(&reload_form_replacement($back_location,'','','[login_page]'));					
					}
					else
					{
						#if the error message is not defined, give it a default one
						if ($form_configuration{'[MISC]'}{'ErrorMessageFileAccess'} eq "")
						{
							$form_configuration{'[MISC]'}{'ErrorMessageFileAccess'} = "File Access Error: An error occurred attempting to access a file. Please check the file and directory permissions before continuing.";
						}

						&show_server_error($ERROR_NUM_FILE_ACCESS,"File Access Error",$form_configuration{'[MISC]'}{'ErrorMessageFileAccess'} . " [" . $html_file . "]", __LINE__);
					}
					exit;
				}
			}
			
			#not password protected
			else
			{
				#create the initial uid file
				&generate_uid_file;

				#write out a uid file
				&write_config(\%form_uid,$uid_file,1);

				#read in the uid file
				%form_uid = &read_config($uid_file,1);
				
				#load the correct first page
				&load_first_page();
			}
		}

		#reloading a pre-existing form
		else
		{	 

			#if password protected, diplay login screen
			if($form_configuration{'[MISC]'}{'PasswordProtected'} eq '1')
			{
				#attempt to get the encrypted password and replace =s back into it
				$encrypted_id_param = &get_query_parameter('RWS');
				$encrypted_id_param =~ s/\%3[Dd]/\=/g;

				#used for password protected surveys only
				require rwsem5;

				$username = &get_query_parameter('USER');

				#if there's a username, append the password to it for encryption
				if ($form_configuration{'[MISC]'}{'UsernameQuestionKey'} ne "")
				{
					$full_tmp_hash = &HexDigest(&BinaryEncoding(lc($username))) . ":" . $encrypted_id_param;
				}
				else
				{
					$full_tmp_hash = $encrypted_id_param;
				}
		
				#attempt validation sending in the password hash	  
				$valid_pass = &validate_credentials($full_tmp_hash);

				#if the password is valid
				if ($valid_pass != 1)
				{	    
					#construct the location of our last page
					$back_location = &return_full_path($form_directories{'[Forms]'}{$form_name},'login_page.html');

					#display the user constructed login page else display basic login page
					if (-e $back_location)
					{
						&display_html(&reload_form_replacement($back_location,'','','[login_page]'));					
					}
					else
					{
						&display_login_page;
					}
					exit;
				}
			}
			
				#read in the uid file
				%form_uid = &read_config($uid_file,1);

				#determine which page should be loaded - should be the page they paused on
				$next_page = &last_submitted_page;

				#if a page value was returned
				if ($next_page ne '0')
				{
					#get the expected file location
					$back_location = &return_full_path($form_directories{'[Forms]'}{$form_name},'page_' . $next_page . '.html');
	  				
	  				#display the user constructed page
	  				&display_html(&reload_form_replacement($back_location,'','','[page_' . $next_page . ']'));
		  			
		  			exit;
				}
				#page boundary error occured so display the first page in the form
				else
				{
					&load_first_page();
				}
		}	
	}

	#store the submitted data in the global hash
	%submitted_data = &store_post_data();

	#store the session UID that is being past as part of the consstructed query string
   	if($session_uid eq "")
   	{
   		$session_uid = &get_query_parameter('UID');
   	}	 	 

	#reconstruct the uid file base name
	$uid_file = &return_full_path($form_directories{'[Forms]'}{$form_name},$session_uid);
	
	#reconstruct the uid lock file name
	$uid_lock_file = $uid_file . '.lck';
	
	#reconstruct the uid file name
	$uid_file .= '.uid';
	
	#if lock file exists, delay up to 10 seconds before opening the data file
	while ((-e $uid_lock_file) and ($lock_cnt < 10)) 
	{
		sleep 1;
		$lock_cnt++;
	}

	#if the uid file exists read it into global hash
	if(-e $uid_file)
	{
		%form_uid = &read_config($uid_file,1);
	}
   	
	#if the uid file does not exist and we are not loading from a link report to the user that the session has expired
   	elsif(($id_param eq '') && ($encrypted_id_param eq ''))
	{
 		&general_error_screen("Session Expired","<B>Module:</B> RWS5<BR><B>Line:</B> " . __LINE__ . "<BR><B>Details:</B> The current session has expired due to a form submittal.",$form_configuration{'[MISC]'}{'AdminAddress'});	
 		exit; 
   	}

	#avoid multiple submit collisions
	if (defined $submitted_data{'PAGE_KEY'})
	{
		#if the current page does NOT equal the page we are trying to submit from
		if (($form_uid{'[MISC]'}{'ActiveKey'} ne $submitted_data{'PAGE_KEY'}) && ($submitted_data{'PAGE_KEY'} ne '[error_page]'))
		{
			#split the submitted pages string into hash
			@pages = split (/\,/, $form_uid{'[MISC]'}{'SubmittedPages'});

			#get the previous page in the sequence
			$last_page = $pages[$#pages];

			#turns '[Page_X]' into X]
			$active_page = (split(/\_/,$form_uid{'[MISC]'}{'ActiveKey'}))[1];

			#turns 'X]' into X
			$active_page = (split(/\]/,$active_page))[0];

			#push the active page back onto the queue IF IT IS NOT ALREADY THE LAST ITEM
			if($last_page ne $active_page)
			{
				&add_to_submitted_pages($form_uid{'[MISC]'}{'ActiveKey'});
			}
			
			#report the sequence error to the user 
			&general_error_screen("Invalid Page Sequence","<B>Details:</B> This page was submitted out of sequence; this may be a result of using the browser's navigation buttons.<BR>Click the continue button below to return to the last submitted page.",$form_configuration{'[MISC]'}{'AdminAddress'},1,$data_script_location,,"Continue",1);	
	 		exit;
		} 
	}

	#if attempting an auto form login	
	if(($id_param ne '') || ($encrypted_id_param ne ''))
	{
		#used for password protected surveys only
		require rwsem5;

		if ($id_param ne '')
		{
			#hash the password passed in
			$tmp_hash = &HexDigest(&BinaryEncoding($id_param));
		}
		else
		{
			$tmp_hash = $encrypted_id_param;
		}

		#if there's a username, append the password to it for encryption
		if ($form_configuration{'[MISC]'}{'UsernameQuestionKey'} ne "")
		{
			$full_tmp_hash = &HexDigest(&BinaryEncoding(lc(&get_query_parameter('USER')))) . ":" . $tmp_hash;
		}
		else
		{
			$full_tmp_hash = $tmp_hash;
		}
		
		#attempt validation sending in the password hash	  
		$valid_pass = &validate_credentials($full_tmp_hash);

		#if the password is valid
		if ($valid_pass == 1)
		{	  
			#make sure the password has not expired
			if(&password_status($form_hash_file,$full_tmp_hash,0) == 0)
			{
				exit;
			}
			
			#generate a UID file
			&generate_uid_file();

			#update last access time
			$form_uid{'[MISC]'}{'LastAccessTime'} = time;
			
			#update the uid file with the password hash used to gain access
			$form_uid{'[MISC]'}{'PWD'} = $tmp_hash;

			#if there's a username, append the password to it for encryption
			if ($form_configuration{'[MISC]'}{'UsernameQuestionKey'} ne "")
			{
				$form_uid{'[MISC]'}{'USER'} = &get_query_parameter('USER');
			}

			#write out the uid file
			&write_config(\%form_uid,$uid_file,1);
			
			#get the next page, determine if there were already submissions
			$next_page = &last_submitted_page($submitted_data{'PAGE_KEY'});
			
			if ($next_page ne '0')
			{
				#get the expected file location	of the last submitted page
				$back_location = &return_full_path($form_directories{'[Forms]'}{$form_name},'page_' . $next_page . '.html');	
				
				#add a record to the log file				
				&add_log_record('auto form access','permitted');

				#display the constructed html page
				&display_html(&reload_form_replacement($back_location,'','','[page_' . $next_page . ']'));

				exit;
			}
			
			#page boundary error has occurred so display the first page of the form
			else
			{
				&load_first_page();
			}
		}
		
		#password is not valid for THIS session
		elsif ($valid_pass == -1)
		{
			#add a record to the log
			&add_log_record('auto login invalid','denied');
		
			#supplied password and stored password don't match
			&show_server_error($ERROR_NUM_INVALID_PASSWORD,"Invalid Session Credentials","The credentials supplied do not match the ones associated with this session. Please verify the credentials and try again.", __LINE__);			
		}

		#password is not valid at all
		else
		{
			#add a record to the log
			&add_log_record('auto login invalid','denied');

			#if the error message is not defined, give it a default one
			if ($form_configuration{'[MISC]'}{'ErrorMessageInvalidPassword'} eq "")
			{
				$form_configuration{'[MISC]'}{'ErrorMessageInvalidPassword'} = "Access Denied: The credentials supplied were invalid. Please check the credentials and try again.";
			}

			#supplied password and stored password don't match
			&show_server_error($ERROR_NUM_INVALID_PASSWORD,"Invalid Credentials",$form_configuration{'[MISC]'}{'ErrorMessageInvalidPassword'}, __LINE__); 				
		}
		exit;				
	}
 	
 	#loop thru the submitted data searching for the action
	foreach $key (keys %submitted_data)
	{
		#all page actions are based on the FORM_ACTION parameter
	   	if($key eq 'FORM_ACTION')
		{
			#split the lines 'key=value' into (key, value) pairs
			($action, $method) = split (/\!/, $submitted_data{$key});

			#determine if a timeout value has been set for the form
			if($form_configuration{'[MISC]'}{'SessionLogoutTime'} ne '0')
			{
				#make sure that the session has not timed out
			   	if(($action ne 'LOGIN') && ($action ne 'DISPLAY_LOGIN') && ($action ne ''))
	 			{
					if($form_configuration{'[MISC]'}{'PasswordProtected'} eq '1')
					{
						$timed_out = &valid_session_time();
					}
	 			}
			}

			#if requesting to display the login page
			if($action eq 'DISPLAY_LOGIN')
			{
				#construct the location of our login page and attempt to display it
				$back_location = &return_full_path($form_directories{'[Forms]'}{$form_name},'login_page.html');
				if (-e $back_location)
				{
					&display_html(&reload_form_replacement($back_location,'','','[login_page]'));					}
				else
				{
					&display_login_page;
				}
				exit;
			}

			#if requesting to login
			elsif($action eq 'LOGIN')
			{
				my $temp_password_str = "";

				#used for password protected surveys only!
				require rwsem5;

				#hash the password passed in
				$tmp_hash = &HexDigest(&BinaryEncoding($submitted_data{'PASSWORD'}));

				#if there's a username, append the password to it for encryption
				if ($form_configuration{'[MISC]'}{'UsernameQuestionKey'} ne "")
				{
					$full_tmp_hash = &HexDigest(&BinaryEncoding(lc($submitted_data{$form_configuration{'[MISC]'}{'UsernameQuestionKey'} . '_RWS_TEXT'}))) . ":" . $tmp_hash;
				}
				else
				{
					$full_tmp_hash = $tmp_hash;
				}
		
				#attempt validation sending in the password hash
				$valid_pass = &validate_credentials($full_tmp_hash);	  
   				
				#if the password is valid
   				if ($valid_pass == 1)
				{			  
					#make sure the password has not expired
					if(&password_status($form_hash_file,$full_tmp_hash,0) == 0)
					{
						exit;
					}

					#update last access time
					$form_uid{'[MISC]'}{'LastAccessTime'} = time;

					#update the uid file with the password hash used to gain access
					$form_uid{'[MISC]'}{'PWD'} = $tmp_hash;

					#if there's a username, append the password to it for encryption
					if ($form_configuration{'[MISC]'}{'UsernameQuestionKey'} ne "")
					{
						$form_uid{'[MISC]'}{'USER'} = $submitted_data{$form_configuration{'[MISC]'}{'UsernameQuestionKey'} . '_RWS_TEXT'};
					}
														
					#write out the uid file
					&write_config(\%form_uid,$uid_file,1);
					
					#get the next page, determine if there were already submissions
					$next_page = &last_submitted_page($submitted_data{'PAGE_KEY'});
				
					#if a valid page was returned
					if ($next_page ne '0')
					{
	 					#if we have the RANDOM page value defined
						if(defined $form_configuration{'[page_' . $next_page . ']'}{'#RANDOM_ID#'})
						{
							#if we are dealing with a RANDOM page group
							if($form_configuration{'[page_' . $next_page . ']'}{'#RANDOM_ID#'} ne '-1')
							{
								#return a possible page in the random sequence
								$tmp_page = &next_random_page($form_configuration{'[page_' . $next_page . ']'}{'#RANDOM_ID#'});

								#if a URL was specified (SHOULD NOT be the case) goto that page instead
								if($tmp_page =~ /^http/)
								{
									%merged_data = &merge_submitted_data();

									#check for pipes on the redirect
									$tmp_page = &piping($tmp_page);
									&browser_redirect($tmp_page,$form_directories{'[Defaults]'}{'CGIRedirect'},\%merged_data);
									exit;  
								}
								#an html page key was returned
								else
								{
									#get the target file from the target hash
									$target_page = $form_configuration{$tmp_page}{"#SRC#"};

									#if a URL was specified goto that page instead
									if($target_page =~ /^http/)
									{
										%merged_data = &merge_submitted_data();

										#check for pipes on the redirect
										$target_page = &piping($target_page);
										&browser_redirect($target_page,$form_directories{'[Defaults]'}{'CGIRedirect'},\%merged_data);   
										exit;
									}

									#if a page was specified
									else
									{
										#concatenate the form's directory with the target page
										$target_page = &return_full_path($form_directories{'[Forms]'}{$form_configuration{'[MISC]'}{'FormName'}},$target_page);	
											
										#add log record
										&add_log_record('form access','permitted');
					
										#navigate to the appropriate page
										&display_html(&reload_form_replacement($target_page,'','',$tmp_page));

										exit;
									}
								}
							}

							#not a random page
							else
							{
								#add log record
								&add_log_record('form access','permitted');

								#get the expected file location
								$back_location = &return_full_path($form_directories{'[Forms]'}{$form_name},'page_' . $next_page . '.html');	
							
								#display the appropriate page
								&display_html(&reload_form_replacement($back_location,'','','[page_' . $next_page . ']'));

								exit;
							}
						}
						#not a random page - RANDOM PAGE KEY was not found in config file
						else
						{
							#add log record
							&add_log_record('form access','permitted');

							#get the expected file location
							$back_location = &return_full_path($form_directories{'[Forms]'}{$form_name},'page_' . $next_page . '.html');	

							#display the appropriate page
							&display_html(&reload_form_replacement($back_location,'','','[page_' . $next_page . ']'));

							exit;
						}
					}
					
					#page boundary error occurred so return the first page of the form
					else
					{
						&load_first_page();
					}
				}

				#session password is invalid
				elsif($valid_pass == -1)
				{
					#add record to log file
					&add_log_record('session password invalid','denied');

					#supplied password and stored password don't match
					&show_server_error($ERROR_NUM_INVALID_PASSWORD,"Invalid Session Credentials","The credentials supplied do not match the ones associated with this session. Please verify the credentials and try again.", __LINE__); 				
				}
				
				#password not valid
				else
				{
					#add record to log file
					&add_log_record('password invalid','denied');

					#if the error message is not defined, give it a default one
					if ($form_configuration{'[MISC]'}{'ErrorMessageInvalidPassword'} eq "")
					{
						$form_configuration{'[MISC]'}{'ErrorMessageInvalidPassword'} = "Access Denied: The credentials supplied were invalid. Please check the credentials and try again.";
					}


					#supplied password and stored password don't match
					&show_server_error($ERROR_NUM_INVALID_PASSWORD,"Invalid Credentials",$form_configuration{'[MISC]'}{'ErrorMessageInvalidPassword'}, __LINE__);				
				}

				#we may exit if not already as login procedure has completed
				last;
			}

			#if submitted from the pause page
			elsif($action eq 'SEND_EMAIL')
			{

				#if the user clicked back
				if((exists $submitted_data{'BACK'}) || ((exists $submitted_data{'BACK.x'}) && (exists $submitted_data{'BACK.y'})))
				{
					#get the page they clicked pause from
					$next_page = &last_submitted_page($submitted_data{'PAGE_KEY'});
					
					#if a valid page was returned
					if ($next_page ne '0')
					{
						#remove the last submitted page as we are going back to it
						&remove_from_submitted_pages;
									  
						#construct the location of our last page
						$back_location = &return_full_path($form_directories{'[Forms]'}{$form_name},'page_' . $next_page . '.html');
						
						#reload the last page submitted
						&display_html(&reload_form_replacement($back_location,'','','[page_' . $next_page . ']'));

						exit;
					}
					
					#page boundary error occurred so go to the first page of the form
					else
					{
						&load_first_page();
					}
				}

				#if the user clicked reset from the pause page
				elsif((exists $submitted_data{'RESET'}) || ((exists $submitted_data{'RESET.x'}) && (exists $submitted_data{'RESET.y'})))
				{
					#construct the location of our last page
					$back_location = &return_full_path($form_directories{'[Forms]'}{$form_name},'pause_page.html');
					
					#reload the last page submitted with dummy page key
					&display_html(&reload_form_replacement($back_location,'','',"[reset_pause_page]"));
				}

				#requesting to send email, validate the email address before sending
				elsif(&validate_email_address($submitted_data{'EMAIL'}) eq '1')
				{
					#get the full data script location
					$full_data_script_location = &get_fully_qualified_data_script($data_script_location);

					#build the full "return" URL
					$full_url = $full_data_script_location . '?FORM=' . $form_configuration{'[MISC]'}{'FormName'} . '&UID=' . $session_uid;

					#set the email address flag to 0
					$email_attempts = 0;

					#create an empty hash to save the email attemps within an hour in
					%valid_emails = ();

					#get the current time
					$curr_time = (((localtime)[3] > 9) ? (localtime)[3] : '0' . (localtime)[3]) . (((localtime)[2] > 9) ? (localtime)[2] : '0' . (localtime)[2]) . (((localtime)[1] > 9) ? (localtime)[1] : '0' . (localtime)[1]);

					#go through all the email listings in the UID file
					foreach $attempt (keys %{$form_uid{'[PauseEmail]'}})
					{
						#if the email was sent in the last 60 minutes, increase the flag and save it to be written out again
						if (abs($curr_time - $attempt) <= 60)
						{
							$email_attempts += $form_uid{'[PauseEmail]'}{$attempt};
							$valid_emails{$attempt} = $form_uid{'[PauseEmail]'}{$attempt};
						}
					}

					#if the number of email attempts is over 10					
					if ($email_attempts >= 10)
					{
						#display an error screen
						&general_error_screen("Email Attempt Failed","<B>Module:</B> RWS5<BR><B>Line:</B> " . __LINE__ . "<BR><B>Details:</B> An error occurred sending the email message. You have exceeded the maximum number of email attempts in the last hour.",$form_configuration{'[MISC]'}{'AdminAddress'},0,$full_data_script_location);

						#add the filled in values to the uid file (for fill in forms)
						%form_uid = &append_hash(\%form_uid,'[PauseEmail]',\%valid_emails);
		
						#write out the uid file
						&write_config(\%form_uid,$uid_file,1);

						exit;
					}

					#if we haven't reached our limit
					else
					{
						#add this current time to the hash
						$valid_emails{(((localtime)[3] > 9) ? (localtime)[3] : '0' . (localtime)[3]) . (((localtime)[2] > 9) ? (localtime)[2] : '0' . (localtime)[2]) . (((localtime)[1] > 9) ? (localtime)[1] : '0' . (localtime)[1])} += 1;

						#add the filled in values to the uid file (for fill in forms)
						%form_uid = &append_hash(\%form_uid,'[PauseEmail]',\%valid_emails);
		
						#write out the uid file
						&write_config(\%form_uid,$uid_file,1);
					}

					#set the email message with the link
					$email_message = $form_configuration{'[MISC]'}{'EmailBody'} . "\n\n" . $full_url;

					#if we are appending credentials
					if ($form_configuration{'[MISC]'}{'EmbedCredentialsInEmailReminder'} eq "1")
					{
						#escape out = if exists in the password hash
						$escaped_password =~ s/\=/\%3[Dd]/g;

						#add the password as a query parameter
						$email_message .= "&RWS=" . $form_uid{'[MISC]'}{'PWD'};

						#if we have a username, append the username too
						if ($form_configuration{'[MISC]'}{'UsernameQuestionKey'} ne "")
						{
							$email_message .= "&USER=" . $form_uid{'[MISC]'}{'USER'};
						}
					}

					#if we have a different from address, use that
					if ($form_configuration{'[MISC]'}{'EmailFrom'} ne "")
					{
						$email_from_address = $form_configuration{'[MISC]'}{'EmailFrom'};
					}
					#otherwise use the admin email address
					else
					{
						$email_from_address = $form_configuration{'[MISC]'}{'AdminAddress'};
					}

					#set the email call depending on the type of email in the setting
					if ($form_configuration{'[MISC]'}{'EmailMethod'} eq "SMTP")
					{
						$email_call = &smtp_mail($submitted_data{'EMAIL'},$email_from_address,$form_configuration{'[MISC]'}{'EmailSubject'},$form_configuration{'[MISC]'}{'SMTPServer'},$form_configuration{'[MISC]'}{'PortNumber'}, $email_message, "0", $form_configuration{'[MISC]'}{'SMTPUsername'}, $form_configuration{'[MISC]'}{'SMTPPassword'});
					}
					else
					{
						$email_call = &send_mail($form_configuration{'[MISC]'}{'SendmailServer'}, $submitted_data{'EMAIL'}, $email_from_address, $form_configuration{'[MISC]'}{'EmailSubject'}, $email_message);
					}

					#if attempt email operation is successful
					if($email_call eq '1')
					{
						#add record to log file
						&add_log_record('pause page email','success');
						&general_error_screen("Email Attempt Successful", localtime() . ": Email message was sent successfully to <B>" . $submitted_data{'EMAIL'} . "</B>.",'',1,$full_data_script_location);
					}

					#email attempt failed
					else
					{
						&general_error_screen("Email Attempt Failed","<B>Module:</B> RWS5<BR><B>Line:</B> " . __LINE__ . "<BR><B>Details:</B> An error occurred sending the email message.  Please contact the system administrator regarding the email failure.",$form_configuration{'[MISC]'}{'AdminAddress'},0,$full_data_script_location);
					}
					exit;
				}					
				
				#the email address is not valid
				else
				{
					&general_error_screen("Invalid Email Address","<B>Module:</B> RWS5<BR><B>Line:</B> " . __LINE__ . "<BR><B>Details:</B> The email address supplied is invalid. Please check the address and try again.",$form_configuration{'[MISC]'}{'AdminAddress'},0,$full_data_script_location);
					exit;
				}
			}

			#if submitting from a regular page
			elsif($action eq 'BRANCH')
			{

				#if the user clicked the back button
				if((exists $submitted_data{'BACK'}) || ((exists $submitted_data{'BACK.x'}) && (exists $submitted_data{'BACK.y'})))
				{

					#if not clicking back from confirm, pause, or error
					if (($submitted_data{'PAGE_KEY'} ne '[confirmation_page]') && ($submitted_data{'PAGE_KEY'} ne '[pause_page]') && ($submitted_data{'PAGE_KEY'} ne '[error_page]') && ($submitted_data{'PAGE_KEY'} ne ''))
					{
						#add the filled in values to the uid file (for fill in forms)
						%form_uid = &append_hash(\%form_uid,$submitted_data{'PAGE_KEY'},\%submitted_data);
		
						#write out the uid file
						&write_config(\%form_uid,$uid_file,1);
					}
					
					#if we're returning from a password error page and password protected, display the login
					if (($submitted_data{'PAGE_KEY'} eq "[error_page]") && ($form_configuration{'[MISC]'}{'PasswordProtected'} eq '1'))
					{
						#construct the location of the login page
						$back_location = &return_full_path($form_directories{'[Forms]'}{$form_name},'login_page.html');

						#display the user constructed login page else display basic login page
						if (-e $back_location)
						{
							&display_html(&reload_form_replacement($back_location,'','','[login_page]'));					
						}
						else
						{
							&display_login_page;
						}
						exit;
					}
					else
					{	
						#get the last submitted page
						$next_page = &last_submitted_page($submitted_data{'PAGE_KEY'});

						#if a valid page was returned					
						if ($next_page ne '0')
						{
							#remove the last submitted page as we are going back to it
							&remove_from_submitted_pages;
									  
							#construct the location of our last page
							$back_location = &return_full_path($form_directories{'[Forms]'}{$form_name},'page_' . $next_page . '.html');
						
							#reload the last page submitted
							&display_html(&reload_form_replacement($back_location,'','','[page_' . $next_page . ']'));
						}

						#page boundary error occurred so go to the first page of the form
						else
						{
							&load_first_page();
						}
					}
				}

				#if the user clicked the Change Response button from the confirmation page
				elsif((exists $submitted_data{'Change Response'}) && (exists $submitted_data{'PAGE_NUMBER'}))
				{
					#set the page to the question's page number
					$target_page = $submitted_data{'PAGE_NUMBER'};
					
					#turns '[Page_X]' into X]
					$target_page = (split(/\_/,$target_page))[1];

					#turns 'X]' into X
					$target_page = (split(/\]/,$target_page))[0];
					
					#remove the pages submitted before it
					&remove_from_submitted_pages($target_page);
							  
					#construct the location of our target page
					$back_location = &return_full_path($form_directories{'[Forms]'}{$form_name},'page_' . $target_page . '.html');
						
					#reload the target page
					&display_html(&reload_form_replacement($back_location,'','','[page_' . $target_page . ']'));
				}

				#if the user clicked a pause button on the form
				elsif((exists $submitted_data{'PAUSE'}) || ((exists $submitted_data{'PAUSE.x'}) && (exists $submitted_data{'PAUSE.y'})))
				{
					#push the page onto the queue
					&add_to_submitted_pages($submitted_data{'PAGE_KEY'});

					#add the filled in values to the uid file (for fill in forms)
					%form_uid = &append_hash(\%form_uid,$submitted_data{'PAGE_KEY'},\%submitted_data);
					
					#write out the uid file
					&write_config(\%form_uid,$uid_file,1);

					#add log record
					&add_log_record('form paused','permitted');

					#construct the location of our last page
					$back_location = &return_full_path($form_directories{'[Forms]'}{$form_name},'pause_page.html');
					
					#reload the last page submitted
					&display_html(&reload_form_replacement($back_location,'','',$submitted_data{'PAGE_KEY'}));

					#write in the new active page - pause page
					$form_uid{'[MISC]'}{'ActiveKey'} = '[pause_page]';
					
					#write out the uid file
					&write_config(\%form_uid,$uid_file,1);

					exit;
				}

				#if the user clicked the reset button then reload with original form values
				elsif((exists $submitted_data{'RESET'}) || ((exists $submitted_data{'RESET.x'}) && (exists $submitted_data{'RESET.y'})))
				{
					#if form uid data for this page exists
					if(exists $form_uid{$submitted_data{'PAGE_KEY'}})
					{
						#delete the form uid data for this page
						delete $form_uid{$submitted_data{'PAGE_KEY'}};
						
						#write out a uid file
						&write_config(\%form_uid,$uid_file,1);
					}

					#turns '[Page_X]' into X]
					$target_page = (split(/\_/,$submitted_data{'PAGE_KEY'}))[1];

					#turns 'X]' into X
					$target_page = (split(/\]/,$target_page))[0];

					#construct the location of our current page
					$back_location = &return_full_path($form_directories{'[Forms]'}{$form_name},'page_' . $target_page . '.html');

					#redisplay our current page
					&display_html(&reload_form_replacement($back_location,'','',$submitted_data{'PAGE_KEY'}));
					exit;
				}

				#if the user is requesting a basic submit
			   	else
				{	
					#make sure that data was valid
				   	if(&validate_responses(\%submitted_data) == '1')
					{
						#see if the user has timed out
						if($timed_out ne '1')
						{
							#push the page onto the queue
							&add_to_submitted_pages($submitted_data{'PAGE_KEY'});

							#add the filled in values to the uid file (for fill in forms)
							%form_uid = &append_hash(\%form_uid,$submitted_data{'PAGE_KEY'},\%submitted_data);
							
							#write out the uid file
							&write_config(\%form_uid,$uid_file,1);

							#construct the location of our login page and display it
							$back_location = &return_full_path($form_directories{'[Forms]'}{$form_name},'login_page.html');
							if (-e $back_location)
							{
								&display_html(&reload_form_replacement($back_location,'','','[login_page]'));					}
							else
							{
								&display_login_page;
							}
							exit;
						}
						#form has NOT timed out
						else
						{	
							#add the filled in values to the uid file (for fill in forms)
							%form_uid = &append_hash(\%form_uid,$submitted_data{'PAGE_KEY'},\%submitted_data);
							
							#write out the uid file
							&write_config(\%form_uid,$uid_file,1);

							#push the page onto the queue
							&add_to_submitted_pages($submitted_data{'PAGE_KEY'});

							#perform the branch operation
							$current_page = (&perform_branch($submitted_data{'PAGE_KEY'},\%submitted_data));

							#if the survey is completed
							if($current_page =~ /complete\_page/)
							{				
								#if the lock file does not exist, create it
								if (!(-e $uid_lock_file))
								{
									if (open (LOCK_FILE, ">$uid_lock_file")) 
									{
										close(LOCK_FILE);
									}
								}
										
								#add the form data to the data record
								if(&add_data_records == 1)
								{
									#add log record for completed submission
									&add_log_record('form completed','permitted');

									#set a counter to check for submission email branching
									$rule_counter = 1;

									#make sure the submit_hash has all the pages for branching purposes
									%submit_hash = &merge_uid_hash(\%submit_hash);

	
									#for each submission email branch, run the branch and see if there is another rule
									while ($form_configuration{'[MISC]'}{'#RULE' . sprintf("%04d", $rule_counter) . '#'} ne "")
									{

										#set and pipe the email rule
										$email_rule = $form_configuration{'[MISC]'}{'#RULE' . sprintf("%04d", $rule_counter) . '#'};

										#evaluate the email rule
										eval($email_rule);
										$rule_counter++;
									}

									#send a submission email if all requirements are met
									if(($form_configuration{'[MISC]'}{'SendSubmissionEmails'} eq '1') && ($form_configuration{'[MISC]'}{'RecipientAddressList'} ne ''))
									{
										&SendEmailNotification($form_configuration{'[MISC]'}{'RecipientAddressList'}, 1);					
									}

									#remove the uid file after submission is COMPLETE
								   	unlink $uid_file;

									#clean up the lock file if it exists
									if(-e $uid_lock_file)
									{
										unlink $uid_lock_file; 
									}

									#if cleaning old uid files is on by default
									if ($form_configuration{'[MISC]'}{'UIDExpiration'} ne "0")
									{

										#remove any old UID files
										&remove_old_uid_files;
									}
								}

								#adding data records failed
								else
								{
									#clean up the lock file if it exists
									if(-e $uid_lock_file)
									{
										unlink $uid_lock_file; 
									}
								}
							}
							#a non-success page was successfully submitted
							else
							{
								&add_log_record($submitted_data{'PAGE_KEY'} . ' submitted','permitted');
							}
						}
					}
				}
			}
		}
	}
}

########################################################################################
# 	FUNCTION THAT RETURNS THE LAST SUBMITTED PAGE									   #
#	USE: $last_page_index = &last_submitted_page($submitted{page_key});    	       	   #		
########################################################################################
sub last_submitted_page
{
	my $current_key = $_[0];
	my @pages = ();
	my $page = "";
	my $last_page = 0;
	my $pop_required = 0;
	my $same_page = 1;
	my $current_page = "";

	#add to the log if in diagnostic mode
	if ($diagnostic_on == 1)
	{
		&write_log($LOG_NAME, $MAX_SIZE, "rws5.pm", "last_submitted_page", "current_key = " . $current_key, $thread_ID, 1);
	}


	if(($form_uid{'[MISC]'}{'SubmittedPages'} eq '0') || ($form_uid{'[MISC]'}{'SubmittedPages'} eq ''))
	{
		return(0);
	}
	else
	{
		if ($current_key ne '')
		{
			#turns '[Page_X]' into X]
			$current_page = (split(/\_/,$current_key))[1];

			#turns 'X]' into X
			$current_page = (split(/\]/,$current_page))[0];
		}

		while ($same_page == 1) 
		{
			#split the submitted pages string into hash
			@pages = split (/\,/, $form_uid{'[MISC]'}{'SubmittedPages'});

			#get the previous page in the sequence
			$last_page = $pages[$#pages];

			
			#if the page you are on and the previous page are the same, set the pop flag		
			if ($last_page eq $current_page)
			{
				&remove_from_submitted_pages("");
				$same_page = 1;
			}
			else
			{
				$same_page = 0;	
			}
		} 

		#add to the log if in diagnostic mode
		if ($diagnostic_on == 1)
		{
			&write_log($LOG_NAME, $MAX_SIZE, "rws5.pm", "last_submitted_page", "page = " . $pages[$#pages], $thread_ID, 0);
		}


		#return the last page
		return($pages[$#pages]);
	}
}

########################################################################################
# 	FUNCTION THAT RETURNS THE NEXT PAGE												   #
#	USE: $next_page_location = &get_next_page();					       	       	   #		
########################################################################################
sub get_next_page
{
	my $next_page_index = 0;
	my $location = "";

	#add to the log if in diagnostic mode
	if ($diagnostic_on == 1)
	{
		&write_log($LOG_NAME, $MAX_SIZE, "rws5.pm", "get_next_page", "None", $thread_ID, 1);
	}

	#get the last submitted page and increment it
	$next_page_index = &last_submitted_page;
	$next_page_index++;

	#get the expected file location
	$location = &return_full_path($form_directories{'[Forms]'}{$form_configuration{'[MISC]'}{'FormName'}},'page_' . $next_page_index . '.html');

	#add to the log if in diagnostic mode
	if ($diagnostic_on == 1)
	{
		&write_log($LOG_NAME, $MAX_SIZE, "rws5.pm", "get_next_page", "location = " . $location, $thread_ID, 0);
	}

	return ($location);
}

########################################################################################
# 	FUNCTION GENERATES A UID FILE FOR THE USER 		       		       				   #		
#	USE: &generate_uid_file();					       	       						   #		
########################################################################################
sub generate_uid_file
{
	#add to the log if in diagnostic mode
	if ($diagnostic_on == 1)
	{
		&write_log($LOG_NAME, $MAX_SIZE, "rws5.pm", "generate_uid_file", "None", $thread_ID, 1);
	}

	if($session_uid ne '')
	{
		$form_uid{'[MISC]'}{'IPAddress'} = $ENV{'REMOTE_ADDR'};
		$form_uid{'[MISC]'}{'PWD'} = '';
		$form_uid{'[MISC]'}{'LastAccessTime'} = time;
		$form_uid{'[MISC]'}{'ExpireTime'} = $form_configuration{'[MISC]'}{'SessionLogoutTime'};
		$form_uid{'[MISC]'}{'SubmittedPages'} = '0';
		$form_uid{'[MISC]'}{'FormName'} = $form_configuration{'[MISC]'}{'FormName'};
		$form_uid{'[MISC]'}{'ActiveKey'} = '';
		$form_uid{'[MISC]'}{'AccessTime'} = &get_date . " " . &get_time;

		#get the query string	
		$query_string = $ENV{'QUERY_STRING'};
		if($query_string ne '')
		{
	 		#split the query string into (key, value) pairs
			@query_items = split (/\&/, $query_string);

			#see if we should encode
			$encoded_params = &get_query_parameter('ENC');

			#loop through all the query items
			foreach $query (@query_items)
			{
				#split at the =
				($key,$value) = split (/\=/, $query);

				#skip if this is the UID or FORM
				if (($key eq "UID") || ($key eq "FORM") || ($key eq "USER") || ($key eq "PWD") || ($key eq "RWS") || ($key eq "POPUPINFO") || ($key eq "ENC"))
				{
					next;
				}

				#unescape spaces and other characters for the key
				$key =~ s/%([0-9A-Fa-f]{2})/chr(hex($1))/eg;

				#get the validated input value
				$form_uid{'[Queries]'}{lc($key)} = &validate_input($value);

				#unescape spaces and other characters for values
				$form_uid{'[Queries]'}{lc($key)} =~ s/%([0-9A-Fa-f]{2})/chr(hex($1))/eg;

				#if encoding is set to 1, decode the values
				if ($encoded_params == 1)
				{
					use MIME::Base64;
					$form_uid{'[Queries]'}{lc($key)} = decode_base64($form_uid{'[Queries]'}{lc($key)});
				}				
			}	
		}

		$uid_file = &return_full_path($form_directories{'[Forms]'}{$form_configuration{'[MISC]'}{'FormName'}},$session_uid);
		$uid_file .= '.uid';

		#set the file permissions
		chmod(0600, $uid_file);
	}
	#add to the log if in diagnostic mode
	if ($diagnostic_on == 1)
	{
		&write_log($LOG_NAME, $MAX_SIZE, "rws5.pm", "generate_uid_file", "None", $thread_ID, 0);
	}
			
	return(1);
}

########################################################################################
# 	FUNCTION THAT VALIDATES SESSION INACTIVITY										   #
#	USE: &valid_session_time();					       	       						   #		
########################################################################################
sub valid_session_time
{
	my $cur_time = 0;

	#add to the log if in diagnostic mode
	if ($diagnostic_on == 1)
	{
		&write_log($LOG_NAME, $MAX_SIZE, "rws5.pm", "valid_session_time", "None", $thread_ID, 1);
	}

	if($uid_file eq '')
	{
		#add to the log if in diagnostic mode
		if ($diagnostic_on == 1)
		{
			&write_log($LOG_NAME, $MAX_SIZE, "rws5.pm", "valid_session_time", "Session time invalid.", $thread_ID, 0);
		}

		return (0);
	}
 
	$cur_time = time;

	#if no time limit specified, return 1
	if ($form_configuration{'[MISC]'}{'SessionLogoutTime'} eq "")
	{
		#add to the log if in diagnostic mode
		if ($diagnostic_on == 1)
		{
			&write_log($LOG_NAME, $MAX_SIZE, "rws5.pm", "valid_session_time", "Session time valid.", $thread_ID, 0);
		}

		return (1);
	}

	#if valid time then update the file
	elsif (abs($cur_time - $form_uid{'[MISC]'}{'LastAccessTime'}) < ($form_configuration{'[MISC]'}{'SessionLogoutTime'} * 60))
	{
		$form_uid{'[MISC]'}{'LastAccessTime'} = $cur_time;
		&write_config(\%form_uid,$uid_file,1);

		#add to the log if in diagnostic mode
		if ($diagnostic_on == 1)
		{
			&write_log($LOG_NAME, $MAX_SIZE, "rws5.pm", "valid_session_time", "Session time valid", $thread_ID, 0);
		}

		return (1);
	}
	else
	{
		#add to the log if in diagnostic mode
		if ($diagnostic_on == 1)
		{
			&write_log($LOG_NAME, $MAX_SIZE, "rws5.pm", "valid_session_time", "Session time invalid" . $current_key, $thread_ID, 0);
		}

 		return (0);
	}
}

########################################################################################
# 	FUNCTION THAT ADDS TO THE SUBMITTED PAGE LIST									   #
#	USE: &add_to_submitted_pages($Page_Key);					       	       		   #	
########################################################################################
sub add_to_submitted_pages
{
	my $page_key = $_[0];
	my $page_index = "";
	my @pages = ();

	#add to the log if in diagnostic mode
	if ($diagnostic_on == 1)
	{
		&write_log($LOG_NAME, $MAX_SIZE, "rws5.pm", "add_to_submitted_pages", "page_key = " . $page_key, $thread_ID, 1);
	}

	#turns '[Page_X]' into X]
	$page_index = (split(/\_/,$page_key))[1];

	#turns 'X]' into X
	$page_index = (split(/\]/,$page_index))[0];
	
	#exit if the index is not numeric
	if ($page_index !~ /^-?\d/) 
	{
		return (1);
	}
		   
	#update the uid file
	if(($form_uid{'[MISC]'}{'SubmittedPages'} eq '0') || ($form_uid{'[MISC]'}{'SubmittedPages'} eq ''))
	{
		$form_uid{'[MISC]'}{'SubmittedPages'} = $page_index;
	}
	else
	{
		#store the pages in a hash
		@pages = split(/\,/,$form_uid{'[MISC]'}{'SubmittedPages'});
 
		#add our latest page
		push (@pages,$page_index);

		#create the new string with the last page added
		$form_uid{'[MISC]'}{'SubmittedPages'} = join(',',@pages);
	}
	
	#write out the uid file
	&write_config(\%form_uid,$uid_file,1);

	#add to the log if in diagnostic mode
	if ($diagnostic_on == 1)
	{
		&write_log($LOG_NAME, $MAX_SIZE, "rws5.pm", "add_to_submitted_pages", "None", $thread_ID, 0);
	}

   	return (1);
}

########################################################################################
# 	FUNCTION THAT REMOVES THE LAST SUBMITTED PAGE 									   #
#	USE: &remove_from_submitted_pages();					       	       			   #		
########################################################################################
sub remove_from_submitted_pages
{
	my $target = $_[0];
	my @pages = ();
	my $element = "";
	my $position = -1;

	#add to the log if in diagnostic mode
	if ($diagnostic_on == 1)
	{
		&write_log($LOG_NAME, $MAX_SIZE, "rws5.pm", "remove_from_submitted_page", "target = " . $target, $thread_ID, 1);
	}
 
	#update the uid file
	if(($form_uid{'[MISC]'}{'SubmittedPages'} eq '0') || ($form_uid{'[MISC]'}{'SubmittedPages'} eq ''))
	{
		return (0);
	}
	else
	{
		#store the pages in a hash
		@pages = split(/\,/,$form_uid{'[MISC]'}{'SubmittedPages'});

 		#check to see if there is a target_page defined (used with confirmation page)
		if ($target ne '') 
		{
			#while the last page does not equal our target page, delete the last page in the array
			while (@pages[$#pages] != $target)
			{
				pop (@pages);
			}

			#the last page in the array must now equal the target page, so delete it too
			pop (@pages);
		}

		#otherwise remove the last page
		else 
		{
			#remove the last page
			pop (@pages);
		}

		#create the new string with the last page added
		$form_uid{'[MISC]'}{'SubmittedPages'} = join(',',@pages);
	}
	
	#write out the uid file
	&write_config(\%form_uid,$uid_file,1);

	#add to the log if in diagnostic mode
	if ($diagnostic_on == 1)
	{
		&write_log($LOG_NAME, $MAX_SIZE, "rws5.pm", "remove_from_submitted_pages", "None", $thread_ID, 0);
	}

   	return (1);
}

########################################################################################
# 	FUNCTION THAT DETERMINES IF DATA IS VALID    									   #
#	USE: $valid = &validate_responses(%data);					       	       		   #			
########################################################################################
sub validate_responses
{
 	my %data = %{$_[0]};
 	my $key = "";
	my $question_index = "";
	my $last_index = "";
	my $tmp_var = "";
	my $select_count = 0;
	my $question_type = "";
	my $reload_location = "";
	my $page_src = "";
	my $multiple_str = "";
	my $prefix = "";
	my $counter = 0;
	my $question_number = "";
	my $element = "";
	my $required_ok = 0;	
	my %validation_error = ();

	#add to the log if in diagnostic mode
	if ($diagnostic_on == 1)
	{
		&write_log($LOG_NAME, $MAX_SIZE, "rws5.pm", "validate_responses", "None", $thread_ID, 1);
	}

	#check for required fields
	if(defined $form_configuration{$data{'PAGE_KEY'}}{'QUESTION_START'})
	{
		#loop thru the questions on the page
		for ($counter = $form_configuration{$data{'PAGE_KEY'}}{'QUESTION_START'}; $counter <= $form_configuration{$data{'PAGE_KEY'}}{'QUESTION_END'}; $counter++)
		{
			#get the question ID from the number
			$question_number = 'Q' . sprintf("%04d",$counter);
			$element = $form_configuration{'[Map]'}{$question_number};			

			#if the item is required  
			if($form_configuration{'[Questions]'}{$element . '_REQUIRED'} eq '1') 
			{
				$required_ok = 0;
				
				#loop thru all the submitted data
			 	foreach $key (sort keys %data)
			 	{
			 				 			
		 			$prefix = $element . '_';

					#skip if it is a list question and it is blank (its value is nothing but an answer ID)
					if (($form_configuration{'[Questions]'}{$element . '_TYPE'} eq 'LIST') && ($data{$key} =~ m/^\@\*\[\S*?\]\*\@$/))
					{
						next;
					}
		 							 
					#check to see that at least one answer was selected (and ignore other questions) 
					if(($key =~ /^$prefix/) && ($key !~ /_OTHER$/))
					{
						#key was answered - make sure with something
						if($data{$key} ne '')
						{
							$required_ok = 1;
							last;
						}
					}
				}
		
				#if the item is missing, add it to the error hash
				if($required_ok == 0)
				{
					$validation_error{$element} = $form_configuration{'[Questions]'}{$element . '_REQUIRED_ERR'} . '<BR><LI><FONT NAME="ARIAL,VERDANA,HELVETICA" SIZE="2"><A HREF=#' . $element . '>' . $form_configuration{'[Questions]'}{$element . '_NAME'} . ': ' . $form_configuration{'[Questions]'}{$element . '_TEXT'} . '</A></FONT></LI>';
				}
			}

			#if the item is a text box and has a max length set
			if (($form_configuration{'[Questions]'}{$element . '_MAX_RESPONSE'} ne "") && ($form_configuration{'[Questions]'}{$element . '_TYPE'} eq "TEXT"))
			{
				$key = $element . '_RWS_TEXT';
			
				#if it exceeds the max length, add it to the error hash  
				if(length($data{$key}) > $form_configuration{'[Questions]'}{$element . '_MAX_RESPONSE'})
				{
					$validation_error{$element} = $form_configuration{'[Questions]'}{$element . '_MAXLEN_ERR'} . '<BR><LI><FONT NAME="ARIAL,VERDANA,HELVETICA" SIZE="2"><A HREF=#' . $element . '>' . $form_configuration{'[Questions]'}{$element . '_NAME'} . ': ' . $form_configuration{'[Questions]'}{$element . '_TEXT'} . '</A></FONT></LI>';
				}
			}
			#if the item has a max number of responses set
			elsif ($form_configuration{'[Questions]'}{$element . '_MAX_RESPONSE'} ne "")
			{
				#set a flag
				$question_count = 0;
				
				#loop thru all the submitted data
			 	foreach $key (sort keys %data)
			 	{
			 				 			
		 			$prefix = $element . '_';
		 							 
					#ignore all keys that don't match this question or are an other question 
					if(($key =~ /^$prefix/) && ($key !~ /_OTHER$/))
					{
						#key was answered - make sure with something
						if($data{$key} ne '')
						{
							$question_count++;
						}
					}
				}
			
				#if the question count exceeds the max responses, add it to the error hash
				if ($question_count > $form_configuration{'[Questions]'}{$element . '_MAX_RESPONSE'})
				{
					$validation_error{$element} = $form_configuration{'[Questions]'}{$element . '_MAXRESPONSE_ERR'} . '<BR><LI><FONT NAME="ARIAL,VERDANA,HELVETICA" SIZE="2"><A HREF=#' . $element . '>' . $form_configuration{'[Questions]'}{$element . '_NAME'} . ': ' . $form_configuration{'[Questions]'}{$element . '_TEXT'} . '</A></FONT></LI>';
				}
			}

			#if the question has a matching pattern
			if (($form_configuration{'[Questions]'}{$element . '_INPUT_PATTERN'} ne "") && ($data{$element . '_RWS_TEXT'} ne""))
			{
				$key = $element . '_RWS_TEXT';

				$input_pattern = $form_configuration{'[Questions]'}{$element . '_INPUT_PATTERN'};

				#escape out non word characters
				$input_pattern =~ s/(\W)/\\$1/g;

				#convert 0s to numbers
				$input_pattern =~ s/0/\\d/g;

				#convert As to alpha characters
				$input_pattern =~ s/A/[A-Za-z]/g;

				#convert Xs to alphanumeric
				$input_pattern =~ s/X/\\w/g;

				#check to see if we have any "0"s, "A"s, "X"s
				while ($input_pattern =~ m/\\\"(\\d|\\w|\[A-Za-z\])\\\"/)
				{
					#if "0" convert back to 0
					if ($1 eq '\d')
					{
						$input_pattern =~ s/\\\"(\\d|\\w|\[A-Za-z\])\\\"/0/;
					}
					#if "A" convert back to A
					elsif ($1 eq '[A-Za-z]')
					{
						$input_pattern =~ s/\\\"(\\d|\\w|\[A-Za-z\])\\\"/A/;
					}
					#if "X" convert back to X
					elsif ($1 eq '\w')
					{
						$input_pattern =~ s/\\\"(\\d|\\w|\[A-Za-z\])\\\"/X/;
					}
				}

				#check to see if the data matches the pattern, if not, add it to the error hash
				if ($data{$key} !~ m/^$input_pattern$/)
				{
					$validation_error{$element} = $form_configuration{'[Questions]'}{$element . '_INPUT_PATTERN_ERR'} . '<BR><LI><FONT NAME="ARIAL,VERDANA,HELVETICA" SIZE="2"><A HREF=#' . $element . '>' . $form_configuration{'[Questions]'}{$element . '_NAME'} . ': ' . $form_configuration{'[Questions]'}{$element . '_TEXT'} . '</A></FONT></LI>';
				}

			}
		}

		#check the data for other questions
		foreach $key (sort keys %data)
		{
			#if this item is an other question
			if ($key =~ /_OTHER$/)
			{
				#check to see if theother question is required
				if ($form_configuration{'[Questions]'}{$key . '_REQUIRED'} ne "")
				{
					#split the QID and answer choice from the key
					($QID, $answer_choice) = split(/\_/, $key, 2);

					#get rid of the _OTHER for the answer choice
					$answer_choice =~ s/\_OTHER$//;


					#check to see if the corresponding answer option button or checkbox was selected
					if (($data{$QID . "_RWS_RADIO"} eq $answer_choice) || ($data{$QID . "_" . $answer_choice} eq "on"))
					{
						#if selected but no data, then add the error to the array	
						if($data{$key} eq "")
						{
							$element = (split(/\_/,$key))[0];
							$validation_error{$element} = $form_configuration{'[Questions]'}{$key . '_REQUIRED_ERR'} . '<BR><LI><FONT NAME="ARIAL,VERDANA,HELVETICA" SIZE="2"><A HREF=#' . $element . '>' . $form_configuration{'[Questions]'}{$element . '_NAME'} . ': ' . $form_configuration{'[Questions]'}{$element . '_TEXT'} . '</A></FONT></LI>';
						}
					}
				}

				#check to see if there is a max length defined for the other question
				if ($form_configuration{'[Questions]'}{$key . '_MAX_RESPONSE'} ne "")
				{
					#if it exceeds the max length, display the error message	
					if(length($data{$key}) > $form_configuration{'[Questions]'}{$key . '_MAX_RESPONSE'})
					{
						$element = (split(/\_/,$key))[0];
						$validation_error{$element} = $form_configuration{'[Questions]'}{$key . '_MAXLEN_ERR'} . '<BR><LI><FONT NAME="ARIAL,VERDANA,HELVETICA" SIZE="2"><A HREF=#' . $element . '>' . $form_configuration{'[Questions]'}{$element . '_NAME'} . ': ' . $form_configuration{'[Questions]'}{$element . '_TEXT'} . '</A></FONT></LI>';
					}
				}
			}
		}
	}

	#go through the keys of the page to see if we have ranking questions
	foreach $key (keys %{$form_configuration{$data{'PAGE_KEY'}}})
	{
		#if we have a set of ranking questions
		if ($key =~ /^\#RANK/)
		{
			#split out all the QIDs and store them in the rank_questions array
			@rank_questions = split (/\,/, $form_configuration{$data{'PAGE_KEY'}}{$key});

			#set a blank hash to store the answers
			my %answer_hash = ();

			#for each question in the rank group
			foreach $question_id (@rank_questions)
			{
				#set the answer to the submitted data for the question
				$temp_answer =	$data{$question_id . '_RWS_RADIO'};

				#if there is a value defined for the HTML label for the answer
				if ($form_configuration{'[AnswerMap]'}{'[' . $question_id . '][' . $temp_answer . ']'} ne "")
				{
					#check to see if that answer value has already been added to our hash
					if ($answer_hash{$form_configuration{'[AnswerMap]'}{'[' . $question_id . '][' . $temp_answer . ']'}} == 1)
					{
						#if it has, add the validation_error to the error hash and end the loop
						$validation_error{$question_id} = '<font FACE="Verdana" SIZE="2" ><b><font COLOR="#ff0000">Please select only one option for ranking questions.</font></b></font><BR><BR><LI><FONT NAME="ARIAL,VERDANA,HELVETICA" SIZE="2"><A HREF=#' . $question_id . '>' . $form_configuration{'[Questions]'}{$question_id . '_NAME'} . ': ' . $form_configuration{'[Questions]'}{$question_id . '_TEXT'} . '</A></FONT></LI>';
						last;
					}
					else
					{
						#if not, add the answer value to the hash
						$answer_hash{$form_configuration{'[AnswerMap]'}{'[' . $question_id . '][' . $temp_answer . ']'}} = 1;
					}
				}
				#if there is no HTML label defined for the answer
				else
				{
					#make sure we don't have a blank response
					if ($temp_answer ne "")
					{
						#remove out the answer ID
						$temp_answer =~ s/\@\*\[(\S*?)\]\*\@//;

						#check to see if that answer value has already been added to our hash
						if ($answer_hash{$temp_answer} == 1)
						{
							#if it has, add the validation_error to the error hash and end the loop
							$validation_error{$question_id} = '<font FACE="Verdana" SIZE="2" ><b><font COLOR="#ff0000">Please select only one option for ranking questions.</font></b></font><BR><BR><LI><FONT NAME="ARIAL,VERDANA,HELVETICA" SIZE="2"><A HREF=#' . $question_id . '>' . $form_configuration{'[Questions]'}{$question_id . '_NAME'} . ': ' . $form_configuration{'[Questions]'}{$question_id . '_TEXT'} . '</A></FONT></LI>';
							last;
						}
						else
						{
							#if not, add the answer value to the hash
							$answer_hash{$temp_answer} = 1;
						}
					}	
				}
			}
		}
		#if not a ranking question, 
		else
		{
			next;
		}
	}

	#if there is something in the validation error hash, reload the page with the errors
	if (scalar keys %validation_error)	
	{
		#turns '[Page_X]' into X]
		$page_src = (split(/\_/,$data{'PAGE_KEY'}))[1];

		#turns 'X]' into X
		$page_src = (split(/\]/,$page_src))[0];

		#construct the location of our last page
		$reload_location = &return_full_path($form_directories{'[Forms]'}{$form_configuration{'[MISC]'}{'FormName'}},'page_' . $page_src . '.html');

		#add the filled in values to the uid file (for fill in forms)
		%form_uid = &append_hash(\%form_uid,$data{'PAGE_KEY'},\%data);
					
		#write out the uid file
		&write_config(\%form_uid,$uid_file,1);

		&display_html(&reload_form_replacement($reload_location,\%validation_error,"",$data{'PAGE_KEY'}));

		#add to the log if in diagnostic mode
		if ($diagnostic_on == 1)
		{
			&write_log($LOG_NAME, $MAX_SIZE, "rws5.pm", "validate_responses", "Responses Invalid", $thread_ID, 0);
		}

		return (0);
	}

	#add to the log if in diagnostic mode
	if ($diagnostic_on == 1)
	{
		&write_log($LOG_NAME, $MAX_SIZE, "rws5.pm", "validate_responses", "Responses Valid", $thread_ID, 0);
	}

	return (1);
}

########################################################################################
# 	FUNCTION THAT DISPLAYS THE BUILT ERROR PAGE 									   #
#	USE: &display_built_error($HTML_FILE,$ERROR_MSG,$ERR_NUM,$line_num);   			   #		
########################################################################################
sub display_built_error
{
	my $html_file = $_[0];
	my $error_msg = $_[1];
	my $error_num = $_[2];
	my $line_num = $_[3];
	my @source_lines = ();
	my $all_lines = "";
	my $err_replace = "";

	#add to the log if in diagnostic mode
	if ($diagnostic_on == 1)
	{
		&write_log($LOG_NAME, $MAX_SIZE, "rws5.pm", "display_built_error", "html_file = " . $html_file . " && error_msg = " . $error_msg . " && error_num = " . $error_num, $thread_ID, 1);
	}

	#if the error message is not define, give it a default one
	if ($form_configuration{'[MISC]'}{'ErrorMessageFileAccess'} eq "")
	{
		$form_configuration{'[MISC]'}{'ErrorMessageFileAccess'} = "File Access Error: An error occurred attempting to access a file. Please check the file and directory permissions before continuing.";
	}

	#open the source file and set the source file handle
	open (SRC_FILE, $html_file) || die &show_server_error($ERROR_NUM_FILE_ACCESS,"File Access Error",$form_configuration{'[MISC]'}{'ErrorMessageFileAccess'} . " [" . $html_file . "]", __LINE__);

	#store the whole source file in an array
	@source_lines = <SRC_FILE>;
	
	#now store the whole array into a single scalar
	$all_lines = "@source_lines";

	#insert the uid into our form '@*()'
	if($session_uid ne '')
	{
		$all_lines =~ s/\@\*\(uid\)/\&UID\=$session_uid/g;
	}
	else
	{
		$all_lines =~ s/\@\*\(uid\)//g;
	}

	#insert the uid into our form '@*()'
	if(exists $form_configuration{'[MISC]'}{'FormName'})
	{
		$all_lines =~ s/\@\*\(form_query\)/\?FORM\=$form_configuration{'[MISC]'}{'FormName'}/g;
	}
	else
	{
		$all_lines =~ s/\@\*\(form_query\)//g;
	}

	#insert the image server script into form '@*()'
	$all_lines =~ s/\@\*\(img\)/$form_directories{'[Defaults]'}{'ImageScript'}/g;

	#insert the data script into form '@*()'
	$all_lines =~ s/\@\*\(data\)/$data_script_location/g;
	
	$err_replace = "<B>Module:</B> RWS5<BR><B>Line:</B> " . $line_num . "<BR><B>Error #:</B> " . $error_num . "<BR><B>Details:</B> " . $error_msg;

	#insert the error message '@*()'
	$all_lines =~ s/\@\*\(ERROR_TEXT\)/$err_replace/g;

	#replace the back button depending on which type of error it is
	if (($error_num ne "2000") && ($error_num ne "3000"))
	{
		$all_lines =~ s/\<input.*?\/\>//g;
	}

	#add piping for the page
	$all_lines = &piping($all_lines, 1);

	&display_html($all_lines);
	
	#add to the log if in diagnostic mode
	if ($diagnostic_on == 1)
	{
		&write_log($LOG_NAME, $MAX_SIZE, "rws5.pm", "display_built_error", "None", $thread_ID, 0);
	}

	return(1);
}

########################################################################################
# 	FUNCTION THAT REMOVES OLD UID FILES 		 									   #
#	USE: &remove_old_uid_files();							       	       			   #		
########################################################################################
sub remove_old_uid_files
{
	my $num_days = 0;
	my $dir_file = "";
	my @dir_files = ();
	my $full_file_path = "";
	my $uid_ext = "uid";

	#add to the log if in diagnostic mode
	if ($diagnostic_on == 1)
	{
		&write_log($LOG_NAME, $MAX_SIZE, "rws5.pm", "remove_old_uid_files", "None", $thread_ID, 1);
	}

	#open the form directory
	if (opendir (FORMDIR, $form_directories{'[Forms]'}{$form_configuration{'[MISC]'}{'FormName'}}))
	{
		#store the files in a hash and close the directory
		@dir_files = readdir (FORMDIR);
		closedir FORMDIR;

		#loop thru all the files in the directory
		foreach $dir_file (sort @dir_files)
		{
			#make sure we are looking at a file and NOT a directory
			if (!(-d $dir_file))
			{
				$full_file_path	= &return_full_path($form_directories{'[Forms]'}{$form_configuration{'[MISC]'}{'FormName'}},$dir_file);

				#make sure the file exists (it should)
				if (-e $full_file_path)
				{
					if (lc($dir_file) =~ /^.+\.($uid_ext)$/)
					{
						$num_days = -M $full_file_path;

						if ($num_days > $form_configuration{'[MISC]'}{'UIDExpiration'}) 
						{
							unlink $full_file_path;
						}
					}
				}
			}
		}
	}

	#add to the log if in diagnostic mode
	if ($diagnostic_on == 1)
	{
		&write_log($LOG_NAME, $MAX_SIZE, "rws5.pm", "remove_old_uid_files", "None", $thread_ID, 0);
	}

	return(1);
}

########################################################################################
# 	FUNCTION THAT ADDS RECORDS TO THE DATA FILE	 									   #
#	USE: $add_success=&add_data_records(); 				       	       			   	   #		
########################################################################################
sub add_data_records
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

	#add to the log if in diagnostic mode
	if ($diagnostic_on == 1)
	{
		&write_log($LOG_NAME, $MAX_SIZE, "rws5.pm", "add_data_records", "None", $thread_ID, 1);
	}

	#get the data file name
	$data_file = &return_full_path($form_directories{'[Forms]'}{$form_configuration{'[MISC]'}{'FormName'}},$form_configuration{'[MISC]'}{'DataFile'});
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
			#otherwise, add parentheses and ASCII value 215 for a delimiter
			else
			{
				#if there are parentheses, remove them temporarily
				if (($data_hash{$ques} =~ /^\(/) && ($data_hash{$ques} =~ /\)$/))
				{
					$data_hash{$ques} = substr($data_hash{$ques},1,length($data_hash{$ques})-2);
				}

				#add the new value and reinsert the parantheses
				$data_hash{$ques} .= chr(11) . $value;
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
	
	#add the UID value
	$data_line .= 'UID=' . $session_uid . "\t";

	if ($form_configuration{'[MISC]'}{'TrackIP'} eq "1")
	{
		#add the time value
		$data_line .= 'IP=' . $ENV{'REMOTE_ADDR'} . "\t";
	}

	#add the time value
	$data_line .= 'TIME=' . &get_time . "\t";

	#add the date value
	$data_line .= 'DATE=' . &get_date . "\t";

	#add the number of minutes
	$data_line .= 'DURATION=' . (&localtime_in_seconds - &date_in_seconds($form_uid{'[MISC]'}{'AccessTime'}));

	#if password protected, increment the password count
	if($form_configuration{'[MISC]'}{'PasswordProtected'} eq '1')
	{
		#if valid password fails close data file w/o print and delete lock file
		if(&password_status($form_hash_file,$form_uid{'[MISC]'}{'PWD'},1) == 0)
		{
			close (DATADIR);
			if(-e $lock_file)
			{
				unlink $lock_file; 
			}
			return 0;
		}
		#valid password
		else
		{
			#write out the data to the file
			print DATADIR "$data_line\n";
											
			if(!(close (DATADIR)))
			{
				if(-e $lock_file)
				{
					unlink $lock_file; 
				}

				#if the error message is not define, give it a default one
				if ($form_configuration{'[MISC]'}{'ErrorMessageFileAccess'} eq "")
				{
					$form_configuration{'[MISC]'}{'ErrorMessageFileAccess'} = "File Access Error: An error occurred attempting to access a file. Please check the file and directory permissions before continuing.";
				}

				&show_server_error($ERROR_NUM_FILE_ACCESS,"File Access Error",$form_configuration{'[MISC]'}{'ErrorMessageFileAccess'} . " [" . $data_file . "]", __LINE__);
				return 0;
			}
		}
	}
	#passwords are not required
	else
	{
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
		&write_log($LOG_NAME, $MAX_SIZE, "rws5.pm", "add_data_records", "None", $thread_ID, 0);
	}

	return(1);
}

########################################################################################
# 	FUNCTION THAT ADDS RECORDS TO THE LOG FILE	 									   #
#	USE: &write_log($description,$access);				       	       			   	   #		
########################################################################################
sub add_log_record
{
	my $type = $_[0];
	my $access = $_[1];
	my $log_file = "";
	my $location = "";
	my $date = &get_date;
	my $time = &get_time;
	my $temp_ip = "";

	#add to the log if in diagnostic mode
	if ($diagnostic_on == 1)
	{
		&write_log($LOG_NAME, $MAX_SIZE, "rws5.pm", "add_log_record", "type = " . $type, $thread_ID, 1);
	}

	if($form_directories{'[Defaults]'}{'Logging'} eq '1')
	{
		#get the log file name
		$log_file = $form_configuration{'[MISC]'}{'LogFile'};
		if ($log_file eq '')
		{
			$log_file = 'log-file';
		}
		$log_file .= '.log';

		#get the full location
		$location = &return_full_path($form_directories{'[Forms]'}{$form_configuration{'[MISC]'}{'FormName'}},$log_file);

		#check to make sure IP tracking is on
		if ($form_configuration{'[MISC]'}{'TrackIP'} eq "1")
		{
			#track the IP address
			$temp_ip = $ENV{'REMOTE_ADDR'}; 
		}

		#open the log file for appending
		open (LOG_FILE, ">>$location") || return(0);
		print LOG_FILE "$session_uid\t$type\t$access\t$form_uid{'[MISC]'}{'PWD'}\t$temp_ip\t$date\t$time\n";
		close (LOG_FILE);
	}

	#set the file permissions
	chmod(0600, $location);

	#add to the log if in diagnostic mode
	if ($diagnostic_on == 1)
	{
		&write_log($LOG_NAME, $MAX_SIZE, "rws5.pm", "add_log_record", "None", $thread_ID, 0);
	}

	return(1);
}

########################################################################################
# 	FUNCTION THAT ADDS CONFIRMATION DATA TO THE HMTL FILE							   #
#	USE: $data = &add_confirmation_data(confirm_html,$show_hidden,$convert_chars,$html_page);	   #		
########################################################################################
sub add_confirmation_data
{  
	my $confirm_html = $_[0];
	my $show_hidden = $_[1];
	my $convert_chars = $_[2];
	my $html_page = $_[3];
	my $completed_data = "";
	my $key = "";
	my $sub_key = "";
	my $tmp_key = "";
	my $ques_text = "";
	my $ans_text = "";
	my $tmp_var = "";
	my $question_index = "";
	my $lines = "";
	my $previous_ques = "";
	my %ordered_arr = ();
	my @visited_pages = ();
	my $ok = 0;
	my $tmp_index = "";
	my $temp_text = "";
	my %missing = ();
	my $lcv = 0;
	my %question_page = "";
	my $pause_question = "";
	my $pause_answer = "";
	my %other_questions = ();

	#add to the log if in diagnostic mode
	if ($diagnostic_on == 1)
	{
		&write_log($LOG_NAME, $MAX_SIZE, "rws5.pm", "add_confirmation_data", "confirm_html = " . $confirm_html . " && show_hidden " . $show_hidden . " && convert_chars = " . $convert_chars . " && html_page = " . $html_page, $thread_ID, 1);
	}

	@visited_pages = split(/\,/,$form_uid{'[MISC]'}{'SubmittedPages'});

	#order the array first
	foreach $key (sort keys %form_uid)
	{
		#skip over the MISC section and any complete pages (should not exist)
		if(($key ne '[MISC]') && ($key !~ /complete/))
		{
			#reset the flag
			$ok = 0;

			#turns '[Page_X]' into X]
			$tmp_index = (split(/\_/,$key))[1];

			#turns 'X]' into X
			$tmp_index = (split(/\]/,$tmp_index))[0];

			#determine if current page was a TRULY SUBMITTED PAGE
			foreach $tmp_key (@visited_pages)
			{
				if($tmp_key eq $tmp_index)
				{
					$ok = 1;
					last;
				} 	
			}

			#do NOT write out info for pages that were NOT truly submitted (BACK BUTTON WAS USED)
			if ($ok == 1)
			{
				#reset the missing array
				%missing = ();

				#loop thru each question in array{page_X}
				foreach $sub_key (sort mysort keys %{$form_uid{$key}})
				{
					#if the $key starts with a 'Q' and is not the start or end variable and is NOT hidden and is NOT an other question
		   			if($show_hidden == 1)
					{
		   				next if(($sub_key eq "QUESTION_START") || ($sub_key eq "QUESTION_END") || (($sub_key =~ /\_OTHER/) && ($sub_key !~ /MPD\-/) && ($form_uid{$key}{$sub_key} ne "on")));
					}
					else
					{
						next if(($sub_key eq "QUESTION_START") || ($sub_key eq "QUESTION_END") || ($sub_key =~ "RWS_HIDDEN") || (($sub_key =~ /\_OTHER/) && ($sub_key !~ /MPD\-/) && ($form_uid{$key}{$sub_key} ne "on")));
					}

					#check to see if there is an other and use that value instead
					if ($form_uid{$key}{$sub_key . '_OTHER'} ne "")
					{	
						$ordered_arr{$sub_key} = $form_uid{$key}{$sub_key . '_OTHER'};
					}
					elsif ($form_uid{$key}{(split(/\_/,$sub_key))[0] . '_' . $form_uid{$key}{$sub_key} . '_OTHER'} ne "")
					{	
						$ordered_arr{$sub_key} = $form_uid{$key}{(split(/\_/,$sub_key))[0] . '_' . $form_uid{$key}{$sub_key} . '_OTHER'};
					}
					#if not, use the submitted value
					else
					{
						$ordered_arr{$sub_key} = $form_uid{$key}{$sub_key};
					} 

					#grab the question number - turns 'QID_XYZ=123' into QID
					$tmp_var = (split(/\_/,$sub_key))[0];
					
					#set the question to located in our array
					$missing{$tmp_var} = 1; 

					#add the page number to an away
					$question_page{$tmp_var} = $key;
				}

				#check for missing items on the page from the start question to the end question
				for ($lcv = $form_configuration{$key}{'QUESTION_START'}; $lcv <= $form_configuration{$key}{'QUESTION_END'}; $lcv++)
				{
					#set the key to QXXXX and convert to QID
					$tmp_Q = "Q" . sprintf("%04d",$lcv);
					$tmp_key = $form_configuration{'[Map]'}{$tmp_Q};
					
					#add the page number to an away
					$question_page{$tmp_key} = $key;

					if($show_hidden != 1)
					{
						next if (defined $form_uid{$key}{$tmp_key . "_RWS_HIDDEN"});
					}
					
					#if this item is missing then add it to our array and set it as found
					if($missing{$tmp_key} != 1)
					{
						$ordered_arr{$tmp_key} = "";
						$missing{$tmp_key} = 1;
					}
				}
			}
		}
	}

	#loop thru just a list of questions, sort using mysort function
	foreach $key (sort mysort keys %ordered_arr)
	{	
		#grab the question ID - turns 'QID_XYZ=123' into QID
		$question_index = (split(/\_/,$key))[0];

		#if we have a multiple answer, add a comma to the current answer
		if($previous_ques eq $question_index)
		{
			$ans_text .= ",";
		
		}
		else
		{
   		 	if (($convert_chars == 1) && ($ALLOW_UNICODE != 1))
			{
			
   		 		#escape bad chars for answer text
				$ans_text =~ s/([\<\!\-\#\>\|\0])/'&#'.ord($1).';'/ge;
			}
	
			if ($html_page == 1)
			{
				$ans_text = '<FORM ACTION="@*(data)@*(form_query)@*(uid)#' . $previous_ques . '" METHOD="POST">' . $ans_text . ' <INPUT TYPE="HIDDEN" ID="RWS_NAME" NAME="RWS_NAME" VALUE="' . $form_name . '"> <INPUT TYPE="HIDDEN" ID="PAGE_KEY" NAME="PAGE_KEY" VALUE="[confirmation_page]"> <INPUT TYPE="HIDDEN" ID="FORM_ACTION" NAME="FORM_ACTION" VALUE="BRANCH!"> <INPUT TYPE="HIDDEN" ID="PAGE_NUMBER" NAME="PAGE_NUMBER" VALUE="' . $question_page{$previous_ques} . '"> <span style="text-decoration:underline; color:#0000ff;"><INPUT TYPE="SUBMIT" ID="Change Response" NAME="Change Response" VALUE="Change Response" style="text-align: left; border: medium none; text-decoration:underline; padding: 0; color:#0000ff; background-color:transparent; cursor:pointer" /> </span></FORM>';
			}

			#remove answer id tags
			$ans_text =~ s/\@\*\[(\S*?)\]\*\@//g;

			$previous_ques = $question_index;

			#write out lines with the multiple answers now,replace the holders with the true values
			$lines =~ s/\@\*\(QUESTION_TEXT\)/$ques_text/g;
			$lines =~ s/\@\*\(ANSWER_TEXT\)/$ans_text/g;

			#reset the answer text
			$ans_text = "";

			#reset lines to the replacement html
			$lines .= $confirm_html . "\n";
		}
 
		#store the question text
		$ques_text = $form_configuration{'[Questions]'}{$question_index . '_TEXT'};

		#convert out the bad characters
		if (($convert_chars == 1) && ($ALLOW_UNICODE != 1)) 
		{
			#escape bad characters
			$ques_text =~ s/([\<\!\-\#\>\|\0])/'&#'.ord($1).';'/ge;		
		}

		#if it the question text is missing, set it to the defined text
		if($ques_text eq '')
		{
			$ques_text = $form_configuration{'[Questions]'}{$question_index . '_NAME'};	
		}

		#if the answer is missing, set it to the defined text
		if($ordered_arr{$key} eq '')
		{
			$ans_text = $MISSING_ANSWERS;	
		}
		#if it is a checkbox question
		elsif($ordered_arr{$key} eq 'on')
		{
			#set up a temporary answer variable
			$ans_temp = (split(/\_/,$key,2))[1];

			#check if an HTML display value is defined in the config file, if so, use that ext instead
			if ($form_configuration{'[AnswerMap]'}{'[' . (split(/\_/,$key,2))[0] . '][' . $ans_temp .']'} ne "")
			{
				$ans_temp = $form_configuration{'[AnswerMap]'}{'[' . (split(/\_/,$key,2))[0] . '][' . $ans_temp .']'}
			}

			$ans_text .= $ans_temp; 
		}
		#if it is not a checkbox question
		else
		{
			#check if there is an HTML display value; if so, use that instead
			if ($form_configuration{'[AnswerMap]'}{'[' . (split(/\_/,$key,2))[0] . '][' . $ordered_arr{$key} . ']'} ne "")
			{
				$ans_text .= $form_configuration{'[AnswerMap]'}{'[' . (split(/\_/,$key,2))[0] . '][' . $ordered_arr{$key} . ']'};
			}
			else
			{
				$ans_text .= $ordered_arr{$key};
			}
		}

		#remove answer id tags
		$ans_text =~ s/\@\*\[(\S*?)\]\*\@//g;
	}

	#write the final one
	if($previous_ques eq $question_index)
	{
		#escape bad chars 
		if (($convert_chars == 1) && ($ALLOW_UNICODE != 1))
		{
			$ans_text =~ s/([\<\!\-\#\>\|\0])/'&#'.ord($1).';'/ge;
		}

		#add the review response button if this is the html page	
		if ($html_page == 1)
		{
			$ans_text = '<FORM ACTION="@*(data)@*(form_query)@*(uid)#' . $question_index . '" METHOD="POST">' . $ans_text . ' <INPUT TYPE="HIDDEN" ID="RWS_NAME" NAME="RWS_NAME" VALUE="' . $form_name . '"> <INPUT TYPE="HIDDEN" ID="PAGE_KEY" NAME="PAGE_KEY" VALUE="[confirmation_page]"> <INPUT TYPE="HIDDEN" ID="FORM_ACTION" NAME="FORM_ACTION" VALUE="BRANCH!"> <INPUT TYPE="HIDDEN" ID="PAGE_NUMBER" NAME="PAGE_NUMBER" VALUE="' . $question_page{$question_index} . '"> <span style="text-decoration:underline; color:#0000ff;"><INPUT TYPE="SUBMIT" ID="Change Response" NAME="Change Response" VALUE="Change Response" style="text-align: left; border: medium none; text-decoration:underline; padding: 0; color:#0000ff; background-color:transparent; cursor:pointer" /> </span></FORM><FORM ACTION="@*(data)@*(form_query)@*(uid)" METHOD="POST"><INPUT TYPE="HIDDEN" ID="RWS_NAME" NAME="RWS_NAME" VALUE="' . $form_name . '">';
		}	

		#remove answer id tags
		$ans_text =~ s/\@\*\[(\S*?)\]\*\@//g;	
			
		#replace the holders with the true values
		$lines =~ s/\@\*\(QUESTION_TEXT\)/$ques_text/g;
		$lines =~ s/\@\*\(ANSWER_TEXT\)/$ans_text/g;
	}

	if ($html_page == 1)
	{
		#get rid of the rich-text line breaks in the question text
		$lines =~ s/\&\#60\;br \/\&#62\;//g;
	}
	else
	{
		#get rid of the rich-text line breaks for the email
		$lines =~ s/\<br \/\>//g;
	}

	#while a pipe is found, unset the escaping
	while ($lines =~ m/(\[PIPE\_ID\][A-Fa-f0-9\#\&\;]*\[\/PIPE\])/)
	{
		#save the pipe 
		$pipe = $1;

		#replace the -s in the QID
		$pipe =~ s/\&\#45\;/\-/g;

		#put the new pipe in the lines
		$lines =~ s/\[PIPE\_ID\][A-Fa-f0-9\#\&\;]*\[\/PIPE\]/$pipe/;
	}			
	
	#add to the log if in diagnostic mode
	if ($diagnostic_on == 1)
	{
		&write_log($LOG_NAME, $MAX_SIZE, "rws5.pm", "add_confirmation_data", "None", $thread_ID, 0);
	}

	return $lines;
}

########################################################################################
# 	FUNCTION THAT RETURNS A RANDOM PAGE TO DISPLAY									   #
#	USE: $rand_page = &next_random_page($random_group_id);       	   #		
########################################################################################
sub next_random_page
{
	my $random_group = $_[0];
	my @pages = ();
	my @random_group_pages = ();
 	my $index = 0;
	my $error = 0;
	my $length = 0;
	my $sub_length = 0;
	my $key = "";
	my $sub_key = "";
	my $new_key = "";
	my $found = 0;
	my @available_pages = ();
	my $largest_page = 0;

	#add to the log if in diagnostic mode
	if ($diagnostic_on == 1)
	{
		&write_log($LOG_NAME, $MAX_SIZE, "rws5.pm", "next_random_page", "random_group = " . $random_group, $thread_ID, 1);
	}

	#store the submitted pages in a hash
	@pages = split(/\,/,$form_uid{'[MISC]'}{'SubmittedPages'});
	
	#store the random group pages for the current group in a hash
	@random_group_pages = split(/\,/,$form_configuration{'[MISC]'}{'RandomGroup' . $random_group});

	#get the length of the list
   	$length = @random_group_pages;

	#make sure there are available pages from the group that have not been submitted
	foreach $key (@random_group_pages)
	{
		#store the largest page index in the group
		if($key > $largest_page)
		{
			$largest_page = $key;	
		}

		#reset the found flag
 		$found = 0;
 		foreach $sub_key (@pages)
 		{
 			#if random page was already submitted, increment the count 
 			if($sub_key == $key)
 			{
 				$found = 1;
 			}
 		}
 
 		#add the page index to the available pages hash
 		if($found == 0)
 		{
 			push (@available_pages,$key);
 		}
	}

	#store the number of available pages
	$sub_length = @available_pages;
 		
	#if all the random pages have been submitted return the next page in sequence
	if($sub_length <= 0)
	{	
		return(&next_page_key($largest_page));
	}
	
	#generates random seed
	srand;

	#get a random index from the random group pages
	$index = rand @available_pages;

	#add to the log if in diagnostic mode
	if ($diagnostic_on == 1)
	{
		&write_log($LOG_NAME, $MAX_SIZE, "rws5.pm", "next_random_page", "page = " . '[page_' . $available_pages[$index] . ']', $thread_ID, 0);
	}

	return ('[page_' . $available_pages[$index] . ']'); 
}

########################################################################################
# 	FUNCTION THAT RETURNS THE NEXT KEY												   #
#	USE: $page_key = &next_page_key($current_index);								   #		
########################################################################################
sub next_page_key
{
	my $current_index = $_[0];
	my $new_key = "";
	my $location = "";

	#add to the log if in diagnostic mode
	if ($diagnostic_on == 1)
	{
		&write_log($LOG_NAME, $MAX_SIZE, "rws5.pm", "next_page_key", "current_index = " . $current_index, $thread_ID, 1);
	}

	#increment the current index
	$current_index++;

	#try the next page in sequence
	$new_key = '[page_' . $current_index . ']';
		 
	#if there are no more pages in the sequence, load the confirmation page or 1st success page 
	if(!(exists $form_configuration{$new_key}))	
	{
		#try to locate a confirmation page
		$location = &return_full_path($form_directories{'[Forms]'}{$form_configuration{'[MISC]'}{'FormName'}},"confirmation_page.html");
		if(-e $location)
		{
			return("[confirmation_page]");
		}

		#no confirmation page, try to locate a complete form page in the sequence
		$new_key = '[complete_page_1]';
		if(!(exists $form_configuration{$new_key}))	
		{
			if($form_configuration{'[MISC]'}{'DefaultWebFormCompletePage'} =~ /^http/)
			{
				#return the URL if a success URL was designated
				return($form_configuration{'[MISC]'}{'DefaultWebFormCompletePage'});
			}
			else
			{
				#make sure the complete page exists
				if(!(exists $form_configuration{'[complete_page_' . $form_configuration{'[MISC]'}{'DefaultWebFormCompletePage'} . ']'}))	
				{
   					&general_error_screen('Form Branch Error','<B>Module:</B> RWS5<BR><B>Line:</B> ' . __LINE__ . '<BR><B>Details:</B> The designated branch path is invalid. Please contact the form administrator before continuing.',$form_configuration{'[MISC]'}{'AdminAddress'});
					exit;
				}
				else
				{
					#return the page key of the first complete page
					return('[complete_page_' . $form_configuration{'[MISC]'}{'DefaultWebFormCompletePage'} . ']');
				}
			}
		}	
	}

	#add to the log if in diagnostic mode
	if ($diagnostic_on == 1)
	{
		&write_log($LOG_NAME, $MAX_SIZE, "rws5.pm", "next_page_key", "new_key = " . $new_key, $thread_ID, 0);
	}

	#return the next page in the sequence
	return ($new_key); 
}

########################################################################################
# 	FUNCTION THAT PRODUCES A SERVER ERROR											   #
#	USE: &show_server_error($err_num,$err_title,$err_text,$line);					   #		
########################################################################################
sub show_server_error
{
	my $err_num = $_[0];
	my $err_title = $_[1];
	my $err_text = $_[2];
	my $err_line = $_[3];
	my $error_file = "";

	#add to the log if in diagnostic mode
	if ($diagnostic_on == 1)
	{
		&write_log($LOG_NAME, $MAX_SIZE, "rws5.pm", "show_server_error", "err_num = " . $err_num . " && err_title = " . $err_title . " && err_text = " . $err_title . " && err_line = " . $err_line, $thread_ID, 1);
	}

	#get the location of the potential error page
	$error_file = &return_full_path($form_directories{'[Forms]'}{$form_configuration{'[MISC]'}{'FormName'}},'error_page.html');
	
	#if the error page exists then display the designer-built page		
	if(-e $error_file)
	{
		&display_built_error($error_file,$err_text,$err_num,$err_line);
	}
	else
	{
		if ($err_num == 2000)
		{
			&general_error_screen($err_title,"<B>Module:</B> RWS5<BR><B>Line:</B> " . $err_line . "<BR><B>Error #:</B> " . $err_num . "<BR><B>Details:</B> " . $err_text,$form_configuration{'[MISC]'}{'AdminAddress'}, 2);
		}
		elsif ($err_num == 3000)
		{
			&general_error_screen($err_title,"<B>Module:</B> RWS5<BR><B>Line:</B> " . $err_line . "<BR><B>Error #:</B> " . $err_num . "<BR><B>Details:</B> " . $err_text,$form_configuration{'[MISC]'}{'AdminAddress'}, 2);
		}
		else
		{
			&general_error_screen($err_title,"<B>Module:</B> RWS5<BR><B>Line:</B> " . $err_line . "<BR><B>Error #:</B> " . $err_num . "<BR><B>Details:</B> " . $err_text,$form_configuration{'[MISC]'}{'AdminAddress'});
		}
	}

	#add to the log if in diagnostic mode
	if ($diagnostic_on == 1)
	{
		&write_log($LOG_NAME, $MAX_SIZE, "rws5.pm", "show_server_error", "None", $thread_ID, 0);
	}
}

########################################################################################
# 	FUNCTION THAT RETURNS THE BODY FOR A SUBMISSION EMAIL  		       				   #	
#	USE: $email_body=&construct_email_body();					       	       		   #		
########################################################################################
sub construct_email_body
{
	my $header = "";
	my $date = "";
	my $day = (Sunday,Monday,Tuesday,Wednesday,Thursday,Friday,Saturday)[(localtime)[6]];
	my $mday = (localtime)[3];
	my $month = (January,February,March,April,May,June,July,August,September,October,November,December)[(localtime)[4]]; 
	my $yr = (localtime)[5]+1900;
	my $html_content = "";
	my $display_hidden = $_[0];

	#add to the log if in diagnostic mode
	if ($diagnostic_on == 1)
	{
		&write_log($LOG_NAME, $MAX_SIZE, "rws5.pm", "construct_email_body", "display_hidden = " . $display_hidden, $thread_ID, 1);
	}

	$date = $day . ", " . $month . " " . $mday . ", " . $yr;    

	$header .= "================================================================\n";
	$header .= " *** Automated Mailing - Remark Web Survey 5.0 *** \n";
	$header .= "================================================================\n\n";

	$header .= "Form:\t[" . $form_configuration{'[MISC]'}{'FormName'} . "]\n";
	$header .= "URL:\t" . $form_configuration{'[MISC]'}{'DataScript'} . "?form=" . $form_configuration{'[MISC]'}{'FormName'} . "\n";
	$header .= "Date:\t" . $date . "\n";
	$header .= "Time:\t" . &get_time() . "\n\n\n";

	$html_content = "@*(QUESTION_TEXT)\n";
	$html_content .= "   --> @*(ANSWER_TEXT)\n";

	$header .= &add_confirmation_data($html_content,$display_hidden,0);

	#add the piping information
	$header = &piping($header, 0, 1);

	#add to the log if in diagnostic mode
	if ($diagnostic_on == 1)
	{
		&write_log($LOG_NAME, $MAX_SIZE, "rws5.pm", "construct_email_body", "None", $thread_ID, 0);
	}

	return $header;
}

########################################################################################
# 	FUNCTION THAT RETURNS A HASH OF ALL SUBMITTED DATA  		       				   #	
#	USE: %data=&merge_submitted_data();					       	       		   		   #		
########################################################################################
sub merge_submitted_data
{
	my $key_index = ""; ;
	my $tmp_index = "";
	my $tmp_key = "";
	my %merge_hash = ();
	my @visited_pages = ();
	my $key = "";

	#add to the log if in diagnostic mode
	if ($diagnostic_on == 1)
	{
		&write_log($LOG_NAME, $MAX_SIZE, "rws5.pm", "merge_submitted_data", "None", $thread_ID, 1);
	}
	
 	#loop thru all submitted items - skip MISC section
	foreach $key_index (sort keys %form_uid)
	{ 
		next if(($key_index eq '[MISC]') || ($key_index eq 'x') || ($key_index eq 'y'));
		
		foreach $key (sort keys %{$form_uid{$key_index}})
		{ 
			next if(($key eq 'QUESTION_START') || ($key eq 'QUESTION_END') || ($key !~ /^Q/));

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

	#add to the log if in diagnostic mode
	if ($diagnostic_on == 1)
	{
		&write_log($LOG_NAME, $MAX_SIZE, "rws5.pm", "merge_submitted_data", "None", $thread_ID, 0);
	}

	return (%merge_hash);
}

########################################################################################
# 	FUNCTION THAT LOADS THE FIRST PAGE IN A SEQUENCE     		       				   #	
#	USE: &load_first_page();					       	       		   		           #		
########################################################################################
sub load_first_page
{
	my $tmp_page = "";
	my $target_page = "";
	my %merged_data = ();

	#add to the log if in diagnostic mode
	if ($diagnostic_on == 1)
	{
		&write_log($LOG_NAME, $MAX_SIZE, "rws5.pm", "load_first_page", "None", $thread_ID, 1);
	}
		
	if(defined $form_configuration{'[page_1]'}{'#RANDOM_ID#'})
	{
		if($form_configuration{'[page_1]'}{'#RANDOM_ID#'} ne '-1')
		{
			$tmp_page = &next_random_page($form_configuration{'[page_1]'}{'#RANDOM_ID#'});

			#if a URL was specified (SHOULD NOT be the case) goto that page instead
			if($tmp_page =~ /^http/)
			{
				%merged_data = &merge_submitted_data();

				#check for pipes on the redirect
				$tmp_page = &piping($tmp_page);
				&browser_redirect($tmp_page,$form_directories{'[Defaults]'}{'CGIRedirect'},\%merged_data);  
			}
			else
			{
				#get the target file from the target hash
				$target_page = $form_configuration{$tmp_page}{"#SRC#"};

				#if a URL was specified goto that page instead
				if($target_page =~ /^http/)
				{
					%merged_data = &merge_submitted_data();

					#check for pipes on the redirect
					$target_page = &piping($target_page);
					&browser_redirect($target_page,$form_directories{'[Defaults]'}{'CGIRedirect'},\%merged_data);   
				}
				else
				{
					#concatenate the form's directory with the target page
					$target_page = &return_full_path($form_directories{'[Forms]'}{$form_configuration{'[MISC]'}{'FormName'}},$target_page);	
	
					#navigate to the appropriate page
					&display_html(&reload_form_replacement($target_page,'','',$tmp_page));
				}
			}
		}
		else
		{
			&display_html(&reload_form_replacement(&get_next_page,'','','[page_1]'));
		}
	}
	else
	{
		&display_html(&reload_form_replacement(&get_next_page,'','','[page_1]'));
	}

	#add log record
	&add_log_record('form access','permitted');

	#add to the log if in diagnostic mode
	if ($diagnostic_on == 1)
	{
		&write_log($LOG_NAME, $MAX_SIZE, "rws5.pm", "load_first_page", "None", $thread_ID, 0);
	}
	
	exit;
}

########################################################################################
# 	FUNCTION THAT RETURNS THE FULL DATA SCRIPT URL      		       				   #	
#	USE: $full_path = &get_fully_qualified_data_script($script);	   		           #		
########################################################################################
sub get_fully_qualified_data_script()
{
	my $tmp_path = $_[0];	
	my $admin = $form_configuration{'[MISC]'}{'AdminScript'};

	#add to the log if in diagnostic mode
	if ($diagnostic_on == 1)
	{
		&write_log($LOG_NAME, $MAX_SIZE, "rws5.pm", "get_fully_qualified_data_script", "tmp_path = " . $tmp_path, $thread_ID, 1);
	}

	#if the data script is already qualified then return it
	if ($tmp_path =~ /^\http/)
	{
		return($tmp_path);
	}

	#check the environment variable for a full path
	elsif ($ENV{'SCRIPT_NAME'} =~ /^\http/)
	{
		return($ENV{'SCRIPT_NAME'});
	}

	#use the admin script's path from the config file
	elsif ($admin ne '')
	{
		$admin =~ s/rwsad5/rws5/ge;
		return($admin);	
	}

	#add to the log if in diagnostic mode
	if ($diagnostic_on == 1)
	{
		&write_log($LOG_NAME, $MAX_SIZE, "rws5.pm", "get_fully_qualified_data_script", "tmp_path = " . $tmp_path, $thread_ID, 0);
	}

	#if no cases succeed, return the relative path passed in
	return($tmp_path);
}

########################################################################################
# 	FUNCTION THAT CHECKS THAT THE FORM DATE IS ACTIVE      		       				   #	
#	USE: &check_live_form($form_configuration{'[MISC]'}{'LiveStartTime'}, $form_configuration{'[MISC]'}{'LiveEndTime'})	   		           #		
########################################################################################
sub check_live_form()
{
	my $start_date = $_[0];	
	my $end_date = $_[1];
	my $begin;
	my $end;
	my $now;

	#add to the log if in diagnostic mode
	if ($diagnostic_on == 1)
	{
		&write_log($LOG_NAME, $MAX_SIZE, "rws5.pm", "check_live_form", "start_date = " . $start_date . " && end_date = " . $end_date, $thread_ID, 1);
	}

	#format the dates
	$begin = &format_date($start_date);
	$end = &format_date($end_date);
	$now = &format_localtime();

	#if error message is undefined, define it
	if ($form_configuration{'[MISC]'}{'ErrorMessageWebFormUnavailable'} eq "")
	{
		$form_configuration{'[MISC]'}{'ErrorMessageWebFormUnavailable'} = "This form is not currently live.";
	}

	#Check to see if there is both a start and end time defined
	if (($begin != 0) && ($end != 0)) 
	{
		#Check to see if the current time falls between the start and end time
		if (($now >= $begin) && ($now <= $end))
		{
			return 1;
		}

		#Otherwise return an error screen
		else {
			&show_server_error($ERROR_NUM_WEBFORM_UNAVAILABLE,"Web Form Unavailable",$form_configuration{'[MISC]'}{'ErrorMessageWebFormUnavailable'}, __LINE__); 
			exit;
		}
	}

	#If both are not defined, check to see if the start time is
	elsif ($begin != 0) 
	{
		#Check to see if the current time is after the start time
		if ($now >= $begin)
		{
			return 1;
		}

		#Otherwise return an error screen
		else {
			&show_server_error($ERROR_NUM_WEBFORM_UNAVAILABLE,"Web Form Unavailable",$form_configuration{'[MISC]'}{'ErrorMessageWebFormUnavailable'}, __LINE__); 
			exit;
		}
	}

	#If the start time is not defined, check to see if the end time is
	elsif ($end != 0) 
	{
		#Check to see if current time is before end time
		if ($now <= $end)
		{
			return 1;
		}

		#Otherwise return an error screen
		else {
			&show_server_error($ERROR_NUM_WEBFORM_UNAVAILABLE,"Web Form Unavailable",$form_configuratio{'[MISC]'}{'ErrorMessageWebFormUnavailable'}, __LINE__); 
			exit;
		}
	}

	#If neither begin or end time are defined, then return 1
	else 
	{
		#add to the log if in diagnostic mode
		if ($diagnostic_on == 1)
		{
			&write_log($LOG_NAME, $MAX_SIZE, "rws5.pm", "check_live_form", "Form is live", $thread_ID, 0);
		}

		return 1;
	}
}

########################################################################################
# 	FUNCTION THAT FORMATS THE DATE TO BE CHECKED      		       				   #	
#	USE: &format_date($date)	   		           #		
########################################################################################
sub format_date()
{
	my $date = $_[0];
	my $year;
	my $month;
	my $day;
	my $hour;
	my $minute;

	#add to the log if in diagnostic mode
	if ($diagnostic_on == 1)
	{
		&write_log($LOG_NAME, $MAX_SIZE, "rws5.pm", "format_date", "date = " . $date, $thread_ID, 1);
	}

	#Splits the localtime expression at the / occurances
	($month, $day, $expression) = split /\//, $date;
	
	#Splits the expression at spaces
	($year, $time, $meridian) = split ' ', $expression;

	#Splits the expression at :
	($hour, $minute) = split /\:/, $time;

	#if 12 am/pm
	if ($hour eq '12')
	{
		#if 12 am
		if ($meridian eq 'AM')
		{
			$hour = $hour - 12;
		}
	}
	#if PM and not 12
	elsif ($meridian eq 'PM')
	{
		$hour = $hour + 12;
	}

	#add them together in a string so you have year month day hour minute
	$numberic_date = $year . sprintf("%02d",$month) . sprintf("%02d",$day) . sprintf("%02d",$hour) . sprintf("%02d",$minute);

	#add to the log if in diagnostic mode
	if ($diagnostic_on == 1)
	{
		&write_log($LOG_NAME, $MAX_SIZE, "rws5.pm", "format_date", "numeric date = " . $numberic_date, $thread_ID, 0);
	}

	return $numberic_date;
}

########################################################################################
# 	FUNCTION THAT FORMATS THE LOCALTIME TO BE CHECKED   			       #	
#	USE: &format_localtime()	   		          		       #		
########################################################################################
sub format_localtime()
{
	my $date = $_[0];	
	my $year;
	my $month;
	my $day;
	my $hour;
	my $minute;
	my $numberic_current_date = "";

	#add to the log if in diagnostic mode
	if ($diagnostic_on == 1)
	{
		&write_log($LOG_NAME, $MAX_SIZE, "rws5.pm", "format_localtime", "date = " . $date, $thread_ID, 1);
	}

	#use the localtime function
	@current_date = localtime(time);

	#define the year, month, day, hour and minute from the localtime array
	$year = $current_date[5] + 1900;
	$month = $current_date[4] + 1;
	$day = $current_date[3];
	$hour = $current_date[2];
	$minute = $current_date[1];

	#add them together in a string so you have year month day hour minute
	$numberic_current_date = $year . sprintf("%02d",$month) . sprintf("%02d",$day) . sprintf("%02d",$hour) . sprintf("%02d",$minute);

	#add to the log if in diagnostic mode
	if ($diagnostic_on == 1)
	{
		&write_log($LOG_NAME, $MAX_SIZE, "rws5.pm", "format_localtime", "numeric_current_date = " . $numberic_current_date, $thread_ID, 0);
	}

	return $numberic_current_date;
}


########################################################################################
# 	FUNCTION THAT RETURNS THE NUMBER OF MINUTES OF A DATE  			       #	
#	USE: &date_in_seconds($date)	   		           		       #		
########################################################################################
sub date_in_seconds()
{
	my $date = $_[0];
	my $year;
	my $month;
	my $day;
	my $hour;
	my $minute;
	my $seconds;

	#add to the log if in diagnostic mode
	if ($diagnostic_on == 1)
	{
		&write_log($LOG_NAME, $MAX_SIZE, "rws5.pm", "date_in_seconds", "date = " . $date, $thread_ID, 1);
	}

	#Splits the localtime expression at the / occurances
	($month, $day, $expression) = split /\//, $date;
	
	#Splits the expression at spaces
	($year, $time) = split ' ', $expression;

	#determine if it is AM or PM
	if ($time =~ s/PM//)
	{
		$meridian = "PM";
	}
	elsif ($time =~ s/AM//)
	{
		$meridian = "AM";
	}

	#Splits the expression at :
	($hour, $minute, $seconds) = split /\:/, $time;

	#if 12 am/pm
	if ($hour eq '12')
	{
		#if 12 am
		if ($meridian eq 'AM')
		{
			$hour = $hour - 12;
		}
	}
	#if PM and not 12
	elsif ($meridian eq 'PM')
	{
		$hour = $hour + 12;
	}

	#determine the number of minutes based on the year
	$num_minutes = (($year - 1) * 525600);
	#add in an extra days for the number of leap years in between
	$num_minutes += int($year / 4) * 24 * 60;  

	#add in the number of months for each month (through November)
	if (($month - 1) >= 1)
	{
		$num_minutes += 44640;
	}
	if ((($month - 1) >= 2) && ($year % 4 != 0))
	{
		$num_minutes += 40320;
	}
	elsif ((($month - 1) >= 2) && ($year % 4 == 0))
	{
		$num_minutes += 41760;
	}
	if (($month - 1) >= 3)
	{
		$num_minutes += 44640;
	}
	if (($month - 1) >= 4)
	{
		$num_minutes += 43200;
	}
	if (($month - 1) >= 5)
	{
		$num_minutes += 44640;
	}
	if (($month - 1) >= 6)
	{
		$num_minutes += 43200;
	}
	if (($month - 1) >= 7)
	{
		$num_minutes += 44640;
	}
	if (($month - 1) >= 8)
	{
		$num_minutes += 44640;
	}
	if (($month - 1) >= 9)
	{
		$num_minutes += 43200;
	}
	if (($month - 1) >= 10)
	{
		$num_minutes += 44640;
	}
	if (($month - 1) >= 11)
	{
		$num_minutes += 43200;
	}

	#add in the number of minutes for days
	$num_minutes += ($day - 1) * 24 * 60;

	#add in the number of minutes for hours
	$num_minutes += $hour *60;

	#add in the current number of minutes
	$num_minutes += $minute;

	#conver to seconds
	$num_seconds = $num_minutes * 60;
	$num_seconds += $seconds;

	#add to the log if in diagnostic mode
	if ($diagnostic_on == 1)
	{
		&write_log($LOG_NAME, $MAX_SIZE, "rws5.pm", "date_inseconds", "num_seconds = " . $num_seconds, $thread_ID, 1);
	}

	#return the total
	return $num_seconds;
}

########################################################################################
# 	FUNCTION THAT RETURNS THE CURRENT NUMBER OF MINUTES IN TIME		       #	
#	USE: &localtime_in_seconds()	   		          		       #		
########################################################################################
sub localtime_in_seconds()
{
	my $date = $_[0];	
	my $year;
	my $month;
	my $day;
	my $hour;
	my $minute;
	my $numberic_current_date = "";

	#add to the log if in diagnostic mode
	if ($diagnostic_on == 1)
	{
		&write_log($LOG_NAME, $MAX_SIZE, "rws5.pm", "localtime_in_seconds", "date = " . $date, $thread_ID, 1);
	}

	#use the localtime function
	@current_date = localtime(time);

	#define the year, month, day, hour and minute from the localtime array
	$year = $current_date[5] + 1900;
	$month = $current_date[4] + 1;
	$day = $current_date[3];
	$hour = $current_date[2];
	$minute = $current_date[1];
	$seconds = $current_date[0];

	$num_minutes = (($year - 1) * 525600);
	$num_minutes += int($year / 4) * 24 * 60;  

	if (($month - 1) >= 1)
	{
		$num_minutes += 44640;
	}
	if ((($month - 1) >= 2) && ($year % 4 != 0))
	{
		$num_minutes += 40320;
	}
	elsif ((($month - 1) >= 2) && ($year % 4 == 0))
	{
		$num_minutes += 41760;
	}
	if (($month - 1) >= 3)
	{
		$num_minutes += 44640;
	}
	if (($month - 1) >= 4)
	{
		$num_minutes += 43200;
	}
	if (($month - 1) >= 5)
	{
		$num_minutes += 44640;
	}
	if (($month - 1) >= 6)
	{
		$num_minutes += 43200;
	}
	if (($month - 1) >= 7)
	{
		$num_minutes += 44640;
	}
	if (($month - 1) >= 8)
	{
		$num_minutes += 44640;
	}
	if (($month - 1) >= 9)
	{
		$num_minutes += 43200;
	}
	if (($month - 1) >= 10)
	{
		$num_minutes += 44640;
	}
	if (($month - 1) >= 11)
	{
		$num_minutes += 43200;
	}

	$num_minutes += ($day - 1) * 24 * 60;
	$num_minutes += $hour *60;
	$num_minutes += $minute;
	$num_seconds = $num_minutes * 60;
	$num_seconds += $seconds;

	#add to the log if in diagnostic mode
	if ($diagnostic_on == 1)
	{
		&write_log($LOG_NAME, $MAX_SIZE, "rws5.pm", "localtime_in_seconds", "num_seconds = " . $num_seconds, $thread_ID, 0);
	}

	return $num_seconds;
}

########################################################################################
# 	FUNCTION THAT OPENS A FILE AND COUNTS THE NUMBER OF ENDLINES		       #	
#	USE: $lines = &count_lines($filename)	   		          	       #		
########################################################################################
sub count_lines()
{
	my $filename = $_[0];	
	my $lines = 0;

	#add to the log if in diagnostic mode
	if ($diagnostic_on == 1)
	{
		&write_log($LOG_NAME, $MAX_SIZE, "rws5.pm", "cound_lines", "filename = " . $filename, $thread_ID, 1);
	}

	#open the file
	if (open(FILE, $filename)) 
	{
		#read in the file, add an increment for each endline
		while (sysread FILE, $buffer, 4096) 
		{
			$lines += ($buffer =~ tr/\n//);
		}
		close FILE;

		#add to the log if in diagnostic mode
		if ($diagnostic_on == 1)
		{
			&write_log($LOG_NAME, $MAX_SIZE, "rws5.pm", "count_lines", "lines = " . $lines, $thread_ID, 0);
		}

		return $lines;
	}

	else {
		return 0;
	}
}

########################################################################################
# 	FUNCTION THAT READS IN THE CONFIG FILE AND TESTS THE MAX RESPONDENTS	       #	
#	USE: &check_number_respondents()	   		          	       #		
########################################################################################
sub check_number_respondents()
{	
	my $respondents = 0;
	my $max_respondents = $form_configuration{'[MISC]'}{'MaxSubmissions'};

	#add to the log if in diagnostic mode
	if ($diagnostic_on == 1)
	{
		&write_log($LOG_NAME, $MAX_SIZE, "rws5.pm", "cehck_number_respondents", "None", $thread_ID, 1);
	}

	#if max respondents is defined and not set to 0 (unlimited)
	if (($max_respondents ne "") && ($max_respondents != 0)) 
	{

		#get the data and archive file names
		$data_file = &return_full_path($form_directories{'[Forms]'}{$form_configuration{'[MISC]'}{'FormName'}},$form_configuration{'[MISC]'}{'DataFile'});
		$archive_file = $data_file . '.rwa';
		$data_file .= '.rwd';

		#find the number of respondents form the data and archive files
		$respondents = &count_lines($data_file) + &count_lines($archive_file);

		#if the number of respondents is under the max number of respondents, return 1
		if ($respondents < $max_respondents) 
		{
			#add to the log if in diagnostic mode
			if ($diagnostic_on == 1)
			{
				&write_log($LOG_NAME, $MAX_SIZE, "rws5.pm", "check_number_respondents", "Number Respondents Under Max", $thread_ID, 0);
			}

			return 1;
		}

		else 
		{
			#if the error message is undefined, define it
			if ($form_configuration{'[MISC]'}{'ErrorMessageSubmissionCapacity'} eq "")
			{
				$form_configuration{'[MISC]'}{'ErrorMessageSubmissionCapacity'} = "This form is currently over the maximum number of respondents set by the form administrator.";
			}

			&show_server_error($ERROR_NUM_SUBMISSION_CAPACITY,"Form Over the Capped Limit",$form_configuration{'[MISC]'}{'ErrorMessageSubmissionCapacity'}, __LINE__); 

			#add to the log if in diagnostic mode
			if ($diagnostic_on == 1)
			{
				&write_log($LOG_NAME, $MAX_SIZE, "rws5.pm", "check_number_respondents", "Number Respondents Over Max", $thread_ID, 0);
			}

			exit;
		}
	}
	else 
	{
		#add to the log if in diagnostic mode
		if ($diagnostic_on == 1)
		{
			&write_log($LOG_NAME, $MAX_SIZE, "rws5.pm", "check_number_respondents", "No Max Set", $thread_ID, 0);
		}

		return 1;
	}
}

########################################################################################
# 	FUNCTION THAT READS IN LINES (Either HTML or confirmation Email) and adds pipes#	
#	USE: &piping($text_variable, $html, $submission_email)	   		          	       #		
########################################################################################
sub piping()
{
	my $text = $_[0];
	my $html = $_[1];
	my $submission_email = $_[2];

	#add to the log if in diagnostic mode
	if ($diagnostic_on == 1)
	{
		&write_log($LOG_NAME, $MAX_SIZE, "rws5.pm", "piping", "text = " . $text . " && html = " . $html . " && submission_email = " . $submission_email, $thread_ID, 1);
	}

	#if we have the submission email, removed the escaping slashes
	if ($submission_email eq "1")
	{
		$text =~ s/\\\[PIPE\\\_ID\\\](\S*?)\\\[\\\/PIPE\\\]/\[PIPE\_ID\]$1\[\/PIPE\]/g;
	}

	#remove URL escaping - for URL piping
	$text =~ s/\%5BPIPE\_ID\%5D(\S*?)\%5B\/PIPE\%5D/\[PIPE\_ID\]$1\[\/PIPE\]/g;

	#if the pipe has been escaped out with ASCII Character codes
	while ($text =~ /\&\#91\;PIPE\_ID\&\#93\;(\S*?)\&\#91\;\&\#47\;PIPE\&\#93\;/)
	{
		#remove HTML escaping
		$text =~ s/\&\#91\;PIPE\_ID\&\#93\;(\S*?)\&\#91\;\&\#47\;PIPE\&\#93\;/\[PIPE\_ID\]$1\[\/PIPE\]/;

		#store the pipe temporarily
		$temp_pipe = $1;

		#setup a variable to replace the dashes
		$replaced_temp_pipe = $temp_pipe;

		#replace dashes in the QID
		$replaced_temp_pipe =~ s/\&\#45\;/\-/g;

		#remove HTML escaping on dashes
		$text =~ s/\[PIPE\_ID\]$temp_pipe\[\/PIPE\]/\[PIPE\_ID\]$replaced_temp_pipe\[\/PIPE\]/g;
	}

	#if we have escaped out dashes in a db-PIPE-db field from login page (like on confirmation page), removing escaping
	$text =~ s/\[PIPE\_ID\]DB\&\#45\;(.*?)\&\#45\;DB\[\/PIPE\]/\[PIPE\_ID\]DB\-$1\-DB\[\/PIPE\]/g;

	#insert piping answers
	#runs through code each time it finds a pipe in html, saves the QID to $1
	while ($text =~ m/\[PIPE\_ID\](.*?)\[\/PIPE\]/) 
	{
		#store the piping string
		my $piping = $1;

		#If we have a password pipe to bring up the name
		if ($piping eq "RespondentNamePipeID")
		{
			require rwsem5;

			#if we have an XML hash file
			if ($legacy_pass == 0)
			{
				#look up in the UID hash
				$encoded_password_name = $form_uid{'[MISC]'}{'RespondentName'};
			}
			#running legacy version of the hash file
			else
			{
				if(-e $form_hash_file)
				{
					%hash_config_file = &read_config($form_hash_file,1);
				}

				#if we have a username
				if ($form_uid{'[MISC]'}{'USER'} ne '')
				{
					#get the name stored in the hash from the password file
					$encoded_password_name = $hash_config_file{'[RESPONDENT NAMES]'}{&HexDigest(&BinaryEncoding(lc($form_uid{'[MISC]'}{'USER'}))) . ":" . $form_uid{'[MISC]'}{'PWD'}};
				}
				else			
				{	
					#get the name stored in the hash from the password file
					$encoded_password_name = $hash_config_file{'[RESPONDENT NAMES]'}{$form_uid{'[MISC]'}{'PWD'}};
				}
			}
			

			use MIME::Base64;
			$password_name = decode_base64($encoded_password_name);

			#replace in the name on the pipe
			$text =~ s/\[PIPE\_ID\]$piping\[\/PIPE\]/$password_name/;

			#find the next pipe
			next;
		}

		#If we have a password pipe to bring up the email
		if ($piping eq "RespondentEmailPipeID")
		{
			require rwsem5;

			#if we have an XML hash file
			if ($legacy_pass == 0)
			{
				#look up in the UID hash
				$encoded_password_email = $form_uid{'[MISC]'}{'RespondentEmailAddress'};
			}
			#running legacy version of the hash file
			else
			{
				if(-e $form_hash_file)
				{
					%hash_config_file = &read_config($form_hash_file,1);
				}

				#if we have a username
				if ($form_uid{'[MISC]'}{'USER'} ne '')
				{
					#get the name stored in the hash from the password file
					$encoded_password_email = $hash_config_file{'[RESPONDENT EMAIL ADDRESSES]'}{&HexDigest(&BinaryEncoding(lc($form_uid{'[MISC]'}{'USER'}))) . ":" . $form_uid{'[MISC]'}{'PWD'}};
				}
				else			
				{	
					#get the name stored in the hash from the password file
					$encoded_password_email = $hash_config_file{'[RESPONDENT EMAIL ADDRESSES]'}{$form_uid{'[MISC]'}{'PWD'}};
				}
			}

			use MIME::Base64;
			$password_email = decode_base64($encoded_password_email);

			#replace in the email on the pipe
			$text =~ s/\[PIPE\_ID\]$piping\[\/PIPE\]/$password_email/;

			#find the next pipe
			next;
		}

		#If we have a username pipe
		if ($piping eq "RespondentUsernamePipeID")
		{
			#replace in the username on the pipe
			$text =~ s/\[PIPE\_ID\]$piping\[\/PIPE\]/$form_uid{'[MISC]'}{'USER'}/;

			#find the next pipe
			next;
		}

		#If we have an extra field password pipe
		if ($piping =~ /DB\-(.*)\-DB/)
		{
			#store the field name
			$pipe_field = $1;

			#unescape the pipe field (if we are on confirmation and we have an escaped)
			$pipe_field =~ s/\&\#060\;/\</g;
			$pipe_field =~ s/\&\#062\;/\>/g;
			$pipe_field =~ s/\&\#045\;/\-/g;
			$pipe_field =~ s/\&\#033\;/\!/g;
			$pipe_field =~ s/\&\#035\;/\#/g;
			$pipe_field =~ s/\&\#124\;/\!/g;
			$pipe_field =~ s/\%20/ /g;


			use MIME::Base64;

			#decode the text
			$extra_pipe_text = decode_base64($form_uid{'[PIPE]'}{lc($pipe_field)});

			#replace the text in the pipe
			$text =~ s/\[PIPE\_ID\]$piping\[\/PIPE\]/$extra_pipe_text/;

			#find the next pipe
			next;
		}

		#unescape out the dashes if necessary
		$piping =~ s/\&\#45\;/\-/g;

		#determine the type of the question
		$question_type = $form_configuration{'[Questions]'}{$piping . '_TYPE'};

		#set a replaced flag
		$replaced = 0;
		
		#loop through the possible pages to find the stored answer
		for ($counter = 1; $counter <= $form_configuration{'[MISC]'}{'NumPages'}; $counter++) 
		{

			#if it is a checkbox question
			if ($question_type eq 'CHECKBOX') 
			{
				#clear out important variables for this loop
				$checkbox_answer = '';
				$checkbox_temp = '';
				$multiple_answer{$piping} = '';
				$answer_temp = '';

				#loop through the data for each submitted page
				foreach $answer (sort mysort keys %{$form_uid{'[page_' . $counter . ']'}}) 
				{
					#if the answer contains the QID
					if ($answer =~ /\Q$piping/) 
					{

						#if this is an other question already used or if it is blank, ignore it
						if (($answer eq $previous_other) || (($answer =~ /\_OTHER$/) && ($form_uid{'[page_' . $counter . ']'}{$answer} ne "on")))
						{
							next;
						}

						#if it has an other, use that answer instead
						if ($form_uid{'[page_' . $counter . ']'}{$answer . '_OTHER'} ne "")
						{
							$answer_temp = $form_uid{'[page_' . $counter . ']'}{$answer . '_OTHER'};
							$previous_other = $answer . '_OTHER';
						}
						else
						{
							#stores the answer part of QID_Answer into $1, then $answer_temp
							$answer =~ /\_([\S\W]*)/;
							$answer_temp = $1;

							#if it has HTML value defined use that instead
							if ($form_configuration{'[AnswerMap]'}{'[' . $piping . '][' . $answer_temp . ']'} ne "")
							{
								$answer_temp = $form_configuration{'[AnswerMap]'}{'[' . $piping . '][' . $answer_temp . ']'};
							}
						}

						#escape out commas
						$answer_temp =~ s/\,/\&comma\;/g;

						#check if this is the first answer for this question, add the answer to $checkbox_temp
						if ($multiple_answer{$piping} eq '') 
						{
							$checkbox_temp = $answer_temp;
							$multiple_answer{$piping} = 1;
						}
						#if not, add the answer with a comma before it
						else 
						{
							$checkbox_temp .= ',' . $answer_temp;
						}
					}	
				}

				#if there is a comma, then it is a multiple answer, add ()s
				if ($checkbox_temp =~ /\,/) 
				{
					$checkbox_answer = '(' . $checkbox_temp . ')';
				}	

				else 
				{
					$checkbox_answer = $checkbox_temp;
				}

				#unescape out the non-delimiter comments
				$checkbox_answer =~ s/\&comma\;/\,/g;

				#replace the PIPE if there is a response, end the loop
				if ($checkbox_answer ne '') 
				{
					#remove the answer id tags
					$checkbox_answer =~ s/\@\*\[(\S*?)\]\*\@//g;

					if (($html == 1) && ($ALLOW_UNICODE != 1))
					{
						#escape bad chars for answer text
						$checkbox_answer =~ s/([\<\!\#\>\|\0])/'&#'.ord($1).';'/ge;
					}

					$text =~ s/\[PIPE\_ID\]\S*?\[\/PIPE\]/$checkbox_answer/;
					$replaced = 1;
					last;
				}
			}

			#if the type is List
			elsif ($question_type eq 'LIST') 
			{
				#if it is a single list and there is an answer, replcae with answer
				if ($form_uid{'[page_' . $counter . ']'}{$piping . '_RWS_RADIO'} ne '') 
				{	
					$single_list = $form_uid{'[page_' . $counter . ']'}{$piping . '_RWS_RADIO'};

					#if it has HTML value defined use that instead
					if ($form_configuration{'[AnswerMap]'}{'[' . $piping . '][' . $single_list . ']'} ne "")
					{
						$single_list = $form_configuration{'[AnswerMap]'}{'[' . $piping . '][' . $single_list . ']'};
					}

					#remove the answer id tags
					$single_list =~ s/\@\*\[(\S*?)\]\*\@//g;

					if (($html == 1) && ($ALLOW_UNICODE != 1))
					{
						#escape bad chars for answer text
						$single_list =~ s/([\<\!\#\>\|\0])/'&#'.ord($1).';'/ge;
					}
			
					$text =~ s/\[PIPE\_ID\]\S*?\[\/PIPE\]/$single_list/;
					$replaced = 1;
					
				}	

				#otherwise we have multiple list
				else 
				{
					#reset variables
					$multilist_answer = '';
					$multilist_temp = '';
					$multiple_answer{$piping} = '';

					#loop through the data for each submitted page
					foreach $answer (sort mysort keys %{$form_uid{'[page_' . $counter . ']'}}) 
					{

						#if the answer contains the QID
						if ($answer =~ /\Q$piping/) 
						{

							#stores the answer part of QID_Answer into $1
							$answer =~ /MPD\-([\S\W]*)/;

							$answer_temp = $1;

							#if it has HTML value defined use that instead
							if ($form_configuration{'[AnswerMap]'}{'[' . $piping . '][' . $answer_temp . ']'} ne "")
							{
								$answer_temp = $form_configuration{'[AnswerMap]'}{'[' . $piping . '][' . $answer_temp . ']'};
							}

							#check if this is the first answer for this question, add the answer to $checkbox_temp
							if ($multiple_answer{$piping} eq '') 
							{
								$multilist_temp = $answer_temp;
								$multiple_answer{$piping} = 1;
							}
							#if not, add the answer with a comma before it
							else 
							{
								$multilist_temp .= ',' . $answer_temp;
							}
						}
					}

					#if there is a comma, then it is a multiple answer, add ()s
					if ($multilist_temp =~ /\,/) 
					{
						$multilist_answer = '(' . $multilist_temp . ')';
					}

					else 
					{
						$multilist_answer = $multilist_temp;
					}

					#replace the PIPE if there is a response, end the loop
					if ($multilist_answer ne '') 
					{
						#remove the answer id tags
						$multilist_answer =~ s/\@\*\[(\S*?)\]\*\@//g;

						if (($html == 1) && ($ALLOW_UNICODE != 1))
						{
							#escape bad chars for answer text
							$multilist_answer =~ s/([\<\!\#\>\|\0])/'&#'.ord($1).';'/ge;
						}

						$text =~ s/\[PIPE\_ID\]\S*?\[\/PIPE\]/$multilist_answer/;
						$replaced = 1;
						last;
					}
				}
			}

			#if we have a radio question
			elsif ($question_type eq 'RADIO') 
			{
				#if there is an answer
				if ($form_uid{'[page_' . $counter . ']'}{$piping . '_RWS_RADIO'} ne '') 
				{
					#if it has an other, use that answer instead
					if ($form_uid{'[page_' . $counter . ']'}{$piping . '_' . $form_uid{'[page_' . $counter . ']'}{$piping . '_RWS_RADIO'} . '_OTHER'} ne "")
					{
						$radio_answer = $form_uid{'[page_' . $counter . ']'}{$piping . '_' . $form_uid{'[page_' . $counter . ']'}{$piping . '_RWS_RADIO'} . '_OTHER'};

						#remove the answer id tags
						$radio_answer =~ s/\@\*\[(\S*?)\]\*\@//g;

						if (($html == 1) && ($ALLOW_UNICODE != 1))
						{
							#escape bad chars for answer text
							$radio_answer =~ s/([\<\!\#\>\|\0])/'&#'.ord($1).';'/ge;
						}

						$text =~ s/\[PIPE\_ID\]\S*?\[\/PIPE\]/$radio_answer/;
						$replaced = 1;
						last;
					}
					#otherwise use the normal answer
					else
					{
						$radio_answer = $form_uid{'[page_' . $counter . ']'}{$piping . '_RWS_RADIO'};

						#if it has HTML value defined use that instead
						if ($form_configuration{'[AnswerMap]'}{'[' . $piping . '][' . $radio_answer . ']'} ne "")
						{
							$radio_answer = $form_configuration{'[AnswerMap]'}{'[' . $piping . '][' . $radio_answer . ']'};
						}

						#remove the answer id tags
						$radio_answer =~ s/\@\*\[(\S*?)\]\*\@//g;

						if (($html == 1) && ($ALLOW_UNICODE != 1))
						{
							#escape bad chars for answer text
							$radio_answer =~ s/([\<\!\#\>\|\0])/'&#'.ord($1).';'/ge;
						}

						$text =~ s/\[PIPE\_ID\]\S*?\[\/PIPE\]/$radio_answer/;
						$replaced = 1;
						last;
					}
				}
			}
			
			#if there is text data, replace the <pipe> tag and set the flag to 1
			elsif ($form_uid{'[page_' . $counter . ']'}{$piping . '_RWS_' . $question_type} ne '') 
			{
				$text_answer = $form_uid{'[page_' . $counter . ']'}{$piping . '_RWS_' . $question_type};

				if (($html == 1) && ($ALLOW_UNICODE != 1))
				{
					#escape bad chars for answer text
					$text_answer =~ s/([\<\!\#\>\|\0])/'&#'.ord($1).';'/ge;
				}

				$text =~ s/\[PIPE\_ID\]\S*?\[\/PIPE\]/$text_answer/;
				$replaced = 1;
				last;
			}

			#if there is a hidden question, replace the <pipe> tag and set the flag to 1
			elsif ($form_uid{'[page_' . $counter . ']'}{$piping . '_RWS_HIDDEN'} ne '') 
			{
				$text_answer = $form_uid{'[page_' . $counter . ']'}{$piping . '_RWS_HIDDEN'};

				if (($html == 1) && ($ALLOW_UNICODE != 1))
				{
					#escape bad chars for answer text
					$text_answer =~ s/([\<\!\#\>\|\0])/'&#'.ord($1).';'/ge;
				}

				$text =~ s/\[PIPE\_ID\]\S*?\[\/PIPE\]/$text_answer/;
				$replaced = 1;
				last;
			}
			#if there is a query parameter
			elsif ($form_configuration{'[Questions]'}{$piping . '_QUERY'} ne '')
			{
				$text_answer = $form_uid{'[Queries]'}{lc($form_configuration{'[Questions]'}{$piping . '_QUERY'})};

				if (($html == 1) && ($ALLOW_UNICODE != 1))
				{
					#escape bad chars for answer text
					$text_answer =~ s/([\<\!\#\>\|\0])/'&#'.ord($1).';'/ge;
				}

				$text =~ s/\[PIPE\_ID\]\S*?\[\/PIPE\]/$text_answer/;
				$replaced = 1;
				last;
			}
		}

		#if no data replaced, remove the <pipe> tag from the HTML
		if ($replaced == 0) 
		{
			$text =~ s/\[PIPE\_ID\].*?\[\/PIPE\]//;
		}
	}

	#look for URL Pipes
	while ($text =~ m/\%5BURLPIPE\_ID\%5D(.*?)\%5B\/URLPIPE\%5D/) 
	{
		#store the piping string
		my $piping = $1;

		#run a recursive call to get the result from the pipe
		$piping_result = &piping("[PIPE_ID]" . $piping . "[/PIPE]");

		#encode the result 
		$piping_result =~ s/([^A-Za-z0-9])/sprintf("%%%02X", ord($1))/seg;

		#replace the pipe
		$text =~ s/\%5BURLPIPE\_ID\%5D$piping\%5B\/URLPIPE\%5D/$piping_result/;
	}

	#add to the log if in diagnostic mode
	if ($diagnostic_on == 1)
	{
		&write_log($LOG_NAME, $MAX_SIZE, "rws5.pm", "piping", "text = " . $text, $thread_ID, 0);
	}

	return $text;
}

########################################################################################
# 	FUNCTION THAT SENDS A SUBMISSION EMAIL TO THE PASSED EMAIL ADDRESS	       #	
#	USE: &SendEmailNotification($email_address, $display_hidden)         	       #		
########################################################################################
sub SendEmailNotification()
{
	#get the passed email address
	$sendto_address = $_[0];

	#see if we have a script call or a branching call (branching calls do not display hidden questions)
	$display_hidden = $_[1];

	#add to the log if in diagnostic mode
	if ($diagnostic_on == 1)
	{
		&write_log($LOG_NAME, $MAX_SIZE, "rws5.pm", "SendEmailNotification", "sendto_address = " . $sendto_address . " && display_hidden = " . $display_hidden, $thread_ID, 1);
	}

	#pipe the email address
	$sendto_address = &piping($sendto_address, 0, 1);

	#make sure a server is defined
	if (($form_configuration{'[MISC]'}{'SMTPServer'} ne '') || ($form_configuration{'[MISC]'}{'SendmailServer'} ne ''))
	{
		#check to make sure there is a from address defined
		if($form_configuration{'[MISC]'}{'AdminAddress'} ne '')
		{
			#add the confirmation data to the email body
			$email_body = &construct_email_body($display_hidden);												

			#set the email call depending on the type of email in the setting
			if ($form_configuration{'[MISC]'}{'EmailMethod'} eq "SMTP")
			{
				$email_call = &smtp_mail($sendto_address,$form_configuration{'[MISC]'}{'AdminAddress'},"Automated Mailing - Form Submission [" . $form_configuration{'[MISC]'}{'FormName'} . "]",$form_configuration{'[MISC]'}{'SMTPServer'},$form_configuration{'[MISC]'}{'PortNumber'},$email_body, "0", $form_configuration{'[MISC]'}{'SMTPUsername'}, $form_configuration{'[MISC]'}{'SMTPPassword'});
			}

			else
			{
				$email_call = &send_mail($form_configuration{'[MISC]'}{'SendmailServer'}, $sendto_address, $form_configuration{'[MISC]'}{'AdminAddress'}, "Automated Mailing - Form Submission [" . $form_configuration{'[MISC]'}{'FormName'} . "]", $email_body);											
			}

			#if the email was successful, add a successful log record													
			if($email_call)
			{
				&add_log_record('submission email (' . $sendto_address . ')','successful');
			}
			#otherwise add a failed log record
			else
			{
				&add_log_record('submission email (' . $sendto_address . ')','failed');
			}
		}
		#if there was no from address, add the failed log entry
		else
		{
			&add_log_record('submission email (' . $sendto_address . ')','failed (no admin address)');
		}
	}
	#if there was no server defined, add the failed log entry
	else
	{
		&add_log_record('submission email (' . $sendto_address . ')','failed (no server name)');
	}

	#add to the log if in diagnostic mode
	if ($diagnostic_on == 1)
	{
		&write_log($LOG_NAME, $MAX_SIZE, "rws5.pm", "SendEmailNotification", "None", $thread_ID, 0);
	}

	return 1;
}

########################################################################################
# 	FUNCTION THAT DOES BINARY BYTE BASE64 ENCODING FOR AUTHENTICATION	       #	
#	USE: &BinaryEncoding($string)	   		          	       #		
########################################################################################
sub BinaryEncoding()
{
	#get the passed string to encode
	$temp_string = $_[0];

	#add to the log if in diagnostic mode
	if ($diagnostic_on == 1)
	{
		&write_log($LOG_NAME, $MAX_SIZE, "rws5.pm", "BinaryEncoding", "temp_string = " . $temp_string, $thread_ID, 1);
	}

	my $hex_number = "";

	#unpack the string
	my $temp_hex = unpack('H*', "$temp_string"); 
				
	#determine the length of the string (for encoding purposes)
	my $hex_len = length($temp_hex); 
	my $start = 0; 
 
	#encode the binary bytes in base64
	while ($start < $hex_len) 
	{ 
    		$hex_number .= substr($temp_hex,$start,2); 
    		$start += 2; 
	}

	#add to the log if in diagnostic mode
	if ($diagnostic_on == 1)
	{
		&write_log($LOG_NAME, $MAX_SIZE, "rws5.pm", "BinaryEncoding", "hex_number = " . $hex_number, $thread_ID, 0);
	}

	return $hex_number;
}