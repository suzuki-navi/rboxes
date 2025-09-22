#!/usr/bin/perl

use strict;
use warnings;

# Maximum number of files to update in one run
my $MAX_UPDATES1 = 8;
my $MAX_UPDATES2 = 2;

sub main {

    my $target_dir_path = parse_options();

    if (!-d $target_dir_path) {
        die "Error: The specified path '$target_dir_path' is not a directory.\n";
    }

    # Update backlinks in the target directory
    update_backlinks($target_dir_path);

}


# Parse command line options
# Parameters: None
# Returns: None
sub parse_options {
    my $target_dir_path;

    while (my $arg = shift @ARGV) {
        if ($arg eq '-d') {
            $target_dir_path = shift @ARGV;
            if (!defined $target_dir_path) {
                die "Error: -d option requires a directory path\n";
            }
        } elsif ($arg eq '--help') {
            usage();
            exit 0;
        } else {
            die "Error: Unknown option '$arg'\n";
        }
    }

    if (!defined $target_dir_path) {
        die "Error: Missing -d option\n";
    }

    return $target_dir_path;
}


sub usage {
    my $script_dir = $0;
    $script_dir =~ s/[^\/]*$//;  # Remove script name, keep directory
    my $help_path = "${script_dir}help.txt";

    open my $fh, '<', $help_path or die "Cannot open help.txt: $!";
    while (my $line = <$fh>) {
        print $line;
    }
    close $fh;
}


sub update_backlinks {
    my ($dir_path) = @_;

    print "Updating backlinks in directory: $dir_path\n";
    opendir(my $dh, $dir_path) or die "Cannot open directory '$dir_path': $!";
    my @md_files = readdir($dh);
    closedir($dh);
    for my $file (@md_files) {
        print "Found file: $file\n";
    }

    @md_files = grep { /\.md$/ } @md_files;

    @md_files = map { "$dir_path/$_" } @md_files;
    my @md_files2 = ();
    my $now = time();
    for my $file (@md_files) {
        my $timestamp = (stat($file))[9];
        #if ($timestamp > $now - 60 * 60 * 24) {  # Check if modified in the last 24 hours
            push @md_files2, {
                path => $file,
                timestamp => $timestamp,
            };
        #}
    }
    @md_files2 = sort { $b->{timestamp} <=> $a->{timestamp} } @md_files2;  # Sort by timestamp, newest first
    @md_files2 = map { $_->{path} } @md_files2;  # Extract file paths

    # @md_files にはタイムスタンプの新しい順に .md ファイルのパスが入っている

    my $updated_count = 0;
    my %processed_files = ();  # Track processed files
    for my $file (@md_files2) {
        $updated_count += process_markdown_file($file);
        $processed_files{$file} = 1;  # Mark as processed
        if ($updated_count >= $MAX_UPDATES1) {
            last;  # Stop processing after updating $MAX_UPDATES1 files
        }
    }
    @md_files2 = reverse @md_files2;
    $updated_count = 0;
    for my $file (@md_files2) {
        next if $processed_files{$file};  # Skip already processed files
        $updated_count += process_markdown_file($file);
        if ($updated_count >= $MAX_UPDATES2) {
            last;  # Stop processing after updating $MAX_UPDATES2 files
        }
    }
}


sub process_markdown_file {
    my ($file_path) = @_;

    my ($dir_path) = $file_path =~ m{^(.*)/[^/]+$};
    my ($url) = $file_path =~ m{([^/]+)$};

    print "Processing file: $file_path\n";

    my $updated_count = 0;

    my $file_data = parse_markdown_file($file_path);
    my $file_body = $file_data->{body};
    my $links_from_body = $file_data->{links_from_body};
    my $links_from_backlinks = $file_data->{links_from_backlinks};

    for my $link (@$links_from_body) {
        my $link_text = $link->{text};
        my $link_url = $link->{url};

        my $link_dst_path = "$dir_path/$link_url";
        if (-f $link_dst_path) {
            my $f = add_backlink_if_not_exists($file_path, $link_dst_path);
            if ($f) {
                $updated_count++;
            }
        }
    }

    my $links_from_backlinks2 = [];
    my $links_from_backlinks_changed = 0;
    for my $link (@$links_from_backlinks) {
        my $link_text = $link->{text};
        my $link_url = $link->{url};

        # Check if the link also exists in links_from_body
        my $link_exists_in_body = 0;
        for my $body_link (@$links_from_body) {
            if ($body_link->{url} eq $link_url) {
                $link_exists_in_body = 1;
                last;
            }
        }
        if ($link_exists_in_body) {
            $links_from_backlinks_changed = 1;
            next;  # Skip this link, as it already exists in the body
        }

        my $link_dst_path = "$dir_path/$link_url";
        if (!-f $link_dst_path) {
            $links_from_backlinks_changed = 1;
            next;
        }

        my $link_dst_file_data = parse_markdown_file($link_dst_path);
        my $link_exists_from_dst = 0;
        for my $dst_link (@{$link_dst_file_data->{links_from_body}}) {
            if ($dst_link->{url} eq $url) {
                $link_exists_from_dst = 1;
                last;
            }
        }
        if (!$link_exists_from_dst) {
            $links_from_backlinks_changed = 1;
            next;
        }

        push @$links_from_backlinks2, $link;
    }

    if ($links_from_backlinks_changed) {
        $links_from_backlinks = $links_from_backlinks2;
        write_markdown_file($file_path, $file_body, $links_from_backlinks);
        print "update: $file_path\n";
        $updated_count++;
    }

    return $updated_count;
}


sub add_backlink_if_not_exists {
    my ($link_src_path, $link_dst_path) = @_;

    my ($link_src_file_name) = $link_src_path =~ m{([^/]+)$};

    my $file_data = parse_markdown_file($link_dst_path);

    for my $link (@{$file_data->{links_from_body}}) {
        if ($link->{url} eq $link_src_file_name) {
            return 0;  # Backlink already exists, no need to add
        }
    }
    for my $link (@{$file_data->{links_from_backlinks}}) {
        if ($link->{url} eq $link_src_file_name) {
            return 0;  # Backlink already exists, no need to add
        }
    }

    # Backlink does not exist, add it
    my ($text) = $link_src_path =~ m{([^/]+)\.md$};
    my ($url) = $link_src_path =~ m{([^/]+)$};
    my $link = { text => $text, url => $url };
    push @{$file_data->{links_from_backlinks}}, $link;

    write_markdown_file($link_dst_path, $file_data->{body}, $file_data->{links_from_backlinks});

    print "update: $link_dst_path\n";

    return 1;
}



sub parse_markdown_file {
    my ($file_path) = @_;

    my $file_content = do {
        local $/;  # Enable slurp mode
        open my $fh, '<', $file_path or die "Cannot open file '$file_path': $!";
        <$fh>;
    };

    my $file_lines = content_to_lines($file_content);

    my $file_body = [];
    my $backlinks_body = undef;

    my $code_block_fence = undef;
    for my $line (@$file_lines) {
        if ($code_block_fence) {
            if ($line eq $code_block_fence) {
                $code_block_fence = undef;  # End of code block
            }
            push @$file_body, $line;
            next;  # Skip lines inside code blocks
        }
        if ($line =~ /^```/) {
            $code_block_fence = ($line =~ /^(`+)/)[0];
            push @$file_body, $line;
            next;  # Skip lines inside code blocks
        }

        if ($backlinks_body) {
            push @$backlinks_body, $line;
            next;
        }

        if ($line eq "%backlinks") {
            # Remove existing backlinks section
            $backlinks_body = [];
            next;
        }

        push @$file_body, $line;
    }
    if (!$backlinks_body) {
        $backlinks_body = [];
    }

    # $file_body からMarkdownリンクを抽出
    my @links_from_body;
    $code_block_fence = undef;
    for my $line (@$file_body) {
        if ($code_block_fence) {
            if ($line eq $code_block_fence) {
                $code_block_fence = undef;  # End of code block
            }
            next;  # Skip lines inside code blocks
        }
        if ($line =~ /^```/) {
            $code_block_fence = ($line =~ /^(`+)/)[0];
            next;  # Skip lines inside code blocks
        }

        while ($line =~ /\[([^\]]+)\]\(([^)]+)\)/g) {
            push @links_from_body, { text => $1, url => $2 };
        }
        while ($line =~ /\[\[([^\]]+)\]\]/g) {
            push @links_from_body, { text => $1, url => "$1.md" };
        }
    }
    my @links_from_backlinks;
    for my $line (@$backlinks_body) {
        while ($line =~ /\[([^\]]+)\]\(([^)]+)\)/g) {
            push @links_from_backlinks, { text => $1, url => $2 };
        }
        while ($line =~ /\[\[([^\]]+)\]\]/g) {
            push @links_from_backlinks, { text => $1, url => "$1.md" };
        }
    }

    return {
        body => $file_body,
        links_from_body => \@links_from_body,
        links_from_backlinks => \@links_from_backlinks,
    };
}


sub write_markdown_file {
    my ($file_path, $file_body, $links_from_backlinks) = @_;

    open my $fh, '>', $file_path or die "Cannot open file '$file_path': $!";
    
    for my $line (@$file_body) {
        print $fh "$line\n";
    }
    

    if (@$links_from_backlinks) {
        my $last_line_is_blank = (@$file_body && $file_body->[-1] =~ /^\s*$/) ? 1 : 0;
        if (!$last_line_is_blank) {
            print $fh "\n";  # Ensure a blank line before backlinks section
        }
        print $fh "%backlinks\n";
        for my $link (@$links_from_backlinks) {
            if ($link->{url} eq "$link->{text}.md") {
                print $fh "- [[$link->{text}]]\n";
            } else {
                print $fh "- [$link->{text}]($link->{url})\n";
            }
        }
    }

    close $fh;
}


sub content_to_lines {
    my ($content) = @_;
    
    my @lines = split /\n/, $content;
    pop @lines if @lines && $lines[-1] eq '';
    return \@lines;
}


# Main execution
main();
