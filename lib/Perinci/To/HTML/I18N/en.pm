package Perinci::To::HTML::I18N::en;
use parent qw(Perinci::To::HTML::I18N Perinci::To::PackageBase::I18N::en);

use Locale::Maketext::Lexicon::Gettext;
our %Lexicon = %{ Locale::Maketext::Lexicon::Gettext->parse(<DATA>) };

# VERSION

#use Data::Dump; dd \%Lexicon;

1;
# ABSTRACT: English translation for Perinci::To::HTML
__DATA__

msgid  "Parameters"
msgstr "Parameters"

