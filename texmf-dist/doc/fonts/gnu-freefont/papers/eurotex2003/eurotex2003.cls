\NeedsTeXFormat{LaTeX2e}[1994/12/01]
\ProvidesClass  {eurotex2003}
                   [2003/03/06 v1.0
                       EuroTeX 2003 proceedings class%
                   ]
\LoadClass[harvardcite]{ltugproc}
\newif\if@yhproc@fr
\@yhproc@frfalse
\DeclareOption{english}{\@yhproc@frfalse}
\DeclareOption{francais}{\@yhproc@frtrue}
\ExecuteOptions{tug\tugProcYear,nonumber,title}
\ProcessOptions

\usepackage[latin1]{inputenc}
\usepackage[T1]{fontenc}
\if@yhproc@fr\usepackage[english,francais]{babel}\else\usepackage[francais,english]{babel}\fi
\def\@maketitle{%
   {\parskip\z@
    \TITLEfont\raggedright\noindent\@title\par
      \count@=0
      \loop
      \ifnum\count@<\authornumber
        \vskip20\p@
        \advance\count@\@ne
        {\AUTHORfont\theauthor{\number\count@}\endgraf}%
        \addressfont\theaddress{\number\count@}\endgraf
        {%
          \allowhyphens
          \hangindent1.5pc
          \netaddrfont\thenetaddress{\number\count@}\endgraf
          \hangindent1.5pc
          \thePersonalURL{\number\count@}\endgraf
        }%
      \repeat
   \vskip20\p@}%
   \if@abstract
      \centerline{\bfseries Abstract}%
      \vskip.5\baselineskip\rmfamily
      \list{}{\listparindent20\p@
         \itemindent\z@ \leftmargin4.875pc
         \rightmargin\leftmargin \parsep \z@}\item[]\ignorespaces
            \selectlanguage{english}\the\abstract@toks
      \endlist\global\@ignoretrue
   \fi
   \vskip1pc
   \if@resume
      \centerline{\bfseries R\'esum\'e}%
      \vskip.5\baselineskip\rmfamily
      \list{}{%
         %\listparindent20\p@
         %\itemindent-\parindent
         \leftmargin0pt 
         %\leftmargin4.875pc
         %\rightmargin\leftmargin 
         %\parsep \z@
         }\item[]\ignorespaces
            \selectlanguage{francais}\the\resume@toks
      \endlist\global\@ignoretrue
   \fi
   \vskip1pc
   \global\@afterindentfalse\aftergroup\@afterheading
  }
\abstract@toks{Please include an abstract.}
\def\abstract{\abstract@toks{}%
  \ifTB@madetitle
    \TBWarning{abstract environment after \string\maketitle}
  \fi
  \def\@abstract@{abstract}%
  \ifx\@currenvir\@abstract@
  \else
    \TBError{\string\abstract\space is illegal:%
      \MessageBreak
      use \string\begin{\@abstract@} instead}%
      {\@abstract@\space may only be used as an environment}
  \fi
  \global\let\if@abstract\iftrue
  {\ifnum0=`}\fi
  \@abstract@getbody}\newtoks\resume@toks  \resume@toks{Veuillez inclure un r\'esum\'e.}
\let\if@resume\iffalse
\def\resume{\resume@toks{}%
  \ifTB@madetitle
    \TBWarning{resume environment after \string\maketitle}
  \fi
  \def\@resume@{resume}%
  \ifx\@currenvir\@resume@
  \else
    \TBError{\string\resume\space is illegal:%
      \MessageBreak
      use \string\begin{\@resume@} instead}%
      {\@resume@\space may only be used as an environment}
  \fi
  \global\let\if@resume\iftrue
  {\ifnum0=`}\fi
  \@resume@getbody}
\let\endresume\relax
\long\def\@resume@getbody#1\end{%
  \global\resume@toks\expandafter{\the\resume@toks#1}%
  \@resume@findend}
\def\@resume@findend#1{%
  \def\@tempa{#1}%
  \ifx\@tempa\@resume@
    \expandafter\@resume@end
  \else
    \def\@tempb{document}%
    \ifx\@tempa\@tempb
      \TBError{\string\begin{\@resume@}
          ended by \string\end{\@tempb}}%
        {You've forgotten \string\end{\@resume@}}
    \else
       \global\resume@toks\expandafter{\the\resume@toks\end{#1}}%
       \expandafter\expandafter\expandafter\@resume@getbody
    \fi
  \fi}
\def\@resume@end{\ifnum0=`{\fi}%
  \expandafter\end\expandafter{\@resume@}}
\def\pfoottext{{\smc Preprint}: Proceedings of Euro\TeX\ 2003}
\def\rfoottext{\normalfont\TUB, \volx\Dash
   {Proceedings of Euro\TeX\ 2003}}
\if@yhproc@fr\AtBeginDocument{\selectlanguage{francais}}\else\AtBeginDocument{\selectlanguage{english}}\fi
\endinput
