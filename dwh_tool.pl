#!/bin/perl

use strict;
use warnings;
use Data::Dumper;
use File::Basename;
use Cwd 'abs_path';

$Data::Dumper::Sortkeys = 1;

#****v* getDependencies/globalVariables
# NAME
#   Global variables
# SOURCE
my $verbose = 0;
my $demo    = 0;
my $data;
my $g_scriptDir;

#****

#****f* dwh_tool/parseDdlFile
# NAME
#   parseDdlFile
# DESCRIPTION
#   It parses the given ddl file
# INPUTS
#   ddlFile -- the ddlFile to parse
# SOURCE
sub parseDdlFile
{
    my ( $ddlFile ) = @_;
    my $activeBlock = '';
    my $target      = '';    #target of the block
    my $index       = 0;
    print( "parseDdlFile($ddlFile)\n" );
    open my $DDLFILE, "<$ddlFile" or die "'$ddlFile': $!\n";
    while ( my $line = <$DDLFILE> ) {
        $line =~ s/\R//;     # strip line end
        next unless $line;

        # print "parseDdlFile loop: [$line]\n";

        if ( not( $activeBlock ) ) {    # not in a block
            if ( $line =~ m/^CREATE TABLE ".*"."(.*)"/ ) {
                $activeBlock = "tableCreation";
                $target      = lc( $1 );
                $index       = 0;

                # print "activeBlock: '$target'\n";
            } elsif ( 1 ) {
            }
        } elsif ( $activeBlock =~ "tableCreation" ) {

            #             "ZIELSYSTEM" VARCHAR(30) NOT NULL WITH DEFAULT '  ' ,
            if ( $line =~ m/\s*"(.*)" (.*) ([,)]) / ) {
                my $key   = $1;
                my $value = $2;
                my $comma = $3;

                # parse type
                my $type;
                my $length;

                # VARCHAR(5) WITH DEFAULT '2'
                # CHAR(5) WITH DEFAULT 'DEL'
                if ( $value =~ m/((var)?char)\((\d+)\)/i ) {
                    $type   = lc( $1 );
                    $length = $3;
                } elsif ( $value =~ m/(integer)/i ) {
                    $type   = lc( $1 );
                    $length = 11;
                }

                if ( $value =~ m/( not null )/i ) {
                    $data->{ddl}->{$target}->{names}->{$key}->{notNull} = 1;
                } else {

                    # validIp \d +;
                }

                # INTEGER WITH DEFAULT 22

                $data->{ddl}->{$target}->{names}->{$key}->{notNull} = 0 if not defined $data->{ddl}->{$target}->{names}->{$key}->{notNull};
                $data->{ddl}->{$target}->{indexes}->{$index} = $key;

                # print( " $index: $key\n" );
                $data->{ddl}->{$target}->{names}->{$key}->{type}              = $type;
                $data->{ddl}->{$target}->{names}->{$key}->{length}            = $length;
                $data->{ddl}->{$target}->{names}->{$key}->{otherRestrictions} = ''
                  unless $data->{ddl}->{$target}->{names}->{$key}->{otherRestrictions};
                $data->{ddl}->{$target}->{names}->{$key}->{original} = $line;

                $index++;
                if ( $comma ne ',' ) {
                    $activeBlock = undef;
                    $target      = undef;
                    $index       = undef;
                }

                # print " type: [$type]\n";
                # print " len: [$length]\n";

                # "SCHNITTSTELLEN_ID" CHAR(12) )
            } ### if ( $line =~ m/\s*"(.*)" (.*) ([,)]) /([(]))

        } ### elsif ( $activeBlock =~ "tableCreation")
    } ### while ( my $line = <$DDLFILE>)

    close $DDLFILE;

} ### sub parseDdlFile

#****

#****f* dwh_tool/checkRow
# NAME
#   checkRow
# DESCRIPTION
#   It checks the given row for errors agains ddl (length, "", type, etc) and other given rules (example: validIp) defined in the ini file.
# INPUTS
#   table -- the name of the table validate again
#   row   -- the string to be validated
# SOURCE
sub checkRow
{
    my ( $table, $row ) = @_;
    $table = lc( $table );

    $row //= "";
    print "checkRow($table, <$row>)\n" if $verbose;
    die "Table $table is not defined in the ddl files.\n" if not defined $data->{ddl}->{$table};
    die "Row is empty\n" unless $row;

    my $errCnt = 0;

    my $separator = getSeparator( $table );
    print "Separator: [$separator]\n" if $verbose;
    $row .= "${separator}dummy";
    my @values = split( /$separator/, $row );
    pop @values;

    die "Wrong separator [$separator] - No separator found in [$row" if ( index( $row, $separator ) == -1 );
    if ( scalar( keys %{ $data->{ddl}->{$table}->{indexes} } ) != scalar( @values ) ) {

        # print "ddl info:\n" . Dumper( $data->{ddl}->{$table}->{indexes} );
        # print "splitted row:\n" . Dumper( @values );
        warn "The given row does not have " . scalar( keys %{ $data->{ddl}->{$table}->{indexes} } ) . " vs: " . scalar( @values );
    } ### if ( scalar( keys %{ $data...}))

    for my $index ( 0 .. $#values ) {
        my $value = $values[$index];

        my $keyName = $data->{ddl}->{$table}->{indexes}->{$index};
        die "Index $index not defined for $table.\n" unless $keyName;
        my $key = $data->{ddl}->{$table}->{names}->{$keyName};

        print "\n$table.$keyName='$value'\n" if $verbose;

        # char, varchar must be delimited by "
        if ( $key->{type} eq 'char' or $key->{type} eq 'varchar' ) {
            if ( $value ) {
                if ( $value !~ m/^"/ ) {
                    print "\n$table.$keyName='$value'\n" if not $verbose;
                    print " Error: value [$value] must be surrounded by \"-s\n";
                    $errCnt++;
                }
                if ( $value !~ m/"$/ ) {
                    print "\n$table.$keyName='$value'\n" if not $verbose;
                    print " Error: value [$value] must be surrounded by \"-s\n";
                    $errCnt++;
                }
            } ### if ( $value )
            $value =~ s/^"//;
            $value =~ s/"$//;
        } elsif ( $key->{type} eq 'integer' ) {
            if ( $value =~ m/\D/ ) {
                print "\n$table.$keyName='$value'\n" if not $verbose;
                print " Error: value containt not only digits: [$value]\n";
                $errCnt++;
            }
        } ### elsif ( $key->{type} eq 'integer')

        if ( $key->{length} and $key->{length} < length( $value ) ) {
            print "\n$table.$keyName='$value'\n" if not $verbose;
            print " Error: lenght checkRow problem: it should be maximal $key->{length} long, value ["
              . $value . "] is "
              . length( $value )
              . " long.\n";
            $errCnt++;
        } else {
            print " OK:    lenght checkRow (" . length( $value ) . " <= $key->{length})\n" if $verbose;
        }
        if ( $key->{otherRestrictions} ) {
            if ( $key->{otherRestrictions} =~ m/validIp/i ) {
                if ( $value =~ m/^(\d+)\.(\d+)\.(\d+)\.(\d+)$/ ) {
                    my ( $d1, $d2, $d3, $d4 ) = ( $1, $2, $3, $4 );
                    if ( $d1 == 0 or $d2 == 0 or $d3 == 0 or $d4 == 0 or $d1 > 254 or $d2 > 254 or $d3 > 254 or $d4 > 254 ) {
                        print "\n$table.$keyName='$value'\n" if not $verbose;
                        print " Error: Invalid IP: [$value]\n";
                        $errCnt++;
                    } else {
                        print " OK:    valid ip [$value]\n" if $verbose;
                    }
                } else {
                    print "\n$table.$keyName='$value'\n" if not $verbose;
                    print " Error: Invalid IP: [$value]\n";
                    $errCnt++;
                }
            } ### if ( $key->{otherRestrictions...})
        } ### if ( $key->{otherRestrictions...})

        # $value;
    } ### for my $index ( 0 .. $#values)

    # print Dumper( @values );
    return $errCnt;
} ### sub checkRow

#****

#****f* dwh_tool/checkCSVFile
# NAME
#   checkCSVFile
# DESCRIPTION
#   It reads the given file and calls checkRow for every row. Comment: The table name will be calculated from the name of the file.
# INPUTS
#   input file -- the input (CSV) file to be validated
# SOURCE
sub checkCSVFile
{
    my ( $controlFileName ) = @_;

    my $errCnt=0;

    open my $controlFile, "<$controlFileName" or die "'$controlFileName': $!\n";

    my $table = basename( $controlFileName );
    $table =~ s/d\d+(.*)\.dat/$1/;

    print( "checkCSVFile($controlFileName, $table)\n" );
    open my $errorFile, ">${controlFileName}.error" or die "'${controlFileName}.error': $!\n";

    while ( my $line = <$controlFile> ) {
        $line =~ s/\R//;    # strip line end
                            # my $chr=substr( $line, 16, 1 ); $line=~ s/$chr/¦/g;
        next unless $line;
        print "Line: $.\n" if $verbose;
        my $separator;
        if ( not( $separator ) ) {
            if ( $line =~ m/"(.)"/ ) {
                $separator = $1;
                print "Separator in file $controlFileName: [$separator]\n" if $verbose;
            }
        } ### if ( not( $separator ))

        if ( checkRow( $table, $line ) ) {
            print $errorFile "$line\n";
            $errCnt++;
        }
    } ### while ( my $line = <$controlFile>)
    close $errorFile;
    close $controlFile;
    return $errCnt;
} ### sub checkCSVFile

#****

# DESCRIPTION
#   It reads the given file and calls checkRow for every row. Comment: The table name will be calculated from the name of the file.
# INPUTS
#   input file -- the input (CSV) file to be validated
# RESULT
#   The separator used for the given table
#****f* dwh_tool/getSeparator
# NAME
#   getSeparator
# SOURCE
sub getSeparator
{
    my ( $table ) = @_;
    $table = lc( $table );
    my $retval;
    $retval = $data->{_defaults}->{separator} if defined( $data->{_defaults}->{separator} );
    $retval = $data->{$table}->{separator}    if defined( $data->{$table}->{separator} );
    die "getSeparator($table): aborting\n" unless $retval;

    # print "getSeparator($table): $retval\n";
    return $retval;
} ### sub getSeparator

#****

#****f* dwh_tool/joinArray
# NAME
#   joinArray
# SOURCE
sub joinArray
{

    my $str;

    $str = '"a","b0,b1,b2",3,4';
    my @values = split( /,/, $str );
    print "$str: \n" . Dumper( @values );

    my @valuesOut;
    my $in;
    my $joined;
    my $join = 0;
    for my $index ( 0 .. $#values ) {
        my $value = $values[$index];

        # "a"
        if ( $value =~ m/^"/ and $value =~ m/"$/ ) {
            push( @valuesOut, $value );
            $join = 0;

            # "b0
        } elsif ( not $join and ( $value !~ m/^"/ and $value !~ m/"$/ ) ) {
            push( @valuesOut, $value );
            $join = 0;

        } elsif ( $value =~ m/^"/ and $value !~ m/"$/ ) {
            $join   = 1;
            $joined = "$value,";

            # b1
        } elsif ( $join and ( $value !~ m/^"/ and $value !~ m/"$/ ) ) {
            $joined .= "$value,";

            # b2"
        } elsif ( $join and ( $value !~ m/^"/ and $value =~ m/"$/ ) ) {
            $joined .= "$value";
            push( @valuesOut, $joined );
            $join = 0;
        }
    } ### for my $index ( 0 .. $#values)
    print "$str: \n" . Dumper( @valuesOut );
} ### sub joinArray

#****

#****f* dwh_tool/generateTemplate
# NAME
#   generateTemplate
# DESCRIPTION
#   It generates a template for the given table in readable form.
# INPUTS
#   table   -- the table ;)
#   outFile -- the output file
# SOURCE
sub generateTemplate
{
    my ( $table, $outFileName ) = @_;
    $table = lc( $table );
    die "Table $table is not defined in the ddl files.\n" if not defined $data->{ddl}->{$table};

    open my $outFile, ">$outFileName" or die "'$outFileName': $!\n";

    my $maxLen = 0;
    for my $index ( 0 .. scalar( keys %{ $data->{ddl}->{$table}->{indexes} } ) - 1 ) {

        # print "ind: $index / " . scalar( keys %{ $data->{ddl}->{$table}->{indexes} } ) . "\n";
        my $keyName = $data->{ddl}->{$table}->{indexes}->{$index};
        $maxLen = length( $keyName ) if $maxLen < length( $keyName );
    } ### for my $index ( 0 .. scalar...)

    # print "maxl: $maxLen\n";

    for my $index ( 0 .. scalar( keys %{ $data->{ddl}->{$table}->{indexes} } ) - 1 ) {

        # print "ind: $index / " . scalar( keys %{ $data->{ddl}->{$table}->{indexes} } ) . "\n";
        my $keyName = $data->{ddl}->{$table}->{indexes}->{$index};
        my $key     = $data->{ddl}->{$table}->{names}->{$keyName};
        my $comment = $key->{original};
        $comment =~ s/"$keyName"//;
        $comment =~ s/\s*,\s*$//;
        $comment =~ s/^\s*//;

        print "$keyName: \"\" " . ' ' x ( $maxLen - length( $keyName ) + 4 ) . "# $comment\n";
        print $outFile "$keyName: \"\" " . ' ' x ( $maxLen - length( $keyName ) + 4 ) . "# $comment\n";

        # print "\n# $key->{type}($key->{length}) \n$keyName: \"\"";
    } ### for my $index ( 0 .. scalar...)
    close $outFile;
} ### sub generateTemplate

#****

#****f* dwh_tool/parseInputRecord
# NAME
#   parseInputRecord
# SOURCE
sub parseInputRecord
{
    my ( $table, $inFileName ) = @_;
    $table = lc( $table );

    print "parseInputRecord($table, $inFileName)\n";
    die "Table $table is not defined in the ddl files.\n" if not defined $data->{ddl}->{$table};
    die "File '$inFileName' does not exist, aborting\n"   if ( not -e $inFileName );
    my $values = ();
    open my $inFile, "<$inFileName" or die "'$inFileName': $!\n";
    while ( my $line = <$inFile> ) {
        $line =~ s/\R//;    # strip line end
        next unless $line;

        # print "Line: [$line]\n";

        # ZIELSYSTEM: ""            # VARCHAR(30) NOT NULL WITH DEFAULT '  '
        if ( $line =~ m/^(.*): "(.*)"/ ) {
            my ( $key, $value ) = ( $1, $2 );
            $values->{$key} = $value;
        } else {
            print "Line [$line] skipped\n";
        }
    } ### while ( my $line = <$inFile>)

    my $separator = getSeparator( $table );
    my $row       = "";
    for my $index ( 0 .. scalar( keys %{ $data->{ddl}->{$table}->{indexes} } ) - 1 ) {
        my $keyName = $data->{ddl}->{$table}->{indexes}->{$index};
        my $key     = $data->{ddl}->{$table}->{names}->{$keyName};
        if ( not defined( $values->{$keyName} ) ) {
            die "Missing value: $keyName\n";
        }
        my $value = $values->{$keyName};
        if ( $key->{type} eq 'char' or $key->{type} eq 'varchar' ) {
            $row .= "\"$value\"$separator";
        } else {
            $row .= "$value$separator";
        }
    } ### for my $index ( 0 .. scalar...)
    $row =~ s/$separator$//;
    close $inFile;

    print " parseInputRecord OK\n";

    # check is NOT made
    # if ( not checkRow( $table, $row ) ) {
    #     print "[$row]\n";
    # } else {
    #     $row = undef;
    # }

    return $row;

} ### sub parseInputRecord

#****

#****f* dwh_tool/parseAndSaveRecord
# NAME
#   parseAndSaveRecord
# SOURCE
sub parseAndSaveRecord
{
    my ( $table, $inFileName, $outFileName ) = @_;
    my $row = parseInputRecord( $table, $inFileName );
    return unless ( $row );
    open my $outFile, ">$outFileName" or die "'$outFileName': $!\n";
    print $outFile "$row\n";
    close $outFile;

} ### sub parseAndSaveRecord

#****

#****f* dwh_tool/iniLoad
# NAME
#   iniLoad
# SOURCE
sub iniLoad
{
    my ( $inFileName ) = @_;
    die "File '$inFileName' does not exist, aborting\n" if ( not -e $inFileName );
    print "iniLoad($inFileName)\n";
    open my $inFile, "<$inFileName" or die "'$inFileName': $!\n";
    while ( my $line = <$inFile> ) {
        $line =~ s/\R//;    # strip line end
        next unless $line;
        if ( $line =~ m/^table\.(.*)\.separator[:=]\s*"(.*)"/i ) {
            my ( $table, $separator ) = ( lc( $1 ), $2 );
            $data->{$table}->{separator} = $separator;
        } elsif ( $line =~ m/^default.separator[:=]\s*"(.*)"/i ) {
            my ( $separator ) = ( $1 );
            $data->{_defaults}->{separator} = $separator;

            # table.a_export_strg.field.ZIELADRESSE.restriction: "validIp"
        } elsif ( $line =~ m/^table\.(.*)\.field\.(.*)\.restriction[:=]\s*"(.*)"/i ) {
            my ( $table, $field, $value ) = ( lc( $1 ), $2, $3 );
            $data->{ddl}->{$table}->{names}->{$field}->{otherRestrictions} = $value;
        }

    } ### while ( my $line = <$inFile>)
        # print Dumper($data);
    close $inFile;
} ### sub iniLoad

#****

#****f* dwh_tool/demo
# NAME
#   demo
# SOURCE
sub demo
{
    parseDdlFile( "input/a_export_strg.ddl" );

    my $row = parseInputRecord( "a_export_strg", "input/demo_input_a_export_strg.dat" );
    if ( checkRow( "a_export_strg", $row ) ) {
        warn "There might be a problem in the row, please check it.\n";
    } else {
        print "Row seems to be valid.\n";
    }
    print "\n";

    parseDdlFile( "input/a_batch_input.ddl" );
    checkCSVFile( 'input/d063a_batch_input.dat' );

    parseDdlFile( "input/a_batch_input.ddl" );
    checkCSVFile( 'input/d063a_batch_input.dat' );

    #****

} ### sub demo

#****

#****f* dwh_tool/usage
# NAME
#   usage
# SOURCE
sub usage
{
    print "dwh_tool.pl -f[unction] FUNCTION [-f[unction] FUNCTION...] -v[erbose] -h[elp]
  FUNCTION: 
    - checkCSVFile(INPUTFILE)
    - demo
    - generateTemplate(TABLENAME,INPUTFILE)
    - parseDdlFile(INPUTFILE)
    - parseInputRecord(TABLENAME,INPUTFILE)
    - parseAndSaveRecord(TABLENAME,INPUTFILE,OUTPUTFILE)

    ./dwh_tool.pl -f demo
    ./dwh_tool.pl -f parseDdlFile\\(input/a_batch_input.ddl\\)
    ./dwh_tool.pl -f parseDdlFile\\(input/a_batch_input.ddl\\) -f checkCSVFile\\(input/d063a_batch_input.dat\\)
    ./dwh_tool.pl -f parseDdlFile\\(input/a_export_strg.ddl\\) -f generateTemplate\\(a_export_strg,demo_input_a_export_strg.dat\\)
    ./dwh_tool.pl -f parseDdlFile\\(input/a_export_strg.ddl\\) -f parseInputRecord\\(a_export_strg,demo_input_a_export_strg.dat\\)


";
    exit 0;
} ### sub usage

#****

#****f* dwh_tool/ini
# NAME
#   ini
# SOURCE
sub ini
{
    $g_scriptDir = abs_path( dirname( __FILE__ ) );
    iniLoad( "$g_scriptDir/dwh_tool.ini" );
    use Getopt::Long;
    my $help;
    my @functions;
    GetOptions(
        "function|f=s{1,}" => \@functions,
        "verbose|v"        => \$verbose,     # flag
        "help|h"           => \$help         # flag
    );

    usage() if ( $help );
    demo()  if ( $demo );

    if ( scalar( @functions ) == 0 ) {
        warn "You have to define at least one function.\n";
        usage();
    }

    foreach my $function ( @functions ) {
        if ( $function eq 'demo' ) {
            demo();
        } elsif ( $function =~ m/parseDdlFile\((.*)\)/i ) {
            parseDdlFile( $1 );
        } elsif ( $function =~ m/checkCSVFile\((.*)\)/i ) {
            checkCSVFile( $1 );
        } elsif ( $function =~ m/generateTemplate\((.*),(.*)\)/i ) {
            generateTemplate( $1, $2 );
        } elsif ( $function =~ m/parseInputRecord\((.*),(.*)\)/i ) {
            parseInputRecord( $1, $2 );
        } elsif ( $function =~ m/parseAndSaveRecord\((.*),(.*),(.*)\)/i ) {
            parseAndSaveRecord( $1, $2, $3 );
        } else {
            warn "Warning: Unknown function call: $function\n";
            usage;
        }
    } ### foreach my $function ( @functions)

} ### sub ini

#****

#****f* dwh_tool/main
# NAME
#   main
# SOURCE
sub main
{
    ini();

}

#****

$demo = 1;
main();
