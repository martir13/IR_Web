########################################################################################
# Remark Web Survey Utilities Script          Version 5.2.0	  	               #
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
########################################################################################
#use CGI qw/:standard :html3/;
1;

########################################################################################
# 	FUNCTION THAT CONVERTS A STRING TO LEGAL CHARS 				       #
#	USE: $RETURN_STRING = &convert_string($STRING);       		               #
########################################################################################
sub convert_string
{
	my $string = $_[0];

	#add to the log if in diagnostic mode
	if ($diagnostic_on == 1)
	{
		&write_log($LOG_NAME, $MAX_SIZE, "rwsutils5.pm", "convert_string", "string = " . $string, $thread_ID, 1);
	}

	$string =~ s/ /_/g;
	$string =~ s/\%/_/g;
	$string =~ s/\?/_/g;
	
	#add to the log if in diagnostic mode
	if ($diagnostic_on == 1)
	{
		&write_log($LOG_NAME, $MAX_SIZE, "rwsutils5.pm", "convert_string", "string = " . $string, $thread_ID, 0);
	}
	
	return ($string);
}

########################################################################################
# 	FUNCTION PARSES A QUERY STRING AND RETURS REQUESTED PARAMETER 		       #	
#	USE: $val = &get_query_parameter($param);	       	       		       #		
########################################################################################
sub get_query_parameter
{
	my $param = $_[0];
	my $query_string = "";
	my @query_items = ();
	my $query = "";
	my $key = "";
	my $value = "";
	my $req_val = "";

	#add to the log if in diagnostic mode
	if ($diagnostic_on == 1)
	{
		&write_log($LOG_NAME, $MAX_SIZE, "rwsutils5.pm", "get_query_parameter", "param = " . $param, $thread_ID, 1);
	}
				
	#get the query string	
	$query_string = $ENV{'QUERY_STRING'};
	if($query_string ne '')
	{
	 	#split the query string into (key, value) pairs
		@query_items = split (/\&/, $query_string);	

		foreach $query (@query_items)
		{
			($key,$value) = split (/\=/, $query);

			#switch case to validate special instances - right now just UID
			#for UIDs, check the UID
			SWITCH: 
			{
			if ($key eq "UID") {$value = &check_valid_uid($value); last SWITCH };
			}

			#if it is an image file, unescape the characters first
			SWITCH:
			{
			if ($key eq "IMAGE")
			{
				$value =~ s/%([A-Fa-f0-9][A-Fa-f0-9])/pack("c", hex($1))/ge;
				$value =~ s/([\+\t\n])/ /g;
				last SWITCH
			}
			}			

			if(uc $key eq $param)
			{
				$req_val = $value;
				last;
			}		
		}	
	}

	#validate the query string input
	$req_val = &validate_input($req_val);

	#add to the log if in diagnostic mode
	if ($diagnostic_on == 1)
	{
		&write_log($LOG_NAME, $MAX_SIZE, "rwsutils5.pm", "get_query_parameter", "req_val = " . $req_val, $thread_ID, 0);
	}

	return($req_val);
}

########################################################################################
# 	FUNCTION THAT READS A CONFIGURATION FILE 				       #
#	USE: %RETURN_HASH = &read_config($CONFIG_FILE,$HEADERS);                       #
########################################################################################
sub read_config
{	
	#variable holding parameter data
	my $file_name = $_[0];

	#variable holding parameter data
	my $tmp_headers = $_[1];

	#add to the log if in diagnostic mode
	if ($diagnostic_on == 1)
	{
		&write_log($LOG_NAME, $MAX_SIZE, "rwsutils5.pm", "read_config", "file_name = " . $file_name . " && tmp_headers = " . $tmp_headers, $thread_ID, 1);
	}

	#local variables
	my $config_input = "";
	my $section = "";	
	my $key_name = "";
	my $key_value = "";
	my %tmp_configuration = ();

	#check to see if the config file exists
	if (-e $file_name)
	{
		#open the config file and set the config file handle
		open (CONFIG, $file_name) || die &general_error_screen('File Error', '<B>Module:</B> RWSUtils<BR><B>Line:</B> ' . __LINE__ . '<BR><B>Details:</B> <I>[' . $file_name . ']</I> ' . $! . '.'); 
	}
	else
	{
		&general_error_screen('File Error', '<B>Module:</B> RWSUtils<BR><B>Line:</B> ' . __LINE__ . '<BR><B>Details:</B> <I>' . $file_name . '</I> does not exist on the system.');
		die;
	}
	
	#loop thru setting $config_input to the next line of the file
	while (defined ($config_input = <CONFIG>))
	{
		#remove the line feed from the data
		chomp $config_input;
		
		#remove the carriage return from the data
		$config_input =~ s/\r//g;

		#make sure we have data
		next if $config_input =~ /^\s*$/;

		#read file WITH headers '[HEADERS]'
		if($tmp_headers != 0)
		{
			#check for opening and closing brackets
			if (($config_input =~ /^\[/) && ($config_input =~ /\]$/) && ($config_input !~ /\=/))
			{
				#store the current configuration section
				$section = $config_input;
			}
			else
			{
				#make sure there exists an = sign
				if ($config_input =~ /\=/)
				{
					#store key-value pair
					($key_name,$key_value) = split (/\=/,$config_input,2);

					#assign the key-value pairs to the section hash
					$tmp_configuration{$section}{$key_name} = $key_value;
				}
			}
		}
		
		#else no headers
		else
		{
			#make sure there exists an = sign
			if ($config_input =~ /\=/)
			{
				#store key-value pair
				($key_name,$key_value) = split (/\=/,$config_input);

				#assign the key-value pairs to the section hash
				$tmp_configuration{$key_name} = $key_value;
			}
		}		
	}

	#close the config file after use
	close (CONFIG) || die &general_error_screen('File Error', '<B>Module:</B> RWSUtils<BR><B>Line:</B> ' . __LINE__ . '<BR><B>Details:</B> <I>[' . $file_name . ']</I> ' . $! . '.');
	
	#add to the log if in diagnostic mode
	if ($diagnostic_on == 1)
	{
		&write_log($LOG_NAME, $MAX_SIZE, "rwsutils5.pm", "read_config", "None", $thread_ID, 0);
	}

	#return the config hash
	return	(%tmp_configuration);
}

########################################################################################
# 	FUNCTION THAT WRITES A HASH TO A CONFIGURATION FILE			       #
#	USE: &write_config(\%ORIGINAL_HASH,$CONFIG_FILE,$HEADERS);		       #	
########################################################################################
sub write_config
{
	#local variables referencing passed in data - holds the original hash
	my %write_hash = %{$_[0]}; 	
	
	#local variables referencing passed in data - holds the file name	
	my $tmp_file = $_[1];

	#local variables referencing passed in data - determines if headers are used	
	my $tmp_headers = $_[2];

	#add to the log if in diagnostic mode
	if ($diagnostic_on == 1)
	{
		&write_log($LOG_NAME, $MAX_SIZE, "rwsutils5.pm", "write_config", "tmp_file = " . $tmp_file . " && tmp_headers = " . $tmp_headers, $thread_ID, 1);
	}

	#local variables
	my $key_index = "";
	my $key_value = "";

	#open the config file and set the config file handle
	open (CONFIG, ">$tmp_file") || die &general_error_screen('File Error', '<B>Module:</B> RWSUtils<BR><B>Line:</B> ' . __LINE__ . '<BR><B>Details:</B> <I>[' . $tmp_file . ']</I> ' . $! . '.');
	
	#if we are to store header sections '[HEADER]'
	if ($tmp_headers != 0)
	{
		#write the sections and the key-value pairs in the hash
		foreach $key_index (keys %write_hash)
		{
			#print the section header of the hash
			print CONFIG "$key_index\n";
			
			#loop thru writing the key-value pairs
			foreach $key_value (keys %{$write_hash{$key_index}})
			{	
				my $clean_str = $key_value;
				#$clean_str =~ s/\$/\$/g;
				print CONFIG "$clean_str=$write_hash{$key_index}{$key_value}\n";
			}
			print CONFIG "\n";
		}
	}

	#no headers, just key=value pairs
	else
	{	
		#loop thru writing the key-value pairs
		foreach $key_index (keys %write_hash)
		{			
			print CONFIG "$key_index=$write_hash{$key_index}\n";
		}
		print CONFIG "\n";
	}

	#close the config file after use
	close (CONFIG) || die &general_error_screen('File Error', '<B>Module:</B> RWSUtils<BR><B>Line:</B> ' . __LINE__ . '<BR><B>Details:</B> <I>[' . $tmp_file . ']</I> ' . $! . '.');
	
	#set the file permissions
	chmod (0600, $tmp_file);

	#add to the log if in diagnostic mode
	if ($diagnostic_on == 1)
	{
		&write_log($LOG_NAME, $MAX_SIZE, "rwsutils5.pm", "write_config", "string = " . $string, $thread_ID, 0);
	}

	#return success
	return (1);
}

########################################################################################
# 	FUNCTION THAT GENERATES A UID STRING			     		       #	
#	USE: $uid = &generate_uid;			   			       #		
########################################################################################
sub generate_uid
{
	my $ip_address = $ENV{'REMOTE_ADDR'};
	
	#remove non digits from the IP address
  	$ip_address =~ s/\W*//g;
	$ip_address =~ s/[A-Za-z]*//g;

	#generate a random value using the current time
	srand($$|time);
  	
	return unpack "H*", pack "Nnn", int(rand($ip_address + time)), int(rand($$)), int(rand(time));
}

########################################################################################
# 	FUNCTION THAT STORES THE SUBMITTED POST DATA TO A HASH	       		       #	
#	USE: @RETURN = &store_post_data();				       	       #		
########################################################################################
sub store_post_data
{
	
	my $buffer = "";
	my $element = "";	
	my $key ="";
	my $value = "";
	my @data = ();
	my %hash = ();	

	#add to the log if in diagnostic mode
	if ($diagnostic_on == 1)
	{
		&write_log($LOG_NAME, $MAX_SIZE, "rwsutils5.pm", "store_post_data", "None", $thread_ID, 1);
	}

	if ($ENV{'REQUEST_METHOD'} eq 'POST') 
	{
		read(STDIN, $buffer, $ENV{'CONTENT_LENGTH'});
		close STDIN;
		@data = split(/&/, $buffer);

		#cycle through each CGI variable
		foreach $element (@data)
		{
			#split the lines 'key=value' into (key, value) pairs
			($key, $value) = split (/=/, $element);

			#convert all binhexed special characters into their appropriate symbols
			$key =~ s/%([A-Fa-f0-9][A-Fa-f0-9])/pack("c", hex($1))/ge;
			$value =~ s/%([A-Fa-f0-9][A-Fa-f0-9])/pack("c", hex($1))/ge;

			#convert the '+' signs into spaces as per standard CGI stuff
			$key =~ s/([\+\t\n])/ /g;
			$value =~ s/([\+\t\n])/ /g;
			
			#or we can do the following	
			#$value =~ tr/+/ /;
			#$value =~ s/%([a-fA-F0-9][a-fA-F0-9])/pack("C", hex($1))/eg;
			
			#run the submitted data validation
			$value = &validate_submitted($key, $value);
			
			#determine if we are dealing with a multi-list alter the keys to account for same names
			if($key =~ /_RWS_MPD/)
			{ 
				$hash{$key . '-' . $value} = $value;
			}
			else
			{ 
				$hash{$key} = $value;	
			}
		}
	}
	else
	{
		#return a failure
		return (0);
	}

	#add to the log if in diagnostic mode
	if ($diagnostic_on == 1)
	{
		&write_log($LOG_NAME, $MAX_SIZE, "rwsutils5.pm", "store_post_data", "None", $thread_ID, 0);
	}
	
	#return success, by returning hash
	return %hash;
}

########################################################################################
# 	FUNCTION THAT RETURNS A HASH OF DATA FROM BOTH GET / POST METHODS     	       #
#	USE: %RETURN_HASH = &store_form_data($CGI_Object);					       #	
########################################################################################
sub store_cgi_data
{
	#local variables
	my $cgi = $_[0];
	my $key = "";
	my $val = "";
	my @parameters = ();
	my %data_hash = ();

	#add to the log if in diagnostic mode
	if ($diagnostic_on == 1)
	{
		&write_log($LOG_NAME, $MAX_SIZE, "rwsutils5.pm", "store_cgi_data", "cgi = " . $cgi, $thread_ID, 1);
	}

	#store all the form keys in an array
	@parameters = $cgi->param;

	#loop thru the keys writing the key=value hash
	foreach $key (@parameters)
	{					
		if($key =~ /_RWS_MPD/)
		{
			#get the value from the form data
			$val = $cgi->param($key);

			#store the form data hash
			$data_hash{$key  . '-' .$val} = $val;
		}
		else
		{
			#get the value from the form data
			$val = $cgi->param($key);

			#store the form data hash
			$data_hash{$key} = $val;
		}

	#run the submitted data validation
	$val = &validate_submitted($key, $val)

	}

	#add to the log if in diagnostic mode
	if ($diagnostic_on == 1)
	{
		&write_log($LOG_NAME, $MAX_SIZE, "rwsutils5.pm", "store_cgi_data", "None", $thread_ID, 0);
	}
	return (%data_hash);
}

########################################################################################
# 	FUNCTION THAT WRITES OUT HTML TO THE BROWSWER 		       		       #	
#	USE: &display_html($HTML_DATA);					       	       #		
########################################################################################
sub display_html
{
	my $output_text = $_[0];

	#add to the log if in diagnostic mode
	if ($diagnostic_on == 1)
	{
		&write_log($LOG_NAME, $MAX_SIZE, "rwsutils5.pm", "display_html", "None", $thread_ID, 1);
	}

	print "Content-type: text/html\n\n";
	print "$output_text";

	#add to the log if in diagnostic mode
	if ($diagnostic_on == 1)
	{
		&write_log($LOG_NAME, $MAX_SIZE, "rwsutils5.pm", "display_html", "None", $thread_ID, 0);
	}

	return 1;
}

########################################################################################
# 	FUNCTION THAT RETURNS FULL PATH  #
#	USE: $FULL_PATH = &return_full_path($path,$file);					       	       #		
########################################################################################
sub return_full_path
{
	my $tmp_path = $_[0];
	my $tmp_file = $_[1]; 	
 	my $tmp_full_path = "";

	#add to the log if in diagnostic mode
	if ($diagnostic_on == 1)
	{
		&write_log($LOG_NAME, $MAX_SIZE, "rwsutils5.pm", "return_full_path", "tmp_path = " . $tmp_path . " && tmp_file = " . $tmp_file, $thread_ID, 1);
	}

  	#construct full path and make sure there is not already a slash at the end of the path
	if (($tmp_path =~ /\//) && !($tmp_path =~ /\/$/))
	{
		$tmp_full_path = $tmp_path . "/" . $tmp_file;
	}
	elsif(($tmp_path =~ /\\/) && !($tmp_path =~ /\\$/))
	{
		$tmp_full_path = $tmp_path . "\\" . $tmp_file;
	}
	else
	{
		$tmp_full_path = $tmp_path . $tmp_file;
	}

	#add to the log if in diagnostic mode
	if ($diagnostic_on == 1)
	{
		&write_log($LOG_NAME, $MAX_SIZE, "rwsutils5.pm", "return_full_path", "tmp_full_path = " . $tmp_full_path, $thread_ID, 0);
	}

	return $tmp_full_path;
}

########################################################################################
# 	FUNCTION THAT VALIDATES AN EMAIL ADDRESS			       	       #	
#	USE: &validate_email_address($address);					       #		
######################################################################################## 
sub validate_email_address
{
	my $mail_address = $_[0];

	#add to the log if in diagnostic mode
	if ($diagnostic_on == 1)
	{
		&write_log($LOG_NAME, $MAX_SIZE, "rwsutils5.pm", "validate_email_address", "mail_address = " . $mail_address, $thread_ID, 1);
	}

	if ($mail_address eq '')
	{
		return(0);
	}
	elsif ($mail_address =~ /^([a-zA-Z0-9_\-\.]+)@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.)|(([a-zA-Z0-9\-]+\.)+))([a-zA-Z].*?|[0-9]{1,3})(\]?)$/)
	{
		#add to the log if in diagnostic mode
		if ($diagnostic_on == 1)
		{
			&write_log($LOG_NAME, $MAX_SIZE, "rwsutils5.pm", "validate_email_address", "Success", $thread_ID, 0);
		}
		return(1); 
	}
	#add to the log if in diagnostic mode
	if ($diagnostic_on == 1)
	{
		&write_log($LOG_NAME, $MAX_SIZE, "rwsutils5.pm", "validate_email_address", "Failure", $thread_ID, 1);
	}
	return(0);
}

########################################################################################
# 	FUNCTION THAT SENDS EMAIL PASSING IN A COMMA DELIMITED STRING       	       #	
#	USE: &smtp_mail(TO,From,Subj,SMTP FQDN,Port,Msg,HTML (defined, undefined));       #		
######################################################################################## 

sub smtp_mail 
{
	use Socket;

	my $code = "";
	my $authenticated = "";
	my %config_hash = "";
	my $rws_config_file = "";

	# Retrieve email parameters
	local ($to, $from, $subject, $them, $port, $message, $html, $user, $pass, $smtp_test_local) = @_;
	local $a = '';

	#add to the log if in diagnostic mode
	if ($diagnostic_on == 1)
	{
		&write_log($LOG_NAME, $MAX_SIZE, "rwsutils5.pm", "smtp_mail", "to = " . $to . " && from = " . $from . " && subject = " . $subject . " && them " . $them . " && port = " . $port . " && message = " . $message . " && html = " . $html . " && user = " . $user . " && pass = " . $pass, $thread_ID, 1);
	}

	#convert directional apostrophes and quotes
	$message =~ s/\xe2\x80\x99/\'/gs;
 	$message =~ s/\xe2\x80\x98/\'/gs;
 	$message =~ s/\xe2\x80\x9c/\"/gs;
 	$message =~ s/\xe2\x80\x9d/\"/gs;

	#unescape out < and > for the to address
	$to =~ s/\&lt\;/\</g;
	$to =~ s/\&gt\;/\>/g;
	$to =~ s/\&quot\;/\"/g;

	if ($to !~ /([0-9a-zA-Z]([-+\w]*|(\.?[-+\w]*)[0-9a-zA-Z])*\@(([0-9a-zA-Z][-\w]*)*[0-9a-zA-Z]\.)+[a-zA-Z]{2,9})/)
	{
		return(0);
	}

	#unescape out < and > for the from address
	$from =~ s/\&lt\;/\</g;
	$from =~ s/\&gt\;/\>/g;
	$from =~ s/\&quot\;/\"/g;

	#read in the config file so we can see if an IP address is defined
	$rws_config_file = &return_full_path($config_dir,'rwsad5.cfg');
	%config_hash = &read_config($rws_config_file,1);

	# Initialize vars
	$ENV{'SERVER_ADDR'} ='LOCALHOST' if (!defined $ENV{'SERVER_ADDR'});
	$servername = $ENV{'SERVER_NAME'};
	$servername = $ENV{'SERVER_ADDR'} if(!defined $ENV{'SERVER_NAME'});
	$localhost = $ENV{'SERVER_NAME'} if(defined $ENV{'SERVER_NAME'});

	#if defined in the config file, use that IP
	if ($config_hash{'[Defaults]'}{'LocalIP'} ne "")
	{
		$localhost = $config_hash{'[Defaults]'}{'LocalIP'};
	}
	
	$port = 25 if($port < 1);

	local $sockaddr = 'S n a4 x8';

	# split up the "to" names for multiple recipients
	$to =~ s/\,/\;/g;
	@to = split(';',$to);

	# Get socket information
	local $proto = getprotobyname('tcp');
	local $port = getservbyname($port,'tcp') unless $port =~ /^\d+$/;;
	#if defined in the config file, use that IP
	if ($smtp_test_local ne "")
	{
		local $thisaddr = gethostbyname($smtp_test_local);
	}
	else
	{
		local $thisaddr = gethostbyname($localhost);
	}
	local $thataddr = gethostbyname($them);
	local $this = pack($sockaddr, PF_INET, 0, $thisaddr);
	local $that = pack($sockaddr, PF_INET, $port, $thataddr);

	# Open a socket
	if (! socket(S, PF_INET, SOCK_STREAM, $proto)) { 
		if ($html ne "0") {
			print "Content-type: text/html\n\n";
			print "<HTML><HEAD><TITLE>SMTP Test Restult</TITLE></HEAD>\n";
			print "<BODY><H2>SMTP Test Result</H2><P><FONT FACE='Verdana,Arial,Helvetica' SIZE=2><B>Socket Open Failed</B></P>\n";
			print "<P>Unable to open a socket.</P>\n";
			print "<P><DIR>Error: $!<BR></DIR>\n";
			print "<DIR>Protocol: $proto<P></DIR></P>\n";
			#if the HTML is set to 1, we have the test script calling, link back to the test script
			if ($html eq "1")
			{
				print "<p><a href=\"rwstest5.pl\">Return</a> to the test script.</a></PRE></DIR></FONT></BODY></HTML>";
			}
			#if the HTML is set to 2, we have the admin script, link back to diagnostics tab
			elsif ($html eq "2")
			{
				print "<p><a href=\"" . $admin_script . "?UID\=" . $session_uid . "&NAV=Diagnostics\">Return</a> to the diagnostics tab.</a></PRE></DIR></FONT></BODY></HTML>";
			}
			print "</FONT></BODY></HTML>";
			exit;
		};
		return(0);
	};

	# Bind to local system
	if (! bind(S, $this)) {

		# If first attempt fails, try localhost
		local $thisaddr = gethostbyname('localhost');
		local $this = pack($sockaddr, PF_INET, 0, $thisaddr);

		if (! bind(S, $this)) {
			if ($html ne "0") {
				print "Content-type: text/html\n\n";
				print "<HTML><HEAD><TITLE>SMTP Test Result</TITLE></HEAD>\n";
				print "<BODY><H2>SMTP Test Result</H2><P><FONT FACE='Verdana,Arial,Helvetica' SIZE=2><B>Bind Failed</B><P>\n";
				print "<P>The SMTP Test failed because the script was unable to bind to local system: $servername. The most common cause of this is defining your local IP address to an address not associated to the script server. Please double-check the local IP and try again.</P>\n";
				print "<P><DIR>Error: $!</DIR></P>\n";
				#if the HTML is set to 1, we have the test script calling, link back to the test script
				if ($html eq "1")
				{
					print "<p><a href=\"rwstest5.pl\">Return</a> to the test script.</a></PRE></DIR></FONT></BODY></HTML>";
				}
				#if the HTML is set to 2, we have the admin script, link back to diagnostics tab
				elsif ($html eq "2")
				{
					print "<p><a href=\"" . $admin_script . "?UID\=" . $session_uid . "&NAV=Diagnostics\">Return</a> to the diagnostics tab.</a></PRE></DIR></FONT></BODY></HTML>";
				}
				print "</FONT></BODY></HTML>";
				exit;
			};
			return(0);
		};
	};

	# Connect to SMTP server
	if (! connect(S, $that)) {
		if ($html ne "0") {
			print "Content-type: text/html\n\n";
			print "<HTML><HEAD><TITLE>SMTP Test Result</TITLE></HEAD>\n";
			print "<BODY><H2>SMTP Test Result</H2><P><FONT FACE='Verdana,Arial,Helvetica' SIZE=2><B>Connect Failed</B></P>\n";
			print "<P>The SMTP failed because the script was unable to connect to remote system: $them, Port: $port. The most common causes of this is either having an invalid SMTP server address or port, using a Local IP address that is assigned to a different network than the SMTP server address or having an SMTP server improperly configured to relay from your script server. Please check both server addresses and try again. If it still does not work, please contact your mail server administrator to ensure it is properly configured to allow relays from your web server.</P>\n";
			print "<P><DIR>Error: $!</DIR></P>\n";
			#if the HTML is set to 1, we have the test script calling, link back to the test script
			if ($html eq "1")
			{
				print "<p><a href=\"rwstest5.pl\">Return</a> to the test script.</a></PRE></DIR></FONT></BODY></HTML>";
			}
			#if the HTML is set to 2, we have the admin script, link back to diagnostics tab
			elsif ($html eq "2")
			{
				print "<p><a href=\"" . $admin_script . "?UID\=" . $session_uid . "&NAV=Diagnostics\">Return</a> to the diagnostics tab.</a></PRE></DIR></FONT></BODY></HTML>";
			}
			print "</FONT></BODY></HTML>";
			exit;
		};
		return(0);
	};

	# Construct carriage return line feed sequence (required by MS Exchange Server)
	my $crlf = pack ('c', 13) . pack ('c', 10);

	# Set Socket to auto-flush output
	select(S);
	$| = 1;

	# Set default file handle back to standard out
	select(STDOUT);

	# Retrieve SMTP greeting
	$a = <S>;

	# Reply to greeting prompt
	print S "EHLO ${servername}$crlf";
	$a .= "EHLO ${servername}\n";
	#sysread(S, $Response, 1024); #Read what the server says

	while ($response !~ /^250\ /)
	{
		$response = <S>;
		$a .= $response;
	}
	 

	#if username, password are defined and the base64 module is available
	if (($user ne "") && ($pass ne "") && (eval "use MIME::Base64 qw(encode_base64 decode_base64); 1")) 
	{

		#Set a flag for log purposes
		$authenticated = 'denied';

		if (eval "use Digest::HMAC_MD5 qw(hmac_md5 hmac_md5_hex); 1")
		{
			#Request CRAM-MD5 authentication, store the response in $response
			print S "AUTH CRAM-MD5$crlf";
			$a .= "AUTH CRAM-MD5$crlf\n";
			$response = <S>;
			$a .= "$response\n";

			#split the response to get the response code into $code and the challenge ticket in $text 
			($code, $text) = split(' ', $response, 2);
		}

		#if we come back with a 334 response code, send the authentication informaiton
		if ($code =~ m/^334/) 
		{	
			#decode the challenge ticket
			$a .= decode_base64($text) . "\n";

			#Encode in MD5 the authentication using the challenge ticket
			$login = &encode_cram_md5($text, $user, $pass);

			#send the login information
			print S "$login$crlf";
			$response = <S>;
			$a .= "$login$crlf";
			$a .= $response;

			#if we get a 235 response, it is authenticated
			if ($response =~ /^235/)
			{
				$authenticated = "successful";
			}

		}

		if (($code !~ m/^334/) || ($response =~ /^535/)) 
		{
			#if the SSL modules are installed on the machine, try to make a secure tunnel
			if ((eval "use IO::Socket::SSL; 1") && (eval "use Net::SSLeay; 1") && ($USE_STARTTLS == 1)) 
			{

				# Request STARTTLS
				print S "STARTTLS$crlf";
				$a .= "STARTTLS$crlf\n";
				$a .= <S>;     

				# Do Net::SSLeay initialization
				Net::SSLeay::load_error_strings();
				Net::SSLeay::SSLeay_add_ssl_algorithms();
				Net::SSLeay::randomize();

				if (! IO::Socket::SSL::socket_to_SSL(<S>, SSL_version => 'SSLv3 TLSv1'))
				{
					die ("STARTTLS: ".IO::Socket::SSL::errstr()."\n"); 
				}

				$a .= <S>;
	
				# Reply to greeting prompt
				print S "EHLO ${servername}$crlf";
				$a .= "EHLO ${servername}\n";
				sysread(S, $Response, 1024); #Read what the server says
				$a .= $response;
			}  

			# Request LOGIN authentication
			print S "AUTH LOGIN$crlf";
			$auth_response = <S>;
			$a .= "AUTH LOGIN$crlf";
			$a .= $auth_response;
	
			# Check to see if server accepts AUTH LOGIN
			if ($auth_response =~ m/^334/) 
			{
				# Send Encoded base64 Username
				$encoded_user = encode_base64 ($user, "");
				print S "$encoded_user$crlf";

				$a .= "$encoded_user$crlf";
				$a .= <S>;

				# Send Encoded base64 Password
				$encoded_pass = encode_base64 ($pass, "");

				print S "$encoded_pass$crlf";
				$a .= "$encoded_pass$crlf";
				$response = <S>;
				$a .= $response;

				#if it responds with a 235 response, authentication was successful
				if ($response =~ m/^235/)
				{
					$authenticated = 'successful';
				}
			}

			else 
			{

				# Request PLAIN authentication
				print S "AUTH PLAIN$crlf";
				$auth_response = <S>;
				$a .= "AUTH PLAIN$crlf";
				$a .= $auth_response;

				# Check to see if server accepts AUTH PLAIN
				if ($auth_response =~ m/^334/) 
				{	
	
					# Send Encoded base64 login
					$login = "$user\0$user\0$pass";
					$encoded_login = encode_base64 ($login, "");
					print S "$encoded_login$crlf";
					$a .= "$encoded_login$crlf";
					$response = <S>;
					$a .= $response;

					#if the response is accepted, mark it in the flag
					if ($response =~ m/^235/)
					{
						$authenticated = 'successful';
					}
				}
			}
		}
	}

	#set a smtp from to deal with spaces if they are found
	$smtp_from = $from;

	#check to see if it is just the email address and add brackets around it if it doesn't have it
	if (($smtp_from !~ /\s/) && ($smtp_from !~ /\"/) && ($smtp_from !~ /(\<.*?\>)/))
	{
		$smtp_from =~ s/(.*)/\<$1\>/;		
	}
	$smtp_from =~ s/(\".*?\").*?(\<.*?\>)/$1$2/;

	print S "MAIL FROM: $smtp_from$crlf";
	$a .= "MAIL FROM: " . $smtp_from . "\n";
	$a .= <S>;

	#set a smtp to to deal with spaces if they are found
	@smtp_to = @to;

	#get rid of the space if it is there
	if (($smtp_to[0] !~ /\s/) && ($smtp_to[0] !~ /\"/) && ($smtp_to[0] !~ /(\<.*?\>)/))
	{
		$smtp_to[0] =~ s/(.*)/\<$1\>/;		
	}
	$smtp_to[0] =~ s/(\".*?\").*?(\<.*?\>)/$1$2/;

	print S "RCPT TO: $smtp_to[0]$crlf";
	$a .= "RCPT TO: $smtp_to[0]\n";
	$a .= <S>;

	if ($#smtp_to > 0) 
	{
		foreach (1..$#smtp_to) 
		{
			if (($smtp_to[$_] !~ /\s/) && ($smtp_to[$_] !~ /\"/) && ($smtp_to[$_] !~ /(\<.*?\>)/))
			{
				$smtp_to[$_] =~ s/(.*)/\<$1\>/;		
			}
			#get rid of the space if it is there
			$smtp_to[$_] =~ s/(\".*?\").*?(\<.*?\>)/$1$2/;

			print S "RCPT TO: $smtp_to[$_]$crlf";
			$a .= "RCPT TO: $smtp_to[$_]\n";
			$a .= <S>;
		};
	};

	print S "DATA$crlf";
	$a .= "DATA\n";
	$a .= <S>;

	print S "To: $to[0]$crlf";
	if ($#to > 0) { foreach (1..$#to) { print S "Cc: $to[$_]$crlf"; }
	                  }
	print S "From: $from$crlf";
	print S "Subject: $subject$crlf";
	print S "Reply-To: $from$crlf";
	print S "MIME-Version: 1.0$crlf";
	print S "Content-Transfer-Encoding: 8bit$crlf";

	#see if there is a default encoding defined in the form configuration
	if ($form_configuration{'[MISC]'}{"EmailEncoding"} ne "")
	{
		$charset = $form_configuration{'[MISC]'}{"EmailEncoding"};
	}
	#if not, default to utf-8
	else
	{
		$charset = "utf-8";
	}

	print S "Content-Type: text/plain; charset=\"$charset\"$crlf$crlf";
	print S "$message$crlf.$crlf";
	$response = <S>;
	$a .= $response;

	print S "QUIT$crlf";
	$a .= "QUIT\n";
	$a .= <S>;

	close S;

	if ($html ne "0") 
	{
		print "Content-type: text/html\n\n<HTML><HEAD></HEAD><BODY><H2>SMTP Test Result</H2><FONT FACE=\"Verdana,Arial,Helvetica\"><B>SMTP Session Log</B><P><DIR><PRE>";
		print $a;
		if ($authenticated ne "")
		{
			print "Authenticated = " . $authenticated;
		}

		#if the HTML is set to 1, we have the test script calling, link back to the test script
		if ($html eq "1")
		{
			print "<p><a href=\"rwstest5.pl\">Return</a> to the test script.</a></PRE></DIR></FONT></BODY></HTML>";
		}
		#if the HTML is set to 2, we have the admin script, link back to diagnostics tab
		elsif ($html eq "2")
		{
			print "<p><a href=\"" . $admin_script . "?UID\=" . $session_uid . "&NAV=Diagnostics\">Return</a> to the diagnostics tab.</a></PRE></DIR></FONT></BODY></HTML>";
		}
	};

	#if we tried authentication, add a log record
	if (($authenticated ne "") && (html eq "0"))
	{
		&add_log_record('SMTP authentication',$authenticated);
	}

	#if it had a 250 response, it was successful
	if ($response =~ m/^250/)
	{
		#add to the log if in diagnostic mode
		if ($diagnostic_on == 1)
		{
			&write_log($LOG_NAME, $MAX_SIZE, "rwsutils5.pm", "smtp_mail", "Success. Output = " . $a, $thread_ID, 0);
		}
		return(1);
	}
	else
	{
		#add to the log if in diagnostic mode
		if ($diagnostic_on == 1)
		{
			&write_log($LOG_NAME, $MAX_SIZE, "rwsutils5.pm", "smtp_mail", "Failure. Output = " . $a, $thread_ID, 0);
		}
		return(0);
	}
}

########################################################################################
# 	HELPER FUNCTION THAT DOES CRAM-MD5 Encryption				       #
#	USE: &encode_cram_md5($ticket, $username, $password);       	    	       #		
########################################################################################
sub encode_cram_md5
{
	my ($ticket64, $username, $password) = @_;
	my $ticket = decode_base64($ticket64) or
		die ("Unable to decode Base64 encoded string '$ticket64'\n");
	my $password_md5 = hmac_md5_hex($ticket, $password);
	return encode_base64 ("$username $password_md5", "");
}

########################################################################################
# 	FUNCTION THAT RETURNS TIME 						       #
#	USE: &get_time();					       	    	       #		
########################################################################################
sub get_time
{
	my $hour = "";
	my $append = "AM";

	#add to the log if in diagnostic mode
	if ($diagnostic_on == 1)
	{
		&write_log($LOG_NAME, $MAX_SIZE, "rwsutils5.pm", "get_time", "None", $thread_ID, 1);
	}

	#add the time value
	$hour = (localtime)[2];
	if($hour > 12)
	{
		$append='PM';
		$hour = $hour - 12;
	}
	#if it is noon, make sure it is appended with the PM
	elsif ($hour == 12)
	{
		$append='PM';		
	}
	#add to the log if in diagnostic mode
	if ($diagnostic_on == 1)
	{
		&write_log($LOG_NAME, $MAX_SIZE, "rwsutils5.pm", "convert_string", "None", $thread_ID, 0);
	}
	return((($hour > 9) ? $hour : '0' . $hour) . ":" . (((localtime)[1] > 9) ? (localtime)[1] : '0' . (localtime)[1]) . ":" . (((localtime)[0] > 9) ? (localtime)[0] : "0" . (localtime)[0]) . $append);
}

########################################################################################
# 	FUNCTION THAT RETURNS DATE #
#	USE: &get_date();					       	       #		
########################################################################################
sub get_date
{
	my $month = "";
	my $yr = "";

	#add to the log if in diagnostic mode
	if ($diagnostic_on == 1)
	{
		&write_log($LOG_NAME, $MAX_SIZE, "rwsutils5.pm", "get_date", "None", $thread_ID, 1);
	}

	#add the date value
	$month = (localtime)[4]+1; 
	$yr = (localtime)[5]+1900;

	#add to the log if in diagnostic mode
	if ($diagnostic_on == 1)
	{
		&write_log($LOG_NAME, $MAX_SIZE, "rwsutils5.pm", "get_date", "None", $thread_ID, 0);
	}
	
	return ($month . "/" . (localtime)[3] . "/" . $yr);
}

###################################################################################################
# 	FUNCTION THAT DISPLAYS HTML OF A GENERIC SCREEN FILLED WITH PARAMETERS 			   			  #
#	USE: &general_error_screen($title,$msg,$email_address,$backbutton,$data,$back_text,$get);     #		
###################################################################################################
sub general_error_screen
{
	my $html_title = $_[0];
	my $msg_text = $_[1];
	my $email_text = $_[2];
	my $back = $_[3];
	my $data_script = $_[4];
	my $back_text = $_[5];
	my $use_get_action = $_[6];
	my $html_text = "";
	my $replace = "";

	#add to the log if in diagnostic mode
	if ($diagnostic_on == 1)
	{
		&write_log($LOG_NAME, $MAX_SIZE, "rwsutils5.pm", "general_error_screen", "html_title = " . $html_title . " && msg_text = " . $msg_text . " && email_text = " . $email_text, $thread_ID, 1);
	}
			
	$html_text = "<HTML><HEAD>\n";
	$html_text .= "<META HTTP-EQUIV=\"pragma\" CONTENT=\"no-cache\">\n";
	$html_text .= "<TITLE>Remark Web Survey&reg; 5.0</TITLE>\n";
	$html_text .= "</HEAD>\n";											   
	$html_text .= "<BODY TOPMARGIN=20 BGCOLOR=\"#FFFFFF\" TEXT=\"#000000\" LINK=\"#185397\" VLINK=\"#185397\">\n";
	$html_text .= "<P><FONT FACE=\"Verdana,Arial,Helvetica\" SIZE=4><B>@*(html_title)</B></FONT></P>\n";
	$html_text .= "<P><FONT FACE=\"Verdana,Arial,Helvetica\" SIZE=2>@*(msg_text)</FONT></P>\n";
	
	if($email_text ne '')
	{
		$html_text .= "<P><FONT FACE=\"Verdana,Arial,Helvetica\" SIZE=2>If you have any questions regarding this error please contact the <A HREF=\"mailto:@*(email_address)\">form administrator</A>.</FONT></P>\n";	
	}

	if(($back == 1) || ($back == 2))
	{
		if (($use_get_action != 1) && ($back == 1))
		{
			$html_text .= "<FORM NAME=\"RWSADMIN\" ACTION=\"@*(data)@*(form_query)@*(uid)\" METHOD=\"POST\">\n";
		}
		else
		{
			$html_text .= "<FORM NAME=\"RWSADMIN\" ACTION=\"@*(data)@*(form_query)@*(uid)\" METHOD=\"GET\">\n";
		}
		
		#only add the form action input if we are performing a POST (not on sequence error page)
		if (($use_get_action != 1) && ($back != 2))
		{
			$html_text .= "<input type=\"hidden\" id=\"PAGE_KEY\" name=\"PAGE_KEY\" value=\"[error_page]\" />";
			$html_text .= "<INPUT TYPE=\"HIDDEN\" ID=\"FORM_ACTION\" NAME=\"FORM_ACTION\" VALUE=\"BRANCH!\">";
		}
		elsif($back == 2)
		{
			$html_text .= "<INPUT TYPE=\"HIDDEN\" ID=\"FORM\" NAME=\"FORM\" VALUE=\"@*(get_form_query)\">";
			$html_text .= "<INPUT TYPE=\"HIDDEN\" ID=\"UID\" NAME=\"UID\" VALUE=\"@*(get_uid)\">";
		}
		#add the appropriate input types to the form for sequence error page
		else
		{
			$html_text .= "<INPUT TYPE=\"HIDDEN\" ID=\"FORM\" NAME=\"FORM\" VALUE=\"@*(get_form_query)\">";
			$html_text .= "<INPUT TYPE=\"HIDDEN\" ID=\"UID\" NAME=\"UID\" VALUE=\"@*(get_uid)\">";
		}

		#insert the uid into our form '@*()'
		if (($back == 1) || ($back == 2))
		{
			$replace = &get_query_parameter('UID');
		}
		else
		{
			$replace = "";
		}
			
 		$html_text =~ s/\@\*\(uid\)/\&UID\=$replace/g;
 		$html_text =~ s/\@\*\(get_uid\)/$replace/g;

		#insert the uid into our form '@*()'
		$replace = &get_query_parameter('FORM');
		$html_text =~ s/\@\*\(form_query\)/\?FORM\=$replace/g;
		$html_text =~ s/\@\*\(get_form_query\)/$replace/g;

		if($back_text eq '')
		{
			$html_text .= "<BR><CENTER><INPUT TYPE=\"SUBMIT\" NAME=\"BACK\" ID=\"BACK\" VALUE=\"Back\"></CENTER></FORM>"; 
		}
		#add custom back button text
		else
		{
			$html_text .= "<BR><CENTER><INPUT TYPE=\"SUBMIT\" NAME=\"BACK\" ID=\"BACK\" VALUE=\"$back_text\"></CENTER></FORM>";
		}
	}	

	$html_text .= "</BODY></HTML>\n";         

	#insert the title into our form '@*()'
	$html_text =~ s/\@\*\(html_title\)/$html_title/g;
		
	#insert the message/question/confirmation into our form '@*()'
	$html_text =~ s/\@\*\(msg_text\)/$msg_text/g;														
 		
	#if there is a "User Name" <email@email.com> address defined, only use what is in the <>
	if ($email_text =~ /\<(.*?)\>/)
	{
		$email_text = $1;
	}
		
	#insert the email address into form '@*()'
	$html_text =~ s/\@\*\(email_address\)/$email_text/g;

	#insert the data scipt  into form '@*()'
	$html_text =~ s/\@\*\(data\)/$data_script/g;
									   
	&display_html($html_text);

	#add to the log if in diagnostic mode
	if ($diagnostic_on == 1)
	{
		&write_log($LOG_NAME, $MAX_SIZE, "rwsutils5.pm", "general_error_screen", "None", $thread_ID, 1);
	}

	return 1;
}

########################################################################################
# 	FUNCTION THAT REDIRECTS THE BROWSER LOCATION        		       				   #	
#	USE: &browser_redirect($location,$use_cgi,%data_hash);		       		   		   #		
########################################################################################
sub browser_redirect
{
	my $location = $_[0];
	my $use_cgi = $_[1];
	my %cgi_vars = %{$_[2]};
	my $cgi = "";

	#add to the log if in diagnostic mode
	if ($diagnostic_on == 1)
	{
		&write_log($LOG_NAME, $MAX_SIZE, "rwsutils5.pm", "browser_direct", "location = " . $location . " && use_cgi = " . $use_cgi, $thread_ID, 1);
	}

	require CGI;
	$cgi = new CGI;

	$location =~ s/\[\$(\w*?)\]/$cgi_vars{$1}/g;

	#if running on Dos/Windows
	if($use_cgi == 1)
	{
		if ((lc($^O) =~ /win/) || (index($0,'\\') != -1))
		{
			print $cgi->redirect(-uri=>$location, -nph=>1);
		}
		
		#unix does not take the nph parameter
		else
		{
			print $cgi->redirect(-uri=>$location);
		}
	}
	else
	{
		print "Location: $location\n\n";
	}
	#add to the log if in diagnostic mode
	if ($diagnostic_on == 1)
	{
		&write_log($LOG_NAME, $MAX_SIZE, "rwsutils5.pm", "browser_redirect", "None", $thread_ID, 0);
	}
	return(1);
}

########################################################################################
# 	FUNCTION THAT VALIDATES INPUT FOR SECURITY 				       #
#	USE: $VALIDATED_INPUT = &validate_input($STRING);                       #
########################################################################################
sub validate_input
{
	my $string = $_[0];

	#add to the log if in diagnostic mode
	if ($diagnostic_on == 1)
	{
		&write_log($LOG_NAME, $MAX_SIZE, "rwsutils5.pm", "validate_input", "string = " . $string, $thread_ID, 1);
	}

	#if (\/|<>;'":` or .. or \0) are found, string is set to nothing
	if ($string =~ /[\\\/\|\<\>\;\'\"\:\`]|(\.\.)|(\0)/)
	{
		$string = '';
	}

	#add to the log if in diagnostic mode
	if ($diagnostic_on == 1)
	{
		&write_log($LOG_NAME, $MAX_SIZE, "rwsutils5.pm", "validatE_input", "string = " . $string, $thread_ID, 0);
	}
	
	return ($string);
}

########################################################################################
# 	FUNCTION THAT VALIDATES SUBMITTED INPUT FOR SECURITY 			       #
#	USE: $value = &validate_submitted($key, $value);				#
########################################################################################
sub validate_submitted
{
	my $current_key = $_[0];
	my $submitted_value =$_[1];

	#add to the log if in diagnostic mode
	if ($diagnostic_on == 1)
	{
		&write_log($LOG_NAME, $MAX_SIZE, "rwsutils5.pm", "validate_submitted", "current_key = " . $current_key . " && submitted_value = " . $submitted_value, $thread_ID, 1);
	}

	#Switch case to validate data submitted for input
	SWITCH: {

	#validates input if it is a PAGE_KEY or PAGE_NUMBER (used in confirmation page)
	if (($current_key eq 'PAGE_KEY') or ($current_key eq 'PAGE_NUMBER')) {

		#checks to see if page key is in the [lettersdigitsunderscore] format
		if ($submitted_value !~ m/^[\[]\w*[\]]$/)
		{
			&general_error_screen("Invalid Page Key", "This form was submitted using an invalid Page Key");
			exit;
		} last SWITCH };

	#validates input if it is DATANAME key
	if ($current_key eq 'DATANAME') { $submitted_value = validate_input($submitted_value); last SWITCH };
	
	#validates input if it is the FORMNAME
	if ($current_key eq 'FORMNAME') { $submitted_value = validate_input($submitted_value); last SWITCH };

	#validates input if it is 'IMAGEFILE'
	if ($current_key eq 'IMAGEFILE') { $submitted_value = validate_input($submitted_value); last SWITCH };

	#validates input if it is 'TEXTFILE'
	if ($current_key eq 'TEXTFILE') { $submitted_value = validate_input($submitted_value); last SWITCH };
	
	#validates input if it is 'FORM_ACTION'
	if ($current_key eq 'FORM_ACTION') {

		#if it is update, factor out unused harmful characters, leave passwords be and validate every other type of FORM_ACTION
		SWITCH: {
			if ($submitted_value =~ /UPDATE/) { $submitted_value =~ s/[\|\'\"\;\<]//g; last SWITCH };
			if ($submitted_value =~ /CHANGE\_PASSWORD/) { last SWITCH };
			$submitted_value = &validate_input($submitted_value);
		} last SWITCH };

}

	#check to remove any #RULE entries
	$submitted_value = &remove_rule($submitted_value);

	#add to the log if in diagnostic mode
	if ($diagnostic_on == 1)
	{
		&write_log($LOG_NAME, $MAX_SIZE, "rwsutils5.pm", "validate_submitted", "submitted_value = " . $submitted_value, $thread_ID, 0);
	}	
	
	return ($submitted_value);
}

########################################################################################
# 	FUNCTION THAT VERIFIES A UID IS 16-Digits and Hexadecimal		       #
#	USE: $value = &check_valid_uid($UID);			                       #
########################################################################################
sub check_valid_uid
{
	my $current_uid = $_[0];

	#add to the log if in diagnostic mode
	if ($diagnostic_on == 1)
	{
		&write_log($LOG_NAME, $MAX_SIZE, "rwsutils5.pm", "check_valid_uid", "current_uid = " . $current_uid, $thread_ID, 1);
	}

	#verify that it is a 16-digit hexadecimal number
	if ($current_uid !~ /^[\da-fA-F]{16}/ || length($current_uid) != 16)
	{
		&general_error_screen("Invalid UID", "The UID is invalid. Please check your UID and try again.");
		#add to the log if in diagnostic mode
		if ($diagnostic_on == 1)
		{
			&write_log($LOG_NAME, $MAX_SIZE, "rwsutils5.pm", "check_valid_uid", "Failed", $thread_ID, 0);
		}
		exit;
	}

	#add to the log if in diagnostic mode
	if ($diagnostic_on == 1)
	{
		&write_log($LOG_NAME, $MAX_SIZE, "rwsutils5.pm", "check_valid_uid", "Success", $thread_ID, 1);
	}
	return ($current_uid);
}


########################################################################################
# 	FUNCTION THAT VALIDATES DIRECTORIES					       #
#	USE: $directory = &validate_directories($directory);			                       #
########################################################################################
sub validate_directory
{
	my $directory = $_[0];

	#add to the log if in diagnostic mode
	if ($diagnostic_on == 1)
	{
		&write_log($LOG_NAME, $MAX_SIZE, "rwsutils5.pm", "validate_directory", "directory = " . $directory, $thread_ID, 1);
	}

	#strip out dangerous characters (|;'!") 	
	$directory =~ s/[\|\;\'\!\"]//g;

	#add to the log if in diagnostic mode
	if ($diagnostic_on == 1)
	{
		&write_log($LOG_NAME, $MAX_SIZE, "rwsutils5.pm", "validate_directory", "directory = " . $directory, $thread_ID, 0);
	}

	return ($directory);
}


########################################################################################
# 	FUNCTION THAT REMOVES #RULE000# Inputs					       #
#	USE: $string = &remove_rule($string);			                       #
########################################################################################
sub remove_rule
{
	my $submitted_string = $_[0];

	#add to the log if in diagnostic mode
	if ($diagnostic_on == 1)
	{
		&write_log($LOG_NAME, $MAX_SIZE, "rwsutils5.pm", "remove_rule", "submitted_string = " . $submitted_string, $thread_ID, 1);
	}

	#strip out #RULE entries
	$submitted_string =~ s/\#RULE\d*\#//g;

	#add to the log if in diagnostic mode
	if ($diagnostic_on == 1)
	{
		&write_log($LOG_NAME, $MAX_SIZE, "rwsutils5.pm", "remove_rule", "submitted_string = " . $submitted_string, $thread_ID, 1);
	}

	return ($submitted_string);
}

########################################################################################
# 	FUNCTION THAT VALIDATES A PORT NUMBER FOR SOCKET CONNECTIONS		       #
#	USE: $port = &validate_port($port);			                       #
########################################################################################
sub validate_port
{
	my $port = $_[0];

	#add to the log if in diagnostic mode
	if ($diagnostic_on == 1)
	{
		&write_log($LOG_NAME, $MAX_SIZE, "rwsutils5.pm", "validate_port", "port = " . $port, $thread_ID, 1);
	}

	#verify that the port is a whole number (has nothing but digits)
	if ($port =~ /[^\d]/)
	{
		&general_error_screen("Invalid Port", "The specified port is invalid. Please check the port and try again.");

		#add to the log if in diagnostic mode
		if ($diagnostic_on == 1)
		{
			&write_log($LOG_NAME, $MAX_SIZE, "rwsutils5.pm", "validate_port", "Failure", $thread_ID, 0);
		}
		exit;
	}

	#add to the log if in diagnostic mode
	if ($diagnostic_on == 1)
	{
		&write_log($LOG_NAME, $MAX_SIZE, "rwsutils5.pm", "validate_port", "Success", $thread_ID, 0);
	}

	return ($port);
}

########################################################################################
# 	FUNCTION THAT SENDS EMAIL USING SENDMAIL      	      			       #	
#	USE: &send_mail(sendmail_location, to, from, subject, content);            #		
######################################################################################## 
sub send_mail
{
	my $sendmail_location = $_[0];
	my $to = $_[1];
	my $from = $_[2];
	my $subject = $_[3];
	my $content = $_[4];

	#add to the log if in diagnostic mode
	if ($diagnostic_on == 1)
	{
		&write_log($LOG_NAME, $MAX_SIZE, "rwsutils5.pm", "send_mail", "sendmail_location = " . $sendmail_location . " && to = " . $to . " && from = " . $from . " && subject = " . $subject . " && content = " . $content, $thread_ID, 1);
	}

	#convert semicolons to commas for multiple email addresses
	$to =~ s/\;/\,/g;

	#convert directional apostrophes and quotes
	$content =~ s/\xe2\x80\x99/\'/gs;
 	$content =~ s/\xe2\x80\x98/\'/gs;
 	$content =~ s/\xe2\x80\x9c/\"/gs;
 	$content =~ s/\xe2\x80\x9d/\"/gs;

	#open a connection to sendmail, then print the header information
	if (open(SENDMAIL, "|$sendmail_location -t" || die "")) 
	{
		print SENDMAIL "From: " . $from . "\n";
		print SENDMAIL "Subject: " . $subject . "\n";
		print SENDMAIL "To: " . $to . "\n";
		print SENDMAIL "MIME-Version: 1.0\n";
		print SENDMAIL "Content-Transfer-Encoding: 8bit\n";
		print SENDMAIL "Content-Type: text/plain; charset=\"utf-8\"\n\n";
		print SENDMAIL $content;
		close(SENDMAIL);

		#add to the log if in diagnostic mode
		if ($diagnostic_on == 1)
		{
			&write_log($LOG_NAME, $MAX_SIZE, "rwsutils5.pm", "send_mail", "Success", $thread_ID, 0);
		}

		return(1);
	}

	else 
	{
		#add to the log if in diagnostic mode
		if ($diagnostic_on == 1)
		{
			&write_log($LOG_NAME, $MAX_SIZE, "rwsutils5.pm", "send_mail", "Failure", $thread_ID, 0);
		}

		return 0;
	}
}

########################################################################################
# 	FUNCTION THAT SORTS THE CONFIRMATION DATA				       #	
#	USE: sort mysort keys %hash		   		          	       #		
########################################################################################
sub mysort 
{
	#store the reverse hash of the map file
	%lookup_q = reverse %{$form_configuration{'[Map]'}};

	#create an empty hash to store the html values in
	%html_values = ();

	#if these keys have the same QIDs, sort alphabetically
	if ($lookup_q{(split(/\_/,$a))[0]} eq $lookup_q{(split(/\_/,$b))[0]})
	{
		#If there is an HTML value for a checkbox, store that in the html hash
		if ($form_configuration{'[AnswerMap]'}{'[' . (split(/\_/,$a))[0] . '][' . (split(/\_/,$a))[1] . ']'})
		{
			$html_value{$a} = $form_configuration{'[AnswerMap]'}{'[' . (split(/\_/,$a))[0] . '][' . (split(/\_/,$a))[1] . ']'};
		}
		#If there is an HTML value for a multiple-list, store that in the html hash
		elsif ($form_configuration{'[AnswerMap]'}{'[' . (split(/\_/,$a))[0] . '][' . (split(/MPD\-/,$a))[1] . ']'})
		{
			$html_value{$a} = $form_configuration{'[AnswerMap]'}{'[' . (split(/\_/,$a))[0] . '][' . (split(/MPD\-/,$a))[1] . ']'};
		}
		#Otherwise use the value in the key
		else
		{
			$html_value{$a} = $a;
			$html_value{$a} =~ s/([\S\_]*?)\@\*\[(\S*?)\]\*\@//g;
		}

		#If there is an HTML value for a checkbox, store that in the html hash
		if ($form_configuration{'[AnswerMap]'}{'[' . (split(/\_/,$b))[0] . '][' . (split(/\_/,$b))[1] . ']'})
		{
			$html_value{$b} = $form_configuration{'[AnswerMap]'}{'[' . (split(/\_/,$b))[0] . '][' . (split(/\_/,$b))[1] . ']'};
		}
		#If there is an HTML value for a multiple-list, store that in the html hash
		elsif ($form_configuration{'[AnswerMap]'}{'[' . (split(/\_/,$b))[0] . '][' . (split(/MPD\-/,$b))[1] . ']'})
		{
			$html_value{$b} = $form_configuration{'[AnswerMap]'}{'[' . (split(/\_/,$b))[0] . '][' . (split(/MPD\-/,$b))[1] . ']'};
		}
		#Otherwise use the value in the key
		else
		{
			$html_value{$b} = $b;
			$html_value{$b} =~ s/([\S\_]*?)\@\*\[(\S*?)\]\*\@//g;
		}

		lc($html_value{$a}) cmp lc($html_value{$b});
	}

	#otherwise sort by the order of the map
	else
	{
		$lookup_q{(split(/\_/,$a))[0]} cmp $lookup_q{(split(/\_/,$b))[0]};
	}
}	

########################################################################################
# 	FUNCTION THAT STRIPS THE ANSWER IDS FROM ANSWERS			       #
#	USE: $RETURN_STRING = &StripID($STRING);                       #
########################################################################################
sub StripID
{
	my $string = $_[0];

	#add to the log if in diagnostic mode
	if ($diagnostic_on == 1)
	{
		&write_log($LOG_NAME, $MAX_SIZE, "rwsutils5.pm", "StripID", "string = " . $string, $thread_ID, 1);
	}

	$string =~ s/\@\*\[\S*?\]\*\@//g;

	#add to the log if in diagnostic mode
	if ($diagnostic_on == 1)
	{
		&write_log($LOG_NAME, $MAX_SIZE, "rwsutils5.pm", "StripID", "string = " . $string, $thread_ID, 0);
	}
	
	return ($string);
}

########################################################################################
# 	FUNCTION THAT RETURNS THE CURRENT NUMBER OF MINUTES IN TIME		       #	
#	USE: &localtime_in_minutes()	   		          		       #		
########################################################################################
sub localtime_in_minutes()
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
		&write_log($LOG_NAME, $MAX_SIZE, "rwsutils5.pm", "localtime_in_minutes", "date = " . $date, $thread_ID, 1);
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

	#add to the log if in diagnostic mode
	if ($diagnostic_on == 1)
	{
		&write_log($LOG_NAME, $MAX_SIZE, "rwsutils5.pm", "localtime_in_minutes", "num_minutes = " . $num_minutes, $thread_ID, 0);
	}

	return $num_minutes;
}

########################################################################################
# 	FUNCTION THAT WRITES OUT THE LOG FILE (in diagnostic mode)		       #
#	USE: &write_log($log_name, $max_size, $script_name, $function_name, $parameters, $thread_ID, $start_flag);        #
########################################################################################
sub write_log
{
	my $log_name = $_[0];
	my $max_size = $_[1];
	my $script_name = $_[2];
	my $function_name = $_[3];
	my $parameters = $_[4];
	my $thread_ID = $_[5];
	my $start_flag = $_[6];

	#if the log exists
	if (-e $log_name)
	{
		#get the file size
		$file_size = -s $log_name;

		#if the log is too big, delete it	
		if ($file_size > $max_size)
		{
			unlink $log_name;
		}
		$log_text = "";	
	}
	#if it doesn't exist, set the headers
	else
	{
		$log_text = "Thread ID\tFunction\tBegin/End\tScript\tParameters";
	}

	#if this is a function start
	if ($start_flag == 1)
	{
		$log_text .= $thread_ID . "\t" . $function_name . "\tBegin\t" . $script_name . "\t" . $parameters . "\n";
		#$log_text .= "Function Called: " . $function_name . "|Script: " . $script_name . "|Thread ID: " . $thread_ID . "\n";
		#$log_text .= "Parameters: " . $parameters . "\n";
		#$log_text .= "---------------------------------------\n";
	}
	#otherwise this is the end of a function
	else
	{
		$log_text .= $thread_ID . "\t" . $function_name . "\tEnd\t" . $script_name . "\t" . $parameters . "\n";
		#$log_text .= "---------------------------------------\n";
		#$log_text .= "Function Ended: " . $function_name . "|Script: " . $script_name . "|Thread ID: " . $thread_ID . "\n";
		#$log_text .= "Parameters Returned: " . $parameters . "\n";
		#$log_text .= "---------------------------------------\n";
	}

	#open the Log file for appending
	open (LOG, ">>$log_name") || die ("Could not open file. $!");

	#pring the text to the file
	print LOG ($log_text);

	#close the file
	close (LOG);	

	return 1;
}