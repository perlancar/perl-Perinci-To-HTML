package Perinci::To::HTML::I18N::id;
use parent qw(Perinci::To::HTML::I18N Perinci::To::PackageBase::I18N::id);

use Locale::Maketext::Lexicon::Gettext;
our %Lexicon = %{ Locale::Maketext::Lexicon::Gettext->parse(<DATA>) };

# VERSION

#use Data::Dump; dd \%Lexicon;

1;
# ABSTRACT: Indonesian translation for Perinci::To::HTML
__DATA__

msgid  "Parameters"
msgstr "Parameter"

