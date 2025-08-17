#!/usr/bin/perl
use strict;
use warnings;
use File::Basename;
use File::Temp qw(tempdir);
use IPC::Run3;

sub main {
    if (@ARGV != 2) {
        print "Usage: office2pdf <INPUT_PATH> <OUTPUT_PATH>\n";
        exit 1;
    }

    my ($path, $output_path) = @ARGV;
    
    my ($name, $dir, $suffix) = fileparse($path, qr/\.[^.]*/);
    my $extension = lc($suffix);
    $extension =~ s/^\.//;  # Remove leading dot
    
    unless ($extension =~ /^(ppt|pptx|doc|docx|xls|xlsx)$/) {
        print "Unsupported file type: $extension\n";
        exit 1;
    }
    
    convert_office_to_pdf($path, $output_path);
}

sub convert_office_to_pdf {
    my ($office_file_path, $desired_output_path) = @_;
    
    my $temp_output_dir = dirname($office_file_path);
    
    # Create a temporary user directory for LibreOffice
    my $temp_user_dir = tempdir(CLEANUP => 1);
    
    # Set up environment
    local %ENV = %ENV;
    $ENV{HOME} = $temp_user_dir;
    $ENV{TMPDIR} = $temp_user_dir;
    $ENV{LANG} = 'ja_JP.UTF-8';
    $ENV{LC_ALL} = 'ja_JP.UTF-8';
    $ENV{JAVA_TOOL_OPTIONS} = '-Djava.awt.headless=true';
    
    my @cmd = (
        'libreoffice',
        '--headless',
        '--invisible',
        '--nodefault',
        '--nolockcheck',
        '--nologo',
        '--norestore',
        '--convert-to', 'pdf',
        '--outdir', $temp_output_dir,
        "-env:UserInstallation=file://$temp_user_dir/.config/libreoffice",
        $office_file_path,
    );
    
    my ($stdout, $stderr);
    eval {
        local $SIG{ALRM} = sub { die "timeout\n" };
        alarm 60;  # 60 second timeout
        
        run3(\@cmd, \undef, \$stdout, \$stderr);
        my $exit_code = $? >> 8;
        
        alarm 0;
        
        print $stdout if $stdout;
        print STDERR $stderr if $stderr;
        
        if ($exit_code == 0) {
            my $base_name = basename($office_file_path);
            $base_name =~ s/\.[^.]*$//;  # Remove extension
            my $temp_pdf_path = "$temp_output_dir/$base_name.pdf";
            
            unless (-f $temp_pdf_path) {
                print "Error: PDF file not created at $temp_pdf_path\n";
                return;
            }
            
            # Move the PDF to the desired output location
            rename($temp_pdf_path, $desired_output_path) or do {
                print "Error: Could not move PDF to $desired_output_path: $!\n";
                return;
            };
            
            return $desired_output_path;
        } else {
            print "LibreOffice conversion failed: $stderr\n" if $stderr;
            return;
        }
    };
    
    if ($@) {
        if ($@ =~ /timeout/) {
            print "Error: Conversion timed out after 60 seconds\n";
        } elsif ($@ =~ /failed to start/) {
            print "Error: LibreOffice not found. Please install LibreOffice.\n";
        } else {
            print "Error during conversion: $@\n";
        }
        return;
    }
}

main();