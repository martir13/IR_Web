
########################################################################################
# Remark Web Survey XML Parsing Script        Version 5.2.0	 	               #
# (C) Copyright 2010     http://www.gravic.com/about/copyrght.html                     #
# Gravic, Inc. http://www.gravic.com/ 						       #
########################################################################################
# COPYRIGHT NOTICE                                                           	       #
# (C) Copyright 2010 Gravic, Inc.            					       #
# All Rights Reserved.                  					       #
#										       #
# Warning: This program is protected by copyright laws and international               #
# treaties. Unauthorized reproduction or distribution of this program, or              #
# any poriton of it, may result in severe civil and criminal penalties and             #
# will be prosecuted to the maximum extent possible under the law.                     #
########################################################################################

#use CGI qw/:standard :html3/;
1;


########################################################################################
# 	FUNCTION THAT READS IN AN XML FILE AND PARSES IT TO A HASH		       			   #
#	USE: $XML_Input = &XMLin($file_name, $keyattribute, $pipe_attribute);              #
########################################################################################
sub read_XML
{
	my $file_name = $_[0];
	my $password_hash = $_[1];
	my %pass_info = {};
	my $file_text;

	#open the source file and set the source file handle
	open (SRC_FILE, $file_name) || die &show_server_error($ERROR_NUM_FILE_ACCESS,"File Access Error",$form_configuration{'[MISC]'}{'ErrorMessageFileAccess'} . " [" . $file_name . "]", __LINE__);

	#read the file into an array 
	@file_data=<SRC_FILE>;

	#loop thru storing the lines
 	foreach $source_line (@file_data)
 	{
		#remove the \n character
 		chomp ($source_line);

		#add the line to the file_text
		$file_text .= $source_line;
	}

	#close the source file because we are finished reading in the key=value pairs
	close (SRC_FILE);

	#set the password flag to 0
	$pass_info{'exists'} = 0;

	#find the password entry
	if ($file_text =~ /<respondent (.*?)hash\=\"(.*?)\"(.*?)\>(.*?)<\/respondent>/)
	{
		#parse though the text, eliminating a tag at a time
		while ($file_text =~ s/<respondent (.*?)hash\=\"(.*?)\"(.*?)\>(.*?)<\/respondent>//)
		{

			$hash_value = $2;

			#if we have our hash
			if ($hash_value eq $password_hash)
			{
				$preceding_text = $1;
				$ending_text = $3;
				$pipe_text = $4;

				$pass_info{'exists'} = 1;
				$pass_info{'pipe_text'} = $pipe_text;

				#go through and sort out all of the key-value pairs
				while ($preceding_text =~ s/(\S*?)\=\"(.*?)\"//)
				{
					#set the key and value
					$key = $1;
					$value = $2;

					#add the key value to the hash
					$pass_info{$key} = $value;		
				}

				#go through and sort out all of the key-value pairs
				while ($ending_text =~ s/(\S*?)\=\"(.*?)\"//)
				{
					#set the key and value
					$key = $1;
					$value = $2;

					#add the key value to the hash
					$pass_info{$key} = $value;		
				}

				#exit the while loop
				last;
			}
		}	
	}
	#check for self-closing tags
	elsif ($file_text =~ /<respondent (.*?)hash\=\"(.*?)\"(.*?)\/\>/)
	{
		#parse though the text, eliminating a tag at a time
		while ($file_text =~ s/<respondent (.*?)hash\=\"(.*?)\"(.*?)\/\>//)
		{
			$hash_value = $2;

			#if we have our hash
			if ($hash_value eq $password_hash)
			{

				$preceding_text = $1;
				$ending_text = $3;

				$pass_info{'exists'} = 1;

				#go through and sort out all of the key-value pairs
				while ($preceding_text =~ s/(\S*?)\=\"(.*?)\"//)
				{
					#set the key and value
					$key = $1;
					$value = $2;

					#add the key value to the hash
					$pass_info{$key} = $value;		
				}

				#go through and sort out all of the key-value pairs
				while ($ending_text =~ s/(\S*?)\=\"(.*?)\"//)
				{
					#set the key and value
					$key = $1;
					$value = $2;

					#add the key value to the hash
					$pass_info{$key} = $value;		
				}

				#exit the loop
				last;

			}
		}	
	}

	return %pass_info;
}

########################################################################################
# 	FUNCTION THAT READS IN AN XML FILE AND PARSES IT TO A HASH		       			   #
#	USE: $pipe_hash = &read_pipe($pipe_text, $pipe_name);              #
########################################################################################
sub read_pipe
{
	my $pipe_text = $_[0];
	my %key_hash = {};
				
	#if there are pipes
	while ($pipe_text =~ /\<(\S*)(.*?)\>(.*?)\<\/\1\>/)
	{		

		#store the attribute
		$third_attribute_name = $1;

		#store the key-value pairs
		$pipe_name_text = $2;
	
		#store the value text between the tags
		$pipe_value = $3;

		#clear out the pipe text
		$pipe_text =~ s/\<(\S*)(.*?)\>(.*?)\<\/\1\>//;
	
		#go through and sort out all of the key-value pairs
		while ($pipe_name_text =~ /(\S*?)\=\"(.*?)\"/)
		{
			#set the key and value
			$key = $1;
			$value = $2;

			#clear out the pipe_name text
			$pipe_name_text =~ s/(\S*?)\=\"(.*?)\"//;

			#store it in the hash
			$key_hash{lc($value)} = $pipe_value;			
		}
	}

	#return the pipe_result
	return %key_hash;
}

########################################################################################
# 	FUNCTION THAT READS IN AN XML FILE AND PARSES IT TO A HASH		       			   #
#	USE: $XML_Input = &XMLin($file_name, $keyattribute, $pipe_attribute);              #
########################################################################################
sub read_fullXML
{
	my $file_name = $_[0];
	my $key_attribute = $_[1];
	my $pipe_attribute = $_[2];
	my $xml_file;
	my $xml_hash;

	#open up the external html file
	open (SRC_FILE, $file_name) || die print "Could not open file $htmlfile";
	
	#read the file into an array 
	@file_data = <SRC_FILE>;

	#close the source file because we are finished reading in the key=value pairs
	close (SRC_FILE);

	#loop thru storing the lines into the variable $html_text
 	foreach $source_lines (@file_data)
 	{	
 		#remove the \n character
 		chomp ($source_lines);
		$xml_file .=  $source_lines;		
 	}
	
	#drop the opening line
	$xml_file =~ s/\<\?.*?\?\>//g;

	#drop any comments
	$xml_file =~ s/\<\!\-\-.*?\-\-\>//g;

	#read in the overall attributes
	while ($xml_file =~ /\<(\S*)(.*?)\>(.*?)\<\/\1\>/)
	{
		my $key_attribute_match = 0;

		#store the attribute
		my $attribute_name = $1;

		#store the key-value pairs
		my $key_pair_text = $2;
		
		#store the value text between the tags
		my $value_text = $3;

		#set the regex to clear out the string
		#$regex = "\<" . $attribute_name . $key_pair_text . "\>" . $value_text . "\<\/" . $atribute_name . "\>";

		#clear out the string
		#$xml_data =~ s/$regex//;
		$xml_file =~ s/\<(\S*)(.*?)\>(.*?)\<\/\1\>//;

		#setup a key value hash to store
		my %key_hash = {};

		#go through and sort out all of the key-value pairs
		while ($key_pair_text =~ /(\S*?)\=\"(.*?)\"/)
		{
			#set the key and value
			$key = $1;
			$value = $2;

			#remove the key/value from the text
			$regex = $key . '\=\"' . $value . '\"';
			$key_pair_text =~ s/$regex//;

			#check to see if there is a key attribute
			if ($key_attribute eq $key)
			{
				$key_attribute_match = 1;
			}

			#add the key value to the hash
			$key_hash{$key} = $value;		
		}
		
		#loop through the key/value hash
		foreach $key (keys %key_hash)
		{
			#if it's the key value, skip it
			if (($key eq $key_attribute) || ($key =~ /HASH\(/))
			{
				next;
			}
			#otherwise we need to define it
			else
			{
				#if this level has the key attribute, turn the data
				if ($key_attribute_match == 1)
				{
					$xml_hash -> {$attribute_name} -> {$key_hash{$key_attribute}} -> {$key} = $key_hash{$key};
				}
				else
				{
					$xml_hash -> {$attribute_name} -> {$key} = $key_hash{$key};
				}
			}
		}

		#if there are more matches
		if ($value_text =~ /\<(\S*)(.*?)\>(.*?)\<\/\1\>/)
		{
			$level_1 = $attribute_name;
			
			while ($value_text =~ /\<(\S*)(.*?)\>(.*?)\<\/\1\>/)
			{
				$key_attribute_match = 0;

				#store the attribute
				$second_attribute_name = $1;

				#store the key-value pairs
				$key_pair_text = $2;
		
				#store the value text between the tags
				$second_value_text = $3;

				$value_text =~ s/\<(\S*)(.*?)\>(.*?)\<\/\1\>//;

				#set the regex to clear out the string
				#$regex = "\<" . $attribute_name . $key_pair_text . "\>" . $value_text . "\<\/" . $atribute_name . "\>";

				#clear out the string
				#$xml_data =~ s/$regex//;
				#$xml_data =~ s/\<(\S*)(.*?)\>(.*?)\<\/\1\>//;

				#setup a key value hash to store
				%key_hash = {};
	
				#go through and sort out all of the key-value pairs
				while ($key_pair_text =~ /(\S*?)\=\"(.*?)\"/)
				{
					#set the key and value
					$key = $1;
					$value = $2;

					#remove the key/value from the text
					$regex = $key . '\=\"' . $value . '\"';
					$key_pair_text =~ s/$regex//;

					#check to see if there is a key attribute
					if ($key_attribute eq $key)
					{
						$key_attribute_match = 1;
					}

					#add the key value to the hash
					$key_hash{$key} = $value;		
				}
		
				#loop through the key/value hash
				foreach $key (keys %key_hash)
				{
					#if it's the key value, skip it
					if (($key eq $key_attribute) || ($key =~ /HASH\(/))
					{
						next;
					}
					#otherwise we need to define it
					else
					{
						#if this level has the key attribute, turn the data
						if ($key_attribute_match == 1)
						{
							$xml_hash -> {$level_1} -> {$second_attribute_name} -> {$key_hash{$key_attribute}} -> {$key} = $key_hash{$key};
						}
						else
						{
							$xml_hash -> {$level_1} -> {$second_attribute_name} -> {$key} = $key_hash{$key};
						}
					}
				}
				#if there are more matches
				if ($second_value_text =~ /\<(\S*)(.*?)\>(.*?)\<\/\1\>/)
				{
					$level_2 = $second_attribute_name;
					$key_hash_value = $key_hash{$key_attribute};
					$level_2_key_attribute = $key_hash{$key_attribute};

					while ($second_value_text =~ /\<(\S*)(.*?)\>(.*?)\<\/\1\>/)
					{		
						$key_attribute_match = 0;

						#store the attribute
						$third_attribute_name = $1;

						#store the key-value pairs
						$key_pair_text = $2;
		
						#store the value text between the tags
						$third_value_text = $3;

						#clear out the string
						#$xml_data =~ s/$regex//;
						$second_value_text =~ s/\<(\S*)(.*?)\>(.*?)\<\/\1\>//;

						#setup a key value hash to store
						%key_hash = {};
	
						#go through and sort out all of the key-value pairs
						while ($key_pair_text =~ /(\S*?)\=\"(.*?)\"/)
						{
							#set the key and value
							$key = $1;
							$value = $2;
		
							#remove the key/value from the text
							$regex = $key . '\=\"' . $value . '\"';
							$key_pair_text =~ s/$regex//;

							#check to see if there is a key attribute
							if ($key_attribute eq $key)
							{
								$key_attribute_match = 1;
							}
	
							#add the key value to the hash
							$key_hash{$key} = $value;		
						}

						if ($third_attribute_name ne $pipe_attribute)
						{
							#loop through the key/value hash
							foreach $key (keys %key_hash)
							{
								#if it's the key value, skip it
								if (($key eq $key_attribute) || ($key =~ /HASH\(/))
								{
									next;
								}
								#otherwise we need to define it
								else
								{
									$xml_hash -> {$level_1} -> {$level_2} -> {$key_hash_value} -> {$third_attribute_name} -> {$key} = $key_hash{$key};
								
								}
							}
						}
		
						if($third_value_text ne "")
						{
							#if this level has the key attribute, turn the data
							if($third_attribute_name eq $pipe_attribute)
							{
								$xml_hash -> {$level_1} -> {$level_2} -> {$key_hash_value} -> {$third_attribute_name} -> {$key_hash{"field"}} = $third_value_text;
							}
							else
							{
								$xml_hash -> {$level_1} -> {$level_2} -> {$key_hash_value} -> {$third_attribute_name} -> {'content'} = $third_value_text;
							}
						}
					}
				}
			}
		}
		#else if we have self-closing tags
		elsif ($value_text =~ /\<(\S*)(.*?)\ \/\>/)
		{
			$level_1 = $attribute_name;
			
			while ($value_text =~ /\<(\S*)(.*?)\ \/\>/)
			{
				$key_attribute_match = 0;

				#store the attribute
				$second_attribute_name = $1;

				#store the key-value pairs
				$key_pair_text = $2;

				$value_text =~ s/\<(\S*)(.*?)\ \/\>//;

				#setup a key value hash to store
				%key_hash = {};
	
				#go through and sort out all of the key-value pairs
				while ($key_pair_text =~ /(\S*?)\=\"(.*?)\"/)
				{
					#set the key and value
					$key = $1;
					$value = $2;

					#remove the key/value from the text
					$regex = $key . '\=\"' . $value . '\"';
					$key_pair_text =~ s/$regex//;

					#check to see if there is a key attribute
					if ($key_attribute eq $key)
					{
						$key_attribute_match = 1;
					}

					#add the key value to the hash
					$key_hash{$key} = $value;		
				}
		
				#loop through the key/value hash
				foreach $key (keys %key_hash)
				{
					#if it's the key value, skip it
					if (($key eq $key_attribute) || ($key =~ /HASH\(/))
					{
						next;
					}
					#otherwise we need to define it
					else
					{
						#if this level has the key attribute, turn the data
						if ($key_attribute_match == 1)
						{
							$xml_hash -> {$level_1} -> {$second_attribute_name} -> {$key_hash{$key_attribute}} -> {$key} = $key_hash{$key};
						}
						else
						{
							$xml_hash -> {$level_1} -> {$second_attribute_name} -> {$key} = $key_hash{$key};
						}
					}
				}
			}
		}
		elsif ($value_text ne "")
		{
			if ($key_attribute_match == 1)
			{
				$xml_hash -> {$attribute_name} -> {$key_hash{$key_attribute}} -> {'content'}  = $value_text; 
			}
			else
			{
					$xml_hash -> {$attribute_name} -> {'content'} = $value_text; 
			}
		}
	}

	return $xml_hash;

}

########################################################################################
# 	FUNCTION THAT READS IN AN XML FILE AND PARSES IT TO A HASH		       			   #
#	USE: &write_passwordXML($file_name, $xml_hash, $keyattribute, $pipe_attribute, $xml_declaration);              #
########################################################################################
sub write_passwordXML
{
	my $file_name = $_[0];
	my $xml_hash = $_[1];
	my $key_attribute = $_[2];
	my $pipe_attribute = $_[3];
	my $first_line = $_[4];
	my $file_text = $first_line;
	
	#loop through the keys
	foreach $key (keys %$xml_hash)
	{
		#start with the base tag
		$file_text .= "<" . $key;
		
		
		#loop through all the level 1 values and write them in the file text
		foreach $value (keys %level_1_hash)
		{
			$file_text .= " " . $value . "=\"" . $level_1_hash{$value} . '"';
		}
		
		#add the closing bracket
		$file_text .= ">\n";
		
		#this level is the hashes, which is our key_attribute
		foreach $level_3_key (keys %{$xml_hash -> {$key} -> {'respondent'}})
		{
			#clear out the hashes
			%pipe_hash = {};
			%level_2_hash = {};

			#start the respondent tag
			$file_text .= "  <" . 'respondent' .  " " . $key_attribute . "=\"" . $level_3_key . '"';
				
			#get all the next level
			foreach $level_4_key (keys %{$xml_hash -> {$key} -> {'respondent'} -> {$level_3_key}})
			{
				#if if this is a pipe, store it in the pipe hash
				if ($level_4_key eq $pipe_attribute)
				{
					foreach $level_5_key (keys %{$xml_hash -> {$key} -> {'respondent'} -> {$level_3_key} -> {$level_4_key}})
					{
						$pipe_hash{$level_5_key} = $xml_hash -> {$key} -> {'respondent'} -> {$level_3_key} -> {$level_4_key} -> {$level_5_key};
					}
				}
				#otherwise store it in the level 2 hash
				else
				{
					$level_2_hash{$level_4_key} = $xml_hash -> {$key} -> {'respondent'} -> {$level_3_key} -> {$level_4_key};
				}
			}
				
			foreach $value (keys %level_2_hash)
			{
				if ($value !~ /HASH\(/)
				{
					$file_text .= " " . $value . "=\"" . $level_2_hash{$value} . '"';
				}
			}
				
			#add the closing bracket
			$file_text .= ">\n";
			
			foreach $value (keys %pipe_hash)
			{
				if ($value !~ /HASH\(/)
				{
					$file_text .= "    <pipe field=\"" . $value . "\">" . $pipe_hash{$value} . "</pipe>\n";
				}
			}
				
			$file_text .= "  </" . 'respondent' . ">\n";
		}
		
		$file_text .= "</" . $key . ">\n";
	}
	
	open (PASS_FILE, ">$file_name") || die ("Could not open file. $!");
	print PASS_FILE ($file_text);
	close (PASS_FILE);
	
	return 1;
}

########################################################################################
# 	FUNCTION THAT READS IN AN XML FILE AND PARSES IT TO A HASH		       			   #
#	USE: &increment_passwordXML($file_name, $password_hash, $password_count);              #
########################################################################################
sub increment_passwordXML
{
	my $file_name = $_[0];
	my $password_hash = $_[1];
	my $password_count = $_[2];
	my $file_text;
	
	#open the source file and set the source file handle
	open (SRC_FILE, $file_name) || die &show_server_error($ERROR_NUM_FILE_ACCESS,"File Access Error",$form_configuration{'[MISC]'}{'ErrorMessageFileAccess'} . " [" . $file_name . "]", __LINE__);

	#read the file into an array 
	@file_data=<SRC_FILE>;

	#loop thru storing the lines
 	foreach $source_line (@file_data)
 	{
		#add the line to the file_text
		$file_text .= $source_line;
	}

	#close the source file because we are finished reading in the key=value pairs
	close (SRC_FILE);

	#find the password entry
	$file_text =~ /<respondent (.*?)hash\=\"$password_hash\"(.*?)\>/;

	$old_preceding_text = $1;
	$old_end_text = $2;	

	$new_preceding_text = $old_preceding_text;
	$new_end_text = $old_end_text;
	
	$new_preceding_text =~ s/usecount\=\".*?\"/usecount\=\"$password_count\"/;
	$new_end_text =~ s/usecount\=\".*?\"/usecount\=\"$password_count\"/;

	$search_text = "<respondent " . $old_preceding_text . "hash\=\"$password_hash\"" . $old_end_text . "\>";
	$replace_text = "<respondent " . $new_preceding_text . "hash\=\"$password_hash\"" . $new_end_text . "\>";

	#find the password entry
	$file_text =~ s/$search_text/$replace_text/;

	open (PASS_FILE, ">$file_name") || die ("Could not open file. $!");
	print PASS_FILE ($file_text);
	close (PASS_FILE);
	
	return 1;
}