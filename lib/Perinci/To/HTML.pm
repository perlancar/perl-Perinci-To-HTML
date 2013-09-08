package Perinci::To::HTML;

use 5.010001;
use Log::Any '$log';
use Moo;

extends 'Perinci::To::PackageBase';

# VERSION

has heading_level => (is => 'rw', default=>sub{1});

sub BUILD {
    my ($self, $args) = @_;
}

sub _md2html {
    require Text::Markdown;

    my ($self, $md) = @_;
    state $m2h = Text::Markdown->new;
    $m2h->markdown($md);
}

sub h {
    my ($self, $level, $text) = @_;
    $level += $self->heading_level;

    "<h$level>$text</h$level>";
}

sub span {
    my ($self, $class, $text) = @_;
    qq[<span class="$class">$text</span>];
}

sub start_div {
    my ($self, $class) = @_;
    $self->add_doc_lines(qq[<div class="$class">]);
    $self->inc_indent;
}

sub end_div {
    my ($self, $class) = @_;
    $self->dec_indent;
    $self->add_doc_lines(qq[</div><!-- $class -->]);
}

sub before_generate_doc {
    my ($self) = @_;
    $self->SUPER::before_generate_doc;
    $self->start_div("doc");
}

sub after_generate_doc {
    my ($self) = @_;
    $self->end_div("doc");
    $self->SUPER::after_generate_doc;
}

sub doc_gen_summary {
    my ($self) = @_;

    $self->start_div("name");
    $self->add_doc_lines(
        $self->h(0, uc($self->loc("Name"))),
        $self->doc_parse->{name},
    );
    $self->end_div("name");
    $self->add_doc_lines("");

    return unless $self->doc_parse->{summary};

    $self->start_div("summary");
    $self->add_doc_lines(
        $self->h(0, uc($self->loc("Summary"))),
        $self->doc_parse->{summary},
    );
    $self->add_doc_lines("");
}

sub doc_gen_version {
    my ($self) = @_;

    $self->start_div("version");
    $self->add_doc_lines(
        $self->{_meta}{entity_v},
    );
    $self->end_div("version");
    $self->add_doc_lines("");
}

sub doc_gen_description {
    my ($self) = @_;

    return unless $self->doc_parse->{description};

    $self->start_div("description");
    $self->add_doc_lines(
        $self->h(0, uc($self->loc("Description"))),
        $self->_m2h($self->doc_parse->{description}),
    );
    $self->start_div("description");
    $self->add_doc_lines("");
}

sub _fdoc_gen {
    my ($self, $url) = @_;
    my $p = $self->doc_parse->{functions}{$url};

    my $has_args = !!keys(%{$p->{args}});

    $self->start_div("fdoc");

    $self->start_div("name");
    $self->add_doc_lines(
        $self->h(1, $self->loc("Name")),
        $p->{name},
    );
    $self->end_div("name");

    if ($p->{summary}) {
        $self->start_div("summary");
        $self->add_doc_lines(
            $self->h(1, $self->loc("Summary")),
            $p->{summary} . ($p->{summary} =~ /\.$/ ? "":"."),
        );
        $self->end_div("summary");
    }

    if ($p->{description}) {
        $self->start_div("description");
        $self->add_doc_lines(
            $self->h(1, $self->loc("Description")),
            $p->{description},
        );
        $self->end_div("description");
    }

    $self->start_div("parameters");
    $self->add_doc_lines(
        $self->h(1, $self->loc("Parameters")),
        "<ul>",
    );
    for my $name (sort keys %{$p->{args}}) {
        my $pa = $p->{args}{$name};
        my $req = $pa->{schema}[1]{req};

        $self->add_doc_lines(join(
            "",
            qq[<li><span class="name${\($req ? ' req' : '')}">$name</span> ],
            $pa->{human_arg},
            (defined($pa->{human_arg_default}) ?
                 " (" . $self->loc("default") .
                     ": $pa->{human_arg_default})" : "")
        ), "");
        if ($pa->{summary}) {
            $self->start_div("summary");
            $self->add_doc_lines(
                $pa->{summary} . ($p->{summary} =~ /\.$/ ? "" : "."),
                "") if $pa->{summary};
            $self->end_div("summary");
        }
        if ($pa->{description}) {
            $self->start_div("description");
            $self->add_doc_lines(
                $self->_m2h($pa->{description})
            );
            $self->end_div("description");
        }
    }
    $self->add_doc_lines("</ul>");
    $self->end_div("parameters");

    # XXX result summary

    # XXX result description

    $self->end_div("fdoc");
    $self->add_doc_lines("");
}

sub doc_gen_functions {
    my ($self) = @_;
    my $pff = $self->doc_parse->{functions};

    $self->start_div("functions");

    # XXX categorize functions based on tags
    for my $url (sort keys %$pff) {
        my $p = $pff->{$url};
        $self->_fdoc_gen($url);
    }

    $self->end_div("functions");
}

1;
# ABSTRACT: Generate HTML documentation from Rinci package metadata

=head1 DESCRIPTION

This documentation is geared more into documenting HTTP API. If you want
something more Perl-oriented, try L<Perinci::To::POD> (and convert the resulting
POD to HTML).

=cut
