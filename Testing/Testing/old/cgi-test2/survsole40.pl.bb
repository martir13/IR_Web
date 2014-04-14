#!/usr/local/bin/perl
#
# survsol40.pl -- the Perseus Survey Server.
#
# (c) 1997-2001 Perseus Development Corp.
# for assistance, contact techsupport@perseus.com
#
# This form handler is written in the Perl programming language and
# uses language components only available in version 5.000 and above.
# Much effort has been put into making this script robust, understandable,
# and secure.  If you find problems with any part of this script, please
# send your concerns to our support address listed above.
#
# If you want to replace this with a different form handler, simply
# ensure that the response e-mail is a series of name/value pairs,
# such as 1 = 15 (each separated by a new line), where 1 is the form
# field name and 15 is the corresponding form value.
#
# Three fields are required to be in the HTML form:
#	* PDCPDCEmailAddress
#       * PDCPDCProjectID
#	* PDCPDCThankYouPage
#	* PDCPDCTableName (Enterprise only)
#       * PDCPDCConfigID  (Enterprise only)

require 5.000;		# Perl 5 or better...
use strict;
use Fcntl qw(:DEFAULT :flock);
use CGI;

$| = 1;                 # Flush STDOUT

use IO::Handle;
my $io = new IO::Handle();
# set autoflush
$io->autoflush(1);


#-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
#
# Set configurable constants
#
#-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

#
# Path to 'sendmail' utility.
#
sub SENDMAIL { '/usr/lib/sendmail -t -oi' }

##
# Path to the root of the template files.
#
sub TEMPLATE_ROOT { 'c:\perseus' }

#
# Directory where LiveStats results are stored.
#
sub LIVESTATS_DIR { 'd:\Website\tmp\livestats' }

#
# Directory where TSV files are permitted to be written.
#  (If this is set to '', then any path is allowed)
#  (All TSV file names are relative to this path, and not absolute)
#
sub TSV_PATH { '' }

#
# Mode to set the TSV file to if created.
#
sub TSV_MODE { 0664 }

#
# Perseus fields to be returned in the TSV
#
sub PDCPDC_PASS_FIELDS { qw/ PDCPDCProjectID PDCPDCAppVer/ }

#
# List of environment variables to be returned within the email message.
#
sub EMAIL_ENVS { qw/
       HTTP_USER_AGENT
       REMOTE_ADDR
       REMOTE_HOST
       REMOTE_USER
/}

#
# Default email address to use if AdmEmlAdr not specified.
#
sub ADMIN_EMAIL_DEF { 'techsupport@perseus.com' }


#
# The standard thank you page
#  If the PDCPDCThankYouPage is not set, this is the 
#  value which is returned
# 
sub DEFAULT_THANKYOUPAGE {
<<'EOD';
{HTML}
 {HEAD}{TITLE}Survey Submitted{/TITLE}{/HEAD}
 {BODY BGCOLOR="#FFFFFF"}
  {H1}Survey Submitted{/H1}
  Thank you for completing this survey.{BR}
  {P}{HR}{/BODY}
{/HTML}
EOD
}

#
# The standard testing thank you page
#  If the PDCPDCTestingThankYouPage is not set, this is the 
#  value which is returned
# 
sub TESTING_THANKYOUPAGE {
<<'EOD';
{HTML}
 {HEAD}{TITLE}Survey Submitted{/TITLE}{/HEAD}
 {BODY BGCOLOR="#FFFFFF"}
  {H1}Testing Alert{/H1}
  Your results have been added to the survey database, which is currently in testing mode.{BR}
  If you have any questions, please contact the survey author {A HREF=mailto:}{{PDCPDCAdminEmlAdr}}{/A}.
  {BR}
  {P}{HR}{/BODY}
{/HTML}
EOD
}

#
# The standard "Answers Required" page
#
sub DEFAULT_REQPAG {
<<'EOD';
{HTML}
 {HEAD}{TITLE}Required Questions Need To Be Answered{/TITLE}{/HEAD}
 {BODY BGCOLOR="#FFFFFF"}
  {H1}Required Questions Need To Be Answered{/H1}
  Please answer these required questions:
  {P}{BLOCKQUOTE}{{PDCPDCANSREQ}}{/BLOCKQUOTE}
  {P}Click the Back button on your browser to go back to your survey.
  Answer all the questions, then re-submit it.{P}
 {/BODY}
{/HTML}
EOD
}

#
# The default invalid password message
#
sub PASWRDPAG {
<<'EOD';
{HTML}
 {HEAD}{TITLE}Invalid Password{/TITLE}{/HEAD}
 {BODY BGCOLOR="#FFFFFF"}
  {H1}Password Not Valid{/H1}
  This is a password-protected page, and {{PDCPDCPASWRD}}
  is not the correct password.
  {P}
 {/BODY}
{/HTML}
EOD
}


#
# Expand tab characters in form field values to:
#
sub TAB_EXPAND { '    ' }

#
# Define standard HTML header
#
{
    my $_HTTP_HDR_PRINTED = 0;
    sub HTTPHEADER {
        $_HTTP_HDR_PRINTED++ ? '' : "Content-type: text/html\r\n\r\n"
    }
}

#
# List of valid top-level email domains
#
use vars '%TLDS';
BEGIN {
    %TLDS = ( 'ad'=>1, 'ae'=>1, 'ag'=>1, 'al'=>1, 'am'=>1, 'an'=>1, 'ar'=>1,
    'at'=>1, 'au'=>1, 'aw'=>1, 'ba'=>1, 'be'=>1, 'bf'=>1, 'bg'=>1, 'bh'=>1,
    'bm'=>1, 'bn'=>1, 'bo'=>1, 'br'=>1, 'bs'=>1, 'bw'=>1, 'by'=>1, 'ca'=>1,
    'ch'=>1, 'ci'=>1, 'cl'=>1, 'cm'=>1, 'cn'=>1, 'co'=>1, 'com'=>1, 'cr'=>1,
    'cu'=>1, 'cy'=>1, 'cz'=>1, 'de'=>1, 'dk'=>1, 'dm'=>1, 'do'=> 1, 'ec'=>1,
    'edu'=>1, 'ee'=>1, 'eg'=>1, 'es'=>1, 'fi'=>1, 'fj'=>1, 'fm'=>1, 'fo'=>1,
    'fr'=>1, 'ge'=>1, 'gh'=>1, 'gi'=>1, 'gn'=>1, 'gov'=>1, 'gr'=>1, 'gt'=>1,
    'gu'=>1, 'gy'=>1, 'hk'=>1, 'hn'=>1, 'hr'=>1, 'hu'=>1, 'id'=>1, 'ie'=>1,
    'il'=>1, 'in'=>1, 'int'=>1, 'ir'=>1, 'is'=>1, 'it'=>1, 'jm'=>1, 'jo'=>1,
    'jp'=>1, 'ke'=>1, 'kh'=>1, 'kr'=>1, 'kw'=>1, 'ky'=>1, 'kz'=>1, 'lb'=>1,
    'lc'=>1, 'lk'=>1, 'lt'=>1, 'lu'=>1, 'lv'=>1, 'ma'=>1, 'md'=>1, 'mg'=>1,
    'mil'=>1, 'mk'=>1, 'ml'=>1, 'mo'=>1, 'mr'=>1, 'mt'=>1, 'mu'=>1, 'mv'=>1,
    'mx'=>1, 'my'=>1, 'mz'=>1, 'na'=>1, 'nc'=>1, 'ne'=>1, 'net'=>1, 'ni'=>1,
    'nl'=>1, 'no'=>1, 'np'=>1, 'nu'=>1, 'nz'=>1, 'om'=>1, 'org'=>1, 'pa'=>1,
    'pe'=>1, 'pf'=>1, 'pg'=>1, 'ph'=>1, 'pk'=>1, 'pl'=>1, 'pt'=>1, 'py'=>1,
    'qa'=>1, 'ro'=>1, 'ru'=>1, 'sa'=>1, 'se'=>1, 'sg'=>1, 'si'=>1, 'sk'=>1,
    'sn'=>1, 'su'=>1, 'td'=>1, 'tg'=>1, 'th'=>1, 'tj'=>1, 'tm'=>1, 'tn'=>1,
    'to'=>1, 'tr'=>1, 'tt'=>1, 'tw'=>1, 'tz'=>1, 'ua'=>1, 'ug'=>1, 'uk'=>1,
    'us'=>1, 'uy'=>1, 'uz'=>1, 've'=>1, 'vi'=>1, 'vn'=>1, 'ye'=>1, 'yu'=>1,
    'za'=>1, 'zm'=>1, 'zw'=>1,
    );
}

#-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
#
# End of configuration section -- Don't change anything following!
#
#-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

#
# Deprecated form names and their preferred values.
#
my %DEPRECATED = ( 
    PDCPDCAdminEmlAdr             => 'PDCPDCAdmEmlAdr',
    PDCPDCThkYouPag               => 'PDCPDCThankYouPage',
    PDCPDCResEmlAdr               => 'PDCPDCEmailAddress',
    PDCPDCResEmlMsg               => 'PDCPDCRspEmlMsg',
    PDCPDCResEmlAdrQstHdg         => 'PDCPDCRspEmlAdrQstHdg',
    PDCPDCServerFil               => 'PDCPDCSvrFil',
    PDCPDCServerFile              => 'PDCPDCSvrFil',
    );
		  
my @DEBUG = ();
eval {
    ############################################
    # Parse the form data into name/value pairs
    ############################################
    my $params = new CGI();

    ############################################
    # Pre-Process
    ############################################

    my @survey_configuration_options = get_survey_configuration_options($params);
    my($livestats) = @survey_configuration_options;
    
    # Check any required fields
    check_required_fields($params);
    
    # Do server side validation of form values(if the PDCPDCVld and PDCPDCVldErrMsg 
    #form fields, and the the validation module exists)
    #if ($params->param('PDCPDCVld') && $params->param('PDCPDCVldErrMsg')) {
    #	if (-e "survval.pl") {
    #	    require "survval.pl";
    #	    Sur_Validate($params);
    #	}
    #}

    ############################################
    # Add the response to the database (if the PDCPDCOptions field contains
    #  DBType)
    ############################################
        
    my $status="";
        
    if (($params->param('PDCPDCOptions') =~ /DBTyp/)||($params->param('PDCPDCTableName'))) {
    	if (-e 'sse_main40.pl') {
    	    require "sse_main40.pl";
    	    $status=update_database($params);
    	}
    }

    ############################################
    # Encrypt the form values if the PDCPDCEncRes field is set
    ############################################
    encode_results($params);

    ############################################
    # Send the results as an e-mail message to the survey administrator.
    ############################################
    email_form_results($params, $status);

    ############################################
    # Save form data to TSV file
    ############################################
    
    if ($status ne "CLOSED")
    {
    save_to_tsv($params);
    }
    
    ############################################
    # Update live stats (need to do this before encrypting the data values)
    ############################################
    my $stats="";
    
    if ((!defined($livestats))||($livestats == 1)) {
       $stats = update_live($params);
    }

    # Defect #233 - Response e-mail does not get sent if thank you page is a redirect 
    ############################################
    # Determine if the respondent should get an email
    ############################################
    check_email_respondent($params, $stats);

    ############################################
    # Send a confirmation page
    ############################################
    thankyou($params, $stats, $status);
};

if ($@) {
    print HTTPHEADER, <<"EOD";
<HTML>
<BODY BGCOLOR="#FFFFFF">
   We're sorry, but an error occurred in trying to process your script.
   <!-- $@ -->
</BODY>
</HTML>
EOD
}

exit(0);

#-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
#
# Subroutines:
#
#-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

#-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# update_live($cgi_object)
# Update the live stats.
# Returns reference to hash of question attributes.
sub update_live {
    my $cgi = shift;
    
    #
    # Form a hash of the questions answered in this survey.
    #
    my %data = ();
    my $k;
    foreach $k (grep !/^PDCPDC/, sort $cgi->param) {
	my $v = $cgi->param($k);
	
	#kill all occurences of <space><apostrophe> to end of entry
	if (index($v, " '") > -1) {
	    $v = substr($v, 0, index($v, " '"));
	}
	
	next unless ($v =~ /^\s*(\d+)\s*$/);	 # Only tally numeric values
	
	#
	# Split the form fieldname(x_y) into a
	# question # (x) and a question option   # (_y)
	#
	
	#my ($q,$opt) = ($k =~ m/^(\w+)(_\d+)?/);
	# break apart question name (key in $cgi->param hash) into
	# a question and an option: Q1_3 --> Question: Q1, Option: _3
	my ($q, $opt);
	my $underscore_index = rindex($k, '_');
	
	if ($underscore_index < 0) {    # if underscore was not found
	    $q = $k;                    # the entire question becomes the key
	} else {                        # otherwise break up the question and option
	    $q = substr($k, 0, $underscore_index);
	    $opt = substr($k, $underscore_index);
	}
	
	count(\%data, $q, $v); 		     # Tally Qx attributes
	
	if ($opt) {
	    count(\%data, $q.$opt, $v);		 # Tally Qx_y attributes
	    count(\%data, $q.$opt."_$v", $v);	 # Tally Qx_y_v attributes
	} else {
	    count(\%data, $q."_$v", $v);	         # Tally Qx_v attributes
	}
    }
    
    #
    # Form the name of the live stats data file
    #
    my $adm_email = $cgi->param('PDCPDCAdmEmlAdr') || ADMIN_EMAIL_DEF;
    my $project   = $cgi->param('PDCPDCProjectID') || 'No_Project_ID';
    my $ls_file = join ('/',
			LIVESTATS_DIR,
			encode_scalar($adm_email) .' for '.$project.'.liv');
    
    # This is so that we can use the name $lstats which is definied in the
    # livestats file
    use vars '$lstats';

    # following is the region where the current livestats file is read
 
    # Get a lock, so that we don't run into problems with
    # trying to read this file while we are writing at the same time    
    open (LS_FH, "+<$ls_file");
    flock(LS_FH, LOCK_EX);
    # check to see if the livestats file exists
    my $exist_result = (-e $ls_file);

    # only testing once for the file has gotten us into trouble
    # because perl might report that the file does not exist if it is currently
    # being written, or flushed, etc. Hence, we try multiple times if the 
    # file is reported not to exist to reduce the chance of an error
    my $MAXTRIES = 10;
    my $tries = 0;
    while ((not $exist_result) && ($tries < $MAXTRIES)) {
	#check to see if the file exists again
	$exist_result = (-e $ls_file);
	# increment tries
	$tries++;
    }

    # release the file lock, and close the handle
    flock(LS_FH, LOCK_UN);
    close(LS_FH);
    
        
    # if the livestats file exists
    if ($exist_result) {	
	if (not (do $ls_file)) {
	
	    my $thanks = $cgi->param('PDCPDCThankYouPage');
	    my $admin = $cgi->param('PDCPDCAdminEmlAdr');
	    
	    # there was an error (most probably in compilation)
	    # signal an error and abort (instead of resetting the livestats file)
	    
	    if ($thanks=~/{{/)
	    {
	       if ($thanks=~/PDCPDC/)
	       {
	          return;
	       }   
	    
	       if (-e "sse_main40.pl")
	       {
	          LivestatsError("Your response was saved. However, an error occured while processing the Live Results. " .
	                         "Please contact the Survey Administrator $admin for the latest results.($@)($!)");	       
	       }
	       else
	       {
	          LivestatsError("Your response was processed. However, an error occured while processing the Live Results." .
	                         "Please contact the Survey Administrator $admin for the latest results.($@)($!)");
	       }	              
            }
            else
            {
            return;
            }
	}
	
        #
	# Merge the stats from this survey into the
	# Live Stat data that was just read.
	#
	foreach (keys %data) {
	    /(CNT|SUM)$/ and do {
		$lstats->{$_} ||= 0;	# To eliminate 5.003 warnings
		$lstats->{$_} +=  $data{$_};
		next;
	    };
	    /MIN$/ and do {
		$lstats->{$_} = min($lstats->{$_}, $data{$_});
		next;
	    };
	    /MAX$/ and do {
		$lstats->{$_} = max($lstats->{$_}, $data{$_});
		next;
	    };
	}
    } else {
	#
	# This is most probably the first survey recorded.
	# Use the current data as the complete set.
	# (This gets us into trouble with the reseting of the livestat's file)

	if (-e $ls_file) {
	    LivestatsError ("An error occured while processing your response." .
			    " Please wait a minute and then click the Refresh button in your browser to vote again." . 
                            " We apologize for the inconvenience and appreciate your taking the time to complete this survey.");
	}
	
	$lstats = \%data;
    }

    sysopen(LS_FH, "$ls_file", O_WRONLY | O_CREAT) or Error("Couldn't open the LiveStats data file '$ls_file' ($!)");

    # Lock file
    flock(LS_FH, LOCK_EX);

    # +++Critical region +++

    # Seek to BOF
    truncate (LS_FH, 0);
    
    # Write out the contents of %lstats hash
    # (The 'map' function applies the function specified to all
    #  elements in a list)
    print LS_FH join ("\n",
		      '$lstats = {',
		      (map {
			  sprintf "  '%-12s, '%s',", "$_'", $lstats->{$_}
		      } sort keys %$lstats),
		      '};',
		      '1;',
		      '');

    # Release exclusive file lock    
    flock LS_FH, LOCK_UN;
    close LS_FH;

    # --- End of critical region ---


    #
    # Now calculate AVG and PCT attributes(Average and Percent) 
    # for any questions that have a CNT attribute
    #
    foreach (grep /CNT$/, keys %$lstats) {
	my $tag = substr($_,0,-3); # Each tag is the lstat without 
	# the last three characters
        my $cnt = $lstats->{$_} or $lstats->{$tag.'AVG'} = '--',next;
        my $sum = $lstats->{$tag.'SUM'};
	$lstats->{$tag.'AVG'} = sprintf '%.2f', $sum/$cnt;
	
	#
	# Strip off everything prior to the final underscore.
	# Use the CNT of this parent tag to calculate the
	# PCT of answers that this option has received.
	#
	my $unsc = rindex($tag, '_');
	my $par  = ($unsc > 0) ? substr($tag, 0, $unsc) : $tag;
	my $parcnt = $lstats->{$par.'CNT'} or next;		
	$lstats->{$tag.'PCT'} = sprintf '%.2f', $cnt*100/$parcnt;
    }
    return $lstats || {};
}


#+++++++++++++++++++
# Support subroutines for update_live()

# Count one question answer.
#  Set CNT to 1
#  Recalculate MIN
#  Recalculate MAX
#  Increment the total SUM
# Note: CNT is always 1, as even if multiple options are specified
#	to a question, the question was only answered once.

sub count {
    my $h = shift;	# Hash reference
    my $k = shift;	# Key to set
    my $v = shift;	# Value to add in

    $h->{$k.'CNT'} = 1;                         # QxCNT
    $h->{$k.'MIN'} = min($v, $h->{$k.'MIN'});	# QxMIN
    $h->{$k.'MAX'} = max($v, $h->{$k.'MAX'}); 	# QxMAX
    $h->{$k.'SUM'} ||= 0;                       # To eliminate 5.003 warnings
    $h->{$k.'SUM'} += $v;                       # QxSUM
}

# min($a, $b)
# Return minimum of 2 args
sub min {
    my $a = shift || 1E20;
    my $b = shift || 1E20;
    ($a < $b) ? $a : $b;
}

# max($a, $b)
# Return maximum of 2 args
sub max {
    my $a = shift || -1E20;
    my $b = shift || -1E20;
    ($a > $b) ? $a : $b;
}
# End support routnes for update_live
#----------------------------------

#-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# encode_scalar($data)
# Endecoding routine. Uses the super-secret Endcoding technique to encode
# information. Used to encode email addresses of the survey admin for the
# live stats file and to encode data for transmission back to the survey admin.

sub encode_scalar {
    my $name = shift;
    $name =~ tr{abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ@.}
               {labyrinthjkmopqsuvwxyzcdeflabyrinthjkmopqsuvwxyzcdefff};
    $name;
}

#-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# encode_results($cgi_object)
# Encrypt the form field values if the PDCPDCEncRes field has the value "true"
# Modifies the main cgi object such that the form values are encrypted.

sub encode_results {
    my $cgi = shift;
    # for each of the form fields, if the name does not start with PDCPDC encrypt the values
    if ($cgi->param('PDCPDCEncRes') eq 'True') {
	foreach (grep (!/^PDCPDC/, $cgi->param)) {
	    #the next command encrypts and sets the field value in one go
	    #we love perl
	    $cgi->param($_, encode_scalar($cgi->param($_)));
	}
    }
}

#-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# check_required_fields($cgi_object)
# Form parameter 'PDCPDCReqAns' lists any required fields.
# Check that all fields listed have a valid value.
#  (This is an outdated method to require answers. The preferred 
#   way is to use the Perseus Validation Suite -AAL 8/16/2000)

sub check_required_fields {
    my $cgi = shift;
    
    # Convert any deprecated form field names into their correct ones
    foreach ($cgi->param) {
    	# If current fieldname is deprecated 
    	if ($DEPRECATED{$_}) {
			# Create a new entry in the $cgi object for the perferred name
			$cgi->param($DEPRECATED{$_}, $cgi->param($_));
		}
	}
	
	my ($key,$value,$data);
		    
	foreach $key($cgi->param)
	{
	$value=$cgi->param($key);
	$data->{$key}=$value;
        }

    my $emailfld = $cgi->param('PDCPDCRspEmlAdrQstHdg');
       $emailfld =~ tr/a-z-/A-Z_/;
    my $required = $cgi->param('PDCPDCReqAns');
    my (@required);

    #
    # Previous version used ';' as the field separator in PDCPDCREQANS.
    # We now use a space (to allow word wrapping when viewing form in an
    # editor.)  determine which one is in use, and split on it.
    #
    if ($required =~ tr/;/;/) {
        @required = split(/\s*;\s*/, $required);
    } else {
        @required = split(' ', $required);
    }

    my @missing  = ();
    REQUIRED:
    foreach (@required) {
		my ($name,$label) = split(/\s*=\s*/);
		#$name =~ tr/a-z-/A-Z_/;
		
		# Defect #349 Required field functionality in survsole.pl needs to recognize 0 as an answer 
		unless (($cgi->param($name)) || ($cgi->param($name) eq "0" )) {
			push @missing, $label || $name;
		}

		if ($emailfld and $name
		and ($emailfld eq $name or $emailfld eq "Q$name")) {
			my $email = $cgi->param($emailfld) or next REQUIRED;
			#
			# This is the respondent's email field.  Check it for
			# valid syntax for an email address.
			#
			my $tld = lc $email;
			   $tld =~ s{.*\.}{};		# Grab top level domain
			unless ($email =~ m{[a-zA-Z0-9_.,+-]+	# Username
						@
						[a-zA-Z0-9_-]+		# subdomain
						(\.[a-zA-Z0-9_-]+)+	# .sub[.sub...]
					  }x
			   and  $TLDS{$tld}) {
			push @missing, "($label [$email] doesn't look "
					 . "like a valid email address)";
			}
		}
    }

    if (@missing) {
		print HTTPHEADER,
			  expand($cgi->param('PDCPDCReqPag') || DEFAULT_REQPAG,
				 PDCPDCANSREQ => join('<BR>', @missing, ''),
				 %$data);
		exit(0);
    }
}



#-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# expand($template, %replacement_hash)
# Print the specified template data, substituting any
# {{TOKEN}} tags with values taken from the passed hash.
# If a token doesn't exist in the hash, look for a value
# in the %ENV hash.
#
sub expand {
    my $template = shift;	# Template HTML data
    my %repl     = @_;		# Hash of name/value pairs

    $template =~ s[{{(.*?)}}]                       #Match the double brace ({{Q1}}-->$1=Q1)
                  [ $repl{"$1"}             ||        #Replace: Actual name in the hash (eg Q1_1) or 
                    $repl{"Q$1"}            ||        #Replace: Actual name plus leading Q 
                                                    #(eg 1_1 --> Q1_1) or
                    $ENV{$1}              ||        #Replace: Environment variable named $1
		    ((substr($1,-3) eq 'PCT') 
		     ? '0.00' : '') ]ge;            #If a percent, return 0.00, otherwise ''
    $template =~ tr/{}/<>/;                         #convert braces({}) to GTLT(<>)
    $template =~ s/<<(\w+)>>/{{$1}}/g;
    $template =~ s/''/"/g;
    return $template;
}

#-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
#
# If the PDCPDCSvrFil form field is specified, save
# a copy of this form submittal in the file as TSV data.
#
sub save_to_tsv {
    my $cgi = shift;
    
    # get TSV filename from PDCPDCSvrFil parameter, or stop here
    my $tsv_file = $cgi->param('PDCPDCSvrFil') or return;
    
    # Replace illegal characters in the form fields
    replace_illegal_characters($cgi);    

    my $hdr = '';
    if (-e $tsv_file) {
        Error("The data file '$tsv_file' isn't writeable")
	   unless (-w $tsv_file);
    } 

    my @cols = (); #Column names
    	
	#
	# Write the field names specified in PDCPDCFrmFld
	# to columns we are going to save. PDCPDCFrmFld is
	# delineated by '; '
	
	#@cols = grep !/^PDCPDC/, sort($cgi->param);
	@cols = split /; /, $cgi->param("PDCPDCFrmFld");
		
	#
	# Add a date and time stamp to the parameters
	# 
	$cgi->param('Date', current_time());
	push(@cols, 'Date');	
		
	#
	# Add the specified additional PDCPDC_PASS_FIELDS
	# to the beginning of the column list if they are not
	# already in the list
	#
	my %seen;
	foreach (@cols) {$seen{$_} = 1;} #make a hash of seen column names
	foreach (PDCPDC_PASS_FIELDS) {
		unshift(@cols, $_) unless ($seen{$_});
	}
	
	#
	# Add any desired environmental variables to the end of the column list
	#  (these are defined in the user configurable constants)
	foreach (EMAIL_ENVS) {
		$cgi->param($_, $ENV{$_} || '');
		push @cols, $_;
	}
    
    # 
    # Check the file name that we were passed to ensure that we don't
    # let some less than jovial user fool around with files that we don't
    # want them to
    
    if (TSV_PATH) {
		($tsv_file =~ m{^([^/]+)$} && $tsv_file ne "." && $tsv_file ne "..")
			or Error("Bad filename for data file. (No path allowed)");
		$tsv_file = $1;
	} 
	
    #
    # @cols contains the ordered column names.
    # Write them to the tsv file.
    #
    umask 002;
    Error("Failed to open the data file '$tsv_file' ($!)")
	unless (open(TSV_FH, ">>$tsv_file"));
    chmod TSV_MODE, $tsv_file;
    flock TSV_FH, LOCK_EX;		# Lock file

    # +++Critical region +++

    seek TSV_FH, 0, 2;				      # Seek to EOF
    (tell > 0) or print TSV_FH tsv(@cols),"\n";    # Write hdr if new file
    # Defect #207 - Zero is not being saved in the tsv file.
     print TSV_FH tsv(map { (defined($cgi->param($_))) ? 
				$cgi->param($_) : '' } 
		      @cols), "\n";
    flock TSV_FH, LOCK_UN;

    # --- End of critical region ---

    close(TSV_FH);
}

#-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
#
# Subroutine: tsv() -- Convert the given list to a tab-separated-value
#	record.
#
sub tsv {
    #join "\t", map(qq{"$_"}, @_);
	join "\t", @_;
}

#-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
#
# If the EmailAddress form field is specified, email
# a copy of this form submittal back to that address.
#
sub email_form_results {
    my $cgi = shift;
    my $status=shift;
    
    my ($name,$value,$data);
   
    foreach $name($cgi->param)
    {
    $value=$cgi->param($name);
    $data->{$name}=$value;
    }

    my $from_addr = $cgi->param('PDCPDCAdmEmlAdr') || ADMIN_EMAIL_DEF;
    my $project   = $cgi->param('PDCPDCProjectID') || '-- Not Supplied --';
    
    if ($status eq "CLOSED")
    {
    local (*SMAIL);
    open(SMAIL, '|'. SENDMAIL)
        or die "Can't start mail program.";
    #
    # [to test on a system without mail: open MAIL, ">mail.txt";]
    #
    
    # print the subject header
print SMAIL <<"EOM";
To: $from_addr
From: $from_addr
Subject: Project ID: $project
    
The aforementioned project is now at a status of Closed and should be
maintained accordingly.  While the project is at a status of Closed, no
results will be accepted.
    
EOM

# close the mail message
    close(SMAIL);
    
    return;
    
    }
    
    
    my $to_addr   = $cgi->param('PDCPDCEmailAddress') or return;
       $to_addr   =~ s/([^a-zA-Z0-9_@.,-])/\\$1/g;	# Quote shell metas
       
    my $message=$cgi->param('PDCPDCAdmEmlMsg');   

    #
    # open the mail program
    # [make sure the next statement points to the mail system on your
    # server;  one alternative: open(MAILOUT, "| mail $resadr_ls") || ]
    #

    local (*SMAIL);
    open(SMAIL, '|'. SENDMAIL)
        or die "Can't start mail program.";
    #
    # [to test on a system without mail: open MAIL, ">mail.txt";]
    #
    
    if ($message) {
    
       my $expanded_message=expand($message, %$data);
       
       print SMAIL <<"EOM";
To: $to_addr
From: $from_addr
Subject: Project ID: $project

$expanded_message

EOM
    }
    else
    {
    # print the subject header
    print SMAIL <<"EOM";
To: $to_addr
From: $from_addr
Subject: Project ID: $project

This e-mail is the result of a web survey and is intended
for use with Perseus SurveySolutions for the Web.  You can
use SurveySolutions to process these results to build a
database, to generate tables and charts analyzing that
database and also to print out individual responses as
completed questionnaires (see Database/Profile Records).

EOM

    #
    # Print the form values.
    my $k;
    foreach $k (sort $cgi->param) {
	next if ($k =~ /^PDCPDC/);
	my $v = $cgi->param($k);
	print SMAIL "$k = $v\n";
    }

    #
    # Print the PDCPDC parameters that need passed
    #
    foreach $k (PDCPDC_PASS_FIELDS) {
	my $v = $cgi->param($k);
	print SMAIL "$k = $v\n";
    }

    #
    # print desired environmental variables
    #
    foreach (EMAIL_ENVS) {
	my $v = $ENV{$_} || '';
	print SMAIL "$_ = $v\n";
    }

    #
    # print system information that may be
    # helpful if debugging is necessary
    #

    #
    # operating system this script is running on
    #
    print SMAIL "PDCPDCOS = $^O\n";

    # close the mail message
    close(SMAIL);
    }
}

#-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# email_respondent($cgi_object, $to_address)
# Email a response page to the survey respondent

sub email_respondent {
    my $cgi      = shift or return;

    my $to_addr   = shift or return;
       $to_addr   =~ s/([^a-zA-Z0-9_@.,-])/\\$1/g;	# Quote shell metas
    my $from_addr = $cgi->param('PDCPDCAdmEmlAdr') || ADMIN_EMAIL_DEF;

    #
    # open the mail program
    # [make sure the next statement points to the mail system on your
    # server;  one alternative: open(MAILOUT, "| mail $resadr_ls") || ]
    #

    local (*SMAIL);
    open(SMAIL, '|'. SENDMAIL)
        or die "Can't start mail program.";
    #
    # [to test on a system without mail: open MAIL, ">mail.txt";]
    #

    my $subject = "Survey Response";
    if ($cgi->param('PDCPDCOptions') =~ m/(?:^|;)\s*EmlHdg=([^;]+?)\s*(;|$)/i) {
        $subject = $1;
    }

    # print the message header, the message body is
    # whatever parameters are still on the argument list.
    #
    print SMAIL <<"EOM", @_;
To: $to_addr
From: $from_addr
Subject: $subject

EOM
    # close the mail message
    close(SMAIL);
}

# Defect #233 - Response e-mail does not get sent if thank you page is a redirect
#-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# check_email_respondent($cgi_object, $stats)
# Determine if the respondent should receive an email
#
sub check_email_respondent {

    my $cgi  = shift;
    my $stats = shift || {};
    
    my ($name,$value,$data);
        
    foreach $name($cgi->param)
    {
    $value=$cgi->param($name);
    $data->{$name}=$value;
    }

    #
    # If a respondent-email message is defined, send the
    # message with the appropriate expansions performed.
    #
    my $response   = $cgi->param('PDCPDCRspEmlMsg');
    my $email_hdg  = $cgi->param('PDCPDCRspEmlAdrQstHdg');
    my $respondent = $email_hdg
		   ? $cgi->param($email_hdg)
		   : '';
    if ($response and $respondent) {
	READ_FILE:
	{
	    if ($response =~ /^File:\s*(\S*)/) {
		my $file = join '/', TEMPLATE_ROOT, $1;
		   $file =~ tr{/}{/}s;

		unless (-r $file) {
		    warn "Email response template file '$file' "
		       . "isn't readable\n";
		    last READ_FILE;
		}
		local (*FH);
		open(FH, "<$file") or do {
		    warn "Couldn't open email response template "
		       . "file '$file' (!$)\n";
		    last READ_FILE;
		};
		$response = join("\n", <FH>);
		close(FH);
	    }
	    email_respondent($cgi,
			     $respondent,
			     expand($response, %$data, %$stats));
	}
    }
}

#-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# thankyou($cgi_object, $stats)
# Return a confirmation page that data was received
#
sub thankyou {
    my $cgi  = shift;
    my $stats = shift || {};
    my $status= shift;
    
    my ($name,$value,$data);
        
    foreach $name($cgi->param)
    {
    $value=$cgi->param($name);
    $data->{$name}=$value;
    }
    
    my $thanks;

    if ($status eq "TESTING")
    {
    $thanks = $cgi->param('PDCPDCThankYouPage');
       if ($thanks!~/Live/)
       {
       $thanks=$cgi->param('PDCPDCTestingThankYouPage') || TESTING_THANKYOUPAGE;
       } 
    }
    else
    {
    $thanks = $cgi->param('PDCPDCThankYouPage') || DEFAULT_THANKYOUPAGE;
    }

    if ($thanks =~ /^Location:/i) {
		$thanks =~ s/\s*$/\n\r\n\r/;
		print $thanks;
    } else {
		READ_FILE:
		{
			if ($thanks =~ /^File:\s*(\S*)/) {
				my $file = join '/', TEMPLATE_ROOT, $1;
				   $file =~ tr{/}{/}s;

				unless (-r $file) {
					warn "Template file '$file' isn't readable\n";
					if ($status eq "TESTING")
					{
					$thanks = $cgi->param('PDCPDCThankYouPage');
					       if ($thanks!~/Live/)
					       {
					       $thanks=$cgi->param('PDCPDCTestingThankYouPage') || TESTING_THANKYOUPAGE;
                                               }
					}
					else
					{
					$thanks = $cgi->param('PDCPDCThankYouPage') || DEFAULT_THANKYOUPAGE;
					}
					last READ_FILE;
				}
			local (*FH);
			
			open(FH, "<$file") or do {
				warn "Couldn't open template file '$file' (!$)\n";
				if ($status eq "TESTING")
				{
				$thanks = $cgi->param('PDCPDCThankYouPage');
				       if ($thanks!~/Live/)
				       {
				       $thanks=$cgi->param('PDCPDCTestingThankYouPage') || TESTING_THANKYOUPAGE;
                                       }
				}
				else
				{
				$thanks = $cgi->param('PDCPDCThankYouPage') || DEFAULT_THANKYOUPAGE;
				}
				last READ_FILE;
			};
			
			$thanks = join("\n", <FH>);
			close(FH);
			}
		}
		my $dbg = @DEBUG ? join("\n",'<UL>',map("<LI>$_", @DEBUG),'</UL>')
				 : '';
		print HTTPHEADER, expand($thanks, %$data, %$stats);
    }
}

#-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# Error()
# Prints a page which displays a nice error message to the user, and
# returns the last error perl encountered in a comment in the page body,
# and then exits

sub Error {
    print HTTPHEADER, <<"EOD";

<HTML>
<HEAD><TITLE>Error</TITLE></HEAD>
<BODY BGCOLOR="#FFFFFF">
<H1>Error:</H1>
An error occurred in processing your request:
<BLOCKQUOTE> @_ </BLOCKQUOTE>
</BODY></HTML>
EOD
    exit(0);
}

#-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# LivestatsError
# (Used when a livestats error occurs which would have reset
#  the livestats file)
# Prints a page which asks a user to click the reload
# button in a few moments (and also includes perl's last error message
sub LivestatsError {
    my $message = shift || "no message";
    print HTTPHEADER, <<"EOD";

<HTML>
<HEAD><TITLE>Thank you, But...</TITLE></HEAD>
<BODY BGCOLOR="#FFFFFF">
<H1>Thank you, But...</H1>
<FONT SIZE=2>$message.</FONT>

<! Perl message: $@ >
<! Programmer Message: $message>
</BODY></HTML>
EOD
    exit(0);
}



#-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# current_time()
# Gets the current date and time, formatting it nicely for insertion
# into the tsv file.

sub current_time {
	my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
	my ($datetime);
	
	$year += 1900;
	if ($mday < 10)	{ $mday = "0$mday"; }
	if ($hour < 10)	{ $hour = "0$hour"; }
	if ($min  < 10)	{ $min  = "0$min";  }
	if ($sec  < 10)	{ $sec  = "0$sec";  }
	
	$datetime = ('Sun','Mon','Tue','Wed','Thu','Fri','Sat')[$wday] . ' ';
	$datetime .= ('Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec')[$mon] . " ";
	$datetime .= $mday . " " . $year . " ";
	$datetime .= $hour . ":" . $min . ":" . $sec;
	
	return $datetime;
}

# replace_illegal_characters($cgi_object)
# Replaces characters in the form fields
# which don't play nicely with other processing
# such as hard returns in the TSV files

sub replace_illegal_characters {
    my $CRLF = "     "; # replace CR/LF combinations with 5 spaces

    my $cgi = shift;

    my $field_name;
    my $field_value;

    # iterate through all of the field values
    foreach $field_name ($cgi->param) {
	$field_value = $cgi->param($field_name);
	# Defect #275 - survsole40 accepts <TAB> in turn causing errors in TSV file 
	$field_value =~ s/[\n\r\f\t]/$CRLF/g;   # replace all \n,\r,\f,\t characters
	$cgi->param($field_name, $field_value); # replace the old form value
    } 

}


sub get_survey_configuration_options
{
	my($html) = @_;

	my $i = 0;
	my $options = $html->param("PDCPDCSurCfg");

	my($option, @opt_name, @opt_value);

	foreach $option (split(/\s*;\s*/, $options))
	{
		($opt_name[$i], $opt_value[$i]) = split(/=/, $option);
		$i++;
	}

	my($livestats);

	for ($i=0; $i<@opt_name; $i++)
	{
		if ($opt_name[$i] eq 'livestats')
		{
			$livestats = $opt_value[$i];
		}
		else
		{
			next;
		}
	}

	return ($livestats);
}


